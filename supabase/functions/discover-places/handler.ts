import { applyJevAnswers, buildJevRequest, type Place } from './jev.ts';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
const fieldMask = [
  'places.id', 'places.displayName', 'places.formattedAddress', 'places.primaryType',
  'places.types', 'places.businessStatus', 'places.priceLevel', 'places.rating',
  'places.userRatingCount', 'places.currentOpeningHours.openNow', 'places.outdoorSeating',
  'places.goodForGroups', 'places.servesVegetarianFood', 'places.reservable', 'places.googleMapsUri',
].join(',');
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status, headers: { ...cors, 'Content-Type': 'application/json' },
});
const numberOrNull = (v: unknown) => typeof v === 'number' && Number.isFinite(v) ? v : null;

export function normalizePlace(raw: Record<string, any>): Place {
  return {
    googlePlaceId: String(raw.id ?? ''), name: raw.displayName?.text ?? 'Unnamed place',
    address: raw.formattedAddress ?? 'Address unavailable', primaryType: raw.primaryType ?? null,
    types: Array.isArray(raw.types) ? raw.types.filter((t: unknown) => typeof t === 'string') : [],
    priceLevel: raw.priceLevel ?? null, rating: numberOrNull(raw.rating),
    ratingCount: numberOrNull(raw.userRatingCount), openNow: raw.currentOpeningHours?.openNow ?? null,
    googleMapsUri: raw.googleMapsUri ?? null,
    signals: { outdoorSeating: raw.outdoorSeating ?? null, goodForGroups: raw.goodForGroups ?? null,
      servesVegetarianFood: raw.servesVegetarianFood ?? null, reservable: raw.reservable ?? null },
  };
}

export function createHandler(env: (name: string) => string | undefined, fetcher: typeof fetch = fetch) {
  return async (request: Request): Promise<Response> => {
    if (request.method === 'OPTIONS') return new Response('ok', { headers: cors });
    if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
    const authorization = request.headers.get('Authorization');
    if (!authorization?.startsWith('Bearer ')) return json({ error: 'Please sign in again.', code: 'auth_required' }, 401);
    const url = env('SUPABASE_URL');
    const adminKey = env('SUPABASE_SERVICE_ROLE_KEY');
    const apiKey = env('GOOGLE_PLACES_API_KEY');
    if (!url || !adminKey || !apiKey) return json({ error: 'Live search setup is incomplete.', code: 'setup_required' }, 503);
    let input: Record<string, unknown>;
    try {
      input = await request.json();
      if (!input || typeof input !== 'object' || Array.isArray(input)) throw new Error();
    } catch { return json({ error: 'Invalid search request.' }, 400); }
    const query = typeof input.query === 'string' ? input.query.trim() : '';
    if (query.length < 2 || query.length > 160) return json({ error: 'Enter a search between 2 and 160 characters.' }, 400);
    if (input.pageToken) return json({ error: 'Each search is limited to 10 places. Pagination is disabled.' }, 400);
    const type = typeof input.placeType === 'string' ? input.placeType : null;
    if (type && !['restaurant', 'cafe', 'park', 'museum'].includes(type)) return json({ error: 'Unsupported category.' }, 400);
    try {
      const authResponse = await fetcher(`${url}/auth/v1/user`, {
        headers: { apikey: adminKey, Authorization: authorization }, signal: AbortSignal.timeout(10000),
      });
      if (!authResponse.ok) return json({ error: 'Please sign in again.', code: 'auth_required' }, 401);
      const user = await authResponse.json();
      if (!user.id) return json({ error: 'Please sign in again.', code: 'auth_required' }, 401);
      const saved = user.user_metadata?.preferences ?? {};
      const prefs: Record<string, unknown> = {};
      for (const key of ['mood', 'plan_type', 'venue_type', 'budget', 'duration']) {
        if (typeof saved[key] === 'string') prefs[key] = saved[key].slice(0, 40);
      }
      for (const key of ['cuisines', 'dietary_needs']) {
        prefs[key] = Array.isArray(saved[key]) ? saved[key].filter((v: unknown) => typeof v === 'string').slice(0, 10).map((v: string) => v.slice(0, 40)) : [];
      }
      prefs.group_size = Number.isInteger(saved.group_size) ? Math.max(1, Math.min(10, saved.group_size)) : 1;
      const reserve = async (provider: string) => {
        const response = await fetcher(`${url}/rest/v1/rpc/reserve_discovery_request`, {
          method: 'POST', headers: { apikey: adminKey, Authorization: `Bearer ${adminKey}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({ p_provider: provider }), signal: AbortSignal.timeout(10000),
        });
        if (!response.ok) throw new Error('Budget unavailable');
        const budget = await response.json();
        if (!budget || typeof budget.allowed !== 'boolean' || !Number.isInteger(budget.remaining) ||
            budget.remaining < 0 || !Number.isInteger(budget.limit) || budget.limit > 900 || budget.limit < 0) throw new Error('Invalid budget');
        return budget;
      };
      // Reserve BEFORE sending: concurrent requests cannot overshoot. Even failed
      // upstream attempts consume the reservation; never retry automatically.
      const budget = await reserve('google_places');
      if (!budget.allowed) return json({ error: budget.limit === 0
        ? 'Search is paused until the remaining free allowance is confirmed.'
        : 'Monthly search limit reached. No paid search was sent.', code: 'quota_exhausted', quota: budget }, 429);
      const labels: Record<string, string> = { restaurant: 'restoranlar', cafe: 'kafeler', park: 'parklar', museum: 'müzeler' };
      const intent = prefs.plan_type === 'Food' ? 'restoranlar ve kafeler' : 'gezilecek mekanlar';
      const body = { textQuery: type ? `${labels[type]} ${query}` : `${intent} ${query}`,
        pageSize: 10, languageCode: 'tr', regionCode: 'TR',
        ...(type ? { includedType: type, strictTypeFiltering: true } : {}),
        ...(input.openNow === true ? { openNow: true } : {}),
      };
      const googleResponse = await fetcher('https://places.googleapis.com/v1/places:searchText', {
        method: 'POST', headers: { 'Content-Type': 'application/json', 'X-Goog-Api-Key': apiKey, 'X-Goog-FieldMask': fieldMask },
        body: JSON.stringify(body), signal: AbortSignal.timeout(15000),
      });
      if (!googleResponse.ok) return json({ error: 'Google Places could not complete this search. Check API setup and try again.', code: 'places_failed', quota: budget }, 502);
      const googleData = await googleResponse.json();
      const seen = new Set<string>();
      let places: Place[] = (Array.isArray(googleData.places) ? googleData.places : [])
        .filter((p: Record<string, any>) => p.id && p.businessStatus !== 'CLOSED_PERMANENTLY')
        .map(normalizePlace).filter((p: Place) => !seen.has(p.googlePlaceId) && !!seen.add(p.googlePlaceId)).slice(0, 10);
      // Only known conflicts are excluded; missing facts remain unverified.
      const priceRanks: Record<string, number> = { PRICE_LEVEL_FREE: 0, PRICE_LEVEL_INEXPENSIVE: 0, PRICE_LEVEL_MODERATE: 1, PRICE_LEVEL_EXPENSIVE: 2, PRICE_LEVEL_VERY_EXPENSIVE: 2 };
      const budgetRank = { Low: 0, Medium: 1, High: 2 }[String(prefs.budget) as 'Low' | 'Medium' | 'High'];
      places = places.filter((place) => {
        if (budgetRank != null && place.priceLevel && priceRanks[place.priceLevel] != null && priceRanks[place.priceLevel] > budgetRank) return false;
        if ((prefs.dietary_needs as string[]).includes('Vegetarian') && place.signals.servesVegetarianFood === false) return false;
        return true;
      });
      const ranking: Record<string, unknown> = { provider: 'Google Maps', status: 'not_configured',
        message: 'Jev is not connected yet. Results use Google Maps ordering.' };
      const jevKey = env('TYPESAFE_API_KEY');
      // Key presence alone NEVER authorizes a metered Jev request.
      if (places.length && jevKey && env('JEV_FREE_CREDITS_CONFIRMED') === 'true') {
        try {
          const jevBudget = await reserve('jev');
          if (!jevBudget.allowed) {
            ranking.status = 'quota_exhausted';
            ranking.message = 'Jev allowance is exhausted. Results use Google Maps ordering.';
          } else {
            const response = await fetcher('https://api.typesafe.ai/v1/systemone', {
              method: 'POST', headers: { Authorization: `Bearer ${jevKey}`, 'Content-Type': 'application/json' },
              body: JSON.stringify(buildJevRequest(places, prefs)), signal: AbortSignal.timeout(15000),
            });
            if (!response.ok) throw new Error('Jev failed');
            places = applyJevAnswers(places, prefs, await response.json());
            ranking.provider = 'Jev'; ranking.status = 'ranked';
            ranking.message = 'Jev estimates preference fit from available facts; missing details remain unverified.';
          }
        } catch {
          ranking.status = 'unavailable'; ranking.message = 'Jev could not evaluate these places. Results use Google Maps ordering.';
        }
      }
      return json({ places, nextPageToken: null, ranking, quota: budget,
        source: { provider: 'Google Maps', attributionRequired: true } });
    } catch {
      return json({ error: 'Search could not complete. Check the server setup and connection.', code: 'discovery_unavailable' }, 503);
    }
  };
}

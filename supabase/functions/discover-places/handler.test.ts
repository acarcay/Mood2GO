import test from 'node:test';
import assert from 'node:assert/strict';
import { createHandler } from './handler.ts';
import { buildJevRequest, applyJevAnswers } from './jev.ts';

const envValues: Record<string, string> = {
  SUPABASE_URL: 'https://test.supabase.co', SUPABASE_SERVICE_ROLE_KEY: 'server-key',
  GOOGLE_PLACES_API_KEY: 'google-key', TYPESAFE_API_KEY: 'jev-key',
};
const candidate = (i: number) => ({ id: `place-${i}`, displayName: { text: `Place ${i}` },
  formattedAddress: 'Izmir', primaryType: 'cafe', types: ['cafe'], businessStatus: 'OPERATIONAL' });
const request = (body: unknown = { query: 'İzmir', pageSize: 100 }) => new Request('https://app.test', {
  method: 'POST', headers: { Authorization: 'Bearer signed-in', 'Content-Type': 'application/json' }, body: JSON.stringify(body),
});
function harness(options: { allowed?: boolean; failBudget?: boolean; auth?: boolean; jevEnabled?: boolean; jevFail?: boolean } = {}) {
  const calls: { url: string; body: any }[] = [];
  const fetcher = async (url: any, init: any = {}) => {
    calls.push({ url: String(url), body: init.body ? JSON.parse(init.body) : null });
    if (String(url).endsWith('/user')) return Response.json({ id: 'user', user_metadata: { preferences: { mood: 'Relaxed' } } }, { status: options.auth === false ? 401 : 200 });
    if (String(url).includes('/rpc/')) return Response.json({ allowed: options.allowed ?? true, limit: 900, remaining: 899 }, { status: options.failBudget ? 500 : 200 });
    if (String(url).includes('places.googleapis')) return Response.json({ places: Array.from({ length: 15 }, (_, i) => candidate(i)) });
    if (String(url).includes('api.typesafe.ai')) {
      if (options.jevFail) return Response.json({}, { status: 500 });
      const body = JSON.parse(init.body);
      return Response.json({ answers: Object.fromEntries(Object.keys(body.questions).map((id) => [id, { type: 'score', score: 3.5, confidence: 0.8 }])) });
    }
    throw new Error('Unexpected request');
  };
  const env = (key: string) => key === 'JEV_FREE_CREDITS_CONFIRMED' ? String(options.jevEnabled ?? false) : envValues[key];
  return { handler: createHandler(env, fetcher as typeof fetch), calls };
}

test('one search makes one Google request for 10; pagination is absent', async () => {
  const { handler, calls } = harness();
  const response = await handler(request());
  assert.equal(response.status, 200);
  const data = await response.json();
  assert.equal(data.places.length, 10);
  assert.equal(data.nextPageToken, null);
  const google = calls.filter((c) => c.url.includes('places.googleapis'));
  assert.equal(google.length, 1);
  assert.equal(google[0].body.pageSize, 10);
  assert.match(google[0].body.textQuery, /İzmir/);
  assert.equal(calls.some((c) => c.url.includes('api.typesafe.ai')), false);
  assert.equal(data.ranking.status, 'not_configured');
});
test('quota exhaustion blocks Google before any upstream request', async () => {
  const { handler, calls } = harness({ allowed: false });
  assert.equal((await handler(request())).status, 429);
  assert.equal(calls.some((c) => c.url.includes('places.googleapis')), false);
});
test('missing budget setup fails closed', async () => {
  const { handler, calls } = harness({ failBudget: true });
  assert.equal((await handler(request())).status, 503);
  assert.equal(calls.some((c) => c.url.includes('places.googleapis')), false);
});
test('invalid auth does not reserve quota or call Google', async () => {
  const { handler, calls } = harness({ auth: false });
  assert.equal((await handler(request())).status, 401);
  assert.equal(calls.length, 1);
});
test('invalid input and pagination do not consume requests', async () => {
  for (const body of [null, [], { query: 'İzmir', pageToken: 'next' }, { query: 'x' }]) {
    const { handler, calls } = harness();
    assert.equal((await handler(request(body))).status, 400);
    assert.equal(calls.length, 0);
  }
});
test('Jev is one batch for 10 candidates, only after its budget reservation', async () => {
  const { handler, calls } = harness({ jevEnabled: true });
  const data = await (await handler(request())).json();
  const jevCalls = calls.filter((c) => c.url.includes('api.typesafe.ai'));
  assert.equal(jevCalls.length, 1);
  assert.equal(jevCalls[0].body.state.candidates.length, 10);
  assert.equal(Object.keys(jevCalls[0].body.questions).length, 40);
  assert.equal(data.ranking.provider, 'Jev');
  assert.equal(data.places[0].recommendation.score, 88);
  assert.equal(data.places[0].recommendation.coverage, 45);
  assert.equal(data.places[0].recommendation.reasons.length, 1);
  assert.equal(calls[calls.length - 2].body.p_provider, 'jev');
});
test('Jev failure is visible and never fabricates AI scores or retries', async () => {
  const { handler, calls } = harness({ jevEnabled: true, jevFail: true });
  const data = await (await handler(request())).json();
  assert.equal(data.ranking.status, 'unavailable');
  assert.equal(data.places[0].recommendation, undefined);
  assert.equal(calls.filter((c) => c.url.includes('api.typesafe.ai')).length, 1);
});
test('Jev validates responses and unknown evidence does not earn a score', async () => {
  const p = { googlePlaceId: 'p', name: 'p', address: '', primaryType: null, types: [], rating: null, ratingCount: null, priceLevel: null, openNow: null, googleMapsUri: null, signals: {} };
  const questions = buildJevRequest([p], {}).questions;
  const answers = Object.fromEntries(Object.keys(questions).map((id) => [id, { type: 'score', score: 4, confidence: 1 }]));
  const ranked = applyJevAnswers([p], {}, { answers });
  assert.equal(ranked[0].recommendation?.score, null);
  assert.equal(ranked[0].recommendation?.coverage, 0);
  assert.throws(() => applyJevAnswers([p], {}, { answers: {} }));
  answers.p0_mood.score = 99;
  assert.throws(() => applyJevAnswers([p], {}, { answers }));
});

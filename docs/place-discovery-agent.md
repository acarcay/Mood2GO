# Live search and Jev ranking

Flutter calls `discover-places`; the Google key and TypeSafe key stay in Supabase
secrets. One search makes at most one Google Text Search call with `pageSize: 10`.
Neither the server nor the UI offers pagination. Ten returned places count as one
search request, not ten. Unknown venue details are never invented.

## Deploy

1. From the project folder, sign in to Supabase locally (`supabase login`).
2. Link the project: `supabase link --project-ref ntwnrorwpgsocgqwtklu`.
3. Apply the migration: `supabase db push`. Alternatively, run
   `supabase/migrations/202610140001_discovery_budget.sql` in the dashboard SQL editor.
4. Set `GOOGLE_PLACES_API_KEY` in Edge Functions → Secrets.
5. Check the current month's remaining Text Search Enterprise + Atmosphere free
   allowance in Google Cloud, including other projects on the same billing account.
   Authorize only that many requests, maximum 900, in the SQL editor:

   ```sql
   -- Replace 0 ONLY with the verified remaining allowance (maximum 900).
   insert into public.discovery_budget (provider, month, request_limit)
   values ('google_places', date_trunc('month', now() at time zone 'America/Los_Angeles')::date, 0)
   on conflict (provider, month) do nothing;
   ```

   To adjust an existing row, keep `used` unchanged and set `request_limit` to
   `used + newly_verified_remaining`, capped at 900. Do not reset the used counter.
6. Deploy: `supabase functions deploy discover-places --project-ref ntwnrorwpgsocgqwtklu`.

The function verifies the user's bearer token through Supabase Auth. Keep JWT
verification enabled. Missing secrets, missing migration, no approved quota, or
unavailable quota storage block the Google request. The app shows the error.

## Spending boundary

The SQL reservation is atomic and shared by all users and function instances.
It is taken before each upstream call; failed/ambiguous requests remain counted.
No automatic retries or refunds. A new month is closed until approved again.
The counter governs only this app, not Google's entire billing account. It does
not measure prior usage or calls made with the key outside this function. Quotas
and billing settings in Google Cloud have not been modified by these files.

## Jev setup (not yet activated)

Official documentation: https://docs.typesafe.ai/api and https://docs.typesafe.ai/models.
An account/key is obtained from https://console.typesafe.ai. The published API is
metered; this project has not verified a free-credit offer for the user's account.
No TypeSafe account or credits have been configured, and no real Jev calls were made.

The adapter is implemented for `POST https://api.typesafe.ai/v1/systemone` with
model `jev-1.13.0`. It batches four Score questions per candidate (mood, cuisine,
setting, group suitability) into one request for up to ten candidates. Valid
0–4 scores are normalized and weighted 45/25/15/15. These weights are Mood2GO's
initial design choices, not Jev's training algorithm. Numerical arithmetic and
known budget conflicts are handled by code.

To activate later, first verify free credits and a provider-side spending cap.
Then set `TYPESAFE_API_KEY`, `JEV_FREE_CREDITS_CONFIRMED=true`, and a separate
approved `jev` row in `discovery_budget`. A request-count cap alone cannot guarantee
free inference because requests consume different token amounts. Leave Jev
unconfigured until the account's spending boundary is verified.

If Jev is missing, unavailable, or out of its separate allowance, Google results
still appear with an explicit ranking status. They never receive invented AI
scores. Low-confidence or unsupported dimensions are excluded; absent evidence
gets no match score. The UI discloses that mood fit is estimated and diet/allergen
safety, visit time and exact group capacity are unverified.

## Data and verification

Place details stay in the request/UI session. No copied venue directory or model
training corpus is stored. Google Maps is attributed beside the results and in
place details. Jev receives sanitized preferences and categories/signals, without
user names, emails or coordinates. Review third-party inference data handling
before production.

Backend contract tests run with `node --test supabase/functions/discover-places/handler.test.ts`.
These mock both providers; they do not verify real account access, Jev recommendation
quality, deployed functions or database concurrency. SQL deployment must be verified
on Supabase before enabling live search.

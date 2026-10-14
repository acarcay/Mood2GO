-- Admin-approved monthly allowances. Default is closed until remaining free
-- Google allowance / TypeSafe credits have been checked in their dashboards.
create table if not exists public.discovery_budget (
  provider text not null check (provider in ('google_places', 'jev')),
  month date not null,
  request_limit integer not null default 0 check (request_limit between 0 and 900),
  used integer not null default 0 check (used >= 0),
  primary key (provider, month)
);
alter table public.discovery_budget enable row level security;
revoke all on public.discovery_budget from public, anon, authenticated;
grant all on public.discovery_budget to service_role;

create or replace function public.reserve_discovery_request(p_provider text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_month date := date_trunc('month', now() at time zone 'America/Los_Angeles')::date;
  budget public.discovery_budget%rowtype;
begin
  -- No automatic renewal: a new month requires a new approved allowance.
  select * into budget from public.discovery_budget
    where provider = p_provider and month = current_month for update;
  if not found then
    return jsonb_build_object('allowed', false, 'limit', 0, 'used', 0, 'remaining', 0);
  end if;
  if budget.used >= budget.request_limit then
    return jsonb_build_object('allowed', false, 'limit', budget.request_limit,
      'used', budget.used, 'remaining', 0);
  end if;
  update public.discovery_budget set used = used + 1
    where provider = p_provider and month = current_month returning * into budget;
  return jsonb_build_object('allowed', true, 'limit', budget.request_limit,
    'used', budget.used, 'remaining', budget.request_limit - budget.used);
end;
$$;
revoke all on function public.reserve_discovery_request(text) from public, anon, authenticated;
grant execute on function public.reserve_discovery_request(text) to service_role;

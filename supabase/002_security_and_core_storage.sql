-- Internet Court: production safety + core vote/report schema
-- IMPORTANT: review and run this in Supabase SQL Editor only after verifying the policies.
-- This file is intentionally NOT auto-applied by ChatGPT because RLS changes can block access if policies are incomplete.

-- 1) Lock down all currently exposed public tables.
alter table public.profiles enable row level security;
alter table public.cases enable row level security;
alter table public.follows enable row level security;
alter table public._internet_court_bootstrap_check enable row level security;

-- 2) Public profiles: readable, but users may update only their own profile.
drop policy if exists "profiles_public_read" on public.profiles;
create policy "profiles_public_read" on public.profiles
  for select to anon, authenticated using (true);

drop policy if exists "profiles_self_update" on public.profiles;
create policy "profiles_self_update" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- 3) Cases: anyone can read open cases; authenticated users may create only for themselves.
drop policy if exists "cases_open_read" on public.cases;
create policy "cases_open_read" on public.cases
  for select to anon, authenticated using (status = 'open');

drop policy if exists "cases_self_insert" on public.cases;
create policy "cases_self_insert" on public.cases
  for insert to authenticated
  with check ((select auth.uid()) = author_id);

drop policy if exists "cases_author_update" on public.cases;
create policy "cases_author_update" on public.cases
  for update to authenticated
  using ((select auth.uid()) = author_id and status in ('draft','open'))
  with check ((select auth.uid()) = author_id);

-- 4) Follows: each user can manage only relationships where they are the follower.
drop policy if exists "follows_read" on public.follows;
create policy "follows_read" on public.follows
  for select to authenticated using (true);

drop policy if exists "follows_insert_self" on public.follows;
create policy "follows_insert_self" on public.follows
  for insert to authenticated
  with check ((select auth.uid()) = follower_id and follower_id <> following_id);

drop policy if exists "follows_delete_self" on public.follows;
create policy "follows_delete_self" on public.follows
  for delete to authenticated
  using ((select auth.uid()) = follower_id);

-- 5) Keep the bootstrap test table inaccessible through the API.
revoke all on table public._internet_court_bootstrap_check from anon, authenticated;

-- 6) Vote storage. Direct writes should be avoided; the cast_vote RPC should own writes.
create table if not exists public.votes (
  user_id uuid not null references auth.users(id) on delete cascade,
  case_id uuid not null references public.cases(id) on delete cascade,
  verdict text not null check (verdict in ('guilty','innocent','both')),
  created_at timestamptz not null default now(),
  primary key (user_id, case_id)
);
create index if not exists votes_case_id_idx on public.votes(case_id);
alter table public.votes enable row level security;

drop policy if exists "votes_self_read" on public.votes;
create policy "votes_self_read" on public.votes
  for select to authenticated using ((select auth.uid()) = user_id);

revoke insert, update, delete on table public.votes from anon, authenticated;

-- 7) Reports. Direct inserts should be avoided; submit_report RPC should own writes.
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  case_id uuid not null references public.cases(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text not null,
  details text not null default '',
  status text not null default 'pending' check (status in ('pending','reviewed','dismissed')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);
create index if not exists reports_case_id_idx on public.reports(case_id);
create index if not exists reports_status_idx on public.reports(status);
alter table public.reports enable row level security;

drop policy if exists "reports_self_read" on public.reports;
create policy "reports_self_read" on public.reports
  for select to authenticated using ((select auth.uid()) = reporter_id);

revoke insert, update, delete on table public.reports from anon, authenticated;

-- NOTE:
-- The frontend currently expects these server-side RPCs:
-- get_case_vote_counts(p_case_ids uuid[])
-- cast_vote(p_case_id uuid, p_verdict text)
-- create_case(p_category text, p_title text, p_summary text, p_side_a text, p_side_b text)
-- submit_report(p_case_id uuid, p_reason text, p_details text)
-- is_moderator()
-- moderator_list_reports()
-- moderator_set_case_status(...)
-- moderator_resolve_report(...)
-- Those functions should be added only after their authorization/rate-limit rules are reviewed.

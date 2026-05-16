-- ─────────────────────────────────────────────────────────────
-- Oh Wisey · Supabase schema
--
-- Run this in your Supabase project: SQL Editor → New query → paste → Run.
-- Safe to run twice (uses `if not exists` / `drop policy if exists`).
--
-- The dashboard tile list lives in CODE (the TILES array in index.html).
-- This schema only sets up what STANDALONES need to sync their own data
-- (workouts, sleep, weights, etc.) across the user's devices.
-- ─────────────────────────────────────────────────────────────

-- Generic key-value store any standalone can use to sync its data.
-- Workout logger, water tracker, sleep log — each picks an app_slug
-- and writes (key, value) pairs scoped to the signed-in user.
create table if not exists public.app_data (
  user_id     uuid not null references auth.users(id) on delete cascade,
  app_slug    text not null,
  key         text not null,
  value       jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now(),
  primary key (user_id, app_slug, key)
);

alter table public.app_data enable row level security;

drop policy if exists "select own app_data" on public.app_data;
drop policy if exists "insert own app_data" on public.app_data;
drop policy if exists "update own app_data" on public.app_data;
drop policy if exists "delete own app_data" on public.app_data;

create policy "select own app_data"
  on public.app_data for select
  using (auth.uid() = user_id);

create policy "insert own app_data"
  on public.app_data for insert
  with check (auth.uid() = user_id);

create policy "update own app_data"
  on public.app_data for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "delete own app_data"
  on public.app_data for delete
  using (auth.uid() = user_id);

create index if not exists app_data_user_app_idx on public.app_data (user_id, app_slug);

-- ─────────────────────────────────────────────────────────────
-- Role grants
--
-- RLS controls which ROWS each signed-in user can see/modify.
-- Grants control whether a role can hit the table AT ALL.
-- Without these, signed-in users hit a 403 even with correct policies.
-- ─────────────────────────────────────────────────────────────

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.app_data to authenticated;

-- ─────────────────────────────────────────────────────────────
-- Cleanup (only needed if you ran an earlier version of this schema
-- that created public.dashboard_config — that table is no longer used).
-- Safe to run; no-op if the table doesn't exist.
-- ─────────────────────────────────────────────────────────────

drop table if exists public.dashboard_config;

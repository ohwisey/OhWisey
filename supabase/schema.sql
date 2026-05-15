-- ─────────────────────────────────────────────────────────────
-- Oh Wisey · dashboard schema
--
-- Run this in your Supabase project: SQL Editor → New query → paste → Run.
-- It's safe to run twice (uses `if not exists` / `create or replace`).
-- ─────────────────────────────────────────────────────────────

-- One row per signed-in user. Holds the tile list for their dashboard.
create table if not exists public.dashboard_config (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  apps        jsonb not null default '[]'::jsonb,
  updated_at  timestamptz not null default now()
);

-- Lock it down: users can only read/write their own row.
alter table public.dashboard_config enable row level security;

drop policy if exists "select own dashboard"  on public.dashboard_config;
drop policy if exists "insert own dashboard"  on public.dashboard_config;
drop policy if exists "update own dashboard"  on public.dashboard_config;
drop policy if exists "delete own dashboard"  on public.dashboard_config;

create policy "select own dashboard"
  on public.dashboard_config for select
  using (auth.uid() = user_id);

create policy "insert own dashboard"
  on public.dashboard_config for insert
  with check (auth.uid() = user_id);

create policy "update own dashboard"
  on public.dashboard_config for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "delete own dashboard"
  on public.dashboard_config for delete
  using (auth.uid() = user_id);

-- Optional: generic key-value table any standalone can use to sync its own data.
-- Workout logger, water tracker, sleep log — each gets its own (app_slug, key) namespace.
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

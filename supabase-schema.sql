-- Swedish Verb Trainer — database setup
-- Run this once in Supabase: SQL Editor → New query → paste everything → Run.
-- Every account gets its own private progress row. Nobody can read or change anyone else's.

create table if not exists public.progress (
  user_id uuid primary key references auth.users on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.progress enable row level security;

drop policy if exists "progress: own only" on public.progress;
create policy "progress: own only" on public.progress
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

grant select, insert, update on public.progress to authenticated;

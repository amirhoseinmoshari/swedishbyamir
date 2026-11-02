-- Swedish Verb Trainer — database setup
-- Run this once in Supabase: SQL Editor → New query → paste everything → Run.
-- BEFORE running: replace OWNER_EMAIL@example.com below with YOUR email (the owner / approver).

-- 1) Who can approve learners
create table if not exists public.app_admins (
  email text primary key
);
insert into public.app_admins (email) values (lower('OWNER_EMAIL@example.com'))
on conflict do nothing;

-- 2) One row per learner: their email and approval status
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  email text not null,
  status text not null default 'pending' check (status in ('pending','approved','declined')),
  requested_at timestamptz not null default now(),
  approved_at timestamptz
);

-- 3) Each learner's private progress
create table if not exists public.progress (
  user_id uuid primary key references auth.users on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Helper checks (run with owner rights so they can read app_admins)
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.app_admins a where a.email = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;

create or replace function public.is_approved() returns boolean
language sql stable security definer set search_path = public as $$
  select public.is_admin() or exists (select 1 from public.profiles p where p.id = auth.uid() and p.status = 'approved');
$$;

-- Creates the signed-in person's profile row if it is missing (status: pending, or approved for the owner)
create or replace function public.ensure_profile() returns void
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then return; end if;
  insert into public.profiles (id, email, status, approved_at)
  values (auth.uid(), lower(auth.jwt() ->> 'email'),
          case when public.is_admin() then 'approved' else 'pending' end,
          case when public.is_admin() then now() else null end)
  on conflict (id) do nothing;
end $$;

grant execute on function public.is_admin() to authenticated;
grant execute on function public.is_approved() to authenticated;
grant execute on function public.ensure_profile() to authenticated;

-- 4) Security: everyone only sees what they are allowed to
alter table public.app_admins enable row level security;   -- no policies: nobody can read it from the app
alter table public.profiles   enable row level security;
alter table public.progress   enable row level security;

drop policy if exists "profiles: read own or admin" on public.profiles;
create policy "profiles: read own or admin" on public.profiles
  for select to authenticated using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles: admin updates" on public.profiles;
create policy "profiles: admin updates" on public.profiles
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "progress: own, approved" on public.progress;
create policy "progress: own, approved" on public.progress
  for all to authenticated
  using (user_id = auth.uid() and public.is_approved())
  with check (user_id = auth.uid() and public.is_approved());

grant select, update on public.profiles to authenticated;
grant select, insert, update on public.progress to authenticated;

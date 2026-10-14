-- SatGold Cloud foundation: PostgreSQL / Supabase
create extension if not exists pgcrypto;

create type public.school_role as enum ('owner','administrator','teacher','staff','student','parent');
create type public.member_status as enum ('active','invited','suspended','inactive');

create table public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  school_email text not null,
  phone text not null,
  address text not null,
  state text not null,
  country text not null default 'Nigeria',
  school_type text not null,
  education_levels jsonb not null default '[]'::jsonb,
  website text,
  description text,
  status text not null default 'active' check (status in ('active','suspended','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.school_memberships (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete restrict,
  user_id uuid not null references auth.users(id) on delete restrict,
  role public.school_role not null,
  status public.member_status not null default 'active',
  permissions jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (school_id,user_id)
);
create unique index schools_school_email_unique on public.schools(lower(trim(school_email)));
create index school_memberships_user_idx on public.school_memberships(user_id,status);
create index school_memberships_school_role_idx on public.school_memberships(school_id,role,status);
create table public.academic_settings (
  school_id uuid primary key references public.schools(id) on delete restrict,
  configuration jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table public.school_subscriptions (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null unique references public.schools(id) on delete restrict,
  plan text not null default 'trial',
  status text not null default 'trialing' check (status in ('trialing','active','past_due','cancelled','expired')),
  trial_starts_at timestamptz not null default now(),
  trial_ends_at timestamptz not null default (now() + interval '2 months'),
  current_period_ends_at timestamptz,
  provider text,
  provider_customer_id text,
  created_at timestamptz not null default now()
);
create table public.school_classes (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  name text not null, arm text, created_at timestamptz not null default now()
);
create unique index school_classes_tenant_name_arm_unique on public.school_classes(school_id,name,coalesce(arm,''));
create table public.school_subjects (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  name text not null, created_at timestamptz not null default now(), unique (school_id,name)
);
create table public.audit_logs (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  actor_id uuid references auth.users(id) on delete set null, action text not null, entity_type text not null,
  entity_id uuid, details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);
create index audit_logs_school_created_idx on public.audit_logs(school_id,created_at desc);

create function public.is_school_member(target_school uuid) returns boolean
language sql stable security definer set search_path=public,pg_temp as $$
  select exists(select 1 from public.school_memberships m where m.school_id=target_school and m.user_id=auth.uid() and m.status='active')
$$;
create function public.is_school_owner(target_school uuid) returns boolean
language sql stable security definer set search_path=public,pg_temp as $$
  select exists(select 1 from public.school_memberships m where m.school_id=target_school and m.user_id=auth.uid() and m.role='owner' and m.status='active')
$$;
revoke all on function public.is_school_member(uuid) from public;
revoke all on function public.is_school_owner(uuid) from public;
grant execute on function public.is_school_member(uuid) to authenticated;
grant execute on function public.is_school_owner(uuid) to authenticated;

-- Authenticated owner signup provisions the tenant as part of the auth.users transaction.
-- Role and school_id are always assigned by this trigger; user-supplied role metadata is ignored.
create function public.provision_school_owner() returns trigger
language plpgsql security definer set search_path=public,auth,pg_temp as $$
declare r jsonb; acad jsonb; school_uuid uuid; base_slug text; final_slug text;
begin
  if new.email_confirmed_at is null then return new; end if;
  r := new.raw_user_meta_data->'registration';
  if r is null or r->>'school_name' is null then return new; end if;
  if exists(select 1 from public.school_memberships where user_id=new.id and role='owner') then return new; end if;
  if length(coalesce(new.raw_user_meta_data->>'full_name',''))=0 then raise exception 'Owner full name is required'; end if;
  if length(coalesce(new.raw_user_meta_data->>'phone',''))=0 then raise exception 'Owner phone is required'; end if;
  acad := coalesce(r->'academic','{}'::jsonb);
  base_slug := trim(both '-' from regexp_replace(lower(coalesce(r->>'school_name','school')), '[^a-z0-9]+', '-', 'g'));
  if base_slug='' then base_slug := 'school'; end if;
  final_slug := left(base_slug,48)||'-'||substr(replace(new.id::text,'-',''),1,8);
  insert into public.schools(name,slug,school_email,phone,address,state,country,school_type,education_levels,website,description)
  values(r->>'school_name',final_slug,r->>'school_email',r->>'school_phone',r->>'address',r->>'state',coalesce(r->>'country','Nigeria'),r->>'school_type',coalesce(r->'education_levels','[]'::jsonb),r->>'website',r->>'description') returning id into school_uuid;
  insert into public.school_memberships(school_id,user_id,role,status) values(school_uuid,new.id,'owner','active');
  insert into public.academic_settings(school_id,configuration) values(school_uuid,acad);
  insert into public.school_classes(school_id,name)
    select distinct school_uuid, trim(value) from jsonb_array_elements_text(coalesce(acad->'classes','[]'::jsonb)) as classes(value)
    where trim(value) <> '' on conflict do nothing;
  insert into public.school_subjects(school_id,name)
    select school_uuid, trim(value) from jsonb_array_elements_text(coalesce(acad->'subjects','[]'::jsonb)) as subjects(value)
    where trim(value) <> '' on conflict do nothing;
  insert into public.school_subscriptions(school_id,plan,status,trial_starts_at,trial_ends_at)
    values(school_uuid,'trial','trialing',now(),now()+interval '2 months');
  insert into public.audit_logs(school_id,actor_id,action,entity_type,details)
    values(school_uuid,new.id,'school.registered','school',jsonb_build_object('source','owner_signup'));
  return new;
end $$;
revoke all on function public.provision_school_owner() from public;
create trigger on_auth_user_confirmed_provision_school
after insert or update of email_confirmed_at on auth.users
for each row when (new.email_confirmed_at is not null)
execute function public.provision_school_owner();

alter table public.schools enable row level security;
alter table public.school_memberships enable row level security;
alter table public.academic_settings enable row level security;
alter table public.school_subscriptions enable row level security;
alter table public.school_classes enable row level security;
alter table public.school_subjects enable row level security;
alter table public.audit_logs enable row level security;
create policy "members read their school" on public.schools for select to authenticated using (public.is_school_member(id));
create policy "owners update their school" on public.schools for update to authenticated using (public.is_school_owner(id)) with check (public.is_school_owner(id));
create policy "members read memberships" on public.school_memberships for select to authenticated using (public.is_school_member(school_id));
create policy "owners add non-owner memberships" on public.school_memberships for insert to authenticated with check (public.is_school_owner(school_id) and role <> 'owner');
create policy "owners update non-owner memberships" on public.school_memberships for update to authenticated using (public.is_school_owner(school_id) and role <> 'owner') with check (public.is_school_owner(school_id) and role <> 'owner');
create policy "owners remove non-owner memberships" on public.school_memberships for delete to authenticated using (public.is_school_owner(school_id) and role <> 'owner');
create policy "members read academic config" on public.academic_settings for select to authenticated using (public.is_school_member(school_id));
create policy "owners manage academic config" on public.academic_settings for all to authenticated using (public.is_school_owner(school_id)) with check (public.is_school_owner(school_id));
create policy "members read subscription" on public.school_subscriptions for select to authenticated using (public.is_school_member(school_id));
create policy "owners read classes" on public.school_classes for select to authenticated using (public.is_school_member(school_id));
create policy "owners manage classes" on public.school_classes for all to authenticated using (public.is_school_owner(school_id)) with check (public.is_school_owner(school_id));
create policy "members read subjects" on public.school_subjects for select to authenticated using (public.is_school_member(school_id));
create policy "owners manage subjects" on public.school_subjects for all to authenticated using (public.is_school_owner(school_id)) with check (public.is_school_owner(school_id));
create policy "members read audit logs" on public.audit_logs for select to authenticated using (public.is_school_member(school_id));

grant select,update on public.schools to authenticated;
grant select,insert,update,delete on public.school_memberships,public.academic_settings,public.school_classes,public.school_subjects to authenticated;
grant select on public.school_subscriptions to authenticated;
grant select on public.audit_logs to authenticated;




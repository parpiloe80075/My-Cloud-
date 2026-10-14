-- GENERATED SCHEMA SNAPSHOT for SatGold Cloud (PostgreSQL / Supabase).
-- Canonical source: ordered files in supabase/migrations/.
-- Apply either the timestamped migrations OR this complete snapshot to an empty project, never both.
-- To update this reference file, concatenate all migration files in timestamp order.


-- ===== BEGIN 202610130001_foundation.sql =====
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
after insert or update of email_confirmed_at, raw_user_meta_data on auth.users
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




-- ===== END 202610130001_foundation.sql =====

-- ===== BEGIN 202610130002_school_operations.sql =====
-- Core school operations and academic setup.
create table public.academic_sessions (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  name text not null, starts_on date, ends_on date, status text not null default 'planned' check(status in ('planned','active','completed','archived')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(school_id,name), unique(school_id,id),
  check((starts_on is null and ends_on is null) or (starts_on is not null and ends_on is not null and ends_on > starts_on))
);
create unique index academic_sessions_one_active on public.academic_sessions(school_id) where status='active';
alter table public.school_memberships add constraint school_memberships_school_id_id_unique unique(school_id,id);
alter table public.school_classes add column session_id uuid;
alter table public.school_classes add constraint school_classes_session_fk foreign key(school_id,session_id) references public.academic_sessions(school_id,id) on delete restrict;
alter table public.school_classes add constraint school_classes_school_id_id_unique unique(school_id,id);
alter table public.school_subjects add constraint school_subjects_school_id_id_unique unique(school_id,id);

create table public.academic_periods (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, session_id uuid not null,
  name text not null, sequence integer not null check(sequence > 0), starts_on date, ends_on date,
  resumption_on date, status text not null default 'planned' check(status in ('planned','active','completed','archived')),
  created_at timestamptz not null default now(),
  unique(school_id,id), unique(school_id,session_id,name), unique(school_id,session_id,sequence),
  foreign key(school_id,session_id) references public.academic_sessions(school_id,id) on delete restrict,
  check((starts_on is null and ends_on is null) or (starts_on is not null and ends_on is not null and ends_on >= starts_on)),
  check(resumption_on is null or ends_on is null or resumption_on >= ends_on)
);
create table public.school_calendar_events (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  session_id uuid, period_id uuid, title text not null, description text, event_type text not null default 'event',
  starts_at timestamptz not null, ends_at timestamptz, audience text not null default 'school' check(audience in ('school','staff','students','parents','class')),
  class_id uuid, created_by uuid not null,
  created_at timestamptz not null default now(),
  foreign key(school_id,session_id) references public.academic_sessions(school_id,id) on delete restrict,
  foreign key(school_id,period_id) references public.academic_periods(school_id,id) on delete restrict,
  foreign key(school_id,class_id) references public.school_classes(school_id,id) on delete restrict,
  foreign key(school_id,created_by) references public.school_memberships(school_id,id) on delete restrict,
  check(ends_at is null or ends_at >= starts_at)
);
create index calendar_school_start_idx on public.school_calendar_events(school_id,starts_at);

create table public.staff_profiles (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  membership_id uuid not null, staff_code text not null, staff_type text not null check(staff_type in ('teaching','non_teaching')),
  department text, job_title text, hired_on date, status text not null default 'active' check(status in ('active','suspended','inactive')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(school_id,id), unique(school_id,membership_id), unique(school_id,staff_code),
  foreign key(school_id,membership_id) references public.school_memberships(school_id,id) on delete restrict
);
create table public.student_profiles (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  membership_id uuid not null, student_code text not null, date_of_birth date, enrolled_on date not null default current_date,
  status text not null default 'active' check(status in ('active','suspended','withdrawn','graduated')),
  passcode_hash text, passcode_changed_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(school_id,id), unique(school_id,membership_id), unique(school_id,student_code),
  foreign key(school_id,membership_id) references public.school_memberships(school_id,id) on delete restrict
);
create table public.guardian_profiles (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  membership_id uuid not null, relationship text, preferred_contact text check(preferred_contact is null or preferred_contact in ('email','phone')),
  created_at timestamptz not null default now(), unique(school_id,id), unique(school_id,membership_id),
  foreign key(school_id,membership_id) references public.school_memberships(school_id,id) on delete restrict
);
create table public.student_guardians (
  school_id uuid not null, student_id uuid not null, guardian_id uuid not null, is_primary boolean not null default false,
  created_at timestamptz not null default now(), primary key(student_id,guardian_id),
  foreign key(school_id,student_id) references public.student_profiles(school_id,id) on delete restrict,
  foreign key(school_id,guardian_id) references public.guardian_profiles(school_id,id) on delete restrict
);
create index student_guardians_guardian_idx on public.student_guardians(school_id,guardian_id);
create unique index student_guardians_one_primary on public.student_guardians(school_id,student_id) where is_primary;
create table public.class_enrollments (
  school_id uuid not null, class_id uuid not null, student_id uuid not null, enrolled_on date not null default current_date,
  left_on date, status text not null default 'active' check(status in ('active','completed','transferred')),
  primary key(class_id,student_id),
  foreign key(school_id,class_id) references public.school_classes(school_id,id) on delete restrict,
  foreign key(school_id,student_id) references public.student_profiles(school_id,id) on delete restrict,
  check(left_on is null or left_on >= enrolled_on)
);
create index class_enrollments_student_idx on public.class_enrollments(school_id,student_id,status);
create table public.teacher_assignments (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, staff_id uuid not null,
  class_id uuid not null, subject_id uuid not null, is_class_teacher boolean not null default false,
  created_at timestamptz not null default now(), unique(school_id,id), unique(school_id,staff_id,class_id,subject_id),
  foreign key(school_id,staff_id) references public.staff_profiles(school_id,id) on delete restrict,
  foreign key(school_id,class_id) references public.school_classes(school_id,id) on delete restrict,
  foreign key(school_id,subject_id) references public.school_subjects(school_id,id) on delete restrict
);
create index teacher_assignments_membership_lookup on public.teacher_assignments(school_id,staff_id,class_id,subject_id);
create unique index teacher_assignments_one_class_teacher on public.teacher_assignments(school_id,class_id) where is_class_teacher;
create function public.validate_teacher_assignment() returns trigger
language plpgsql security definer set search_path=public,pg_temp as $$
begin
 if not exists(select 1 from public.staff_profiles s where s.id=new.staff_id and s.school_id=new.school_id and s.staff_type='teaching' and s.status='active') then raise exception 'Teacher assignments require an active teaching staff profile'; end if;
 return new;
end $$;
revoke all on function public.validate_teacher_assignment() from public;
create trigger teacher_assignment_role_guard before insert or update of school_id,staff_id on public.teacher_assignments for each row execute function public.validate_teacher_assignment();

create table public.school_invitations (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  email text not null, role public.school_role not null check(role <> 'owner'), permissions jsonb not null default '{}'::jsonb,
  token_hash text not null unique, invited_by uuid not null,
  expires_at timestamptz not null, accepted_at timestamptz, revoked_at timestamptz, created_at timestamptz not null default now(),
  foreign key(school_id,invited_by) references public.school_memberships(school_id,id) on delete restrict
);
create index school_invitations_pending_idx on public.school_invitations(school_id,lower(email)) where accepted_at is null and revoked_at is null;

create table public.grading_scales (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, session_id uuid,
  name text not null, is_default boolean not null default false, created_at timestamptz not null default now(),
  unique(school_id,id), unique(school_id,name),
  foreign key(school_id) references public.schools(id) on delete restrict,
  foreign key(school_id,session_id) references public.academic_sessions(school_id,id) on delete restrict
);
create unique index grading_scales_one_default on public.grading_scales(school_id) where is_default;
create table public.grading_scale_bands (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, scale_id uuid not null,
  grade text not null, lower_bound numeric(5,2) not null, upper_bound numeric(5,2) not null,
  remark text, sequence integer not null check(sequence > 0), unique(school_id,scale_id,grade), unique(school_id,scale_id,sequence),
  foreign key(school_id,scale_id) references public.grading_scales(school_id,id) on delete cascade,
  check(lower_bound >= 0 and upper_bound <= 100 and upper_bound >= lower_bound)
);
create table public.assessment_categories (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  name text not null, weight numeric(6,3) not null check(weight > 0 and weight <= 100), sequence integer not null check(sequence > 0),
  created_at timestamptz not null default now(), unique(school_id,id), unique(school_id,name), unique(school_id,sequence)
);

create function public.validate_profile_membership_role() returns trigger
language plpgsql security definer set search_path=public,pg_temp as $$
declare member_role public.school_role;
begin
 select role into member_role from public.school_memberships where school_id=new.school_id and id=new.membership_id and status='active';
 if member_role is null then raise exception 'Profile needs an active school membership'; end if;
 case tg_table_name
   when 'staff_profiles' then
     if not ((new.staff_type='teaching' and member_role='teacher') or (new.staff_type='non_teaching' and member_role='staff')) then raise exception 'Staff type must match the school membership role'; end if;
   when 'student_profiles' then
     if member_role<>'student' then raise exception 'Student profile needs a student membership'; end if;
   when 'guardian_profiles' then
     if member_role<>'parent' then raise exception 'Guardian profile needs a parent membership'; end if;
 end case;
 return new;
end $$;
revoke all on function public.validate_profile_membership_role() from public;
create trigger staff_profile_role_guard before insert or update of school_id,membership_id,staff_type on public.staff_profiles for each row execute function public.validate_profile_membership_role();
create trigger student_profile_role_guard before insert or update of school_id,membership_id on public.student_profiles for each row execute function public.validate_profile_membership_role();
create trigger guardian_profile_role_guard before insert or update of school_id,membership_id on public.guardian_profiles for each row execute function public.validate_profile_membership_role();

create or replace function public.has_school_permission(target_school uuid, permission_name text)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
  select exists(select 1 from public.school_memberships m where m.school_id=target_school and m.user_id=auth.uid() and m.status='active'
    and (m.role='owner' or (m.role='administrator' and m.permissions->>permission_name='true')))
$$;
create or replace function public.has_school_role(target_school uuid, target_role public.school_role)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
  select exists(select 1 from public.school_memberships m where m.school_id=target_school and m.user_id=auth.uid() and m.role=target_role and m.status='active')
$$;
create or replace function public.is_self_student(target_student uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.student_profiles s join public.school_memberships m on m.id=s.membership_id and m.school_id=s.school_id where s.id=target_student and m.user_id=auth.uid() and m.status='active')
$$;
create or replace function public.is_linked_guardian(target_student uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.student_guardians sg join public.guardian_profiles g on g.id=sg.guardian_id and g.school_id=sg.school_id join public.school_memberships m on m.id=g.membership_id and m.school_id=g.school_id where sg.student_id=target_student and m.user_id=auth.uid() and m.status='active')
$$;
create or replace function public.is_assigned_teacher(target_school uuid,target_class uuid,target_subject uuid default null)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.teacher_assignments a join public.staff_profiles s on s.id=a.staff_id and s.school_id=a.school_id join public.school_memberships m on m.id=s.membership_id and m.school_id=s.school_id where a.school_id=target_school and a.class_id=target_class and (target_subject is null or a.subject_id=target_subject) and m.user_id=auth.uid() and m.status='active' and m.role='teacher' and s.staff_type='teaching' and s.status='active')
$$;
create or replace function public.is_enrolled_student(target_school uuid,target_class uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.class_enrollments e join public.student_profiles s on s.id=e.student_id and s.school_id=e.school_id join public.school_memberships m on m.id=s.membership_id and m.school_id=s.school_id where e.school_id=target_school and e.class_id=target_class and e.status='active' and s.status='active' and m.user_id=auth.uid() and m.status='active')
$$;
revoke all on function public.has_school_permission(uuid,text),public.has_school_role(uuid,public.school_role),public.is_self_student(uuid),public.is_linked_guardian(uuid),public.is_assigned_teacher(uuid,uuid,uuid),public.is_enrolled_student(uuid,uuid) from public;
grant execute on function public.has_school_permission(uuid,text),public.has_school_role(uuid,public.school_role),public.is_self_student(uuid),public.is_linked_guardian(uuid),public.is_assigned_teacher(uuid,uuid,uuid),public.is_enrolled_student(uuid,uuid) to authenticated;

-- Provision the configured academic session and periods with a school registration.
create function public.seed_school_academics() returns trigger
language plpgsql security definer set search_path=public,pg_temp as $$
declare cfg jsonb; school_session uuid; period_name text; period_number integer := 0;
begin
  cfg := new.configuration;
  if nullif(trim(cfg->>'session_name'),'') is null then return new; end if;
  insert into public.academic_sessions(school_id,name,starts_on,ends_on,status)
  values(new.school_id,trim(cfg->>'session_name'),nullif(cfg->>'start_date','')::date,nullif(cfg->>'end_date','')::date,'planned')
  on conflict(school_id,name) do nothing returning id into school_session;
  if school_session is null then select id into school_session from public.academic_sessions where school_id=new.school_id and name=trim(cfg->>'session_name'); end if;
  update public.school_classes set session_id=school_session where school_id=new.school_id and session_id is null;
  for period_name in select trim(value) from jsonb_array_elements_text(coalesce(cfg->'term_names','[]'::jsonb)) as terms(value) loop
    if period_name <> '' then
      period_number := period_number + 1;
      insert into public.academic_periods(school_id,session_id,name,sequence)
      values(new.school_id,school_session,period_name,period_number) on conflict(school_id,session_id,name) do nothing;
    end if;
  end loop;
  return new;
end $$;
revoke all on function public.seed_school_academics() from public;
create trigger on_academic_settings_seed_session after insert on public.academic_settings
for each row execute function public.seed_school_academics();
-- Backfill tenants registered before this academic schema was added.
insert into public.academic_sessions(school_id,name,starts_on,ends_on,status)
select a.school_id,trim(a.configuration->>'session_name'),nullif(a.configuration->>'start_date','')::date,nullif(a.configuration->>'end_date','')::date,'planned'
from public.academic_settings a where nullif(trim(a.configuration->>'session_name'),'') is not null
on conflict(school_id,name) do nothing;
update public.school_classes c set session_id=s.id from public.academic_settings a join public.academic_sessions s on s.school_id=a.school_id and s.name=trim(a.configuration->>'session_name')
where c.school_id=a.school_id and c.session_id is null and nullif(trim(a.configuration->>'session_name'),'') is not null;
insert into public.academic_periods(school_id,session_id,name,sequence)
select a.school_id,s.id,trim(term.value),term.ordinality::integer
from public.academic_settings a join public.academic_sessions s on s.school_id=a.school_id and s.name=trim(a.configuration->>'session_name')
cross join lateral jsonb_array_elements_text(coalesce(a.configuration->'term_names','[]'::jsonb)) with ordinality as term(value,ordinality)
where trim(term.value)<>'' on conflict(school_id,session_id,name) do nothing;
create function public.attach_class_to_default_session() returns trigger
language plpgsql security definer set search_path=public,pg_temp as $$
begin
 if new.session_id is null then
   update public.school_classes c set session_id=s.id from public.academic_settings a join public.academic_sessions s on s.school_id=a.school_id and s.name=trim(a.configuration->>'session_name')
   where c.id=new.id and c.school_id=new.school_id and a.school_id=new.school_id;
 end if;
 return new;
end $$;
revoke all on function public.attach_class_to_default_session() from public;
create trigger school_class_default_session after insert on public.school_classes for each row execute function public.attach_class_to_default_session();

alter table public.academic_sessions enable row level security;
alter table public.academic_periods enable row level security;
alter table public.school_calendar_events enable row level security;
alter table public.staff_profiles enable row level security;
alter table public.student_profiles enable row level security;
alter table public.guardian_profiles enable row level security;
alter table public.student_guardians enable row level security;
alter table public.class_enrollments enable row level security;
alter table public.teacher_assignments enable row level security;
alter table public.school_invitations enable row level security;
alter table public.grading_scales enable row level security;
alter table public.grading_scale_bands enable row level security;
alter table public.assessment_categories enable row level security;

-- ===== END 202610130002_school_operations.sql =====

-- ===== BEGIN 202610130003_assessments_results_reports.sql =====
-- CBT, results, attendance, report forms, notifications and billing event records.
create table public.assessments (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, session_id uuid not null, period_id uuid not null,
  class_id uuid not null, subject_id uuid not null, category_id uuid,
  title text not null, instructions text, starts_at timestamptz, ends_at timestamptz,
  duration_minutes integer check(duration_minutes is null or duration_minutes > 0), max_attempts integer not null default 1 check(max_attempts > 0),
  status text not null default 'draft' check(status in ('draft','published','closed','archived')),
  created_by uuid not null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(school_id,id),
  foreign key(school_id,session_id) references public.academic_sessions(school_id,id) on delete restrict,
  foreign key(school_id,period_id) references public.academic_periods(school_id,id) on delete restrict,
  foreign key(school_id,class_id) references public.school_classes(school_id,id) on delete restrict,
  foreign key(school_id,subject_id) references public.school_subjects(school_id,id) on delete restrict,
  foreign key(school_id,category_id) references public.assessment_categories(school_id,id) on delete restrict,
  foreign key(school_id,created_by) references public.school_memberships(school_id,id) on delete restrict,
  check(ends_at is null or starts_at is null or ends_at > starts_at)
);
create index assessments_class_subject_status_idx on public.assessments(school_id,class_id,subject_id,status,starts_at);
create table public.assessment_questions (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, assessment_id uuid not null,
  sequence integer not null check(sequence > 0), question_type text not null check(question_type in ('multiple_choice','multiple_select','true_false','short_answer','essay')),
  prompt text not null, options jsonb not null default '[]'::jsonb, points numeric(7,2) not null check(points > 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(school_id,id), unique(school_id,assessment_id,id), unique(school_id,assessment_id,sequence),
  foreign key(school_id,assessment_id) references public.assessments(school_id,id) on delete restrict,
  check(jsonb_typeof(options)='array')
);
create table public.assessment_answer_keys (
  school_id uuid not null, question_id uuid not null, expected_answer jsonb not null,
  case_sensitive boolean not null default false, created_at timestamptz not null default now(),
  primary key(question_id), foreign key(school_id,question_id) references public.assessment_questions(school_id,id) on delete cascade
);
create table public.assessment_attempts (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, assessment_id uuid not null, student_id uuid not null,
  attempt_number integer not null check(attempt_number > 0), status text not null default 'in_progress' check(status in ('in_progress','submitted','graded','voided')),
  started_at timestamptz not null default now(), submitted_at timestamptz, score numeric(8,2), graded_by uuid,
  graded_at timestamptz, created_at timestamptz not null default now(), unique(school_id,id), unique(school_id,assessment_id,id), unique(school_id,assessment_id,student_id,attempt_number),
  foreign key(school_id,assessment_id) references public.assessments(school_id,id) on delete restrict,
  foreign key(school_id,student_id) references public.student_profiles(school_id,id) on delete restrict,
  foreign key(school_id,graded_by) references public.school_memberships(school_id,id) on delete restrict,
  check(score is null or score >= 0), check((status='in_progress' and submitted_at is null) or status<>'in_progress')
);
create index assessment_attempts_student_idx on public.assessment_attempts(school_id,student_id,assessment_id,status);
create table public.assessment_responses (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, assessment_id uuid not null, attempt_id uuid not null, question_id uuid not null,
  response jsonb not null default 'null'::jsonb, awarded_points numeric(7,2), marker_comment text,
  saved_at timestamptz not null default now(), marked_by uuid,
  unique(school_id,attempt_id,question_id),
  foreign key(school_id,assessment_id,attempt_id) references public.assessment_attempts(school_id,assessment_id,id) on delete restrict,
  foreign key(school_id,assessment_id,question_id) references public.assessment_questions(school_id,assessment_id,id) on delete restrict,
  foreign key(school_id,marked_by) references public.school_memberships(school_id,id) on delete restrict,
  check(awarded_points is null or awarded_points >= 0)
);
create index assessment_responses_attempt_idx on public.assessment_responses(school_id,attempt_id);

create table public.subject_results (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, session_id uuid not null, period_id uuid not null,
  class_id uuid not null, subject_id uuid not null, student_id uuid not null, entered_by uuid not null,
  continuous_assessment numeric(7,2), examination numeric(7,2), total_score numeric(7,2), grade text, teacher_comment text,
  status text not null default 'draft' check(status in ('draft','submitted','returned','approved','published')),
  submitted_at timestamptz, reviewed_by uuid, reviewed_at timestamptz, review_comment text,
  published_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(school_id,id), unique(school_id,period_id,class_id,subject_id,student_id),
  foreign key(school_id,session_id) references public.academic_sessions(school_id,id) on delete restrict,
  foreign key(school_id,period_id) references public.academic_periods(school_id,id) on delete restrict,
  foreign key(school_id,class_id) references public.school_classes(school_id,id) on delete restrict,
  foreign key(school_id,subject_id) references public.school_subjects(school_id,id) on delete restrict,
  foreign key(school_id,student_id) references public.student_profiles(school_id,id) on delete restrict,
  foreign key(school_id,entered_by) references public.school_memberships(school_id,id) on delete restrict,
  foreign key(school_id,reviewed_by) references public.school_memberships(school_id,id) on delete restrict,
  check(continuous_assessment is null or continuous_assessment between 0 and 100),
  check(examination is null or examination between 0 and 100), check(total_score is null or total_score between 0 and 100),
  check(status<>'published' or (published_at is not null and total_score is not null))
);
create index subject_results_student_period_idx on public.subject_results(school_id,student_id,period_id,status);
create table public.result_review_events (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, result_id uuid not null,
  reviewer_id uuid not null,
  decision text not null check(decision in ('approved','returned','published')), comment text, created_at timestamptz not null default now(),
  foreign key(school_id,result_id) references public.subject_results(school_id,id) on delete restrict,
  foreign key(school_id,reviewer_id) references public.school_memberships(school_id,id) on delete restrict
);

create table public.weekly_report_templates (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  name text not null, questions jsonb not null default '[]'::jsonb, is_active boolean not null default true,
  created_by uuid not null, created_at timestamptz not null default now(),
  unique(school_id,id), check(jsonb_typeof(questions)='array'),
  foreign key(school_id,created_by) references public.school_memberships(school_id,id) on delete restrict
);
create table public.student_weekly_reports (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, template_id uuid not null,
  student_id uuid not null, class_id uuid not null, teacher_id uuid not null,
  week_start date not null, answers jsonb not null default '{}'::jsonb, status text not null default 'draft' check(status in ('draft','submitted','returned','approved','published')),
  submitted_at timestamptz, reviewed_by uuid, reviewed_at timestamptz, review_comment text,
  published_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(school_id,id), unique(school_id,template_id,student_id,week_start),
  foreign key(school_id,template_id) references public.weekly_report_templates(school_id,id) on delete restrict,
  foreign key(school_id,student_id) references public.student_profiles(school_id,id) on delete restrict,
  foreign key(school_id,class_id) references public.school_classes(school_id,id) on delete restrict,
  foreign key(school_id,teacher_id) references public.school_memberships(school_id,id) on delete restrict,
  foreign key(school_id,reviewed_by) references public.school_memberships(school_id,id) on delete restrict,
  check(jsonb_typeof(answers)='object'),
  check(status<>'published' or published_at is not null)
);
create index weekly_reports_student_week_idx on public.student_weekly_reports(school_id,student_id,week_start desc,status);

create table public.attendance_records (
  id uuid primary key default gen_random_uuid(), school_id uuid not null, class_id uuid not null, student_id uuid not null,
  attendance_date date not null, status text not null check(status in ('present','absent','late','excused')),
  note text, marked_by uuid not null, marked_at timestamptz not null default now(),
  unique(school_id,class_id,student_id,attendance_date),
  foreign key(school_id,class_id) references public.school_classes(school_id,id) on delete restrict,
  foreign key(school_id,student_id) references public.student_profiles(school_id,id) on delete restrict,
  foreign key(school_id,marked_by) references public.school_memberships(school_id,id) on delete restrict
);
create index attendance_class_date_idx on public.attendance_records(school_id,class_id,attendance_date desc);

create table public.school_notifications (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  title text not null, body text not null, audience text not null check(audience in ('school','role','class','individual')),
  target_role public.school_role, class_id uuid, created_by uuid not null,
  send_email boolean not null default false, email_status text check(email_status is null or email_status in ('not_requested','queued','sent','failed')),
  published_at timestamptz, created_at timestamptz not null default now(),
  unique(school_id,id), foreign key(school_id,class_id) references public.school_classes(school_id,id) on delete restrict,
  foreign key(school_id,created_by) references public.school_memberships(school_id,id) on delete restrict
);
create table public.notification_recipients (
  school_id uuid not null, notification_id uuid not null, membership_id uuid not null,
  read_at timestamptz, created_at timestamptz not null default now(), primary key(notification_id,membership_id),
  foreign key(school_id,notification_id) references public.school_notifications(school_id,id) on delete cascade,
  foreign key(school_id,membership_id) references public.school_memberships(school_id,id) on delete restrict
);
create index notification_recipients_inbox_idx on public.notification_recipients(school_id,membership_id,created_at desc);

create table public.payment_webhook_events (
  id uuid primary key default gen_random_uuid(), provider text not null, provider_event_id text not null,
  event_type text not null, payload jsonb not null, received_at timestamptz not null default now(), processed_at timestamptz,
  processing_error text, unique(provider,provider_event_id)
);
create table public.school_payments (
  id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id) on delete restrict,
  provider text not null, provider_payment_id text not null, amount_minor bigint not null check(amount_minor >= 0),
  currency char(3) not null default 'NGN', status text not null check(status in ('pending','succeeded','failed','refunded')),
  paid_at timestamptz, created_at timestamptz not null default now(), unique(provider,provider_payment_id)
);
create index school_payments_school_created_idx on public.school_payments(school_id,created_at desc);

-- No client receives payment writes. Verified webhook handlers use the service role on the server.
alter table public.payment_webhook_events enable row level security;
alter table public.school_payments enable row level security;
grant select on public.school_payments to authenticated;
create policy "members read school payments" on public.school_payments for select to authenticated using (public.is_school_member(school_id));

alter table public.assessments enable row level security;
alter table public.assessment_questions enable row level security;
alter table public.assessment_answer_keys enable row level security;
alter table public.assessment_attempts enable row level security;
alter table public.assessment_responses enable row level security;
alter table public.subject_results enable row level security;
alter table public.result_review_events enable row level security;
alter table public.weekly_report_templates enable row level security;
alter table public.student_weekly_reports enable row level security;
alter table public.attendance_records enable row level security;
alter table public.school_notifications enable row level security;
alter table public.notification_recipients enable row level security;

-- ===== END 202610130003_assessments_results_reports.sql =====

-- ===== BEGIN 202610130004_security_policies.sql =====
-- Authorization predicates and RLS policies for all operational records.
create or replace function public.is_self_membership(target_membership uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.school_memberships m where m.id=target_membership and m.user_id=auth.uid() and m.status='active')
$$;
create or replace function public.can_access_student(target_school uuid,target_student uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select public.has_school_permission(target_school,'view_students')
   or public.is_self_student(target_student)
   or public.is_linked_guardian(target_student)
   or exists(select 1 from public.class_enrollments e join public.school_classes c on c.id=e.class_id and c.school_id=e.school_id join public.student_profiles s on s.id=e.student_id and s.school_id=e.school_id where e.school_id=target_school and e.student_id=target_student and e.status='active' and public.is_assigned_teacher(target_school,c.id,null))
$$;
create or replace function public.can_access_assessment(target_assessment uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.assessments a where a.id=target_assessment and (
   public.has_school_permission(a.school_id,'view_assessments') or public.is_assigned_teacher(a.school_id,a.class_id,a.subject_id)
   or (a.status in ('published','closed') and public.is_enrolled_student(a.school_id,a.class_id))))
$$;
create or replace function public.can_edit_assessment(target_assessment uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.assessments a where a.id=target_assessment and a.status='draft' and
   (public.has_school_permission(a.school_id,'manage_assessments') or public.is_assigned_teacher(a.school_id,a.class_id,a.subject_id)))
$$;
create or replace function public.can_start_assessment(target_assessment uuid,target_student uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.assessments a where a.id=target_assessment and a.status='published'
   and (a.starts_at is null or a.starts_at <= now()) and (a.ends_at is null or a.ends_at > now())
   and public.is_self_student(target_student) and public.is_enrolled_student(a.school_id,a.class_id)
   and (select count(*) from public.assessment_attempts at where at.assessment_id=a.id and at.student_id=target_student and at.status<>'voided') < a.max_attempts)
$$;
create or replace function public.can_access_attempt(target_school uuid,target_attempt uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.assessment_attempts at join public.assessments a on a.id=at.assessment_id and a.school_id=at.school_id
   where at.id=target_attempt and at.school_id=target_school and (public.is_self_student(at.student_id)
     or public.has_school_permission(target_school,'view_results') or public.has_school_permission(target_school,'review_results') or public.has_school_permission(target_school,'manage_assessments')
     or public.is_assigned_teacher(a.school_id,a.class_id,a.subject_id)))
$$;
create or replace function public.is_open_student_attempt(target_school uuid,target_attempt uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.assessment_attempts at where at.id=target_attempt and at.school_id=target_school and at.status='in_progress' and public.is_self_student(at.student_id))
$$;
create or replace function public.can_mark_attempt(target_school uuid,target_attempt uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.assessment_attempts at join public.assessments a on a.id=at.assessment_id and a.school_id=at.school_id where at.id=target_attempt and at.school_id=target_school and (public.has_school_permission(target_school,'review_results') or public.is_assigned_teacher(target_school,a.class_id,a.subject_id)))
$$;
create or replace function public.can_review_class_subject(target_school uuid,target_class uuid,target_subject uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select public.has_school_permission(target_school,'view_results') or public.has_school_permission(target_school,'review_results') or public.has_school_permission(target_school,'approve_results') or public.is_assigned_teacher(target_school,target_class,target_subject)
$$;
create or replace function public.can_access_weekly_report(target_school uuid,target_report uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.student_weekly_reports r where r.id=target_report and r.school_id=target_school and
   ((r.status='published' and (public.is_self_student(r.student_id) or public.is_linked_guardian(r.student_id)))
    or public.has_school_permission(target_school,'view_reports')
    or public.is_assigned_teacher(target_school,r.class_id,null)))
$$;
create or replace function public.is_notification_recipient(target_school uuid,target_notification uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.notification_recipients nr join public.school_memberships m on m.id=nr.membership_id and m.school_id=nr.school_id join public.school_notifications n on n.id=nr.notification_id and n.school_id=nr.school_id where nr.school_id=target_school and nr.notification_id=target_notification and n.published_at is not null and m.user_id=auth.uid() and m.status='active')
$$;
create or replace function public.can_read_membership(target_school uuid,target_membership uuid)
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.school_memberships target where target.school_id=target_school and target.id=target_membership and
   (target.user_id=auth.uid() or public.has_school_permission(target_school,'view_staff') or public.has_school_permission(target_school,'view_students') or public.has_school_permission(target_school,'view_parents')
    or exists(select 1 from public.student_profiles s join public.class_enrollments e on e.school_id=s.school_id and e.student_id=s.id where s.school_id=target_school and s.membership_id=target.id and e.status='active' and public.is_assigned_teacher(target_school,e.class_id,null))
    or exists(select 1 from public.guardian_profiles g join public.student_guardians sg on sg.school_id=g.school_id and sg.guardian_id=g.id where g.school_id=target_school and g.membership_id=target.id and public.is_linked_guardian(sg.student_id))))
$$;
revoke all on function public.is_self_membership(uuid),public.can_access_student(uuid,uuid),public.can_access_assessment(uuid),public.can_edit_assessment(uuid),public.can_start_assessment(uuid,uuid),public.can_access_attempt(uuid,uuid),public.is_open_student_attempt(uuid,uuid),public.can_mark_attempt(uuid,uuid),public.can_review_class_subject(uuid,uuid,uuid),public.can_access_weekly_report(uuid,uuid),public.is_notification_recipient(uuid,uuid),public.can_read_membership(uuid,uuid) from public;
grant execute on function public.is_self_membership(uuid),public.can_access_student(uuid,uuid),public.can_access_assessment(uuid),public.can_edit_assessment(uuid),public.can_start_assessment(uuid,uuid),public.can_access_attempt(uuid,uuid),public.is_open_student_attempt(uuid,uuid),public.can_mark_attempt(uuid,uuid),public.can_review_class_subject(uuid,uuid,uuid),public.can_access_weekly_report(uuid,uuid),public.is_notification_recipient(uuid,uuid),public.can_read_membership(uuid,uuid) to authenticated;

drop policy if exists "members read memberships" on public.school_memberships;
create policy "users read permitted memberships" on public.school_memberships for select to authenticated using(public.can_read_membership(school_id,id));
drop policy if exists "members read subscription" on public.school_subscriptions;
create policy "billing managers read subscription" on public.school_subscriptions for select to authenticated using(public.has_school_permission(school_id,'manage_billing'));
drop policy if exists "members read school payments" on public.school_payments;
create policy "billing managers read school payments" on public.school_payments for select to authenticated using(public.has_school_permission(school_id,'manage_billing'));
drop policy if exists "owners update their school" on public.schools;
create policy "school managers update profile" on public.schools for update to authenticated using(public.has_school_permission(id,'manage_school_settings')) with check(public.has_school_permission(id,'manage_school_settings') and status='active');
drop policy if exists "owners manage academic config" on public.academic_settings;
create policy "academic managers manage config" on public.academic_settings for all to authenticated using(public.has_school_permission(school_id,'manage_academics')) with check(public.has_school_permission(school_id,'manage_academics'));
drop policy if exists "owners manage classes" on public.school_classes;
create policy "class managers maintain classes" on public.school_classes for all to authenticated using(public.has_school_permission(school_id,'manage_classes')) with check(public.has_school_permission(school_id,'manage_classes'));
drop policy if exists "owners manage subjects" on public.school_subjects;
create policy "subject managers maintain subjects" on public.school_subjects for all to authenticated using(public.has_school_permission(school_id,'manage_subjects') or public.has_school_permission(school_id,'manage_academics')) with check(public.has_school_permission(school_id,'manage_subjects') or public.has_school_permission(school_id,'manage_academics'));

create function public.publish_assessment(target_assessment uuid)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare assessment_row public.assessments%rowtype;
begin
 select * into assessment_row from public.assessments where id=target_assessment for update;
 if not found or assessment_row.status<>'draft' then raise exception 'Assessment is not a draft'; end if;
 if not (public.has_school_permission(assessment_row.school_id,'manage_assessments') or public.is_assigned_teacher(assessment_row.school_id,assessment_row.class_id,assessment_row.subject_id)) then raise exception 'Not authorized to publish this assessment'; end if;
 if not exists(select 1 from public.assessment_questions q where q.school_id=assessment_row.school_id and q.assessment_id=assessment_row.id) then raise exception 'Add at least one question before publishing'; end if;
 if exists(select 1 from public.assessment_questions q left join public.assessment_answer_keys k on k.school_id=q.school_id and k.question_id=q.id where q.school_id=assessment_row.school_id and q.assessment_id=assessment_row.id and q.question_type in ('multiple_choice','multiple_select','true_false') and k.question_id is null) then raise exception 'Every objective question needs an answer key'; end if;
 update public.assessments set status='published',updated_at=now() where id=target_assessment;
 insert into public.audit_logs(school_id,actor_id,action,entity_type,entity_id) values(assessment_row.school_id,auth.uid(),'assessment.published','assessment',target_assessment);
end $$;

create function public.submit_assessment_attempt(target_attempt uuid)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare attempt_row public.assessment_attempts%rowtype; q record; correct boolean; fully_objective boolean:=true; final_score numeric(8,2); actual_values text[]; expected_values text[];
begin
 select * into attempt_row from public.assessment_attempts where id=target_attempt for update;
 if not found or attempt_row.status<>'in_progress' or not public.is_self_student(attempt_row.student_id) then raise exception 'Attempt cannot be submitted by this user'; end if;
 for q in select question.id,question.question_type,question.points,key.expected_answer,key.case_sensitive,coalesce(response.response,'null'::jsonb) as response from public.assessment_questions question left join public.assessment_answer_keys key on key.school_id=question.school_id and key.question_id=question.id left join public.assessment_responses response on response.school_id=question.school_id and response.attempt_id=attempt_row.id and response.question_id=question.id where question.school_id=attempt_row.school_id and question.assessment_id=attempt_row.assessment_id loop
   insert into public.assessment_responses(school_id,assessment_id,attempt_id,question_id,response)
   values(attempt_row.school_id,attempt_row.assessment_id,attempt_row.id,q.id,q.response) on conflict(school_id,attempt_id,question_id) do nothing;
   if q.question_type in ('multiple_choice','multiple_select','true_false') then
     if q.question_type='multiple_select' and jsonb_typeof(q.response)='array' and jsonb_typeof(q.expected_answer)='array' then
       select coalesce(array_agg(value order by value),array[]::text[]) into actual_values from jsonb_array_elements_text(q.response) as answer(value);
       select coalesce(array_agg(value order by value),array[]::text[]) into expected_values from jsonb_array_elements_text(q.expected_answer) as key(value);
       correct:=actual_values=expected_values;
     else
       correct:=q.response=q.expected_answer;
     end if;
     insert into public.assessment_responses(school_id,assessment_id,attempt_id,question_id,response,awarded_points,marked_by)
     values(attempt_row.school_id,attempt_row.assessment_id,attempt_row.id,q.id,q.response,case when correct then q.points else 0 end,null)
     on conflict(school_id,attempt_id,question_id) do update set awarded_points=excluded.awarded_points,marked_by=null,saved_at=now();
   else
     fully_objective:=false;
   end if;
 end loop;
 if fully_objective then
   select coalesce(sum(awarded_points),0) into final_score from public.assessment_responses where school_id=attempt_row.school_id and attempt_id=attempt_row.id;
   update public.assessment_attempts set status='graded',submitted_at=now(),score=final_score,graded_at=now() where id=target_attempt;
 else
   update public.assessment_attempts set status='submitted',submitted_at=now() where id=target_attempt;
 end if;
end $$;

create function public.mark_assessment_response(target_response uuid,points numeric,comment_text text default null)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare response_row public.assessment_responses%rowtype; max_points numeric; attempt_row public.assessment_attempts%rowtype; q record; all_marked boolean; final_score numeric(8,2); marker uuid;
begin
 select * into response_row from public.assessment_responses where id=target_response;
 if not found then raise exception 'Response not found'; end if;
 select question.points into max_points from public.assessment_questions question where question.school_id=response_row.school_id and question.id=response_row.question_id;
 if points<0 or points>max_points then raise exception 'Points are outside the question range'; end if;
 select * into attempt_row from public.assessment_attempts where id=response_row.attempt_id for update;
 if attempt_row.status not in ('submitted','graded') or not public.can_mark_attempt(response_row.school_id,response_row.attempt_id) then raise exception 'Not authorized to mark this response'; end if;
 select id into marker from public.school_memberships where user_id=auth.uid() and school_id=response_row.school_id and status='active' limit 1;
 update public.assessment_responses set awarded_points=points,marker_comment=comment_text,marked_by=marker,saved_at=now() where id=target_response;
 select not exists(select 1 from public.assessment_questions question left join public.assessment_responses response on response.school_id=question.school_id and response.question_id=question.id and response.attempt_id=attempt_row.id where question.school_id=attempt_row.school_id and question.assessment_id=attempt_row.assessment_id and response.awarded_points is null) into all_marked;
 if all_marked then
   select coalesce(sum(awarded_points),0) into final_score from public.assessment_responses where school_id=attempt_row.school_id and attempt_id=attempt_row.id;
   update public.assessment_attempts set status='graded',score=final_score,graded_by=marker,graded_at=now() where id=attempt_row.id;
 end if;
end $$;

create function public.review_subject_result(target_result uuid,decision text,comment_text text default null)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare result_row public.subject_results%rowtype; reviewer uuid;
begin
 select * into result_row from public.subject_results where id=target_result for update;
 if not found then raise exception 'Result not found'; end if;
 select id into reviewer from public.school_memberships where user_id=auth.uid() and school_id=result_row.school_id and status='active' and (role='owner' or (role='administrator' and (permissions->>'approve_results'='true' or permissions->>'review_results'='true' or permissions->>'publish_results'='true'))) limit 1;
 if reviewer is null then raise exception 'Not authorized to review results'; end if;
 if decision not in ('approved','returned','published') then raise exception 'Unsupported result decision'; end if;
 if decision in ('approved','returned') and result_row.status<>'submitted' then raise exception 'Only submitted results can be reviewed'; end if;
 if decision='published' and (result_row.status<>'approved' or not public.has_school_permission(result_row.school_id,'publish_results')) then raise exception 'Only an authorized publisher can publish approved results'; end if;
 if result_row.total_score is null and decision in ('approved','published') then raise exception 'A result needs a total score before approval'; end if;
 update public.subject_results set status=decision,reviewed_by=reviewer,reviewed_at=now(),review_comment=comment_text,published_at=case when decision='published' then now() else null end,updated_at=now() where id=target_result;
 insert into public.result_review_events(school_id,result_id,reviewer_id,decision,comment) values(result_row.school_id,target_result,reviewer,decision,comment_text);
 insert into public.audit_logs(school_id,actor_id,action,entity_type,entity_id,details) values(result_row.school_id,auth.uid(),'result.'||decision,'subject_result',target_result,jsonb_build_object('comment',comment_text));
end $$;

create function public.review_weekly_report(target_report uuid,decision text,comment_text text default null)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare report_row public.student_weekly_reports%rowtype; reviewer uuid;
begin
 select * into report_row from public.student_weekly_reports where id=target_report for update;
 if not found then raise exception 'Report not found'; end if;
 select id into reviewer from public.school_memberships where user_id=auth.uid() and school_id=report_row.school_id and status='active' and (role='owner' or (role='administrator' and (permissions->>'approve_reports'='true' or permissions->>'manage_reports'='true'))) limit 1;
 if reviewer is null then raise exception 'Not authorized to review reports'; end if;
 if decision in ('approved','returned') and report_row.status<>'submitted' then raise exception 'Only submitted reports can be reviewed'; end if;
 if decision='published' and report_row.status<>'approved' then raise exception 'Only approved reports can be published'; end if;
 if decision not in ('approved','returned','published') then raise exception 'Unsupported report decision'; end if;
 update public.student_weekly_reports set status=decision,reviewed_by=reviewer,reviewed_at=now(),review_comment=comment_text,published_at=case when decision='published' then now() else null end,updated_at=now() where id=target_report;
 insert into public.audit_logs(school_id,actor_id,action,entity_type,entity_id,details) values(report_row.school_id,auth.uid(),'weekly_report.'||decision,'student_weekly_report',target_report,jsonb_build_object('comment',comment_text));
end $$;

create function public.submit_subject_result(target_result uuid)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare result_row public.subject_results%rowtype;
begin
 select * into result_row from public.subject_results where id=target_result for update;
 if not found or result_row.status not in ('draft','returned') or not public.is_self_membership(result_row.entered_by) or not public.is_assigned_teacher(result_row.school_id,result_row.class_id,result_row.subject_id) then raise exception 'Result cannot be submitted by this user'; end if;
 if result_row.total_score is null or result_row.grade is null then raise exception 'Enter the total score and grade before submitting'; end if;
 update public.subject_results set status='submitted',submitted_at=now(),updated_at=now() where id=target_result;
 insert into public.audit_logs(school_id,actor_id,action,entity_type,entity_id) values(result_row.school_id,auth.uid(),'result.submitted','subject_result',target_result);
end $$;

create function public.submit_weekly_report(target_report uuid)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare report_row public.student_weekly_reports%rowtype; incomplete boolean;
begin
 select * into report_row from public.student_weekly_reports where id=target_report for update;
 if not found or report_row.status not in ('draft','returned') or not public.is_self_membership(report_row.teacher_id) or not public.is_assigned_teacher(report_row.school_id,report_row.class_id,null) then raise exception 'Report cannot be submitted by this user'; end if;
 select exists(select 1 from jsonb_array_elements((select t.questions from public.weekly_report_templates t where t.id=report_row.template_id and t.school_id=report_row.school_id)) as required_question(value)
   where coalesce((required_question.value->>'required')::boolean,false) and
   (nullif(required_question.value->>'key','') is null or not (report_row.answers ? (required_question.value->>'key')) or nullif(trim(report_row.answers->>(required_question.value->>'key')),'') is null or report_row.answers->(required_question.value->>'key')='[]'::jsonb)) into incomplete;
 if incomplete then raise exception 'Complete all required report questions before submitting'; end if;
 update public.student_weekly_reports set status='submitted',submitted_at=now(),updated_at=now() where id=target_report;
 insert into public.audit_logs(school_id,actor_id,action,entity_type,entity_id) values(report_row.school_id,auth.uid(),'weekly_report.submitted','student_weekly_report',target_report);
end $$;

create function public.accept_school_invitation(invitation_id uuid,invitation_token text)
returns uuid language plpgsql security definer set search_path=public,extensions,auth,pg_temp as $$
declare invite public.school_invitations%rowtype; membership uuid; verified_email text;
begin
 if auth.uid() is null or coalesce(invitation_token,'')='' then raise exception 'Sign in and provide a valid invitation'; end if;
 select lower(email) into verified_email from auth.users where id=auth.uid() and email_confirmed_at is not null;
 select * into invite from public.school_invitations where id=invitation_id and token_hash=encode(digest(invitation_token,'sha256'),'hex') and lower(email)=verified_email and accepted_at is null and revoked_at is null and expires_at>now() for update;
 if not found then raise exception 'Invitation is invalid, expired, or already used'; end if;
 insert into public.school_memberships(school_id,user_id,role,status,permissions) values(invite.school_id,auth.uid(),invite.role,'active',invite.permissions) returning id into membership;
 update public.school_invitations set accepted_at=now() where id=invite.id;
 return membership;
end $$;

revoke all on function public.publish_assessment(uuid),public.submit_assessment_attempt(uuid),public.mark_assessment_response(uuid,numeric,text),public.submit_subject_result(uuid),public.review_subject_result(uuid,text,text),public.submit_weekly_report(uuid),public.review_weekly_report(uuid,text,text),public.accept_school_invitation(uuid,text) from public;
grant execute on function public.publish_assessment(uuid),public.submit_assessment_attempt(uuid),public.mark_assessment_response(uuid,numeric,text),public.submit_subject_result(uuid),public.review_subject_result(uuid,text,text),public.submit_weekly_report(uuid),public.review_weekly_report(uuid,text,text),public.accept_school_invitation(uuid,text) to authenticated;

-- Academic configuration is visible to school members and editable by owners or delegated admins.
create policy "members read sessions" on public.academic_sessions for select to authenticated using(public.is_school_member(school_id));
create policy "academic managers maintain sessions" on public.academic_sessions for all to authenticated using(public.has_school_permission(school_id,'manage_academics')) with check(public.has_school_permission(school_id,'manage_academics'));
create policy "members read periods" on public.academic_periods for select to authenticated using(public.is_school_member(school_id));
create policy "academic managers maintain periods" on public.academic_periods for all to authenticated using(public.has_school_permission(school_id,'manage_academics')) with check(public.has_school_permission(school_id,'manage_academics'));
create policy "members read calendar" on public.school_calendar_events for select to authenticated using(public.is_school_member(school_id) and (audience='school' or public.has_school_permission(school_id,'manage_academics') or public.is_assigned_teacher(school_id,class_id,null) or (class_id is not null and public.is_enrolled_student(school_id,class_id))));
create policy "academic managers maintain calendar" on public.school_calendar_events for all to authenticated using(public.has_school_permission(school_id,'manage_academics')) with check(public.has_school_permission(school_id,'manage_academics'));

-- Staff, student, guardian, roster and teacher assignment access.
create policy "staff can read own profile or permitted staff" on public.staff_profiles for select to authenticated using(public.is_self_membership(membership_id) or public.has_school_permission(school_id,'view_staff'));
create policy "staff managers create profiles" on public.staff_profiles for insert to authenticated with check(public.has_school_permission(school_id,'manage_staff'));
create policy "staff managers update profiles" on public.staff_profiles for update to authenticated using(public.has_school_permission(school_id,'manage_staff')) with check(public.has_school_permission(school_id,'manage_staff'));
create policy "student and authorized school access" on public.student_profiles for select to authenticated using(public.can_access_student(school_id,id));
create policy "student managers create profiles" on public.student_profiles for insert to authenticated with check(public.has_school_permission(school_id,'manage_students'));
create policy "student managers update profiles" on public.student_profiles for update to authenticated using(public.has_school_permission(school_id,'manage_students')) with check(public.has_school_permission(school_id,'manage_students'));
create policy "guardians read own or managed profile" on public.guardian_profiles for select to authenticated using(public.is_self_membership(membership_id) or public.has_school_permission(school_id,'view_parents'));
create policy "parent managers create profiles" on public.guardian_profiles for insert to authenticated with check(public.has_school_permission(school_id,'manage_parents'));
create policy "parent managers update profiles" on public.guardian_profiles for update to authenticated using(public.has_school_permission(school_id,'manage_parents')) with check(public.has_school_permission(school_id,'manage_parents'));
create policy "student related guardian links readable" on public.student_guardians for select to authenticated using(public.can_access_student(school_id,student_id) or public.has_school_permission(school_id,'view_parents'));
create policy "parent managers maintain guardian links" on public.student_guardians for all to authenticated using(public.has_school_permission(school_id,'manage_parents')) with check(public.has_school_permission(school_id,'manage_parents'));
create policy "class roster readable by relevant users" on public.class_enrollments for select to authenticated using(public.can_access_student(school_id,student_id) or public.is_assigned_teacher(school_id,class_id,null) or public.has_school_permission(school_id,'view_students'));
create policy "student managers maintain enrollment" on public.class_enrollments for all to authenticated using(public.has_school_permission(school_id,'manage_students') or public.has_school_permission(school_id,'manage_classes')) with check(public.has_school_permission(school_id,'manage_students') or public.has_school_permission(school_id,'manage_classes'));
create policy "teachers read own assignments" on public.teacher_assignments for select to authenticated using(public.is_self_membership((select membership_id from public.staff_profiles where id=staff_id and school_id=teacher_assignments.school_id)) or public.has_school_permission(school_id,'view_staff'));
create policy "staff managers maintain assignments" on public.teacher_assignments for all to authenticated using(public.has_school_permission(school_id,'manage_staff')) with check(public.has_school_permission(school_id,'manage_staff'));
create policy "authorized owners read invitations" on public.school_invitations for select to authenticated using(public.has_school_permission(school_id,case when role='parent' then 'manage_parents' else 'manage_staff' end));

-- Grading and assessment settings.
create policy "members read grading scales" on public.grading_scales for select to authenticated using(public.is_school_member(school_id));
create policy "academic managers maintain grading scales" on public.grading_scales for all to authenticated using(public.has_school_permission(school_id,'manage_academics')) with check(public.has_school_permission(school_id,'manage_academics'));
create policy "members read grading bands" on public.grading_scale_bands for select to authenticated using(public.is_school_member(school_id));
create policy "academic managers maintain grading bands" on public.grading_scale_bands for all to authenticated using(public.has_school_permission(school_id,'manage_academics')) with check(public.has_school_permission(school_id,'manage_academics'));
create policy "members read assessment categories" on public.assessment_categories for select to authenticated using(public.is_school_member(school_id));
create policy "academic managers maintain categories" on public.assessment_categories for all to authenticated using(public.has_school_permission(school_id,'manage_academics')) with check(public.has_school_permission(school_id,'manage_academics'));
create policy "authorized assessment readers" on public.assessments for select to authenticated using(public.can_access_assessment(id));
create policy "authorized teachers create assessment drafts" on public.assessments for insert to authenticated with check(status='draft' and (public.has_school_permission(school_id,'manage_assessments') or public.is_assigned_teacher(school_id,class_id,subject_id)) and public.is_self_membership(created_by));
create policy "assessment authors edit drafts" on public.assessments for update to authenticated using(public.can_edit_assessment(id)) with check(public.can_edit_assessment(id));
create policy "authorized users read questions" on public.assessment_questions for select to authenticated using(public.can_access_assessment(assessment_id));
create policy "authorized teachers create questions" on public.assessment_questions for insert to authenticated with check(public.can_edit_assessment(assessment_id));
create policy "authorized teachers update questions" on public.assessment_questions for update to authenticated using(public.can_edit_assessment(assessment_id)) with check(public.can_edit_assessment(assessment_id));
create policy "authorized teachers remove draft questions" on public.assessment_questions for delete to authenticated using(public.can_edit_assessment(assessment_id));
create policy "only staff can read answer keys" on public.assessment_answer_keys for select to authenticated using(public.can_edit_assessment((select assessment_id from public.assessment_questions q where q.id=question_id and q.school_id=assessment_answer_keys.school_id)) or exists(select 1 from public.assessment_questions q join public.assessments a on a.id=q.assessment_id and a.school_id=q.school_id where q.id=question_id and q.school_id=assessment_answer_keys.school_id and (public.has_school_permission(a.school_id,'review_results') or public.is_assigned_teacher(a.school_id,a.class_id,a.subject_id))));
create policy "authorized teachers manage answer keys" on public.assessment_answer_keys for all to authenticated using(public.can_edit_assessment((select assessment_id from public.assessment_questions q where q.id=question_id and q.school_id=assessment_answer_keys.school_id))) with check(public.can_edit_assessment((select assessment_id from public.assessment_questions q where q.id=question_id and q.school_id=assessment_answer_keys.school_id)));

-- Student attempts cannot be directly changed by students after creation; answer keys are not readable by student roles.
create policy "students and markers read attempts" on public.assessment_attempts for select to authenticated using(public.can_access_attempt(school_id,id));
create policy "eligible students start attempts" on public.assessment_attempts for insert to authenticated with check(status='in_progress' and submitted_at is null and score is null and public.can_start_assessment(assessment_id,student_id));
create policy "attempt owners and markers read answers" on public.assessment_responses for select to authenticated using(public.can_access_attempt(school_id,attempt_id));
create policy "students save own in progress answers" on public.assessment_responses for insert to authenticated with check(public.is_open_student_attempt(school_id,attempt_id));
create policy "students update own in progress answers" on public.assessment_responses for update to authenticated using(public.is_open_student_attempt(school_id,attempt_id)) with check(public.is_open_student_attempt(school_id,attempt_id));

-- Results: teachers submit assigned records; authorized administrators review and publish.
create policy "authorized users read results" on public.subject_results for select to authenticated using((status='published' and public.can_access_student(school_id,student_id)) or public.can_review_class_subject(school_id,class_id,subject_id));
create policy "assigned teachers enter result drafts" on public.subject_results for insert to authenticated with check(status='draft' and (public.has_school_permission(school_id,'review_results') or public.is_assigned_teacher(school_id,class_id,subject_id)) and public.is_self_membership(entered_by) and (public.has_school_permission(school_id,'review_results') or exists(select 1 from public.class_enrollments e where e.school_id=subject_results.school_id and e.class_id=subject_results.class_id and e.student_id=subject_results.student_id and e.status='active')));
create policy "assigned teachers edit unreviewed results" on public.subject_results for update to authenticated using(status in ('draft','returned') and public.is_assigned_teacher(school_id,class_id,subject_id)) with check(status='draft' and public.is_assigned_teacher(school_id,class_id,subject_id));
create policy "authorized users read review history" on public.result_review_events for select to authenticated using(public.has_school_permission(school_id,'review_results') or public.has_school_permission(school_id,'approve_results') or public.is_assigned_teacher(school_id,(select class_id from public.subject_results r where r.id=result_id and r.school_id=result_review_events.school_id),(select subject_id from public.subject_results r where r.id=result_id and r.school_id=result_review_events.school_id)));

-- Reports and attendance retain school-specific access; families see only published child records.
create policy "members read active report templates" on public.weekly_report_templates for select to authenticated using(public.is_school_member(school_id) and (is_active or public.has_school_permission(school_id,'manage_reports')));
create policy "report managers maintain templates" on public.weekly_report_templates for all to authenticated using(public.has_school_permission(school_id,'manage_reports')) with check(public.has_school_permission(school_id,'manage_reports') and public.is_self_membership(created_by));
create policy "authorized users read weekly reports" on public.student_weekly_reports for select to authenticated using(public.can_access_weekly_report(school_id,id));
create policy "assigned teachers create report drafts" on public.student_weekly_reports for insert to authenticated with check(status='draft' and public.is_self_membership(teacher_id) and public.is_assigned_teacher(school_id,class_id,null) and exists(select 1 from public.class_enrollments e where e.school_id=student_weekly_reports.school_id and e.class_id=student_weekly_reports.class_id and e.student_id=student_weekly_reports.student_id and e.status='active'));
create policy "teachers edit draft reports" on public.student_weekly_reports for update to authenticated using(status in ('draft','returned') and public.is_self_membership(teacher_id) and public.is_assigned_teacher(school_id,class_id,null)) with check(status='draft' and public.is_self_membership(teacher_id) and public.is_assigned_teacher(school_id,class_id,null));
create policy "authorized users read attendance" on public.attendance_records for select to authenticated using(public.can_access_student(school_id,student_id) or public.is_assigned_teacher(school_id,class_id,null));
create policy "teachers and managers record attendance" on public.attendance_records for insert to authenticated with check(public.is_self_membership(marked_by) and (public.has_school_permission(school_id,'manage_attendance') or public.is_assigned_teacher(school_id,class_id,null)) and exists(select 1 from public.class_enrollments e where e.school_id=attendance_records.school_id and e.class_id=attendance_records.class_id and e.student_id=attendance_records.student_id and e.status='active'));
create policy "attendance corrections by authorized teachers" on public.attendance_records for update to authenticated using(public.has_school_permission(school_id,'manage_attendance') or public.is_assigned_teacher(school_id,class_id,null)) with check(public.has_school_permission(school_id,'manage_attendance') or public.is_assigned_teacher(school_id,class_id,null));

-- Notices are visible to targeted recipients and permitted school managers.
create policy "recipients read own notifications" on public.school_notifications for select to authenticated using(public.is_notification_recipient(school_id,id) or public.has_school_permission(school_id,'send_notifications'));
create policy "authorized users create notifications" on public.school_notifications for insert to authenticated with check(public.has_school_permission(school_id,'send_notifications') and public.is_self_membership(created_by));
create policy "authorized users publish notifications" on public.school_notifications for update to authenticated using(public.has_school_permission(school_id,'send_notifications')) with check(public.has_school_permission(school_id,'send_notifications'));
create policy "recipients read own inbox" on public.notification_recipients for select to authenticated using(public.is_self_membership(membership_id));
create policy "notification managers assign recipients" on public.notification_recipients for insert to authenticated with check(public.has_school_permission(school_id,'send_notifications'));
create policy "recipients mark notices read" on public.notification_recipients for update to authenticated using(public.is_self_membership(membership_id)) with check(public.is_self_membership(membership_id));

-- Replace the starter broad audit read rule with a permission-controlled policy.
drop policy if exists "members read audit logs" on public.audit_logs;
create policy "authorized users read audit logs" on public.audit_logs for select to authenticated using(public.has_school_permission(school_id,'view_audit_logs'));

-- Explicit grants prevent default Supabase schema privileges from exposing sensitive fields.
revoke all on public.academic_sessions,public.academic_periods,public.school_calendar_events,public.staff_profiles,public.student_profiles,public.guardian_profiles,public.student_guardians,public.class_enrollments,public.teacher_assignments,public.school_invitations,public.grading_scales,public.grading_scale_bands,public.assessment_categories,public.assessments,public.assessment_questions,public.assessment_answer_keys,public.assessment_attempts,public.assessment_responses,public.subject_results,public.result_review_events,public.weekly_report_templates,public.student_weekly_reports,public.attendance_records,public.school_notifications,public.notification_recipients,public.payment_webhook_events,public.school_payments from anon,authenticated;

grant select,insert,update,delete on public.academic_sessions,public.academic_periods,public.school_calendar_events to authenticated;
grant select,insert,update on public.staff_profiles to authenticated;
grant select(school_id,id,membership_id,student_code,date_of_birth,enrolled_on,status,created_at,updated_at) on public.student_profiles to authenticated;
grant insert(school_id,membership_id,student_code,date_of_birth,enrolled_on,status) on public.student_profiles to authenticated;
revoke update on public.student_profiles from authenticated;
grant update(date_of_birth,enrolled_on,status) on public.student_profiles to authenticated;
grant select,insert,update on public.guardian_profiles,public.student_guardians,public.class_enrollments,public.teacher_assignments to authenticated;
grant select (school_id,id,email,role,permissions,invited_by,expires_at,accepted_at,revoked_at,created_at) on public.school_invitations to authenticated;
grant select,insert,update,delete on public.grading_scales,public.grading_scale_bands,public.assessment_categories to authenticated;
grant select,insert,update on public.assessments to authenticated;
grant select,insert,update,delete on public.assessment_questions to authenticated;
grant select,insert,update,delete on public.assessment_answer_keys to authenticated;
grant select,insert on public.assessment_attempts to authenticated;
grant select on public.assessment_responses to authenticated;
grant insert(school_id,assessment_id,attempt_id,question_id,response),update(response) on public.assessment_responses to authenticated;
grant select on public.subject_results to authenticated;
grant insert(school_id,session_id,period_id,class_id,subject_id,student_id,entered_by,continuous_assessment,examination,total_score,grade,teacher_comment,status,submitted_at),update(continuous_assessment,examination,total_score,grade,teacher_comment,status,submitted_at,updated_at) on public.subject_results to authenticated;
grant select on public.result_review_events to authenticated;
grant select,insert,update,delete on public.weekly_report_templates to authenticated;
grant select on public.student_weekly_reports to authenticated;
grant insert(school_id,template_id,student_id,class_id,teacher_id,week_start,answers,status,submitted_at),update(answers,status,submitted_at,updated_at) on public.student_weekly_reports to authenticated;
grant select,insert on public.attendance_records to authenticated;
grant update(status,note) on public.attendance_records to authenticated;
grant select,insert,update on public.school_notifications to authenticated;
grant select on public.notification_recipients to authenticated;
grant insert(school_id,notification_id,membership_id) on public.notification_recipients to authenticated;
grant update(read_at) on public.notification_recipients to authenticated;
grant select on public.school_payments to authenticated;
-- Webhook inbox, invitation issuance, passcode hashing, assessment grading and provider payment writes remain server-only.
revoke all on public.payment_webhook_events from anon,authenticated;
revoke all on public.assessment_answer_keys from anon;
revoke all on public.school_invitations from anon;

-- ===== END 202610130004_security_policies.sql =====

-- ===== BEGIN 202610130005_catalogs_platform_admin.sql =====
-- Global reference catalogs and the isolated platform-operator identity boundary.
create table public.permission_definitions (
  permission_key text primary key, label text not null, description text not null, permission_group text not null,
  applies_to text[] not null default array['administrator']::text[], sequence integer not null unique
);
create table public.subscription_plans (
  plan_code text primary key check(plan_code in ('trial','starter','growth','enterprise')),
  name text not null, description text not null, currency char(3) not null default 'NGN',
  billing_interval text not null check(billing_interval in ('month','year','trial')),
  price_minor bigint check(price_minor is null or price_minor >= 0), trial_months integer not null default 0 check(trial_months >= 0),
  entitlements jsonb not null default '{}'::jsonb, is_public boolean not null default true, is_active boolean not null default true,
  updated_at timestamptz not null default now(), check(jsonb_typeof(entitlements)='object')
);
create table public.grading_presets (
  preset_code text primary key, name text not null, description text not null, bands jsonb not null,
  is_public boolean not null default true, check(jsonb_typeof(bands)='array')
);
create table public.assessment_category_presets (
  preset_code text primary key, name text not null, description text not null, categories jsonb not null,
  is_public boolean not null default true, check(jsonb_typeof(categories)='array')
);
create table public.weekly_report_presets (
  preset_code text primary key, name text not null, description text not null, questions jsonb not null,
  is_public boolean not null default true, check(jsonb_typeof(questions)='array')
);

create table public.platform_admins (
  user_id uuid primary key references auth.users(id) on delete restrict,
  granted_by uuid references auth.users(id) on delete set null, granted_at timestamptz not null default now(),
  revoked_at timestamptz, notes text
);
create table public.platform_admin_audit_logs (
  id uuid primary key default gen_random_uuid(), actor_id uuid not null references auth.users(id) on delete restrict,
  action text not null, entity_type text not null, entity_id uuid, details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index platform_audit_created_idx on public.platform_admin_audit_logs(created_at desc);

create or replace function public.is_platform_admin()
returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select exists(select 1 from public.platform_admins p where p.user_id=auth.uid() and p.revoked_at is null)
$$;
revoke all on function public.is_platform_admin() from public;
grant execute on function public.is_platform_admin() to authenticated;
create function public.record_platform_admin_action(action_name text,target_type text,target_id uuid,action_details jsonb default '{}'::jsonb)
returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare audit_id uuid;
begin
 if auth.uid() is null or not public.is_platform_admin() then raise exception 'Platform administrator access required'; end if;
 insert into public.platform_admin_audit_logs(actor_id,action,entity_type,entity_id,details)
 values(auth.uid(),action_name,target_type,target_id,coalesce(action_details,'{}'::jsonb)) returning id into audit_id;
 return audit_id;
end $$;
revoke all on function public.record_platform_admin_action(text,text,uuid,jsonb) from public;
grant execute on function public.record_platform_admin_action(text,text,uuid,jsonb) to authenticated;

alter table public.permission_definitions enable row level security;
alter table public.subscription_plans enable row level security;
alter table public.grading_presets enable row level security;
alter table public.assessment_category_presets enable row level security;
alter table public.weekly_report_presets enable row level security;
alter table public.platform_admins enable row level security;
alter table public.platform_admin_audit_logs enable row level security;
create policy "permission catalog is public" on public.permission_definitions for select to anon,authenticated using(true);
create policy "published plans are readable" on public.subscription_plans for select to anon,authenticated using(is_public and is_active);
create policy "published grading presets are readable" on public.grading_presets for select to authenticated using(is_public);
create policy "published category presets are readable" on public.assessment_category_presets for select to authenticated using(is_public);
create policy "published report presets are readable" on public.weekly_report_presets for select to authenticated using(is_public);
create policy "platform admins read platform audit" on public.platform_admin_audit_logs for select to authenticated using(public.is_platform_admin());
revoke all on public.permission_definitions,public.subscription_plans,public.grading_presets,public.assessment_category_presets,public.weekly_report_presets,public.platform_admins,public.platform_admin_audit_logs from anon,authenticated;
grant select on public.permission_definitions,public.subscription_plans to anon,authenticated;
grant select on public.grading_presets,public.assessment_category_presets,public.weekly_report_presets to authenticated;
grant select on public.platform_admin_audit_logs to authenticated;
-- Platform admin grants and cross-school support actions require an operator-controlled server workflow.

-- Safe reference defaults only. No real or sample schools, people, results or payments are created.
-- Prices are intentionally NULL until the operator configures and verifies a payment provider.
insert into public.permission_definitions(permission_key,label,description,permission_group,sequence) values
('manage_school_settings','Manage school settings','Edit the school profile, branding and operational settings.','school',1),
('view_students','View students','Read student profiles and permitted school rosters.','students',2),
('manage_students','Manage students','Create and update student profiles and class enrollment.','students',3),
('view_staff','View staff','Read permitted staff profiles and assignments.','staff',4),
('manage_staff','Manage staff','Manage staff profiles, assignments and staff invitations.','staff',5),
('view_parents','View parents','Read guardian profiles and approved student links.','families',6),
('manage_parents','Manage parents','Manage guardian profiles, links and parent invitations.','families',7),
('manage_classes','Manage classes','Create and update classes and class arms.','academics',8),
('manage_subjects','Manage subjects','Create and update the school subject list.','academics',9),
('manage_academics','Manage academic settings','Manage sessions, terms, grading and calendars.','academics',10),
('view_assessments','View assessments','Read authorized CBT assessments.','assessments',11),
('manage_assessments','Manage assessments','Create and edit CBT assessments before publication.','assessments',12),
('view_results','View results','Read authorized draft and published results.','results',13),
('review_results','Review results','Review submitted results and mark assessment attempts.','results',14),
('approve_results','Approve results','Approve or return submitted results.','results',15),
('publish_results','Publish results','Publish approved results to students and guardians.','results',16),
('view_reports','View reports','Read authorized weekly student reports.','reports',17),
('manage_reports','Manage reports','Configure report templates and review submissions.','reports',18),
('approve_reports','Approve reports','Approve, return or publish submitted reports.','reports',19),
('generate_report_cards','Generate report cards','Generate school-authorized report card documents.','reports',20),
('manage_attendance','Manage attendance','Record or correct attendance for assigned classes.','academics',21),
('send_notifications','Send notifications','Create school notices and assign recipients.','communication',22),
('view_audit_logs','View audit logs','Read the school activity history.','security',23),
('manage_billing','Manage billing','Read and manage subscription and payment records.','billing',24),
('use_ai','Use AI assistant','Use configured AI tools within school policy and limits.','ai',25)
on conflict(permission_key) do nothing;

insert into public.subscription_plans(plan_code,name,description,currency,billing_interval,price_minor,trial_months,entitlements) values
('trial','School trial','Eligible newly registered schools receive two months of trial access.','NGN','trial',0,2,'{"student_limit":null,"staff_limit":null,"features":[]}'),
('starter','Starter','Entry subscription tier. Configure pricing and included features before offering it.','NGN','month',null,0,'{"student_limit":null,"staff_limit":null,"features":[]}'),
('growth','Growth','Expanded subscription tier. Configure pricing and included features before offering it.','NGN','month',null,0,'{"student_limit":null,"staff_limit":null,"features":[]}'),
('enterprise','Enterprise','Configurable subscription tier for larger school groups.','NGN','month',null,0,'{"student_limit":null,"staff_limit":null,"features":[]}')
on conflict(plan_code) do nothing;

insert into public.grading_presets(preset_code,name,description,bands) values
('percentage-general','General percentage bands','Editable starting point only. Each school must review and configure its grading policy.',
 '[{"grade":"A","minimum":70,"maximum":100,"remark":"Excellent"},{"grade":"B","minimum":60,"maximum":69.99,"remark":"Very good"},{"grade":"C","minimum":50,"maximum":59.99,"remark":"Good"},{"grade":"D","minimum":45,"maximum":49.99,"remark":"Pass"},{"grade":"F","minimum":0,"maximum":44.99,"remark":"Needs improvement"}]'::jsonb)
on conflict(preset_code) do nothing;

insert into public.assessment_category_presets(preset_code,name,description,categories) values
('balanced-two-part','Balanced two-part assessment','Example only; schools should select their own weights before use.',
 '[{"name":"Continuous assessment","weight":40,"sequence":1},{"name":"Examination","weight":60,"sequence":2}]'::jsonb)
on conflict(preset_code) do nothing;

insert into public.weekly_report_presets(preset_code,name,description,questions) values
('teacher-weekly-observation','Teacher weekly observation','Editable prompts for staff reflection; no student information is included in this preset.',
 '[{"key":"participation","label":"How did the student participate this week?","type":"long_text","required":true},{"key":"strengths","label":"What strengths or progress did you observe?","type":"long_text","required":true},{"key":"support","label":"What support or next step would help?","type":"long_text","required":true}]'::jsonb)
on conflict(preset_code) do nothing;


-- ===== END 202610130005_catalogs_platform_admin.sql =====


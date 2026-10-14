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

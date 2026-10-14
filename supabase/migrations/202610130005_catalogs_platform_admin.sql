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


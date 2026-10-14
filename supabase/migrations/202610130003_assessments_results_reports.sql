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

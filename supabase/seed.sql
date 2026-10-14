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

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

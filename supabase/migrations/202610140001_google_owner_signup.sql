-- Google authenticated owners complete the same school registration metadata
-- used by email signups. Provision only after the user's email is confirmed.
drop trigger if exists on_auth_user_confirmed_provision_school on auth.users;
create trigger on_auth_user_confirmed_provision_school
after insert or update of email_confirmed_at, raw_user_meta_data on auth.users
for each row when (new.email_confirmed_at is not null)
execute function public.provision_school_owner();

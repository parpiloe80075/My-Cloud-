# Technical architecture

## Request and trust boundaries

- Next.js App Router renders public pages and handles Supabase Auth callback/sign-out routes.
- Browser code uses the Supabase publishable/anon key only. Supabase Auth handles password hashing, session issuance and email verification.
- An `auth.users` insert trigger provisions a school in the same PostgreSQL transaction as owner signup; a provisioning failure rolls back signup.
- Private owner pages call `auth.getUser()` on the server and require an active school membership. Database RLS is the final tenant boundary.
- Provider secrets are server-only. Gemini, Resend and payment-provider routes do not exist yet.

## Database model

`schools` is the tenant root. `school_memberships` joins authenticated users to a tenant and role. Academic setup is represented by settings, sessions, periods, classes, subjects, calendar events, grading scales and assessment categories. `staff_profiles`, `student_profiles` and `guardian_profiles` attach role-specific records to same-school memberships; composite foreign keys keep enrollments, assignments, assessments and reports within a tenant. Student passcode storage is hash-only and withheld from client column grants.

CBT questions and answer keys use separate tables. Students can read published questions and submit their own attempts and responses; authorized server functions handle publication, objective grading and manual marks. `subject_results` and weekly reports have separate submission and review RPCs, with review events and school audit entries. Notification recipients and payment records are tenant-scoped. Provider webhook events and platform-operator identities/logs are isolated from regular clients.

## Initial authorization matrix

| Action | Owner | Administrator | Teacher | Student | Parent |
|---|---:|---:|---:|---:|---:|
| Read own school | Yes | Yes | Yes | Scoped | Scoped |
| Manage school profile/config | Yes | Permission key | No | No | No |
| Manage memberships | Yes; invitations use a hashed-token RPC | Invitation acceptance | No | No | No |
| Read subscription | Billing permission | Billing permission | No | No | No |
| Operate academic records | Yes | Permission-based | Assigned classes/subjects | Own linked records | Linked children |
| Cross-school access | No | No | No | No | No |

Owner membership is created by the email-confirmation database trigger. The migrations define the data model and guarded database operations, but most application server routes and dashboards that should call them remain pending. Platform-admin identities and an audit function are present; cross-school data access is intentionally not granted, and an operator console is not implemented.

## Implementation checklist

- [x] App Router/TypeScript application skeleton and responsive public site.
- [x] Four-step school registration interface and email-confirming owner signup path.
- [x] PostgreSQL tenant schema, reference catalogs, RLS policies and guarded workflow functions.
- [x] Server-side owner workspace membership check.
- [ ] Apply and validate the full migration sequence on a disposable Supabase project; test trigger rollback and workflow RPCs.
- [ ] Harden policies against owner-role escalation and test cross-tenant access denial.
- [ ] Implement settings, invitations, account lifecycle and delegated permissions.
- [ ] Implement staff, student and guardian management.
- [ ] Implement class assignments, CBT, grading, result approval and reports.
- [ ] Implement notifications and configured email, AI and billing providers.
- [ ] Implement platform administration and audit review.
- [ ] Add automated unit, integration and end-to-end coverage.
- [ ] Production legal, security, backup, monitoring and Vercel deployment review.


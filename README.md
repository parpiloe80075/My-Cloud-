# SatGold Cloud

SatGold Cloud is a Next.js App Router application for multi-tenant school management. This repository currently delivers the public website, registration flow, Supabase signup/session foundation, tenant schema and owner workspace entry point. It is a foundation, not a production-ready school management SaaS yet.

## Current implementation

- Responsive SatGold Cloud landing page and contact details.
- Four-step school registration capture with client-side validation and review.
- Supabase Auth email/password signup and email confirmation callback.
- PostgreSQL trigger atomically creates a school, owner membership, academic configuration, seeded classes and subjects, audit event and eligible two-month trial after email confirmation.
- Ordered PostgreSQL migrations for sessions, terms, classes, staff/students/guardians, enrollments, teacher assignments, CBT, answer keys, attempts, results, approvals, weekly reports, attendance, notifications, billing records and platform administration boundaries.
- Tenant-aware RLS, permission catalogs, invitation acceptance, assessment grading/publication, result/report submission and review RPCs.
- Idempotent reference catalog seeds for role permissions, unpriced plan tiers, and editable grading/report presets; no sample school records.
- Owner-only workspace route, protected by server-side session and membership lookup.
- Draft Privacy Policy and Terms pages; they require legal and operator review before commercial use.

The SQL foundation defines the records and guarded database operations for academic, assessment, result, report, attendance, notification and billing workflows. Most application screens and server routes that call these operations are still pending, as are PDF generation, Gemini, Resend, verified payment webhooks and a platform-admin console. No payment or AI action is claimed operational.

## Local setup

1. Install Node.js 20.9 or newer.
2. Copy `.env.example` to `.env.local` and configure `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` from a Supabase project.
3. Apply the ordered files in `supabase/migrations/` to the Supabase PostgreSQL database. `supabase/schema.sql` is a complete fresh-project snapshot; do not apply it in addition to migrations.
4. In Supabase Auth, enable email/password sign-in and configure the site URL and redirect URL to `http://localhost:3000/auth/callback` (plus your deployed domain callback).
5. Run `npm install`, then `npm run dev`.

Supabase signup email confirmation should remain enabled for deployment. After email confirmation, the auth trigger provisions the school, initial classes and subjects, membership and trial as one database transaction. Do not disable the trigger or grant client users direct ability to set membership roles. Keep the service-role key out of the browser; this foundation does not use it.

## Environment variables

Required for registration and login:

- `NEXT_PUBLIC_APP_URL`: application origin (currently callback uses the active request origin).
- `NEXT_PUBLIC_SUPABASE_URL`: Supabase project URL.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Supabase publishable/anon key.

Future server-only integrations (not yet connected): `SUPABASE_SERVICE_ROLE_KEY`, `GEMINI_API_KEY`, `RESEND_API_KEY`, `RESEND_FROM_EMAIL`, `PAYMENT_PROVIDER_SECRET_KEY`, `PAYMENT_PROVIDER_WEBHOOK_SECRET`. Configure secrets in Vercel and never use a `NEXT_PUBLIC_` prefix for them.

## Database and authorization

The database uses PostgreSQL/Supabase. It assigns the `owner` role in a database trigger and derives membership and permission helpers from `auth.uid()`. Tenant-owned records include a school identifier and RLS policies; child records also use tenant-scoped foreign keys. Student passcodes have a hash-only column with no client read/write grant. CBT answer keys are stored separately from student-readable questions. Approval and payment writes stay behind database functions or server credentials. Review the SQL and test tenant isolation on a disposable Supabase project before any real student information is stored.

See [`supabase/README.md`](supabase/README.md) for local reset, linked-project migration, seed behavior and the no-reset-on-production rule.

## Deployment status

No Supabase project or credentials were provided, so the migration has not been applied to a live database. No Vercel project or domain is connected. No third-party credentials are configured. Automated tests and production security checks have not been run. Do not onboard real schools until the remaining workflows, policies, retention controls, monitoring, backups and legal documents are implemented and verified.

## Next implementation phases

1. Complete auth roles, invitations, administrator permission checks and tenant-isolation testing.
2. Add school settings CRUD and academic calendar/session, class, subject and grading configuration.
3. Implement staff, student and guardian records and role-specific dashboards.
4. Build assessments, attempts, grading and results approval.
5. Add weekly report workflows, PDF reports and notifications.
6. Integrate email and AI behind server authorization and usage controls.
7. Add plans, payment verification/webhooks and platform administration.
8. Add automated tests, operational monitoring, backup/restore documentation and production review.



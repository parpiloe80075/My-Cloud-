# Supabase SQL files

- `migrations/` is the canonical schema and authorization history. Apply files in timestamp order; Supabase CLI tracks which versions were applied.
- `schema.sql` is a complete snapshot for review or a one-time fresh-project setup. Do not execute it together with the migrations; it creates the same objects.
- `seed.sql` contains idempotent reference catalog rows only: permissions, unpriced subscription tiers, and editable grading, assessment-category and weekly-report presets. It creates no schools or sample users/students/results.
- `config.toml` tells `supabase db reset` to load `seed.sql` after migrations. The catalog rows are also included in migration 005 so a linked `supabase db push` provisions the catalogs without needing a separate production seed step.

## Apply locally

1. Install the Supabase CLI and Docker, then run `supabase start` from the repository root.
2. Run `supabase db reset` only against the local development database. This rebuilds it from every migration and runs `seed.sql`.
3. Set the local API URL and publishable key in `.env.local`, then run the Next.js app.

## Apply to a linked Supabase project

1. Back up the target database and review migrations, RLS policies, auth triggers and functions before applying.
2. Link the project with `supabase link --project-ref <project-ref>`.
3. Check the pending migration list with `supabase migration list`.
4. Apply reviewed migrations with `supabase db push`.
5. Confirm the migration versions and reference catalog rows in the project. Configure Auth confirmation and redirect URLs separately.

Never run `supabase db reset` against a linked production database. These SQL files have not been applied to a live project in this workspace. Validate the full migration sequence on a disposable Supabase project before storing real school records.

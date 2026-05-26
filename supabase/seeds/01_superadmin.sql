-- =============================================================
-- SEED: Superadmin user
-- =============================================================
-- Run this MANUALLY after deploying the schema.
-- Steps:
--   1. Create the user in Supabase Auth (Dashboard > Authentication
--      > Users > Invite user), or via the service-role API.
--   2. Copy the resulting auth.users UUID.
--   3. Replace the placeholders below and execute against the DB.
-- =============================================================

INSERT INTO public.users (
  id,
  email,
  nombre,
  apellido,
  role,
  activo
)
VALUES (
  '<AUTH_USER_UUID>',      -- UUID from auth.users
  '<ADMIN_EMAIL>',         -- e.g. admin@ruedda.com
  '<FIRST_NAME>',
  '<LAST_NAME>',
  'superadmin',
  true
)
ON CONFLICT (id) DO UPDATE
  SET role   = EXCLUDED.role,
      activo = EXCLUDED.activo;

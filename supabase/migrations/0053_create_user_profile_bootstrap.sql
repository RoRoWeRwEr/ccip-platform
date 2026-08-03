BEGIN;

CREATE OR REPLACE FUNCTION public.bootstrap_user_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
BEGIN
    INSERT INTO public.user_profiles (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.bootstrap_user_profile()
FROM PUBLIC, anon, authenticated, service_role;

INSERT INTO public.user_profiles (user_id)
SELECT users.id
FROM auth.users AS users
WHERE NOT EXISTS (
    SELECT 1
    FROM public.user_profiles AS profiles
    WHERE profiles.user_id = users.id
);

CREATE TRIGGER trg_auth_users_bootstrap_profile
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.bootstrap_user_profile();

COMMENT ON FUNCTION public.bootstrap_user_profile() IS
'Internal auth.users trigger that provisions a minimal default user profile. SECURITY DEFINER is required because signup callers cannot insert user_profiles; search_path is pinned and all objects are schema-qualified. No auth metadata is copied.';

COMMIT;

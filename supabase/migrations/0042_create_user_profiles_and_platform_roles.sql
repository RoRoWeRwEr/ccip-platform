BEGIN;

CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    display_name TEXT,
    preferred_language_code TEXT NOT NULL DEFAULT 'en',
    timezone_name TEXT NOT NULL DEFAULT 'Asia/Riyadh',
    onboarding_status TEXT NOT NULL DEFAULT 'NOT_STARTED',
    account_status TEXT NOT NULL DEFAULT 'ACTIVE',
    profile_completed_at TIMESTAMPTZ,
    activated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    suspended_at TIMESTAMPTZ,
    suspension_reason TEXT,
    deactivated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_profiles_user UNIQUE (user_id),
    CONSTRAINT chk_user_profiles_display_name
        CHECK (display_name IS NULL OR length(trim(display_name)) BETWEEN 1 AND 200),
    CONSTRAINT chk_user_profiles_language
        CHECK (preferred_language_code ~ '^[a-z]{2}(?:-[A-Z]{2})?$'),
    CONSTRAINT chk_user_profiles_timezone
        CHECK (length(trim(timezone_name)) BETWEEN 1 AND 100),
    CONSTRAINT chk_user_profiles_onboarding_status
        CHECK (onboarding_status IN ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED')),
    CONSTRAINT chk_user_profiles_account_status
        CHECK (account_status IN ('PENDING', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED')),
    CONSTRAINT chk_user_profiles_completion
        CHECK (
            (onboarding_status = 'COMPLETED' AND profile_completed_at IS NOT NULL)
            OR (onboarding_status <> 'COMPLETED' AND profile_completed_at IS NULL)
        ),
    CONSTRAINT chk_user_profiles_activation
        CHECK (account_status <> 'ACTIVE' OR activated_at IS NOT NULL),
    CONSTRAINT chk_user_profiles_suspension
        CHECK (
            (account_status = 'SUSPENDED' AND suspended_at IS NOT NULL)
            OR (
                account_status <> 'SUSPENDED'
                AND suspended_at IS NULL
                AND suspension_reason IS NULL
            )
        ),
    CONSTRAINT chk_user_profiles_deactivation
        CHECK (
            (account_status = 'DEACTIVATED' AND deactivated_at IS NOT NULL)
            OR (account_status <> 'DEACTIVATED' AND deactivated_at IS NULL)
        )
);

CREATE TABLE public.platform_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_code TEXT NOT NULL,
    role_name TEXT NOT NULL,
    description TEXT,
    is_system_managed BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_platform_roles_code UNIQUE (role_code),
    CONSTRAINT chk_platform_roles_code
        CHECK (role_code ~ '^[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$'),
    CONSTRAINT chk_platform_roles_name
        CHECK (length(trim(role_name)) BETWEEN 1 AND 200),
    CONSTRAINT chk_platform_roles_description
        CHECK (description IS NULL OR length(trim(description)) > 0)
);

CREATE TABLE public.platform_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    permission_code TEXT NOT NULL,
    permission_name TEXT NOT NULL,
    description TEXT,
    resource_code TEXT NOT NULL,
    action_code TEXT NOT NULL,
    is_system_managed BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_platform_permissions_code UNIQUE (permission_code),
    CONSTRAINT uq_platform_permissions_resource_action UNIQUE (resource_code, action_code),
    CONSTRAINT chk_platform_permissions_code
        CHECK (permission_code ~ '^[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$'),
    CONSTRAINT chk_platform_permissions_name
        CHECK (length(trim(permission_name)) BETWEEN 1 AND 200),
    CONSTRAINT chk_platform_permissions_description
        CHECK (description IS NULL OR length(trim(description)) > 0),
    CONSTRAINT chk_platform_permissions_resource
        CHECK (resource_code ~ '^[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$'),
    CONSTRAINT chk_platform_permissions_action
        CHECK (action_code ~ '^[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$')
);

CREATE TABLE public.platform_role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL
        REFERENCES public.platform_roles(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    permission_id UUID NOT NULL
        REFERENCES public.platform_permissions(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
    valid_until TIMESTAMPTZ,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    granted_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    grant_reference TEXT,
    revoked_at TIMESTAMPTZ,
    revoked_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    revocation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_platform_role_permissions_validity
        CHECK (valid_until IS NULL OR valid_until > valid_from),
    CONSTRAINT chk_platform_role_permissions_grant_time
        CHECK (granted_at <= valid_from),
    CONSTRAINT chk_platform_role_permissions_reference
        CHECK (
            grant_reference IS NULL
            OR grant_reference ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),
    CONSTRAINT chk_platform_role_permissions_revocation
        CHECK (
            (revoked_at IS NULL AND revoked_by_user_id IS NULL AND revocation_reason IS NULL)
            OR (revoked_at IS NOT NULL AND revoked_at >= valid_from)
        ),
    CONSTRAINT ex_platform_role_permissions_active_window
        EXCLUDE USING gist (
            role_id WITH =,
            permission_id WITH =,
            (tstzrange(valid_from, valid_until, '[)')) WITH &&
        )
        WHERE (revoked_at IS NULL)
);

CREATE TABLE public.user_platform_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    role_id UUID NOT NULL
        REFERENCES public.platform_roles(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    scope_type TEXT NOT NULL DEFAULT 'PLATFORM',
    scope_reference TEXT,
    valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
    valid_until TIMESTAMPTZ,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    assigned_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    assignment_reason TEXT,
    assignment_reference TEXT,
    revoked_at TIMESTAMPTZ,
    revoked_by_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    revocation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_user_platform_role_assignments_scope
        CHECK (
            (scope_type = 'PLATFORM' AND scope_reference IS NULL)
            OR (
                scope_type IN ('COUNTRY', 'BANK', 'FUNCTIONAL_AREA')
                AND scope_reference IS NOT NULL
                AND scope_reference ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
            )
        ),
    CONSTRAINT chk_user_platform_role_assignments_validity
        CHECK (valid_until IS NULL OR valid_until > valid_from),
    CONSTRAINT chk_user_platform_role_assignments_assignment_time
        CHECK (assigned_at <= valid_from),
    CONSTRAINT chk_user_platform_role_assignments_reference
        CHECK (
            assignment_reference IS NULL
            OR assignment_reference ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),
    CONSTRAINT chk_user_platform_role_assignments_revocation
        CHECK (
            (revoked_at IS NULL AND revoked_by_user_id IS NULL AND revocation_reason IS NULL)
            OR (revoked_at IS NOT NULL AND revoked_at >= valid_from)
        ),
    CONSTRAINT ex_user_platform_roles_active_window
        EXCLUDE USING gist (
            user_id WITH =,
            role_id WITH =,
            scope_type WITH =,
            (COALESCE(scope_reference, '')) WITH =,
            (tstzrange(valid_from, valid_until, '[)')) WITH &&
        )
        WHERE (revoked_at IS NULL)
);

CREATE UNIQUE INDEX uq_platform_role_permissions_current
ON public.platform_role_permissions(role_id, permission_id)
WHERE revoked_at IS NULL AND valid_until IS NULL;

CREATE UNIQUE INDEX uq_user_platform_role_assignments_current
ON public.user_platform_role_assignments(
    user_id,
    role_id,
    scope_type,
    COALESCE(scope_reference, '')
)
WHERE revoked_at IS NULL AND valid_until IS NULL;

CREATE INDEX idx_user_profiles_account_status
ON public.user_profiles(account_status, updated_at DESC);

CREATE INDEX idx_user_profiles_onboarding_status
ON public.user_profiles(onboarding_status, updated_at DESC);

CREATE INDEX idx_platform_roles_active
ON public.platform_roles(role_code)
WHERE is_active = TRUE;

CREATE INDEX idx_platform_permissions_resource_action
ON public.platform_permissions(resource_code, action_code)
WHERE is_active = TRUE;

CREATE INDEX idx_platform_role_permissions_permission
ON public.platform_role_permissions(permission_id, valid_from, valid_until);

CREATE INDEX idx_platform_role_permissions_active
ON public.platform_role_permissions(role_id, permission_id, valid_from, valid_until)
WHERE revoked_at IS NULL;

CREATE INDEX idx_platform_role_permissions_granted_by
ON public.platform_role_permissions(granted_by_user_id)
WHERE granted_by_user_id IS NOT NULL;

CREATE INDEX idx_platform_role_permissions_revoked_by
ON public.platform_role_permissions(revoked_by_user_id)
WHERE revoked_by_user_id IS NOT NULL;

CREATE INDEX idx_user_platform_role_assignments_user_active
ON public.user_platform_role_assignments(
    user_id,
    role_id,
    scope_type,
    scope_reference,
    valid_from,
    valid_until
)
WHERE revoked_at IS NULL;

CREATE INDEX idx_user_platform_role_assignments_role_active
ON public.user_platform_role_assignments(role_id, user_id, valid_from, valid_until)
WHERE revoked_at IS NULL;

CREATE INDEX idx_user_platform_role_assignments_expiry
ON public.user_platform_role_assignments(valid_until)
WHERE revoked_at IS NULL AND valid_until IS NOT NULL;

CREATE INDEX idx_user_platform_role_assignments_assigned_by
ON public.user_platform_role_assignments(assigned_by_user_id)
WHERE assigned_by_user_id IS NOT NULL;

CREATE INDEX idx_user_platform_role_assignments_revoked_by
ON public.user_platform_role_assignments(revoked_by_user_id)
WHERE revoked_by_user_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.has_active_platform_role(requested_role_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_platform_role_assignments AS assignment
        JOIN public.platform_roles AS role
          ON role.id = assignment.role_id
        WHERE assignment.user_id = (SELECT auth.uid())
          AND role.role_code = requested_role_code
          AND assignment.scope_type = 'PLATFORM'
          AND role.is_active = TRUE
          AND assignment.revoked_at IS NULL
          AND assignment.valid_from <= statement_timestamp()
          AND (
              assignment.valid_until IS NULL
              OR assignment.valid_until > statement_timestamp()
          )
    );
$$;

CREATE OR REPLACE FUNCTION public.has_active_platform_permission(
    requested_permission_code TEXT
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_platform_role_assignments AS assignment
        JOIN public.platform_roles AS role
          ON role.id = assignment.role_id
        JOIN public.platform_role_permissions AS role_permission
          ON role_permission.role_id = role.id
        JOIN public.platform_permissions AS permission
          ON permission.id = role_permission.permission_id
        WHERE assignment.user_id = (SELECT auth.uid())
          AND permission.permission_code = requested_permission_code
          AND assignment.scope_type = 'PLATFORM'
          AND role.is_active = TRUE
          AND permission.is_active = TRUE
          AND assignment.revoked_at IS NULL
          AND assignment.valid_from <= statement_timestamp()
          AND (
              assignment.valid_until IS NULL
              OR assignment.valid_until > statement_timestamp()
          )
          AND role_permission.revoked_at IS NULL
          AND role_permission.valid_from <= statement_timestamp()
          AND (
              role_permission.valid_until IS NULL
              OR role_permission.valid_until > statement_timestamp()
          )
    );
$$;

CREATE OR REPLACE FUNCTION public.protect_platform_authorization_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF current_user <> 'authenticated' THEN
        RETURN NEW;
    END IF;

    IF TG_TABLE_NAME = 'platform_roles' THEN
        IF TG_OP = 'UPDATE'
           AND (
               OLD.is_system_managed = TRUE
               OR NEW.role_code IS DISTINCT FROM OLD.role_code
               OR NEW.is_system_managed IS DISTINCT FROM OLD.is_system_managed
           ) THEN
            RAISE EXCEPTION 'system-managed roles and protected role fields may not be modified'
                USING ERRCODE = '42501';
        END IF;
        NEW.is_system_managed = FALSE;
    ELSIF TG_TABLE_NAME = 'platform_permissions' THEN
        IF TG_OP = 'UPDATE'
           AND (
               OLD.is_system_managed = TRUE
               OR NEW.permission_code IS DISTINCT FROM OLD.permission_code
               OR NEW.resource_code IS DISTINCT FROM OLD.resource_code
               OR NEW.action_code IS DISTINCT FROM OLD.action_code
               OR NEW.is_system_managed IS DISTINCT FROM OLD.is_system_managed
           ) THEN
            RAISE EXCEPTION 'system-managed permissions and protected permission fields may not be modified'
                USING ERRCODE = '42501';
        END IF;
        NEW.is_system_managed = FALSE;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.manage_role_permission_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF current_user <> 'authenticated' THEN
        RETURN NEW;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.platform_roles AS role
        WHERE role.id = COALESCE(NEW.role_id, OLD.role_id)
          AND role.is_system_managed = TRUE
    ) OR EXISTS (
        SELECT 1
        FROM public.platform_permissions AS permission
        WHERE permission.id = COALESCE(NEW.permission_id, OLD.permission_id)
          AND permission.is_system_managed = TRUE
    ) THEN
        RAISE EXCEPTION 'system-managed role-permission mappings may be changed only by the service role'
            USING ERRCODE = '42501';
    END IF;

    IF TG_OP = 'INSERT' THEN
        NEW.granted_at = now();
        NEW.granted_by_user_id = auth.uid();
        NEW.revoked_at = NULL;
        NEW.revoked_by_user_id = NULL;
        NEW.revocation_reason = NULL;
    ELSE
        IF NEW.role_id IS DISTINCT FROM OLD.role_id
           OR NEW.permission_id IS DISTINCT FROM OLD.permission_id
           OR NEW.granted_at IS DISTINCT FROM OLD.granted_at
           OR NEW.granted_by_user_id IS DISTINCT FROM OLD.granted_by_user_id
           OR NEW.valid_from IS DISTINCT FROM OLD.valid_from
           OR OLD.revoked_at IS NOT NULL THEN
            RAISE EXCEPTION 'protected role-permission history fields may not be modified'
                USING ERRCODE = '42501';
        END IF;

        IF NEW.revoked_at IS NOT NULL AND OLD.revoked_at IS NULL THEN
            NEW.revoked_at = now();
            NEW.revoked_by_user_id = auth.uid();
        ELSIF NEW.revoked_by_user_id IS DISTINCT FROM OLD.revoked_by_user_id THEN
            RAISE EXCEPTION 'revocation actor is database-managed'
                USING ERRCODE = '42501';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.manage_user_role_assignment_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF current_user <> 'authenticated' THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'INSERT' THEN
        NEW.assigned_at = now();
        NEW.assigned_by_user_id = auth.uid();
        NEW.revoked_at = NULL;
        NEW.revoked_by_user_id = NULL;
        NEW.revocation_reason = NULL;
    ELSE
        IF NEW.user_id IS DISTINCT FROM OLD.user_id
           OR NEW.role_id IS DISTINCT FROM OLD.role_id
           OR NEW.scope_type IS DISTINCT FROM OLD.scope_type
           OR NEW.scope_reference IS DISTINCT FROM OLD.scope_reference
           OR NEW.assigned_at IS DISTINCT FROM OLD.assigned_at
           OR NEW.assigned_by_user_id IS DISTINCT FROM OLD.assigned_by_user_id
           OR NEW.valid_from IS DISTINCT FROM OLD.valid_from
           OR OLD.revoked_at IS NOT NULL THEN
            RAISE EXCEPTION 'protected role-assignment history fields may not be modified'
                USING ERRCODE = '42501';
        END IF;

        IF NEW.revoked_at IS NOT NULL AND OLD.revoked_at IS NULL THEN
            NEW.revoked_at = now();
            NEW.revoked_by_user_id = auth.uid();
        ELSIF NEW.revoked_by_user_id IS DISTINCT FROM OLD.revoked_by_user_id THEN
            RAISE EXCEPTION 'revocation actor is database-managed'
                USING ERRCODE = '42501';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.manage_user_profile_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
    IF current_user = 'authenticated' THEN
        IF NEW.id IS DISTINCT FROM OLD.id
           OR NEW.user_id IS DISTINCT FROM OLD.user_id
           OR NEW.account_status IS DISTINCT FROM OLD.account_status
           OR NEW.activated_at IS DISTINCT FROM OLD.activated_at
           OR NEW.suspended_at IS DISTINCT FROM OLD.suspended_at
           OR NEW.suspension_reason IS DISTINCT FROM OLD.suspension_reason
           OR NEW.deactivated_at IS DISTINCT FROM OLD.deactivated_at
           OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
            RAISE EXCEPTION 'protected user profile fields may not be modified'
                USING ERRCODE = '42501';
        END IF;
    END IF;

    IF NEW.onboarding_status = 'COMPLETED'
       AND OLD.onboarding_status <> 'COMPLETED' THEN
        NEW.profile_completed_at = COALESCE(NEW.profile_completed_at, now());
    ELSIF NEW.onboarding_status <> 'COMPLETED' THEN
        NEW.profile_completed_at = NULL;
    END IF;

    IF NEW.account_status = 'ACTIVE'
       AND OLD.account_status <> 'ACTIVE' THEN
        NEW.activated_at = now();
        NEW.suspended_at = NULL;
        NEW.suspension_reason = NULL;
        NEW.deactivated_at = NULL;
    ELSIF NEW.account_status = 'SUSPENDED'
          AND OLD.account_status <> 'SUSPENDED' THEN
        NEW.suspended_at = now();
        NEW.deactivated_at = NULL;
    ELSIF NEW.account_status = 'DEACTIVATED'
          AND OLD.account_status <> 'DEACTIVATED' THEN
        NEW.deactivated_at = now();
        NEW.suspended_at = NULL;
        NEW.suspension_reason = NULL;
    ELSIF NEW.account_status = 'PENDING' THEN
        NEW.suspended_at = NULL;
        NEW.suspension_reason = NULL;
        NEW.deactivated_at = NULL;
    END IF;

    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.audit_platform_authorization_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog
AS $$
DECLARE
    changed_record JSONB;
    previous_record JSONB;
    changed_record_id UUID;
    audit_action TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        changed_record = to_jsonb(NEW);
        previous_record = NULL;
        changed_record_id = NEW.id;
        audit_action = 'CREATE';
    ELSIF TG_OP = 'UPDATE' THEN
        changed_record = to_jsonb(NEW);
        previous_record = to_jsonb(OLD);
        changed_record_id = NEW.id;
        audit_action = CASE
            WHEN changed_record ->> 'revoked_at' IS NOT NULL
                 AND previous_record ->> 'revoked_at' IS NULL THEN 'REVOKE'
            ELSE 'UPDATE'
        END;
    ELSE
        changed_record = NULL;
        previous_record = to_jsonb(OLD);
        changed_record_id = OLD.id;
        audit_action = 'DELETE';
    END IF;

    INSERT INTO public.audit_events (
        audit_reference,
        event_category,
        event_type,
        event_action,
        actor_type,
        actor_user_id,
        source_component,
        entity_type,
        entity_id,
        operation_name,
        data_classification,
        contains_personal_data,
        before_values,
        after_values,
        changed_fields,
        event_details
    )
    VALUES (
        'iam.' || gen_random_uuid()::TEXT,
        'AUTHORIZATION',
        TG_TABLE_NAME || '_' || lower(TG_OP),
        audit_action,
        CASE WHEN auth.uid() IS NULL THEN 'SYSTEM' ELSE 'ADMIN' END,
        auth.uid(),
        'DATABASE_RBAC',
        TG_TABLE_NAME,
        changed_record_id,
        TG_OP,
        'CONFIDENTIAL',
        TG_TABLE_NAME = 'user_platform_role_assignments',
        previous_record,
        changed_record,
        CASE
            WHEN TG_OP = 'UPDATE' THEN (
                SELECT COALESCE(jsonb_agg(key ORDER BY key), '[]'::JSONB)
                FROM jsonb_each(changed_record) AS current_value(key, value)
                WHERE previous_record -> key IS DISTINCT FROM value
            )
            ELSE '[]'::JSONB
        END,
        jsonb_build_object('trigger_operation', TG_OP)
    );

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_user_profiles_manage_update
BEFORE UPDATE ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION public.manage_user_profile_update();

CREATE TRIGGER trg_platform_roles_protect
BEFORE INSERT OR UPDATE ON public.platform_roles
FOR EACH ROW
EXECUTE FUNCTION public.protect_platform_authorization_change();

CREATE TRIGGER trg_platform_permissions_protect
BEFORE INSERT OR UPDATE ON public.platform_permissions
FOR EACH ROW
EXECUTE FUNCTION public.protect_platform_authorization_change();

CREATE TRIGGER trg_platform_role_permissions_manage
BEFORE INSERT OR UPDATE ON public.platform_role_permissions
FOR EACH ROW
EXECUTE FUNCTION public.manage_role_permission_change();

CREATE TRIGGER trg_user_platform_role_assignments_manage
BEFORE INSERT OR UPDATE ON public.user_platform_role_assignments
FOR EACH ROW
EXECUTE FUNCTION public.manage_user_role_assignment_change();

CREATE TRIGGER trg_platform_roles_updated_at
BEFORE UPDATE ON public.platform_roles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_platform_permissions_updated_at
BEFORE UPDATE ON public.platform_permissions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_platform_role_permissions_updated_at
BEFORE UPDATE ON public.platform_role_permissions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_platform_role_assignments_updated_at
BEFORE UPDATE ON public.user_platform_role_assignments
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_platform_roles_audit
AFTER INSERT OR UPDATE OR DELETE ON public.platform_roles
FOR EACH ROW
EXECUTE FUNCTION public.audit_platform_authorization_change();

CREATE TRIGGER trg_platform_permissions_audit
AFTER INSERT OR UPDATE OR DELETE ON public.platform_permissions
FOR EACH ROW
EXECUTE FUNCTION public.audit_platform_authorization_change();

CREATE TRIGGER trg_platform_role_permissions_audit
AFTER INSERT OR UPDATE OR DELETE ON public.platform_role_permissions
FOR EACH ROW
EXECUTE FUNCTION public.audit_platform_authorization_change();

CREATE TRIGGER trg_user_platform_role_assignments_audit
AFTER INSERT OR UPDATE OR DELETE ON public.user_platform_role_assignments
FOR EACH ROW
EXECUTE FUNCTION public.audit_platform_authorization_change();

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_platform_role_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY customer_read_own_user_profile
ON public.user_profiles FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_update_own_user_profile
ON public.user_profiles FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()))
WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY identity_administrator_read_platform_roles
ON public.platform_roles FOR SELECT TO authenticated
USING (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_create_platform_roles
ON public.platform_roles FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_update_platform_roles
ON public.platform_roles FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'))
WITH CHECK (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_read_platform_permissions
ON public.platform_permissions FOR SELECT TO authenticated
USING (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_create_platform_permissions
ON public.platform_permissions FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_update_platform_permissions
ON public.platform_permissions FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'))
WITH CHECK (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_read_role_permissions
ON public.platform_role_permissions FOR SELECT TO authenticated
USING (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_create_role_permissions
ON public.platform_role_permissions FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_update_role_permissions
ON public.platform_role_permissions FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'))
WITH CHECK (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_read_user_role_assignments
ON public.user_platform_role_assignments FOR SELECT TO authenticated
USING (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_create_user_role_assignments
ON public.user_platform_role_assignments FOR INSERT TO authenticated
WITH CHECK (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

CREATE POLICY identity_administrator_update_user_role_assignments
ON public.user_platform_role_assignments FOR UPDATE TO authenticated
USING (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'))
WITH CHECK (public.has_active_platform_permission('IDENTITY_ACCESS_MANAGE'));

REVOKE ALL ON TABLE
    public.user_profiles,
    public.platform_roles,
    public.platform_permissions,
    public.platform_role_permissions,
    public.user_platform_role_assignments
FROM PUBLIC, anon, authenticated;

REVOKE EXECUTE ON FUNCTION public.has_active_platform_role(TEXT)
FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.has_active_platform_permission(TEXT)
FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.manage_user_profile_update()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.audit_platform_authorization_change()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.protect_platform_authorization_change()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.manage_role_permission_change()
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.manage_user_role_assignment_change()
FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE public.user_profiles TO authenticated;
GRANT UPDATE (
    display_name,
    preferred_language_code,
    timezone_name,
    onboarding_status
) ON public.user_profiles TO authenticated;

GRANT SELECT, INSERT, UPDATE ON TABLE
    public.platform_roles,
    public.platform_permissions,
    public.platform_role_permissions,
    public.user_platform_role_assignments
TO authenticated;

GRANT EXECUTE ON FUNCTION public.has_active_platform_role(TEXT)
TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.has_active_platform_permission(TEXT)
TO authenticated, service_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    public.user_profiles,
    public.platform_roles,
    public.platform_permissions,
    public.platform_role_permissions,
    public.user_platform_role_assignments
TO service_role;

INSERT INTO public.platform_roles (
    id,
    role_code,
    role_name,
    description,
    is_system_managed
)
VALUES
    ('42000000-0000-4000-8000-000000000001', 'PLATFORM_ADMINISTRATOR', 'Platform administrator', 'Manages platform identity, access, and all operational authorization domains.', TRUE),
    ('42000000-0000-4000-8000-000000000002', 'CATALOG_ADMINISTRATOR', 'Catalog administrator', 'Manages banks, cards, fees, benefits, rewards, offers, and reference catalog data.', TRUE),
    ('42000000-0000-4000-8000-000000000003', 'COMPLIANCE_REVIEWER', 'Compliance reviewer', 'Reviews compliance cases, governance controls, approvals, consent evidence, and audit records.', TRUE),
    ('42000000-0000-4000-8000-000000000004', 'OPERATIONS_ANALYST', 'Operations analyst', 'Operates recommendation, notification, application, partnership, referral, and settlement workflows.', TRUE),
    ('42000000-0000-4000-8000-000000000005', 'SUPPORT_OPERATOR', 'Support operator', 'Provides least-privilege customer and application support without identity administration.', TRUE),
    ('42000000-0000-4000-8000-000000000006', 'REPORTING_VIEWER', 'Reporting viewer', 'Reads approved operational and governance reporting outputs.', TRUE)
ON CONFLICT (role_code) DO UPDATE
SET role_name = EXCLUDED.role_name,
    description = EXCLUDED.description,
    is_system_managed = EXCLUDED.is_system_managed,
    is_active = TRUE;

INSERT INTO public.platform_permissions (
    id,
    permission_code,
    permission_name,
    description,
    resource_code,
    action_code,
    is_system_managed
)
VALUES
    ('42100000-0000-4000-8000-000000000001', 'IDENTITY_ACCESS_MANAGE', 'Manage identity access', 'Creates and maintains platform roles, permissions, mappings, and user role assignments.', 'IDENTITY_ACCESS', 'MANAGE', TRUE),
    ('42100000-0000-4000-8000-000000000002', 'CATALOG_MANAGE', 'Manage catalog', 'Maintains bank, card, fee, benefit, offer, reward, and reference catalog records.', 'CATALOG', 'MANAGE', TRUE),
    ('42100000-0000-4000-8000-000000000003', 'COMPLIANCE_REVIEW', 'Review compliance', 'Reviews governance, compliance, approval, consent, retention, legal-hold, and audit records.', 'COMPLIANCE', 'REVIEW', TRUE),
    ('42100000-0000-4000-8000-000000000004', 'OPERATIONS_MANAGE', 'Manage operations', 'Operates recommendation, notification, bank-application, partnership, referral, commission, and settlement workflows.', 'OPERATIONS', 'MANAGE', TRUE),
    ('42100000-0000-4000-8000-000000000005', 'SUPPORT_READ', 'Read support context', 'Reads the minimum customer and application context exposed by approved support workflows.', 'SUPPORT', 'READ', TRUE),
    ('42100000-0000-4000-8000-000000000006', 'REPORTING_READ', 'Read reporting', 'Reads approved operational, financial, compliance, and governance reporting outputs.', 'REPORTING', 'READ', TRUE)
ON CONFLICT (permission_code) DO UPDATE
SET permission_name = EXCLUDED.permission_name,
    description = EXCLUDED.description,
    resource_code = EXCLUDED.resource_code,
    action_code = EXCLUDED.action_code,
    is_system_managed = EXCLUDED.is_system_managed,
    is_active = TRUE;

INSERT INTO public.platform_role_permissions (
    id,
    role_id,
    permission_id,
    valid_from,
    granted_at,
    grant_reference
)
SELECT
    mapping.id,
    role.id,
    permission.id,
    TIMESTAMPTZ '2026-01-01 00:00:00+00',
    TIMESTAMPTZ '2026-01-01 00:00:00+00',
    'MIGRATION_0042'
FROM (
    VALUES
        ('42200000-0000-4000-8000-000000000001'::UUID, 'PLATFORM_ADMINISTRATOR', 'IDENTITY_ACCESS_MANAGE'),
        ('42200000-0000-4000-8000-000000000002'::UUID, 'PLATFORM_ADMINISTRATOR', 'CATALOG_MANAGE'),
        ('42200000-0000-4000-8000-000000000003'::UUID, 'PLATFORM_ADMINISTRATOR', 'COMPLIANCE_REVIEW'),
        ('42200000-0000-4000-8000-000000000004'::UUID, 'PLATFORM_ADMINISTRATOR', 'OPERATIONS_MANAGE'),
        ('42200000-0000-4000-8000-000000000005'::UUID, 'PLATFORM_ADMINISTRATOR', 'SUPPORT_READ'),
        ('42200000-0000-4000-8000-000000000006'::UUID, 'PLATFORM_ADMINISTRATOR', 'REPORTING_READ'),
        ('42200000-0000-4000-8000-000000000007'::UUID, 'CATALOG_ADMINISTRATOR', 'CATALOG_MANAGE'),
        ('42200000-0000-4000-8000-000000000008'::UUID, 'COMPLIANCE_REVIEWER', 'COMPLIANCE_REVIEW'),
        ('42200000-0000-4000-8000-000000000009'::UUID, 'OPERATIONS_ANALYST', 'OPERATIONS_MANAGE'),
        ('42200000-0000-4000-8000-000000000010'::UUID, 'SUPPORT_OPERATOR', 'SUPPORT_READ'),
        ('42200000-0000-4000-8000-000000000011'::UUID, 'REPORTING_VIEWER', 'REPORTING_READ')
) AS mapping(id, role_code, permission_code)
JOIN public.platform_roles AS role
  ON role.role_code = mapping.role_code
JOIN public.platform_permissions AS permission
  ON permission.permission_code = mapping.permission_code
ON CONFLICT DO NOTHING;

COMMENT ON TABLE public.user_profiles IS
'Application-facing, non-sensitive profile and lifecycle state linked one-to-one with the Supabase authentication user.';
COMMENT ON COLUMN public.user_profiles.account_status IS
'Service-controlled application access lifecycle; ordinary authenticated users cannot modify this field.';
COMMENT ON COLUMN public.user_profiles.profile_completed_at IS
'Database-maintained timestamp set when onboarding first transitions to COMPLETED and cleared if completion is reversed.';

COMMENT ON TABLE public.platform_roles IS
'Durable internal platform role catalog; PostgreSQL roles and Supabase authentication roles are not duplicated here.';
COMMENT ON COLUMN public.platform_roles.role_code IS
'Stable machine-readable role identifier used by authorization checks and deterministic seed mappings.';

COMMENT ON TABLE public.platform_permissions IS
'Normalized internal permission catalog identified by stable permission, resource, and action codes.';
COMMENT ON COLUMN public.platform_permissions.permission_code IS
'Stable machine-readable permission identifier used by authorization policies and helper functions.';

COMMENT ON TABLE public.platform_role_permissions IS
'History-preserving, time-bounded grants of platform permissions to platform roles.';
COMMENT ON COLUMN public.platform_role_permissions.revoked_at IS
'Non-null when the grant is revoked; historical mappings are retained instead of deleted.';

COMMENT ON TABLE public.user_platform_role_assignments IS
'History-preserving, optionally scoped and time-bounded assignments of platform roles to Supabase authentication users.';
COMMENT ON COLUMN public.user_platform_role_assignments.scope_type IS
'PLATFORM for global authorization or a constrained COUNTRY, BANK, or FUNCTIONAL_AREA scope interpreted by consuming policies.';
COMMENT ON COLUMN public.user_platform_role_assignments.revoked_at IS
'Non-null when the assignment is revoked; historical assignments are retained instead of deleted.';

COMMENT ON FUNCTION public.has_active_platform_role(TEXT) IS
'Returns whether auth.uid() has the requested active, unexpired, and unrevoked platform role; SECURITY DEFINER avoids RLS recursion and exposes no row data.';
COMMENT ON FUNCTION public.has_active_platform_permission(TEXT) IS
'Returns whether auth.uid() receives the requested active permission through an active role and active role mapping; SECURITY DEFINER avoids RLS recursion and exposes no row data.';
COMMENT ON FUNCTION public.manage_user_profile_update() IS
'Protects service-controlled profile lifecycle fields and maintains completion and account lifecycle timestamps.';
COMMENT ON FUNCTION public.audit_platform_authorization_change() IS
'Writes administrative role, permission, mapping, and assignment changes to the existing append-oriented audit_events table.';
COMMENT ON FUNCTION public.protect_platform_authorization_change() IS
'Prevents authenticated administrators from changing deterministic system-managed roles, permissions, or protected stable codes.';
COMMENT ON FUNCTION public.manage_role_permission_change() IS
'Maintains trusted grant and revocation actors while preserving role-permission history.';
COMMENT ON FUNCTION public.manage_user_role_assignment_change() IS
'Maintains trusted assignment and revocation actors while preserving user-role assignment history.';

COMMIT;

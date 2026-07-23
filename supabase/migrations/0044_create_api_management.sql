-- Migration 0044: bounded API-management foundation.
--
-- API secrets are generated outside PostgreSQL. Only a SHA-256 digest and a
-- short, non-secret display prefix are retained. Webhooks, request accounting,
-- gateway enforcement, and background processing are deliberately out of scope.

BEGIN;

CREATE TABLE public.api_clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_code TEXT NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    client_type TEXT NOT NULL DEFAULT 'PARTNER',
    lifecycle_status TEXT NOT NULL DEFAULT 'PENDING',
    activated_at TIMESTAMPTZ,
    suspended_at TIMESTAMPTZ,
    suspension_reason TEXT,
    deactivated_at TIMESTAMPTZ,
    created_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_api_clients_code UNIQUE (client_code),
    CONSTRAINT chk_api_clients_code CHECK (client_code ~ '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$'),
    CONSTRAINT chk_api_clients_name CHECK (length(trim(display_name)) BETWEEN 1 AND 200),
    CONSTRAINT chk_api_clients_description CHECK (description IS NULL OR length(trim(description)) > 0),
    CONSTRAINT chk_api_clients_type CHECK (client_type IN ('INTERNAL', 'PARTNER', 'PUBLIC_APPLICATION')),
    CONSTRAINT chk_api_clients_status CHECK (lifecycle_status IN ('PENDING', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED')),
    CONSTRAINT chk_api_clients_lifecycle CHECK (
        (lifecycle_status = 'PENDING' AND activated_at IS NULL AND suspended_at IS NULL AND suspension_reason IS NULL AND deactivated_at IS NULL)
        OR (lifecycle_status = 'ACTIVE' AND activated_at IS NOT NULL AND suspended_at IS NULL AND suspension_reason IS NULL AND deactivated_at IS NULL)
        OR (lifecycle_status = 'SUSPENDED' AND activated_at IS NOT NULL AND suspended_at IS NOT NULL AND length(trim(suspension_reason)) BETWEEN 1 AND 1000 AND deactivated_at IS NULL)
        OR (lifecycle_status = 'DEACTIVATED' AND deactivated_at IS NOT NULL)
    ),
    CONSTRAINT chk_api_clients_metadata CHECK (jsonb_typeof(metadata) = 'object')
);

CREATE TABLE public.api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES public.api_clients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    key_name TEXT NOT NULL,
    key_prefix TEXT NOT NULL,
    secret_hash TEXT NOT NULL,
    lifecycle_status TEXT NOT NULL DEFAULT 'ACTIVE',
    valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    last_used_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    revoked_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    revocation_reason TEXT,
    created_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_api_keys_hash UNIQUE (secret_hash),
    CONSTRAINT uq_api_keys_client_name UNIQUE (client_id, key_name),
    CONSTRAINT chk_api_keys_name CHECK (length(trim(key_name)) BETWEEN 1 AND 200),
    CONSTRAINT chk_api_keys_prefix CHECK (key_prefix ~ '^[A-Za-z0-9_-]{6,16}$'),
    CONSTRAINT chk_api_keys_hash CHECK (secret_hash ~ '^[0-9a-f]{64}$'),
    CONSTRAINT chk_api_keys_status CHECK (lifecycle_status IN ('ACTIVE', 'REVOKED')),
    CONSTRAINT chk_api_keys_validity CHECK (expires_at IS NULL OR expires_at > valid_from),
    CONSTRAINT chk_api_keys_last_used CHECK (last_used_at IS NULL OR last_used_at >= valid_from),
    CONSTRAINT chk_api_keys_revocation CHECK (
        (lifecycle_status = 'ACTIVE' AND revoked_at IS NULL AND revoked_by_user_id IS NULL AND revocation_reason IS NULL)
        OR (lifecycle_status = 'REVOKED' AND revoked_at IS NOT NULL AND revoked_at >= valid_from AND length(trim(revocation_reason)) BETWEEN 1 AND 1000)
    )
);

CREATE TABLE public.api_scopes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scope_code TEXT NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT NOT NULL,
    is_system_managed BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_api_scopes_code UNIQUE (scope_code),
    CONSTRAINT chk_api_scopes_code CHECK (scope_code ~ '^[a-z][a-z0-9]*(?::[a-z][a-z0-9_-]*)+$'),
    CONSTRAINT chk_api_scopes_name CHECK (length(trim(display_name)) BETWEEN 1 AND 200),
    CONSTRAINT chk_api_scopes_description CHECK (length(trim(description)) BETWEEN 1 AND 1000)
);

CREATE TABLE public.api_client_scope_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES public.api_clients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    scope_id UUID NOT NULL REFERENCES public.api_scopes(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
    valid_until TIMESTAMPTZ,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    granted_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    grant_reason TEXT NOT NULL,
    revoked_at TIMESTAMPTZ,
    revoked_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    revocation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_api_client_scopes_validity CHECK (valid_until IS NULL OR valid_until > valid_from),
    CONSTRAINT chk_api_client_scopes_grant CHECK (granted_at <= valid_from AND length(trim(grant_reason)) BETWEEN 1 AND 1000),
    CONSTRAINT chk_api_client_scopes_revocation CHECK (
        (revoked_at IS NULL AND revoked_by_user_id IS NULL AND revocation_reason IS NULL)
        OR (revoked_at IS NOT NULL AND revoked_at >= valid_from AND length(trim(revocation_reason)) BETWEEN 1 AND 1000)
    ),
    CONSTRAINT ex_api_client_scopes_active_window EXCLUDE USING gist (
        client_id WITH =, scope_id WITH =, tstzrange(valid_from, valid_until, '[)') WITH &&
    ) WHERE (revoked_at IS NULL)
);

CREATE TABLE public.api_rate_limit_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_code TEXT NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    window_seconds INTEGER NOT NULL,
    request_limit INTEGER NOT NULL,
    burst_limit INTEGER,
    lifecycle_status TEXT NOT NULL DEFAULT 'DRAFT',
    activated_at TIMESTAMPTZ,
    retired_at TIMESTAMPTZ,
    created_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    updated_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_api_rate_limit_policies_code UNIQUE (policy_code),
    CONSTRAINT chk_api_rate_limit_policies_code CHECK (policy_code ~ '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$'),
    CONSTRAINT chk_api_rate_limit_policies_name CHECK (length(trim(display_name)) BETWEEN 1 AND 200),
    CONSTRAINT chk_api_rate_limit_policies_description CHECK (description IS NULL OR length(trim(description)) > 0),
    CONSTRAINT chk_api_rate_limit_policies_window CHECK (window_seconds BETWEEN 1 AND 86400),
    CONSTRAINT chk_api_rate_limit_policies_limit CHECK (request_limit > 0 AND (burst_limit IS NULL OR burst_limit >= request_limit)),
    CONSTRAINT chk_api_rate_limit_policies_status CHECK (lifecycle_status IN ('DRAFT', 'ACTIVE', 'RETIRED')),
    CONSTRAINT chk_api_rate_limit_policies_lifecycle CHECK (
        (lifecycle_status = 'DRAFT' AND activated_at IS NULL AND retired_at IS NULL)
        OR (lifecycle_status = 'ACTIVE' AND activated_at IS NOT NULL AND retired_at IS NULL)
        OR (lifecycle_status = 'RETIRED' AND activated_at IS NOT NULL AND retired_at IS NOT NULL AND retired_at >= activated_at)
    )
);

CREATE TABLE public.api_client_rate_limit_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES public.api_clients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    policy_id UUID NOT NULL REFERENCES public.api_rate_limit_policies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
    valid_until TIMESTAMPTZ,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    assigned_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    assignment_reason TEXT NOT NULL,
    revoked_at TIMESTAMPTZ,
    revoked_by_user_id UUID REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL,
    revocation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_api_client_rate_limits_validity CHECK (valid_until IS NULL OR valid_until > valid_from),
    CONSTRAINT chk_api_client_rate_limits_assignment CHECK (assigned_at <= valid_from AND length(trim(assignment_reason)) BETWEEN 1 AND 1000),
    CONSTRAINT chk_api_client_rate_limits_revocation CHECK (
        (revoked_at IS NULL AND revoked_by_user_id IS NULL AND revocation_reason IS NULL)
        OR (revoked_at IS NOT NULL AND revoked_at >= valid_from AND length(trim(revocation_reason)) BETWEEN 1 AND 1000)
    ),
    CONSTRAINT ex_api_client_rate_limits_active_window EXCLUDE USING gist (
        client_id WITH =, tstzrange(valid_from, valid_until, '[)') WITH &&
    ) WHERE (revoked_at IS NULL)
);

CREATE INDEX idx_api_clients_status ON public.api_clients(lifecycle_status, updated_at DESC);
CREATE INDEX idx_api_keys_client_active ON public.api_keys(client_id, valid_from, expires_at) WHERE lifecycle_status = 'ACTIVE';
CREATE INDEX idx_api_keys_expiry ON public.api_keys(expires_at) WHERE lifecycle_status = 'ACTIVE' AND expires_at IS NOT NULL;
CREATE INDEX idx_api_client_scopes_lookup ON public.api_client_scope_assignments(client_id, scope_id, valid_from, valid_until) WHERE revoked_at IS NULL;
CREATE INDEX idx_api_rate_limit_policies_active ON public.api_rate_limit_policies(policy_code) WHERE lifecycle_status = 'ACTIVE';
CREATE INDEX idx_api_client_rate_limits_lookup ON public.api_client_rate_limit_assignments(client_id, valid_from, valid_until) WHERE revoked_at IS NULL;

CREATE OR REPLACE FUNCTION public.manage_api_management_change()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog AS $$
BEGIN
    IF current_user = 'authenticated' THEN
        IF TG_OP = 'INSERT' THEN
            IF to_jsonb(NEW) ? 'created_by_user_id' THEN NEW.created_by_user_id = auth.uid(); END IF;
            IF to_jsonb(NEW) ? 'granted_by_user_id' THEN NEW.granted_by_user_id = auth.uid(); END IF;
            IF to_jsonb(NEW) ? 'assigned_by_user_id' THEN NEW.assigned_by_user_id = auth.uid(); END IF;
        ELSIF TG_TABLE_NAME = 'api_keys' THEN
            IF NEW.id IS DISTINCT FROM OLD.id OR NEW.client_id IS DISTINCT FROM OLD.client_id
               OR NEW.key_prefix IS DISTINCT FROM OLD.key_prefix OR NEW.secret_hash IS DISTINCT FROM OLD.secret_hash
               OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id
               OR NEW.created_at IS DISTINCT FROM OLD.created_at OR OLD.revoked_at IS NOT NULL THEN
                RAISE EXCEPTION 'API key identity and lifecycle history may not be modified' USING ERRCODE = '42501';
            END IF;
            IF NEW.lifecycle_status = 'REVOKED' AND OLD.lifecycle_status = 'ACTIVE' THEN
                NEW.revoked_at = now(); NEW.revoked_by_user_id = auth.uid();
            END IF;
        ELSIF TG_TABLE_NAME = 'api_client_scope_assignments' THEN
            IF NEW.id IS DISTINCT FROM OLD.id OR NEW.client_id IS DISTINCT FROM OLD.client_id
               OR NEW.scope_id IS DISTINCT FROM OLD.scope_id OR NEW.valid_from IS DISTINCT FROM OLD.valid_from
               OR NEW.granted_at IS DISTINCT FROM OLD.granted_at
               OR NEW.granted_by_user_id IS DISTINCT FROM OLD.granted_by_user_id OR OLD.revoked_at IS NOT NULL THEN
                RAISE EXCEPTION 'API scope grant identity and lifecycle history may not be modified' USING ERRCODE = '42501';
            END IF;
            IF NEW.revoked_at IS NOT NULL AND OLD.revoked_at IS NULL THEN NEW.revoked_at = now(); NEW.revoked_by_user_id = auth.uid(); END IF;
        ELSIF TG_TABLE_NAME = 'api_client_rate_limit_assignments' THEN
            IF NEW.id IS DISTINCT FROM OLD.id OR NEW.client_id IS DISTINCT FROM OLD.client_id
               OR NEW.policy_id IS DISTINCT FROM OLD.policy_id OR NEW.valid_from IS DISTINCT FROM OLD.valid_from
               OR NEW.assigned_at IS DISTINCT FROM OLD.assigned_at
               OR NEW.assigned_by_user_id IS DISTINCT FROM OLD.assigned_by_user_id OR OLD.revoked_at IS NOT NULL THEN
                RAISE EXCEPTION 'API rate-limit assignment identity and lifecycle history may not be modified' USING ERRCODE = '42501';
            END IF;
            IF NEW.revoked_at IS NOT NULL AND OLD.revoked_at IS NULL THEN NEW.revoked_at = now(); NEW.revoked_by_user_id = auth.uid(); END IF;
        ELSIF TG_TABLE_NAME = 'api_clients' THEN
            IF NEW.id IS DISTINCT FROM OLD.id OR NEW.client_code IS DISTINCT FROM OLD.client_code
               OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
                RAISE EXCEPTION 'API client identity and creation audit fields may not be modified' USING ERRCODE = '42501';
            END IF;
        ELSIF TG_TABLE_NAME = 'api_scopes' THEN
            IF NEW.id IS DISTINCT FROM OLD.id OR NEW.scope_code IS DISTINCT FROM OLD.scope_code
               OR NEW.is_system_managed IS DISTINCT FROM OLD.is_system_managed
               OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id OR NEW.created_at IS DISTINCT FROM OLD.created_at
               OR OLD.is_system_managed = TRUE THEN
                RAISE EXCEPTION 'API scope identity and system-managed definitions may not be modified' USING ERRCODE = '42501';
            END IF;
        ELSIF TG_TABLE_NAME = 'api_rate_limit_policies' THEN
            IF NEW.id IS DISTINCT FROM OLD.id OR NEW.policy_code IS DISTINCT FROM OLD.policy_code
               OR NEW.created_by_user_id IS DISTINCT FROM OLD.created_by_user_id OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
                RAISE EXCEPTION 'API rate-limit policy identity and creation audit fields may not be modified' USING ERRCODE = '42501';
            END IF;
        END IF;
        IF to_jsonb(NEW) ? 'updated_by_user_id' THEN NEW.updated_by_user_id = auth.uid(); END IF;
    END IF;
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.is_api_key_active(requested_secret_hash TEXT)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.api_keys AS api_key
        JOIN public.api_clients AS client ON client.id = api_key.client_id
        WHERE api_key.secret_hash = requested_secret_hash
          AND requested_secret_hash ~ '^[0-9a-f]{64}$'
          AND api_key.lifecycle_status = 'ACTIVE'
          AND api_key.valid_from <= statement_timestamp()
          AND (api_key.expires_at IS NULL OR api_key.expires_at > statement_timestamp())
          AND client.lifecycle_status = 'ACTIVE'
    );
$$;

CREATE OR REPLACE FUNCTION public.api_client_has_scope(requested_client_id UUID, requested_scope_code TEXT)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.api_client_scope_assignments AS assignment
        JOIN public.api_scopes AS scope ON scope.id = assignment.scope_id
        JOIN public.api_clients AS client ON client.id = assignment.client_id
        WHERE assignment.client_id = requested_client_id AND scope.scope_code = requested_scope_code
          AND client.lifecycle_status = 'ACTIVE' AND scope.is_active = TRUE
          AND assignment.revoked_at IS NULL AND assignment.valid_from <= statement_timestamp()
          AND (assignment.valid_until IS NULL OR assignment.valid_until > statement_timestamp())
    );
$$;

CREATE OR REPLACE FUNCTION public.get_api_client_rate_limit(requested_client_id UUID)
RETURNS TABLE (policy_id UUID, window_seconds INTEGER, request_limit INTEGER, burst_limit INTEGER)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
    SELECT policy.id, policy.window_seconds, policy.request_limit, policy.burst_limit
    FROM public.api_client_rate_limit_assignments AS assignment
    JOIN public.api_rate_limit_policies AS policy ON policy.id = assignment.policy_id
    JOIN public.api_clients AS client ON client.id = assignment.client_id
    WHERE assignment.client_id = requested_client_id AND client.lifecycle_status = 'ACTIVE'
      AND policy.lifecycle_status = 'ACTIVE' AND assignment.revoked_at IS NULL
      AND assignment.valid_from <= statement_timestamp()
      AND (assignment.valid_until IS NULL OR assignment.valid_until > statement_timestamp());
$$;

CREATE OR REPLACE FUNCTION public.audit_api_management_change()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE before_record JSONB; after_record JSONB; record_id UUID; action TEXT;
BEGIN
    before_record := CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE to_jsonb(OLD) - 'secret_hash' END;
    after_record := CASE WHEN TG_OP = 'DELETE' THEN NULL ELSE to_jsonb(NEW) - 'secret_hash' END;
    record_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END;
    action := CASE
        WHEN TG_TABLE_NAME = 'api_keys' AND TG_OP = 'UPDATE' AND NEW.lifecycle_status = 'REVOKED' AND OLD.lifecycle_status <> 'REVOKED' THEN 'REVOKE'
        WHEN TG_TABLE_NAME = 'api_clients' AND TG_OP = 'UPDATE' AND NEW.lifecycle_status = 'ACTIVE' AND OLD.lifecycle_status <> 'ACTIVE' THEN 'ACTIVATE'
        WHEN TG_TABLE_NAME = 'api_clients' AND TG_OP = 'UPDATE' AND NEW.lifecycle_status = 'DEACTIVATED' AND OLD.lifecycle_status <> 'DEACTIVATED' THEN 'DEACTIVATE'
        WHEN TG_OP = 'INSERT' THEN 'CREATE' WHEN TG_OP = 'DELETE' THEN 'DELETE' ELSE 'UPDATE' END;
    INSERT INTO public.audit_events (
        audit_reference, event_category, event_type, event_action, actor_type,
        actor_user_id, source_component, entity_type, entity_id, operation_name,
        data_classification, before_values, after_values, changed_fields, event_details
    ) VALUES (
        'api-management.' || gen_random_uuid()::TEXT, 'ADMINISTRATION',
        'api_management_' || lower(TG_OP), action,
        CASE WHEN auth.uid() IS NULL THEN 'SYSTEM' ELSE 'ADMIN' END, auth.uid(),
        'DATABASE_API_MANAGEMENT', TG_TABLE_NAME, record_id, TG_OP, 'CONFIDENTIAL',
        before_record, after_record,
        CASE WHEN TG_OP = 'UPDATE' THEN (SELECT COALESCE(jsonb_agg(key ORDER BY key), '[]'::JSONB) FROM jsonb_each(after_record) AS item(key, value) WHERE before_record -> key IS DISTINCT FROM value) ELSE '[]'::JSONB END,
        jsonb_build_object('secret_hash_redacted', TG_TABLE_NAME = 'api_keys')
    );
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

DO $$
DECLARE table_name TEXT;
BEGIN
    FOREACH table_name IN ARRAY ARRAY['api_clients','api_keys','api_scopes','api_client_scope_assignments','api_rate_limit_policies','api_client_rate_limit_assignments'] LOOP
        EXECUTE format('CREATE TRIGGER trg_%I_manage BEFORE INSERT OR UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.manage_api_management_change()', table_name, table_name);
        EXECUTE format('CREATE TRIGGER trg_%I_audit AFTER INSERT OR UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.audit_api_management_change()', table_name, table_name);
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', table_name);
        EXECUTE format('CREATE POLICY platform_administrator_read_%I ON public.%I FOR SELECT TO authenticated USING (public.has_active_platform_role(''PLATFORM_ADMINISTRATOR''))', table_name, table_name);
        EXECUTE format('CREATE POLICY platform_administrator_create_%I ON public.%I FOR INSERT TO authenticated WITH CHECK (public.has_active_platform_role(''PLATFORM_ADMINISTRATOR''))', table_name, table_name);
        EXECUTE format('CREATE POLICY platform_administrator_update_%I ON public.%I FOR UPDATE TO authenticated USING (public.has_active_platform_role(''PLATFORM_ADMINISTRATOR'')) WITH CHECK (public.has_active_platform_role(''PLATFORM_ADMINISTRATOR''))', table_name, table_name);
    END LOOP;
END;
$$;

COMMENT ON TABLE public.api_clients IS 'Internal and partner API client identities and their administrative lifecycle.';
COMMENT ON TABLE public.api_keys IS 'API key lifecycle metadata. secret_hash is a lowercase SHA-256 digest; plaintext key material is never stored.';
COMMENT ON COLUMN public.api_keys.secret_hash IS 'Lowercase hexadecimal SHA-256 digest of externally generated key material; excluded from audit snapshots.';
COMMENT ON TABLE public.api_scopes IS 'Normalized API authorization scope definitions; assignments are evaluated independently from platform-user RBAC.';
COMMENT ON TABLE public.api_client_scope_assignments IS 'History-preserving, time-bounded grants of API scopes to clients.';
COMMENT ON TABLE public.api_rate_limit_policies IS 'Reusable request-window and burst-limit metadata for external gateway enforcement.';
COMMENT ON TABLE public.api_client_rate_limit_assignments IS 'History-preserving, time-bounded assignment of one effective rate-limit policy per client.';
COMMENT ON FUNCTION public.is_api_key_active(TEXT) IS 'SECURITY DEFINER exposes only an active/inactive decision while RLS protects key metadata; all references are schema-qualified and search_path is pinned.';
COMMENT ON FUNCTION public.api_client_has_scope(UUID, TEXT) IS 'SECURITY DEFINER exposes only a scope decision for an already identified client; all references are schema-qualified and search_path is pinned.';
COMMENT ON FUNCTION public.get_api_client_rate_limit(UUID) IS 'SECURITY DEFINER exposes only enforceable limit values for an already identified active client; all references are schema-qualified and search_path is pinned.';
COMMENT ON FUNCTION public.audit_api_management_change() IS 'SECURITY DEFINER writes append-oriented audit events without granting audit-table writes and always removes API key hashes from snapshots.';

REVOKE ALL ON TABLE public.api_clients, public.api_keys, public.api_scopes,
    public.api_client_scope_assignments, public.api_rate_limit_policies,
    public.api_client_rate_limit_assignments FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.api_clients, public.api_keys,
    public.api_scopes, public.api_client_scope_assignments,
    public.api_rate_limit_policies, public.api_client_rate_limit_assignments TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.api_clients, public.api_keys,
    public.api_scopes, public.api_client_scope_assignments,
    public.api_rate_limit_policies, public.api_client_rate_limit_assignments TO service_role;
REVOKE EXECUTE ON FUNCTION public.manage_api_management_change(), public.audit_api_management_change(),
    public.is_api_key_active(TEXT), public.api_client_has_scope(UUID, TEXT),
    public.get_api_client_rate_limit(UUID) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_api_key_active(TEXT), public.api_client_has_scope(UUID, TEXT),
    public.get_api_client_rate_limit(UUID) TO service_role;

COMMIT;

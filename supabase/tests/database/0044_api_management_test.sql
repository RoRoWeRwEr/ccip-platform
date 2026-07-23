-- Migration 0044 — schema, lifecycle, assignment, audit, and RLS coverage.
BEGIN;
SELECT plan(31);

SELECT has_table('public', 'api_clients', 'api_clients exists');
SELECT has_table('public', 'api_keys', 'api_keys exists');
SELECT has_table('public', 'api_scopes', 'api_scopes exists');
SELECT has_table('public', 'api_client_scope_assignments', 'scope assignments exist');
SELECT has_table('public', 'api_rate_limit_policies', 'rate-limit policies exist');
SELECT has_table('public', 'api_client_rate_limit_assignments', 'rate-limit assignments exist');
SELECT ok((SELECT bool_and(relrowsecurity) FROM pg_catalog.pg_class WHERE oid IN
    ('public.api_clients'::regclass, 'public.api_keys'::regclass, 'public.api_scopes'::regclass,
     'public.api_client_scope_assignments'::regclass, 'public.api_rate_limit_policies'::regclass,
     'public.api_client_rate_limit_assignments'::regclass)), 'RLS is enabled on every API-management table');

INSERT INTO auth.users (id, email) VALUES
 ('a4400000-0000-4000-8000-000000000001', 'api-admin@example.invalid'),
 ('a4400000-0000-4000-8000-000000000002', 'api-user@example.invalid');
INSERT INTO public.user_platform_role_assignments (user_id, role_id) VALUES
 ('a4400000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000001');

INSERT INTO public.api_clients (id, client_code, display_name, lifecycle_status, activated_at) VALUES
 ('44000000-0000-4000-8000-000000000001', 'partner.test', 'Test partner', 'ACTIVE', now());
INSERT INTO public.api_keys (id, client_id, key_name, key_prefix, secret_hash) VALUES
 ('44000000-0000-4000-8000-000000000002', '44000000-0000-4000-8000-000000000001', 'Primary', 'ccip_ab1', repeat('a', 64));
INSERT INTO public.api_scopes (id, scope_code, display_name, description) VALUES
 ('44000000-0000-4000-8000-000000000003', 'cards:read', 'Read cards', 'Read approved card catalog data.');
SELECT ok(EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type='api_scopes' AND entity_id='44000000-0000-4000-8000-000000000003' AND event_action='CREATE'), 'scope creation uses the generic CREATE audit action');
UPDATE public.api_scopes SET display_name='Read card catalog' WHERE id='44000000-0000-4000-8000-000000000003';
SELECT ok(EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type='api_scopes' AND entity_id='44000000-0000-4000-8000-000000000003' AND event_action='UPDATE'), 'scope changes use the generic UPDATE audit action');
INSERT INTO public.api_scopes (id, scope_code, display_name, description) VALUES
 ('44000000-0000-4000-8000-000000000007', 'tests:delete', 'Delete test', 'Exercises DELETE audit handling.');
DELETE FROM public.api_scopes WHERE id='44000000-0000-4000-8000-000000000007';
SELECT ok(EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type='api_scopes' AND entity_id='44000000-0000-4000-8000-000000000007' AND event_action='DELETE' AND before_values IS NOT NULL AND after_values IS NULL), 'DELETE auditing uses OLD without accessing NEW');
INSERT INTO public.api_client_scope_assignments (id, client_id, scope_id, grant_reason) VALUES
 ('44000000-0000-4000-8000-000000000004', '44000000-0000-4000-8000-000000000001', '44000000-0000-4000-8000-000000000003', 'Contractual API access');
INSERT INTO public.api_rate_limit_policies (id, policy_code, display_name, window_seconds, request_limit, burst_limit, lifecycle_status, activated_at) VALUES
 ('44000000-0000-4000-8000-000000000005', 'partner.standard', 'Partner standard', 60, 100, 150, 'ACTIVE', now());
INSERT INTO public.api_client_rate_limit_assignments (id, client_id, policy_id, assignment_reason) VALUES
 ('44000000-0000-4000-8000-000000000006', '44000000-0000-4000-8000-000000000001', '44000000-0000-4000-8000-000000000005', 'Standard partner tier');

SELECT ok(public.is_api_key_active(repeat('a', 64)), 'an active key for an active client is accepted');
SELECT ok(NOT public.is_api_key_active(repeat('b', 64)), 'an unknown key fails closed');
SELECT ok(public.api_client_has_scope('44000000-0000-4000-8000-000000000001', 'cards:read'), 'active scope metadata is enforced');
SELECT ok(NOT public.api_client_has_scope('44000000-0000-4000-8000-000000000001', 'cards:write'), 'unassigned scope fails closed');
SELECT results_eq(
 $$SELECT window_seconds, request_limit, burst_limit FROM public.get_api_client_rate_limit('44000000-0000-4000-8000-000000000001')$$,
 $$VALUES (60, 100, 150)$$, 'active rate-limit assignment resolves its enforcement metadata');

SELECT throws_ok($$INSERT INTO public.api_keys (client_id,key_name,key_prefix,secret_hash) VALUES ('44000000-0000-4000-8000-000000000001','Bad','ccip_bad','plaintext')$$,
 '23514', NULL, 'plaintext and malformed key hashes are rejected');
SELECT throws_ok($$INSERT INTO public.api_keys (client_id,key_name,key_prefix,secret_hash) VALUES ('44000000-0000-4000-8000-000000000001','Duplicate','ccip_dup',repeat('a',64))$$,
 '23505', NULL, 'key digests are unique');
SELECT throws_ok($$INSERT INTO public.api_client_scope_assignments (client_id,scope_id,grant_reason) VALUES ('44000000-0000-4000-8000-000000000001','44000000-0000-4000-8000-000000000003','overlap')$$,
 '23P01', NULL, 'overlapping active scope grants are rejected');
SELECT throws_ok($$INSERT INTO public.api_client_rate_limit_assignments (client_id,policy_id,assignment_reason) VALUES ('44000000-0000-4000-8000-000000000001','44000000-0000-4000-8000-000000000005','overlap')$$,
 '23P01', NULL, 'overlapping effective rate-limit policies are rejected');

UPDATE public.api_keys SET lifecycle_status='REVOKED', revoked_at=now(), revocation_reason='rotation test'
 WHERE id='44000000-0000-4000-8000-000000000002';
SELECT ok(NOT public.is_api_key_active(repeat('a',64)), 'a revoked key is immediately inactive');
SELECT ok(EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type='api_keys' AND entity_id='44000000-0000-4000-8000-000000000002' AND event_action='REVOKE'), 'key revocation is audited');
SELECT ok(NOT EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type='api_keys' AND (before_values ? 'secret_hash' OR after_values ? 'secret_hash')), 'key hashes are redacted from audit snapshots');

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4400000-0000-4000-8000-000000000002';
SELECT is((SELECT count(*)::integer FROM public.api_clients), 0, 'unprivileged users cannot read clients');
SELECT throws_ok($$INSERT INTO public.api_clients(client_code,display_name) VALUES ('unauthorized.client','Unauthorized')$$, '42501', NULL, 'unprivileged users cannot create clients');
RESET ROLE;
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4400000-0000-4000-8000-000000000001';
SELECT is((SELECT count(*)::integer FROM public.api_clients), 1, 'active platform administrators can read clients');
SELECT lives_ok($$INSERT INTO public.api_clients(client_code,display_name) VALUES ('admin.created','Admin-created')$$, 'active platform administrators can create clients');
RESET ROLE;
UPDATE public.api_clients SET lifecycle_status='ACTIVE', activated_at=now() WHERE client_code='admin.created';
SELECT ok(EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type='api_clients' AND entity_id=(SELECT id FROM public.api_clients WHERE client_code='admin.created') AND event_action='ACTIVATE'), 'client activation uses the ACTIVATE audit action');

UPDATE public.api_client_scope_assignments SET revoked_at=now(), revocation_reason='contract ended' WHERE id='44000000-0000-4000-8000-000000000004';
SELECT ok(NOT public.api_client_has_scope('44000000-0000-4000-8000-000000000001','cards:read'), 'revoked scopes are inactive');
UPDATE public.api_client_rate_limit_assignments SET revoked_at=now(), revocation_reason='tier ended' WHERE id='44000000-0000-4000-8000-000000000006';
SELECT is_empty($$SELECT * FROM public.get_api_client_rate_limit('44000000-0000-4000-8000-000000000001')$$, 'revoked rate-limit assignments do not resolve');
UPDATE public.api_clients SET lifecycle_status='DEACTIVATED', deactivated_at=now() WHERE id='44000000-0000-4000-8000-000000000001';
SELECT ok(NOT public.api_client_has_scope('44000000-0000-4000-8000-000000000001','cards:read'), 'deactivated clients fail scope checks');
SELECT ok(EXISTS (SELECT 1 FROM public.audit_events WHERE entity_type='api_clients' AND entity_id='44000000-0000-4000-8000-000000000001' AND event_action='DEACTIVATE'), 'client deactivation is audited');

SELECT * FROM finish();
ROLLBACK;

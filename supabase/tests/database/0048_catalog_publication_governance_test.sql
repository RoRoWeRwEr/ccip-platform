BEGIN;

SELECT plan(45);

SELECT has_table('public', 'catalog_publication_versions', 'catalog_publication_versions exists');
SELECT has_table('public', 'catalog_publication_requests', 'catalog_publication_requests exists');
SELECT has_table('public', 'catalog_publication_events', 'catalog_publication_events exists');
SELECT ok((SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid='public.catalog_publication_versions'::regclass),'versions has RLS');
SELECT ok((SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid='public.catalog_publication_requests'::regclass),'requests has RLS');
SELECT ok((SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid='public.catalog_publication_events'::regclass),'events has RLS');

INSERT INTO auth.users(id,email) VALUES
 ('a4800000-0000-4000-8000-000000000001','requester48@example.invalid'),
 ('a4800000-0000-4000-8000-000000000002','reviewer48@example.invalid'),
 ('a4800000-0000-4000-8000-000000000003','approver48@example.invalid'),
 ('a4800000-0000-4000-8000-000000000004','outsider48@example.invalid');
INSERT INTO public.user_platform_role_assignments(user_id,role_id) VALUES
 ('a4800000-0000-4000-8000-000000000001','42000000-0000-4000-8000-000000000002'),
 ('a4800000-0000-4000-8000-000000000002','42000000-0000-4000-8000-000000000002'),
 ('a4800000-0000-4000-8000-000000000003','42000000-0000-4000-8000-000000000002');
INSERT INTO public.catalog_administrator_scope_assignments
    (role_assignment_id,scope_type,assignment_reason)
SELECT id,'GLOBAL','0048 publication regression coverage'
FROM public.user_platform_role_assignments
WHERE user_id IN (
 'a4800000-0000-4000-8000-000000000001',
 'a4800000-0000-4000-8000-000000000002',
 'a4800000-0000-4000-8000-000000000003'
);
INSERT INTO public.merchants(id,slug,display_name_en,display_name_ar) VALUES
 ('48000000-0000-4000-8000-000000000001','publication-merchant-48','Publication Merchant','تاجر النشر');

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000001';
SELECT lives_ok($$INSERT INTO public.catalog_publication_versions(id,target_entity_type,merchant_id,version_number,content_snapshot,change_summary)
 VALUES('48000000-0000-4000-8000-000000000101','MERCHANT','48000000-0000-4000-8000-000000000001',1,'{"name":"v1"}','Initial publication')$$,'authorized requester creates draft');
SELECT is((SELECT lifecycle_status FROM public.catalog_publication_versions WHERE id='48000000-0000-4000-8000-000000000101'),'DRAFT','new version is draft');
RESET ROLE;
SET ROLE service_role;
SELECT throws_ok($$INSERT INTO public.catalog_publication_versions(target_entity_type,merchant_id,version_number,content_snapshot,change_summary) VALUES('BANK','48000000-0000-4000-8000-000000000001',2,'{}','bad')$$,'23514',NULL,'typed target mismatch rejected');
RESET ROLE;
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000001';
SELECT throws_ok($$UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED' WHERE id='48000000-0000-4000-8000-000000000101'$$,'42501',NULL,'direct lifecycle transition rejected');
SELECT throws_ok($$SELECT public.submit_catalog_publication('48000000-0000-4000-8000-000000000101','a4800000-0000-4000-8000-000000000002','a4800000-0000-4000-8000-000000000001')$$,'23514',NULL,'requester cannot final-approve');
SELECT throws_ok($$SELECT public.submit_catalog_publication('48000000-0000-4000-8000-000000000101','a4800000-0000-4000-8000-000000000003','a4800000-0000-4000-8000-000000000003')$$,'23514',NULL,'reviewer and final approver must differ');
SELECT lives_ok($$SELECT public.submit_catalog_publication('48000000-0000-4000-8000-000000000101','a4800000-0000-4000-8000-000000000002','a4800000-0000-4000-8000-000000000003')$$,'draft submission succeeds');
SELECT is((SELECT lifecycle_status FROM public.catalog_publication_versions WHERE id='48000000-0000-4000-8000-000000000101'),'IN_REVIEW','submission moves version to review');
SELECT is((SELECT count(*)::integer FROM public.approval_decisions d JOIN public.catalog_publication_requests r ON r.approval_request_id=d.approval_request_id WHERE r.publication_version_id='48000000-0000-4000-8000-000000000101'),2,'existing approval engine stores two assignments');
SELECT is((SELECT approval_type FROM public.approval_requests a JOIN public.catalog_publication_requests r ON r.approval_request_id=a.id WHERE r.publication_version_id='48000000-0000-4000-8000-000000000101'),'CATALOG_PUBLICATION','generic request is typed for catalog publication');
SELECT lives_ok($$SELECT public.submit_catalog_publication('48000000-0000-4000-8000-000000000101','a4800000-0000-4000-8000-000000000002','a4800000-0000-4000-8000-000000000003')$$,'repeat submission is idempotent');
RESET ROLE;

SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000003';
SELECT throws_ok($$SELECT public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000101'),'APPROVED','premature')$$,'23514',NULL,'final approval cannot precede review');
RESET ROLE;
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000002';
SELECT is(public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000101'),'APPROVED','review complete'),'IN_REVIEW','review approval retains in-review state');
RESET ROLE;
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000003';
SELECT is(public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000101'),'APPROVED','approved'),'APPROVED','final approval succeeds');
SELECT is(public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000101'),'APPROVED','approved'),'APPROVED','repeat final decision is idempotent');
RESET ROLE;
SELECT is((SELECT approvals_received FROM public.approval_requests a JOIN public.catalog_publication_requests r ON r.approval_request_id=a.id WHERE r.publication_version_id='48000000-0000-4000-8000-000000000101'),2,'approval counts synchronized');

SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000001';
SELECT is(public.publish_catalog_version('48000000-0000-4000-8000-000000000101'),'PUBLISHED','approved version publishes');
SELECT is(public.publish_catalog_version('48000000-0000-4000-8000-000000000101'),'PUBLISHED','publication is idempotent');
SELECT ok((SELECT published_at IS NOT NULL AND effective_from IS NOT NULL FROM public.catalog_publication_versions WHERE id='48000000-0000-4000-8000-000000000101'),'publication timestamps stamped');
SELECT is(public.unpublish_catalog_version('48000000-0000-4000-8000-000000000101',false,'temporary issue'),'SUSPENDED','published version suspends');
SELECT is(public.publish_catalog_version('48000000-0000-4000-8000-000000000101'),'PUBLISHED','suspended version republishes');

INSERT INTO public.catalog_publication_versions(id,target_entity_type,merchant_id,version_number,content_snapshot,change_summary,effective_from,effective_until)
VALUES('48000000-0000-4000-8000-000000000102','MERCHANT','48000000-0000-4000-8000-000000000001',2,'{"name":"v2"}','Second publication',now(),now()+interval '2 days');
SELECT lives_ok($$SELECT public.submit_catalog_publication('48000000-0000-4000-8000-000000000102','a4800000-0000-4000-8000-000000000002','a4800000-0000-4000-8000-000000000003',now()+interval '1 day',now()+interval '2 days',now()+interval '1 day',now()+interval '2 days')$$,'scheduled submission succeeds');
RESET ROLE;
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000002';
DO $$ BEGIN PERFORM public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000102'),'APPROVED','reviewed'); END $$;
RESET ROLE;
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000003';
SELECT is(public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000102'),'APPROVED','approved'),'SCHEDULED','future publication becomes scheduled');
SELECT throws_ok($$SELECT public.publish_catalog_version('48000000-0000-4000-8000-000000000102')$$,'23514',NULL,'early scheduled publication rejected');
RESET ROLE;

-- Rejection path on version 3.
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000001';
INSERT INTO public.catalog_publication_versions(id,target_entity_type,merchant_id,version_number,content_snapshot,change_summary) VALUES('48000000-0000-4000-8000-000000000103','MERCHANT','48000000-0000-4000-8000-000000000001',3,'{}','Rejected version');
DO $$ BEGIN PERFORM public.submit_catalog_publication('48000000-0000-4000-8000-000000000103','a4800000-0000-4000-8000-000000000002','a4800000-0000-4000-8000-000000000003'); END $$;
RESET ROLE;
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000002';
SELECT is(public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000103'),'REJECTED','insufficient evidence'),'REJECTED','reviewer rejection succeeds');
RESET ROLE;
SELECT ok((SELECT rejected_at IS NOT NULL AND rejection_reason='insufficient evidence' FROM public.catalog_publication_versions WHERE id='48000000-0000-4000-8000-000000000103'),'rejection evidence retained');

-- Overlap constraint, forced as service_role to isolate the database invariant.
SET ROLE service_role;
SELECT throws_ok($$UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=now() WHERE id='48000000-0000-4000-8000-000000000102'$$,'23P01',NULL,'overlapping published window rejected');
RESET ROLE;

-- Rollback to an approved replacement.
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000001';
INSERT INTO public.catalog_publication_versions(id,target_entity_type,merchant_id,version_number,content_snapshot,change_summary) VALUES('48000000-0000-4000-8000-000000000105','MERCHANT','48000000-0000-4000-8000-000000000001',5,'{}','Rollback replacement');
DO $$ BEGIN PERFORM public.submit_catalog_publication('48000000-0000-4000-8000-000000000105','a4800000-0000-4000-8000-000000000002','a4800000-0000-4000-8000-000000000003'); END $$;
RESET ROLE;
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000002'; DO $$ BEGIN PERFORM public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000105'),'APPROVED','reviewed'); END $$; RESET ROLE;
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000003'; DO $$ BEGIN PERFORM public.decide_catalog_publication((SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='48000000-0000-4000-8000-000000000105'),'APPROVED','approved'); END $$; RESET ROLE;
SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000001';
SELECT is(public.rollback_catalog_version('48000000-0000-4000-8000-000000000101','48000000-0000-4000-8000-000000000105','restore known-good content'),'PUBLISHED','atomic rollback publishes replacement');
RESET ROLE;
SELECT ok((SELECT lifecycle_status='ARCHIVED' AND supersedes_version_id='48000000-0000-4000-8000-000000000105' FROM public.catalog_publication_versions WHERE id='48000000-0000-4000-8000-000000000101'),'rolled-back version is archived with successor');
SELECT ok((SELECT lifecycle_status='PUBLISHED' AND rollback_of_version_id='48000000-0000-4000-8000-000000000101' FROM public.catalog_publication_versions WHERE id='48000000-0000-4000-8000-000000000105'),'replacement records rollback lineage');

SELECT ok((SELECT count(*)>=10 FROM public.catalog_publication_events WHERE publication_version_id IN ('48000000-0000-4000-8000-000000000101','48000000-0000-4000-8000-000000000105')),'complete event history accumulated');
SELECT ok(EXISTS(SELECT 1 FROM public.audit_events WHERE entity_type='catalog_publication_versions' AND entity_id='48000000-0000-4000-8000-000000000101'),'publication writes central audit event');

SET ROLE authenticated; SET LOCAL request.jwt.claim.sub='a4800000-0000-4000-8000-000000000004';
SELECT is((SELECT count(*)::integer FROM public.catalog_publication_versions),0,'unprivileged user cannot read governance versions');
SELECT throws_ok($$INSERT INTO public.catalog_publication_versions(target_entity_type,merchant_id,version_number,content_snapshot,change_summary) VALUES('MERCHANT','48000000-0000-4000-8000-000000000001',99,'{}','unauthorized')$$,'42501',NULL,'unprivileged user cannot create versions');
SELECT throws_ok($$SELECT public.publish_catalog_version('48000000-0000-4000-8000-000000000105')$$,'42501',NULL,'unprivileged user cannot invoke workflow');
RESET ROLE;
SET ROLE anon;
SELECT throws_ok($$SELECT count(*) FROM public.catalog_publication_versions$$,'42501',NULL,'anonymous caller cannot read governance versions');
RESET ROLE;

SELECT ok(NOT has_function_privilege('authenticated','public.manage_catalog_publication_version_change()','EXECUTE'),'management trigger is not directly executable');
SELECT ok((SELECT prosecdef AND proconfig @> ARRAY['search_path=pg_catalog'] FROM pg_catalog.pg_proc WHERE oid='public.record_catalog_publication_event()'::regprocedure),'audit trigger is safe SECURITY DEFINER');
SELECT ok((SELECT prosecdef AND proconfig @> ARRAY['search_path=pg_catalog'] FROM pg_catalog.pg_proc WHERE oid='public.submit_catalog_publication(uuid,uuid,uuid,timestamptz,timestamptz,timestamptz,timestamptz)'::regprocedure),'submission function is safe SECURITY DEFINER');

SELECT * FROM finish();
ROLLBACK;

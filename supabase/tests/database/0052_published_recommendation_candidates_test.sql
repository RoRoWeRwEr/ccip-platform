BEGIN;

SELECT plan(17);

SELECT has_column('public','cards','is_recommendation_eligible','candidate flag exists');
SELECT col_not_null('public','cards','is_recommendation_eligible','candidate flag is not null');
SELECT col_default_is('public','cards','is_recommendation_eligible','false','candidate flag defaults closed');
SELECT has_function('public','get_published_recommendation_candidates',ARRAY[]::TEXT[],'candidate function exists');
SELECT function_returns('public','get_published_recommendation_candidates',ARRAY[]::TEXT[],'jsonb','candidate function returns jsonb');
SELECT ok((SELECT prosecdef AND proconfig @> ARRAY['search_path=pg_catalog'] FROM pg_catalog.pg_proc
  WHERE oid='public.get_published_recommendation_candidates()'::regprocedure),'function is hardened SECURITY DEFINER');
SELECT ok(NOT has_function_privilege('public','public.get_published_recommendation_candidates()','EXECUTE'),'PUBLIC cannot execute');
SELECT ok(has_function_privilege('anon','public.get_published_recommendation_candidates()','EXECUTE'),'anon can execute');
SELECT ok(has_function_privilege('authenticated','public.get_published_recommendation_candidates()','EXECUTE'),'authenticated can execute');
SELECT has_index('public','cards','idx_cards_recommendation_candidates','candidate partial index exists');

INSERT INTO auth.users(id,email) VALUES ('52000000-0000-4000-8000-000000000001','reader52@example.invalid');
INSERT INTO public.countries(id,code,slug,name_en,name_ar) VALUES ('52000000-0000-4000-8000-000000000010','SA','saudi-arabia-52','Saudi Arabia','السعودية');
INSERT INTO public.currencies(id,code,slug,name_en,name_ar,symbol) VALUES ('52000000-0000-4000-8000-000000000011','SAR','riyal-52','Saudi Riyal','ريال','SAR');
INSERT INTO public.card_networks(id,slug,name_en,name_ar) VALUES ('52000000-0000-4000-8000-000000000012','visa-52','Visa','فيزا');
INSERT INTO public.banks(id,country_id,slug,name_en,name_ar) VALUES ('52000000-0000-4000-8000-000000000020','52000000-0000-4000-8000-000000000010','bank-52','Mutable Bank','بنك');
INSERT INTO public.cards(id,bank_id,card_network_id,currency_id,slug,name_en,name_ar,is_active,is_recommendation_eligible,published_at) VALUES
 ('52000000-0000-4000-8000-000000000030','52000000-0000-4000-8000-000000000020','52000000-0000-4000-8000-000000000012','52000000-0000-4000-8000-000000000011','eligible-52','Mutable Eligible','مؤهلة',true,true,now()),
 ('52000000-0000-4000-8000-000000000031','52000000-0000-4000-8000-000000000020','52000000-0000-4000-8000-000000000012','52000000-0000-4000-8000-000000000011','core-denied-52','Core denied','مرفوضة',true,false,now()),
 ('52000000-0000-4000-8000-000000000032','52000000-0000-4000-8000-000000000020','52000000-0000-4000-8000-000000000012','52000000-0000-4000-8000-000000000011','snapshot-denied-52','Snapshot denied','مرفوضة',true,true,now());
INSERT INTO public.catalog_publication_versions(id,target_entity_type,bank_id,card_id,version_number,content_snapshot,change_summary) VALUES
 ('52000000-0000-4000-8000-000000000100','BANK','52000000-0000-4000-8000-000000000020',NULL,1,'{"id":"52000000-0000-4000-8000-000000000020","slug":"bank-52","name_en":"Published Bank","name_ar":"البنك"}','bank'),
 ('52000000-0000-4000-8000-000000000101','CARD',NULL,'52000000-0000-4000-8000-000000000030',1,'{"id":"52000000-0000-4000-8000-000000000030","bank_id":"52000000-0000-4000-8000-000000000020","card_network_id":"52000000-0000-4000-8000-000000000012","currency_id":"52000000-0000-4000-8000-000000000011","slug":"eligible-52","name_en":"Published Eligible","name_ar":"مؤهلة","annual_fee":0,"target_user":"GENERAL","is_recommendation_eligible":true,"private_note":"hidden"}','eligible'),
 ('52000000-0000-4000-8000-000000000102','CARD',NULL,'52000000-0000-4000-8000-000000000031',1,'{"id":"52000000-0000-4000-8000-000000000031","bank_id":"52000000-0000-4000-8000-000000000020","card_network_id":"52000000-0000-4000-8000-000000000012","currency_id":"52000000-0000-4000-8000-000000000011","slug":"core-denied-52","name_en":"Core Denied","name_ar":"مرفوضة","annual_fee":0,"target_user":"GENERAL","is_recommendation_eligible":true}','core denied'),
 ('52000000-0000-4000-8000-000000000103','CARD',NULL,'52000000-0000-4000-8000-000000000032',1,'{"id":"52000000-0000-4000-8000-000000000032","bank_id":"52000000-0000-4000-8000-000000000020","card_network_id":"52000000-0000-4000-8000-000000000012","currency_id":"52000000-0000-4000-8000-000000000011","slug":"snapshot-denied-52","name_en":"Snapshot Denied","name_ar":"مرفوضة","annual_fee":0,"target_user":"GENERAL","is_recommendation_eligible":false}','snapshot denied');
UPDATE public.catalog_publication_versions SET lifecycle_status='IN_REVIEW';
UPDATE public.catalog_publication_versions SET lifecycle_status='APPROVED';
UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=now(),effective_from=now()-interval '1 hour';

SET ROLE anon;
SELECT is(pg_catalog.jsonb_array_length(public.get_published_recommendation_candidates()),1,'anon sees only dual-gated candidate');
SELECT is(public.get_published_recommendation_candidates()#>>'{0,card,name_en}','Published Eligible','candidate uses published snapshot detail');
SELECT ok(NOT (public.get_published_recommendation_candidates()#>'{0,card}' ? 'private_note'),'private snapshot fields do not leak');
SELECT throws_ok('SELECT count(*) FROM public.catalog_publication_versions','42501','permission denied for table catalog_publication_versions','anon cannot bypass governance RLS');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub='52000000-0000-4000-8000-000000000001';
SELECT is(pg_catalog.jsonb_array_length(public.get_published_recommendation_candidates()),1,'authenticated sees same candidate boundary');
RESET ROLE;

UPDATE public.catalog_publication_versions SET lifecycle_status='SUSPENDED',suspended_at=now(),suspension_reason='test' WHERE id='52000000-0000-4000-8000-000000000101';
SET ROLE anon;
SELECT is(pg_catalog.jsonb_array_length(public.get_published_recommendation_candidates()),0,'suspension removes candidate immediately');
RESET ROLE;
UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',suspended_at=NULL,suspension_reason=NULL,
 scheduled_publish_at=now()-interval '2 minutes',scheduled_unpublish_at=now()-interval '1 minute'
 WHERE id='52000000-0000-4000-8000-000000000101';
SET ROLE anon;
SELECT is(pg_catalog.jsonb_array_length(public.get_published_recommendation_candidates()),0,'elapsed unpublication removes candidate');
RESET ROLE;

SELECT * FROM finish();
ROLLBACK;

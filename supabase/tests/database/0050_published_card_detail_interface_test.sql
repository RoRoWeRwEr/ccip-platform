BEGIN;

SELECT plan(41);

SELECT has_function('public', 'get_published_card_detail', ARRAY['text'], 'published card-detail function exists');
SELECT function_returns('public', 'get_published_card_detail', ARRAY['text'], 'jsonb', 'function returns jsonb');
SELECT ok((
    SELECT prosecdef AND proconfig @> ARRAY['search_path=pg_catalog']
    FROM pg_catalog.pg_proc
    WHERE oid = 'public.get_published_card_detail(text)'::regprocedure
), 'function is SECURITY DEFINER with a pinned search_path');
SELECT ok(NOT has_function_privilege('public', 'public.get_published_card_detail(text)', 'EXECUTE'), 'PUBLIC cannot execute');
SELECT ok(has_function_privilege('anon', 'public.get_published_card_detail(text)', 'EXECUTE'), 'anon can execute');
SELECT ok(has_function_privilege('authenticated', 'public.get_published_card_detail(text)', 'EXECUTE'), 'authenticated can execute');
SELECT ok(NOT has_table_privilege('anon', 'public.catalog_publication_versions', 'SELECT'), 'anon still cannot read publication governance');
SELECT ok(has_table_privilege('authenticated', 'public.catalog_source_provenance', 'SELECT'), 'existing provenance grant remains RLS-gated for catalog administrators');
SELECT ok(NOT has_table_privilege('anon', 'public.reward_rules', 'SELECT'), 'anon still has no direct reward-rules grant');
SELECT ok(NOT has_table_privilege('authenticated', 'public.card_eligibility_requirements', 'SELECT'), 'authenticated still has no direct eligibility grant');

INSERT INTO auth.users(id,email) VALUES
 ('50000000-0000-4000-8000-000000000001','platform50@example.invalid'),
 ('50000000-0000-4000-8000-000000000002','reader50@example.invalid');
INSERT INTO public.user_platform_role_assignments(user_id,role_id)
VALUES ('50000000-0000-4000-8000-000000000001','42000000-0000-4000-8000-000000000001');

INSERT INTO public.countries(id,code,slug,name_en,name_ar) VALUES
 ('50000000-0000-4000-8000-000000000010','SA','saudi-arabia-50','Saudi Arabia','السعودية');
INSERT INTO public.currencies(id,code,slug,name_en,name_ar,symbol) VALUES
 ('50000000-0000-4000-8000-000000000011','SAR','riyal-50','Saudi Riyal','ريال سعودي','SAR');
INSERT INTO public.card_networks(id,slug,name_en,name_ar) VALUES
 ('50000000-0000-4000-8000-000000000012','visa-50','Visa','فيزا');
INSERT INTO public.merchant_categories(id,code,slug,name_en,name_ar) VALUES
 ('50000000-0000-4000-8000-000000000013','5411','groceries-50','Groceries','البقالة');
INSERT INTO public.reward_categories(id,slug,name_en,name_ar) VALUES
 ('50000000-0000-4000-8000-000000000014','everyday-50','Everyday','يومي');
INSERT INTO public.banks(id,country_id,slug,name_en,name_ar) VALUES
 ('50000000-0000-4000-8000-000000000020','50000000-0000-4000-8000-000000000010','bank-50','Live Draft Bank','بنك');
INSERT INTO public.loyalty_programs(id,slug,name_en,name_ar,type) VALUES
 ('50000000-0000-4000-8000-000000000021','points-50','Live Draft Points','نقاط','BANK_POINTS');
INSERT INTO public.cards(
 id,bank_id,card_network_id,currency_id,loyalty_program_id,slug,name_en,name_ar,
 annual_fee,availability_status,is_active,published_at
) VALUES
 ('50000000-0000-4000-8000-000000000030','50000000-0000-4000-8000-000000000020',
  '50000000-0000-4000-8000-000000000012','50000000-0000-4000-8000-000000000011',
  '50000000-0000-4000-8000-000000000021','published-card-50','Live Draft Card','بطاقة',999,'AVAILABLE',true,now()),
 ('50000000-0000-4000-8000-000000000031','50000000-0000-4000-8000-000000000020',
  '50000000-0000-4000-8000-000000000012','50000000-0000-4000-8000-000000000011',
  NULL,'draft-card-50','Draft Card','مسودة',0,'AVAILABLE',true,now()),
 ('50000000-0000-4000-8000-000000000032','50000000-0000-4000-8000-000000000020',
  '50000000-0000-4000-8000-000000000012','50000000-0000-4000-8000-000000000011',
  NULL,'future-card-50','Future Card','مستقبلية',0,'AVAILABLE',true,now()),
 ('50000000-0000-4000-8000-000000000033','50000000-0000-4000-8000-000000000020',
  '50000000-0000-4000-8000-000000000012','50000000-0000-4000-8000-000000000011',
  NULL,'expired-card-50','Expired Card','منتهية',0,'AVAILABLE',true,now()),
 ('50000000-0000-4000-8000-000000000034','50000000-0000-4000-8000-000000000020',
  '50000000-0000-4000-8000-000000000012','50000000-0000-4000-8000-000000000011',
  NULL,'scheduled-unpublished-card-50','Scheduled Unpublished Card','غير منشورة مجدولة',0,'AVAILABLE',true,now());
INSERT INTO public.card_fees(id,card_id,fee_type,name_en,name_ar,amount) VALUES
 ('50000000-0000-4000-8000-000000000040','50000000-0000-4000-8000-000000000030','ANNUAL','Live Draft Fee','رسوم',999),
 ('50000000-0000-4000-8000-000000000041','50000000-0000-4000-8000-000000000030','ISSUANCE','Unpublished Fee','غير منشورة',50);
INSERT INTO public.card_benefits(id,card_id,slug,name_en,name_ar,display_order) VALUES
 ('50000000-0000-4000-8000-000000000042','50000000-0000-4000-8000-000000000030','airport-50','Airport benefit','ميزة',1),
 ('50000000-0000-4000-8000-000000000043','50000000-0000-4000-8000-000000000030','draft-benefit-50','Draft benefit','مسودة',2);
INSERT INTO public.reward_rules(
 id,card_id,reward_category_id,reward_type,calculation_method,reward_value,priority
) VALUES
 ('50000000-0000-4000-8000-000000000044','50000000-0000-4000-8000-000000000030',
  '50000000-0000-4000-8000-000000000014','POINTS','FIXED',2,1),
 ('50000000-0000-4000-8000-000000000045','50000000-0000-4000-8000-000000000030',
  NULL,'CASHBACK','PERCENTAGE',5,2);
INSERT INTO public.reward_targets(id,reward_rule_id,target_type,merchant_category_id,category_slug) VALUES
 ('50000000-0000-4000-8000-000000000046','50000000-0000-4000-8000-000000000044','MCC','50000000-0000-4000-8000-000000000013',NULL),
 ('50000000-0000-4000-8000-000000000047','50000000-0000-4000-8000-000000000044','CATEGORY',NULL,'unpublished-target-50');
INSERT INTO public.card_eligibility_requirements(
 id,card_id,requirement_type,name_en,name_ar,minimum_age,priority
) VALUES
 ('50000000-0000-4000-8000-000000000048','50000000-0000-4000-8000-000000000030','AGE','Age','العمر',21,1),
 ('50000000-0000-4000-8000-000000000049','50000000-0000-4000-8000-000000000030','OTHER','Draft requirement','مسودة',NULL,2);
INSERT INTO public.merchants(id,slug,display_name_en,display_name_ar) VALUES
 ('50000000-0000-4000-8000-000000000050','merchant-50','Live Draft Merchant','تاجر'),
 ('50000000-0000-4000-8000-000000000051','unpublished-merchant-50','Unpublished Merchant','غير منشور');
INSERT INTO public.merchant_category_assignments(merchant_id,merchant_category_id) VALUES
 ('50000000-0000-4000-8000-000000000050','50000000-0000-4000-8000-000000000013'),
 ('50000000-0000-4000-8000-000000000051','50000000-0000-4000-8000-000000000013');

INSERT INTO public.catalog_source_provenance(
 id,target_entity_type,card_id,source_type,authority_level,source_locator_type,
 source_locator,source_title,source_owner,retrieved_at,verification_status,
 verified_at,verified_by_user_id
) VALUES (
 '50000000-0000-4000-8000-000000000060','CARD','50000000-0000-4000-8000-000000000030',
 'OFFICIAL_PRODUCT_PAGE','OFFICIAL_PRIMARY','URL','https://example.invalid/card-50',
 'Official Card 50','Bank 50',now()-interval '1 day','VERIFIED',now(),'50000000-0000-4000-8000-000000000001'
);

INSERT INTO public.catalog_publication_versions(
 id,target_entity_type,bank_id,card_id,card_fee_id,card_benefit_id,reward_rule_id,
 loyalty_program_id,card_eligibility_requirement_id,merchant_id,version_number,
 content_snapshot,change_summary,source_provenance_id
) VALUES
 ('50000000-0000-4000-8000-000000000100','BANK','50000000-0000-4000-8000-000000000020',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000020","slug":"bank-50","name_en":"Approved Bank","name_ar":"البنك المعتمد"}','bank publication',NULL),
 ('50000000-0000-4000-8000-000000000101','CARD',NULL,'50000000-0000-4000-8000-000000000030',NULL,NULL,NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000030","bank_id":"50000000-0000-4000-8000-000000000020","card_network_id":"50000000-0000-4000-8000-000000000012","currency_id":"50000000-0000-4000-8000-000000000011","loyalty_program_id":"50000000-0000-4000-8000-000000000021","slug":"published-card-50","name_en":"Approved Card","name_ar":"البطاقة المعتمدة","annual_fee":100,"internal_secret":"never expose"}','card publication','50000000-0000-4000-8000-000000000060'),
 ('50000000-0000-4000-8000-000000000102','CARD',NULL,'50000000-0000-4000-8000-000000000031',NULL,NULL,NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000031","bank_id":"50000000-0000-4000-8000-000000000020","card_network_id":"50000000-0000-4000-8000-000000000012","currency_id":"50000000-0000-4000-8000-000000000011","slug":"draft-card-50","name_en":"Draft"}','draft card',NULL),
 ('50000000-0000-4000-8000-000000000103','CARD',NULL,'50000000-0000-4000-8000-000000000032',NULL,NULL,NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000032","bank_id":"50000000-0000-4000-8000-000000000020","card_network_id":"50000000-0000-4000-8000-000000000012","currency_id":"50000000-0000-4000-8000-000000000011","slug":"future-card-50","name_en":"Future"}','future card',NULL),
 ('50000000-0000-4000-8000-000000000112','CARD',NULL,'50000000-0000-4000-8000-000000000033',NULL,NULL,NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000033","bank_id":"50000000-0000-4000-8000-000000000020","card_network_id":"50000000-0000-4000-8000-000000000012","currency_id":"50000000-0000-4000-8000-000000000011","slug":"expired-card-50","name_en":"Expired"}','expired card',NULL),
 ('50000000-0000-4000-8000-000000000113','CARD',NULL,'50000000-0000-4000-8000-000000000034',NULL,NULL,NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000034","bank_id":"50000000-0000-4000-8000-000000000020","card_network_id":"50000000-0000-4000-8000-000000000012","currency_id":"50000000-0000-4000-8000-000000000011","slug":"scheduled-unpublished-card-50","name_en":"Scheduled Unpublished"}','scheduled unpublication card',NULL),
 ('50000000-0000-4000-8000-000000000104','CARD_FEE',NULL,NULL,'50000000-0000-4000-8000-000000000040',NULL,NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000040","card_id":"50000000-0000-4000-8000-000000000030","fee_type":"ANNUAL","name_en":"Approved Fee","name_ar":"رسوم معتمدة","amount":100}','fee publication',NULL),
 ('50000000-0000-4000-8000-000000000105','CARD_FEE',NULL,NULL,'50000000-0000-4000-8000-000000000041',NULL,NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000041","card_id":"50000000-0000-4000-8000-000000000030","fee_type":"ISSUANCE","name_en":"Draft Fee"}','draft fee',NULL),
 ('50000000-0000-4000-8000-000000000106','CARD_BENEFIT',NULL,NULL,NULL,'50000000-0000-4000-8000-000000000042',NULL,NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000042","card_id":"50000000-0000-4000-8000-000000000030","slug":"airport-50","name_en":"Approved Benefit","name_ar":"ميزة معتمدة"}','benefit publication',NULL),
 ('50000000-0000-4000-8000-000000000107','REWARD_RULE',NULL,NULL,NULL,NULL,'50000000-0000-4000-8000-000000000044',NULL,NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000044","card_id":"50000000-0000-4000-8000-000000000030","reward_type":"POINTS","calculation_method":"FIXED","reward_value":1,"priority":1,"target_ids":["50000000-0000-4000-8000-000000000046"]}','reward publication',NULL),
 ('50000000-0000-4000-8000-000000000108','CARD_ELIGIBILITY_REQUIREMENT',NULL,NULL,NULL,NULL,NULL,NULL,'50000000-0000-4000-8000-000000000048',NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000048","card_id":"50000000-0000-4000-8000-000000000030","requirement_type":"AGE","name_en":"Approved Age","name_ar":"العمر المعتمد","minimum_age":21,"priority":1,"is_mandatory":true}','eligibility publication',NULL),
 ('50000000-0000-4000-8000-000000000109','LOYALTY_PROGRAM',NULL,NULL,NULL,NULL,NULL,'50000000-0000-4000-8000-000000000021',NULL,NULL,1,
  '{"id":"50000000-0000-4000-8000-000000000021","slug":"points-50","name_en":"Approved Points","name_ar":"نقاط معتمدة","type":"BANK_POINTS"}','loyalty publication',NULL),
 ('50000000-0000-4000-8000-000000000110','MERCHANT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'50000000-0000-4000-8000-000000000050',1,
  '{"id":"50000000-0000-4000-8000-000000000050","slug":"merchant-50","display_name_en":"Approved Merchant","display_name_ar":"تاجر معتمد","merchant_classification":"RETAIL","internal_secret":"never expose"}','merchant publication',NULL);

UPDATE public.catalog_publication_versions SET lifecycle_status='IN_REVIEW'
WHERE id IN (
 '50000000-0000-4000-8000-000000000100','50000000-0000-4000-8000-000000000101',
 '50000000-0000-4000-8000-000000000104','50000000-0000-4000-8000-000000000106',
 '50000000-0000-4000-8000-000000000107','50000000-0000-4000-8000-000000000108',
 '50000000-0000-4000-8000-000000000109','50000000-0000-4000-8000-000000000110'
);
UPDATE public.catalog_publication_versions SET lifecycle_status='APPROVED'
WHERE id IN (
 '50000000-0000-4000-8000-000000000100','50000000-0000-4000-8000-000000000101',
 '50000000-0000-4000-8000-000000000104','50000000-0000-4000-8000-000000000106',
 '50000000-0000-4000-8000-000000000107','50000000-0000-4000-8000-000000000108',
 '50000000-0000-4000-8000-000000000109','50000000-0000-4000-8000-000000000110'
);
UPDATE public.catalog_publication_versions
SET lifecycle_status='PUBLISHED',published_at=now(),effective_from=now()-interval '1 hour'
WHERE id IN (
 '50000000-0000-4000-8000-000000000100','50000000-0000-4000-8000-000000000101',
 '50000000-0000-4000-8000-000000000104','50000000-0000-4000-8000-000000000106',
 '50000000-0000-4000-8000-000000000107','50000000-0000-4000-8000-000000000108',
 '50000000-0000-4000-8000-000000000109','50000000-0000-4000-8000-000000000110'
);
UPDATE public.catalog_publication_versions SET lifecycle_status='IN_REVIEW'
WHERE id='50000000-0000-4000-8000-000000000103';
UPDATE public.catalog_publication_versions SET lifecycle_status='APPROVED'
WHERE id='50000000-0000-4000-8000-000000000103';
UPDATE public.catalog_publication_versions
SET lifecycle_status='PUBLISHED',published_at=now(),effective_from=now()+interval '1 day'
WHERE id='50000000-0000-4000-8000-000000000103';
UPDATE public.catalog_publication_versions SET lifecycle_status='IN_REVIEW'
WHERE id IN ('50000000-0000-4000-8000-000000000112','50000000-0000-4000-8000-000000000113');
UPDATE public.catalog_publication_versions SET lifecycle_status='APPROVED'
WHERE id IN ('50000000-0000-4000-8000-000000000112','50000000-0000-4000-8000-000000000113');
UPDATE public.catalog_publication_versions
SET lifecycle_status='PUBLISHED',published_at=now()-interval '2 days',
    effective_from=now()-interval '2 days',effective_until=now()-interval '1 day'
WHERE id='50000000-0000-4000-8000-000000000112';
UPDATE public.catalog_publication_versions
SET lifecycle_status='PUBLISHED',published_at=now()-interval '2 days',
    effective_from=now()-interval '2 days',scheduled_publish_at=now()-interval '2 days',
    scheduled_unpublish_at=now()-interval '1 day'
WHERE id='50000000-0000-4000-8000-000000000113';

SET ROLE anon;
SELECT is(public.get_published_card_detail('draft-card-50'),NULL::jsonb,'draft card is not exposed');
SELECT is(public.get_published_card_detail('future-card-50'),NULL::jsonb,'future effective window is not exposed');
SELECT is(public.get_published_card_detail('expired-card-50'),NULL::jsonb,'expired effective window is not exposed');
SELECT is(public.get_published_card_detail('scheduled-unpublished-card-50'),NULL::jsonb,'elapsed scheduled unpublication is enforced');
SELECT is(public.get_published_card_detail('INVALID SLUG'),NULL::jsonb,'invalid slug fails closed');
SELECT ok(public.get_published_card_detail('published-card-50') IS NOT NULL,'anon reads published detail');
SELECT is(public.get_published_card_detail('published-card-50')#>>'{card,name_en}','Approved Card','snapshot value wins over mutable core draft');
SELECT is(public.get_published_card_detail('published-card-50')#>>'{card,annual_fee}','100','approved fee summary is from snapshot');
SELECT ok(NOT (public.get_published_card_detail('published-card-50')->'card' ? 'internal_secret'),'unapproved snapshot keys are not exposed');
SELECT is(public.get_published_card_detail('published-card-50')#>>'{bank,name_en}','Approved Bank','published bank relationship is exposed');
SELECT is(public.get_published_card_detail('published-card-50')#>>'{loyalty_program,name_en}','Approved Points','published loyalty relationship is exposed');
SELECT is(jsonb_array_length(public.get_published_card_detail('published-card-50')->'fees'),1,'unpublished fee is excluded');
SELECT is(public.get_published_card_detail('published-card-50')#>>'{fees,0,name_en}','Approved Fee','published fee snapshot is exposed');
SELECT is(jsonb_array_length(public.get_published_card_detail('published-card-50')->'benefits'),1,'unpublished benefit is excluded');
SELECT is(jsonb_array_length(public.get_published_card_detail('published-card-50')->'reward_rules'),1,'unpublished reward rule is excluded');
SELECT is(jsonb_array_length(public.get_published_card_detail('published-card-50')#>'{reward_rules,0,targets}'),1,'only snapshot-approved reward target is exposed');
SELECT is(jsonb_array_length(public.get_published_card_detail('published-card-50')->'eligibility'),1,'unpublished eligibility is excluded');
SELECT is(jsonb_array_length(public.get_published_card_detail('published-card-50')->'merchants'),1,'only independently published merchant is exposed');
SELECT is(public.get_published_card_detail('published-card-50')#>>'{merchants,0,display_name_en}','Approved Merchant','merchant data comes from published snapshot');
SELECT ok(NOT (public.get_published_card_detail('published-card-50')->'merchants'->0 ? 'internal_secret'),'merchant snapshot is explicitly allowlisted');
SELECT is(public.get_published_card_detail('published-card-50')#>>'{provenance,source_title}','Official Card 50','verified active provenance exposes safe fields');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub='50000000-0000-4000-8000-000000000002';
SELECT ok(public.get_published_card_detail('published-card-50') IS NOT NULL,'ordinary authenticated reader uses the same interface');
SELECT is((SELECT count(*)::integer FROM public.catalog_publication_versions),0,'authenticated reader cannot bypass governance RLS');
SELECT is((SELECT count(*)::integer FROM public.catalog_source_provenance),0,'authenticated reader cannot bypass provenance RLS');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub='50000000-0000-4000-8000-000000000001';
SELECT is(public.unpublish_catalog_version('50000000-0000-4000-8000-000000000101',false,'test suspension'),'SUSPENDED','controlled suspension succeeds');
SELECT is(public.get_published_card_detail('published-card-50'),NULL::jsonb,'suspended card disappears immediately');
SELECT is(public.publish_catalog_version('50000000-0000-4000-8000-000000000101'),'PUBLISHED','controlled republish succeeds');
RESET ROLE;

INSERT INTO public.catalog_publication_versions(
 id,target_entity_type,card_id,version_number,content_snapshot,change_summary
) VALUES (
 '50000000-0000-4000-8000-000000000111','CARD','50000000-0000-4000-8000-000000000030',2,
 '{"id":"50000000-0000-4000-8000-000000000030","bank_id":"50000000-0000-4000-8000-000000000020","card_network_id":"50000000-0000-4000-8000-000000000012","currency_id":"50000000-0000-4000-8000-000000000011","loyalty_program_id":"50000000-0000-4000-8000-000000000021","slug":"published-card-50","name_en":"Rollback Snapshot","name_ar":"نسخة الاستعادة","annual_fee":80}',
 'rollback replacement'
);
UPDATE public.catalog_publication_versions SET lifecycle_status='IN_REVIEW'
WHERE id='50000000-0000-4000-8000-000000000111';
UPDATE public.catalog_publication_versions SET lifecycle_status='APPROVED'
WHERE id='50000000-0000-4000-8000-000000000111';

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub='50000000-0000-4000-8000-000000000001';
SELECT is(public.rollback_catalog_version(
 '50000000-0000-4000-8000-000000000101','50000000-0000-4000-8000-000000000111','rollback test'
),'PUBLISHED','controlled rollback publishes replacement');
SELECT is(public.get_published_card_detail('published-card-50')#>>'{card,name_en}','Rollback Snapshot','rollback switches public snapshot atomically');
SELECT is(public.unpublish_catalog_version('50000000-0000-4000-8000-000000000111',true,'archive test'),'ARCHIVED','controlled archival succeeds');
SELECT is(public.get_published_card_detail('published-card-50'),NULL::jsonb,'archived card is not exposed');
RESET ROLE;

SELECT * FROM finish();
ROLLBACK;

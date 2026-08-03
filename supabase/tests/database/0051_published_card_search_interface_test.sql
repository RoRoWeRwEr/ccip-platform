BEGIN;

SELECT plan(39);

SELECT has_function('public', 'search_published_cards',
  ARRAY['text','text','text','text','numeric','text','numeric','text','text','numeric','text','integer','integer'],
  'published card search function exists');
SELECT function_returns('public', 'search_published_cards',
  ARRAY['text','text','text','text','numeric','text','numeric','text','text','numeric','text','integer','integer'],
  'jsonb', 'search function returns jsonb');
SELECT ok((SELECT prosecdef AND proconfig @> ARRAY['search_path=pg_catalog']
  FROM pg_catalog.pg_proc WHERE oid =
  'public.search_published_cards(text,text,text,text,numeric,text,numeric,text,text,numeric,text,integer,integer)'::regprocedure),
  'function is SECURITY DEFINER with pinned search_path');
SELECT ok(NOT has_function_privilege('public',
  'public.search_published_cards(text,text,text,text,numeric,text,numeric,text,text,numeric,text,integer,integer)', 'EXECUTE'),
  'PUBLIC cannot execute');
SELECT ok(has_function_privilege('anon',
  'public.search_published_cards(text,text,text,text,numeric,text,numeric,text,text,numeric,text,integer,integer)', 'EXECUTE'),
  'anon can execute');
SELECT ok(has_function_privilege('authenticated',
  'public.search_published_cards(text,text,text,text,numeric,text,numeric,text,text,numeric,text,integer,integer)', 'EXECUTE'),
  'authenticated can execute');
SELECT ok(NOT has_table_privilege('anon','public.catalog_publication_versions','SELECT'),
  'anon retains no publication-version grant');
SELECT ok(NOT has_table_privilege('anon','public.reward_rules','SELECT'),
  'anon retains no reward-rule grant');
SELECT ok(NOT has_table_privilege('authenticated','public.reward_rules','SELECT'),
  'ordinary authenticated role receives no direct reward grant');
SELECT has_index('public','catalog_publication_versions','idx_catalog_publication_versions_public_read',
  'effective published-read index exists');
SELECT ok(to_regprocedure('public.get_published_card_detail(text)') IS NOT NULL,
  'migration 0050 detail interface remains present');

INSERT INTO auth.users(id,email) VALUES
 ('51000000-0000-4000-8000-000000000001','reader51@example.invalid');
INSERT INTO public.countries(id,code,slug,name_en,name_ar) VALUES
 ('51000000-0000-4000-8000-000000000010','SA','saudi-arabia-51','Saudi Arabia','السعودية');
INSERT INTO public.currencies(id,code,slug,name_en,name_ar,symbol) VALUES
 ('51000000-0000-4000-8000-000000000011','SAR','riyal-51','Saudi Riyal','ريال','SAR');
INSERT INTO public.card_networks(id,slug,name_en,name_ar) VALUES
 ('51000000-0000-4000-8000-000000000012','visa-51','Visa','فيزا'),
 ('51000000-0000-4000-8000-000000000013','mastercard-51','Mastercard','ماستركارد');
INSERT INTO public.reward_categories(id,slug,name_en,name_ar) VALUES
 ('51000000-0000-4000-8000-000000000014','travel-51','Travel','سفر');
INSERT INTO public.merchant_categories(id,code,slug,name_en,name_ar) VALUES
 ('51000000-0000-4000-8000-000000000015','5411','groceries-51','Groceries','بقالة');
INSERT INTO public.banks(id,country_id,slug,name_en,name_ar) VALUES
 ('51000000-0000-4000-8000-000000000020','51000000-0000-4000-8000-000000000010','bank-a-51','Mutable Bank A','بنك أ'),
 ('51000000-0000-4000-8000-000000000021','51000000-0000-4000-8000-000000000010','bank-b-51','Bank B','بنك ب');
INSERT INTO public.cards(id,bank_id,card_network_id,currency_id,slug,name_en,name_ar,
 target_user,annual_fee,minimum_salary,availability_status,is_active,published_at) VALUES
 ('51000000-0000-4000-8000-000000000030','51000000-0000-4000-8000-000000000020','51000000-0000-4000-8000-000000000012','51000000-0000-4000-8000-000000000011','alpha-51','Mutable Alpha','ألفا','GENERAL',999,9000,'AVAILABLE',true,now()),
 ('51000000-0000-4000-8000-000000000031','51000000-0000-4000-8000-000000000021','51000000-0000-4000-8000-000000000013','51000000-0000-4000-8000-000000000011','beta-51','Beta','بيتا','STUDENT',0,3000,'AVAILABLE',true,now()),
 ('51000000-0000-4000-8000-000000000032','51000000-0000-4000-8000-000000000020','51000000-0000-4000-8000-000000000012','51000000-0000-4000-8000-000000000011','gamma-51','Gamma','جاما','BUSINESS',200,NULL,'AVAILABLE',true,now()),
 ('51000000-0000-4000-8000-000000000033','51000000-0000-4000-8000-000000000020','51000000-0000-4000-8000-000000000012','51000000-0000-4000-8000-000000000011','draft-51','Draft','مسودة','GENERAL',0,NULL,'AVAILABLE',true,now()),
 ('51000000-0000-4000-8000-000000000034','51000000-0000-4000-8000-000000000020','51000000-0000-4000-8000-000000000012','51000000-0000-4000-8000-000000000011','future-51','Future','مستقبل','GENERAL',0,NULL,'AVAILABLE',true,now()),
 ('51000000-0000-4000-8000-000000000035','51000000-0000-4000-8000-000000000020','51000000-0000-4000-8000-000000000012','51000000-0000-4000-8000-000000000011','expired-51','Expired','منتهية','GENERAL',0,NULL,'AVAILABLE',true,now()),
 ('51000000-0000-4000-8000-000000000036','51000000-0000-4000-8000-000000000020','51000000-0000-4000-8000-000000000012','51000000-0000-4000-8000-000000000011','rejected-51','Rejected','مرفوضة','GENERAL',0,NULL,'AVAILABLE',true,now());
INSERT INTO public.reward_rules(id,card_id,reward_category_id,reward_type,calculation_method,reward_value,priority) VALUES
 ('51000000-0000-4000-8000-000000000040','51000000-0000-4000-8000-000000000030','51000000-0000-4000-8000-000000000014','POINTS','FIXED',99,1),
 ('51000000-0000-4000-8000-000000000041','51000000-0000-4000-8000-000000000031',NULL,'CASHBACK','PERCENTAGE',99,1),
 ('51000000-0000-4000-8000-000000000042','51000000-0000-4000-8000-000000000032',NULL,'MILES','FIXED',50,1);
INSERT INTO public.reward_targets(id,reward_rule_id,target_type,merchant_category_id) VALUES
 ('51000000-0000-4000-8000-000000000043','51000000-0000-4000-8000-000000000040','MCC','51000000-0000-4000-8000-000000000015');

INSERT INTO public.catalog_publication_versions(id,target_entity_type,bank_id,card_id,reward_rule_id,version_number,content_snapshot,change_summary) VALUES
 ('51000000-0000-4000-8000-000000000100','BANK','51000000-0000-4000-8000-000000000020',NULL,NULL,1,'{"id":"51000000-0000-4000-8000-000000000020","slug":"bank-a-51","name_en":"Approved Bank A","name_ar":"البنك أ"}','bank a'),
 ('51000000-0000-4000-8000-000000000101','BANK','51000000-0000-4000-8000-000000000021',NULL,NULL,1,'{"id":"51000000-0000-4000-8000-000000000021","slug":"bank-b-51","name_en":"Approved Bank B","name_ar":"البنك ب"}','bank b'),
 ('51000000-0000-4000-8000-000000000102','CARD',NULL,'51000000-0000-4000-8000-000000000030',NULL,1,'{"id":"51000000-0000-4000-8000-000000000030","bank_id":"51000000-0000-4000-8000-000000000020","card_network_id":"51000000-0000-4000-8000-000000000012","currency_id":"51000000-0000-4000-8000-000000000011","slug":"alpha-51","name_en":"Approved Alpha","name_ar":"ألفا المعتمدة","target_user":"GENERAL","annual_fee":100,"minimum_salary":5000,"internal_secret":"hidden"}','alpha'),
 ('51000000-0000-4000-8000-000000000103','CARD',NULL,'51000000-0000-4000-8000-000000000031',NULL,1,'{"id":"51000000-0000-4000-8000-000000000031","bank_id":"51000000-0000-4000-8000-000000000021","card_network_id":"51000000-0000-4000-8000-000000000013","currency_id":"51000000-0000-4000-8000-000000000011","slug":"beta-51","name_en":"Beta","name_ar":"بيتا","target_user":"STUDENT","annual_fee":0,"minimum_salary":3000}','beta'),
 ('51000000-0000-4000-8000-000000000104','CARD',NULL,'51000000-0000-4000-8000-000000000032',NULL,1,'{"id":"51000000-0000-4000-8000-000000000032","bank_id":"51000000-0000-4000-8000-000000000020","card_network_id":"51000000-0000-4000-8000-000000000012","currency_id":"51000000-0000-4000-8000-000000000011","slug":"gamma-51","name_en":"Gamma","name_ar":"جاما","target_user":"BUSINESS","annual_fee":200}','gamma'),
 ('51000000-0000-4000-8000-000000000105','CARD',NULL,'51000000-0000-4000-8000-000000000033',NULL,1,'{"id":"51000000-0000-4000-8000-000000000033","bank_id":"51000000-0000-4000-8000-000000000020","card_network_id":"51000000-0000-4000-8000-000000000012","currency_id":"51000000-0000-4000-8000-000000000011","slug":"draft-51","name_en":"Draft"}','draft'),
 ('51000000-0000-4000-8000-000000000106','CARD',NULL,'51000000-0000-4000-8000-000000000034',NULL,1,'{"id":"51000000-0000-4000-8000-000000000034","bank_id":"51000000-0000-4000-8000-000000000020","card_network_id":"51000000-0000-4000-8000-000000000012","currency_id":"51000000-0000-4000-8000-000000000011","slug":"future-51","name_en":"Future"}','future'),
 ('51000000-0000-4000-8000-000000000107','CARD',NULL,'51000000-0000-4000-8000-000000000035',NULL,1,'{"id":"51000000-0000-4000-8000-000000000035","bank_id":"51000000-0000-4000-8000-000000000020","card_network_id":"51000000-0000-4000-8000-000000000012","currency_id":"51000000-0000-4000-8000-000000000011","slug":"expired-51","name_en":"Expired"}','expired'),
 ('51000000-0000-4000-8000-000000000108','CARD',NULL,'51000000-0000-4000-8000-000000000036',NULL,1,'{"id":"51000000-0000-4000-8000-000000000036","bank_id":"51000000-0000-4000-8000-000000000020","card_network_id":"51000000-0000-4000-8000-000000000012","currency_id":"51000000-0000-4000-8000-000000000011","slug":"rejected-51","name_en":"Rejected"}','rejected'),
 ('51000000-0000-4000-8000-000000000109','REWARD_RULE',NULL,NULL,'51000000-0000-4000-8000-000000000040',1,'{"id":"51000000-0000-4000-8000-000000000040","card_id":"51000000-0000-4000-8000-000000000030","reward_category_id":"51000000-0000-4000-8000-000000000014","reward_type":"POINTS","calculation_method":"FIXED","reward_value":2,"target_ids":["51000000-0000-4000-8000-000000000043"],"private_note":"hidden"}','points'),
 ('51000000-0000-4000-8000-000000000110','REWARD_RULE',NULL,NULL,'51000000-0000-4000-8000-000000000041',1,'{"id":"51000000-0000-4000-8000-000000000041","card_id":"51000000-0000-4000-8000-000000000031","reward_type":"CASHBACK","calculation_method":"PERCENTAGE","reward_value":5,"target_ids":[]}','cashback'),
 ('51000000-0000-4000-8000-000000000111','REWARD_RULE',NULL,NULL,'51000000-0000-4000-8000-000000000042',1,'{"id":"51000000-0000-4000-8000-000000000042","card_id":"51000000-0000-4000-8000-000000000032","reward_type":"MILES","calculation_method":"FIXED","reward_value":50,"target_ids":[]}','draft reward');

UPDATE public.catalog_publication_versions SET lifecycle_status='IN_REVIEW'
 WHERE id <> '51000000-0000-4000-8000-000000000105' AND id <> '51000000-0000-4000-8000-000000000111';
UPDATE public.catalog_publication_versions SET lifecycle_status='APPROVED'
 WHERE lifecycle_status='IN_REVIEW' AND id <> '51000000-0000-4000-8000-000000000108';
UPDATE public.catalog_publication_versions SET lifecycle_status='REJECTED',rejected_at=now(),rejection_reason='not approved'
 WHERE id='51000000-0000-4000-8000-000000000108';
UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=now(),effective_from=now()-interval '1 hour'
 WHERE lifecycle_status='APPROVED' AND id NOT IN ('51000000-0000-4000-8000-000000000106','51000000-0000-4000-8000-000000000107');
UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=now(),effective_from=now()+interval '1 day'
 WHERE id='51000000-0000-4000-8000-000000000106';
UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=now()-interval '2 days',effective_from=now()-interval '2 days',effective_until=now()-interval '1 day'
 WHERE id='51000000-0000-4000-8000-000000000107';

SET ROLE anon;
SELECT is(public.search_published_cards()#>>'{total_count}','3','anon sees only effective published cards');
SELECT is(public.search_published_cards()#>>'{items,0,card,name_en}','Approved Alpha','published snapshot wins over mutable core');
SELECT ok(NOT (public.search_published_cards()#>'{items,0,card}' ? 'internal_secret'),'card snapshot is explicitly allowlisted');
SELECT is(public.search_published_cards(requested_search=>'alpha')#>>'{total_count}','1','localized literal search works');
SELECT is(public.search_published_cards(requested_bank_slug=>'bank-b-51')#>>'{items,0,card,slug}','beta-51','bank filter uses published bank slug');
SELECT is(public.search_published_cards(requested_network_slug=>'mastercard-51')#>>'{total_count}','1','network filter works');
SELECT is(public.search_published_cards(requested_max_annual_fee=>50)#>>'{total_count}','1','annual-fee filter uses published value');
SELECT is(public.search_published_cards(requested_persona=>'STUDENT')#>>'{items,0,card,slug}','beta-51','persona filter works');
SELECT is(public.search_published_cards(requested_maximum_salary=>4000)#>>'{total_count}','1','salary eligibility filter works');
SELECT is(public.search_published_cards(requested_reward_type=>'POINTS')#>>'{items,0,card,slug}','alpha-51','published reward-type filter works');
SELECT is(public.search_published_cards(requested_reward_type=>'MILES')#>>'{total_count}','0','unpublished reward cannot match');
SELECT is(public.search_published_cards(requested_reward_category_slug=>'travel-51')#>>'{total_count}','1','reward-category filter works');
SELECT is(public.search_published_cards(requested_reward_category_slug=>'groceries-51')#>>'{total_count}','1','approved reward-target category filter works');
SELECT is(public.search_published_cards(requested_min_reward_value=>4)#>>'{items,0,card,slug}','beta-51','minimum reward-value filter uses published value');
SELECT ok(NOT (public.search_published_cards(requested_reward_type=>'POINTS')#>'{items,0,reward_summary,0}' ? 'private_note'),'reward snapshot is explicitly allowlisted');
SELECT is(public.search_published_cards(requested_sort=>'ANNUAL_FEE_ASC')#>>'{items,0,card,slug}','beta-51','annual-fee ascending sort works');
SELECT is(public.search_published_cards(requested_sort=>'ANNUAL_FEE_DESC')#>>'{items,0,card,slug}','gamma-51','annual-fee descending sort works');
SELECT is(public.search_published_cards(requested_sort=>'REWARD_VALUE_DESC')#>>'{items,0,card,slug}','beta-51','reward-value sort ignores unpublished reward');
SELECT is(public.search_published_cards(requested_sort=>'NAME_ASC',requested_page=>2,requested_page_size=>1)#>>'{items,0,card,slug}','beta-51','pagination follows stable sort');
SELECT is(public.search_published_cards(requested_page=>2,requested_page_size=>2)#>>'{total_count}','3','pagination preserves total count');
SELECT is(public.search_published_cards(requested_page=>2,requested_page_size=>2)#>>'{total_pages}','2','pagination reports total pages');
SELECT throws_ok('SELECT count(*) FROM public.catalog_publication_versions', '42501',
  'permission denied for table catalog_publication_versions', 'anon cannot bypass governance RLS');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub='51000000-0000-4000-8000-000000000001';
SELECT is(public.search_published_cards()#>>'{total_count}','3','ordinary authenticated reader gets the same published model');
SELECT throws_ok('SELECT count(*) FROM public.reward_rules', '42501',
  'permission denied for table reward_rules', 'authenticated reader cannot bypass reward RLS');
RESET ROLE;

UPDATE public.catalog_publication_versions SET lifecycle_status='SUSPENDED',suspended_at=now(),suspension_reason='test'
 WHERE id='51000000-0000-4000-8000-000000000102';
SET ROLE anon;
SELECT is(public.search_published_cards(requested_search=>'alpha')#>>'{total_count}','0','suspension removes a card immediately');
RESET ROLE;
UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',suspended_at=NULL,suspension_reason=NULL
 WHERE id='51000000-0000-4000-8000-000000000102';
UPDATE public.catalog_publication_versions
 SET scheduled_publish_at=now()-interval '2 hours',scheduled_unpublish_at=now()-interval '1 hour'
 WHERE id='51000000-0000-4000-8000-000000000104';
SET ROLE anon;
SELECT is(public.search_published_cards(requested_search=>'gamma')#>>'{total_count}','0','elapsed scheduled unpublication is enforced');
RESET ROLE;
UPDATE public.catalog_publication_versions SET scheduled_publish_at=NULL,scheduled_unpublish_at=NULL
 WHERE id='51000000-0000-4000-8000-000000000104';

UPDATE public.catalog_publication_versions SET lifecycle_status='SUSPENDED',suspended_at=now(),suspension_reason='replace'
 WHERE id='51000000-0000-4000-8000-000000000102';
INSERT INTO public.catalog_publication_versions(id,target_entity_type,card_id,version_number,content_snapshot,change_summary,rollback_of_version_id)
VALUES ('51000000-0000-4000-8000-000000000112','CARD','51000000-0000-4000-8000-000000000030',2,
 '{"id":"51000000-0000-4000-8000-000000000030","bank_id":"51000000-0000-4000-8000-000000000020","card_network_id":"51000000-0000-4000-8000-000000000012","currency_id":"51000000-0000-4000-8000-000000000011","slug":"alpha-51","name_en":"Rollback Alpha","name_ar":"ألفا الاستعادة","target_user":"GENERAL","annual_fee":100,"minimum_salary":5000}',
 'rollback publication','51000000-0000-4000-8000-000000000102');
UPDATE public.catalog_publication_versions SET lifecycle_status='IN_REVIEW' WHERE id='51000000-0000-4000-8000-000000000112';
UPDATE public.catalog_publication_versions SET lifecycle_status='APPROVED' WHERE id='51000000-0000-4000-8000-000000000112';
UPDATE public.catalog_publication_versions SET lifecycle_status='PUBLISHED',published_at=now(),effective_from=now()-interval '1 minute'
 WHERE id='51000000-0000-4000-8000-000000000112';
SET ROLE anon;
SELECT is(public.search_published_cards(requested_search=>'rollback')#>>'{items,0,card,name_en}','Rollback Alpha','rollback publication replaces the suspended version');
RESET ROLE;

UPDATE public.catalog_publication_versions SET lifecycle_status='ARCHIVED',archived_at=now(),unpublished_at=now()
 WHERE id='51000000-0000-4000-8000-000000000103';
SET ROLE anon;
SELECT is(public.search_published_cards(requested_search=>'beta')#>>'{total_count}','0','unpublication and archival remove a card');
RESET ROLE;

SELECT * FROM finish();
ROLLBACK;

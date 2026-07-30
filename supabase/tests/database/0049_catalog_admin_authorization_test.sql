BEGIN;

SELECT plan(49);

SELECT has_table('public', 'catalog_administrator_scope_assignments',
    'catalog administrator scope assignments table exists');
SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class
      WHERE oid = 'public.catalog_administrator_scope_assignments'::regclass),
    'catalog administrator scope assignments has RLS'
);

INSERT INTO auth.users (id, email) VALUES
    ('a4900000-0000-4000-8000-000000000001', 'platform49@example.invalid'),
    ('a4900000-0000-4000-8000-000000000002', 'bank1-requester49@example.invalid'),
    ('a4900000-0000-4000-8000-000000000003', 'bank1-reviewer49@example.invalid'),
    ('a4900000-0000-4000-8000-000000000004', 'bank1-approver49@example.invalid'),
    ('a4900000-0000-4000-8000-000000000005', 'bank2-admin49@example.invalid'),
    ('a4900000-0000-4000-8000-000000000006', 'global-admin49@example.invalid'),
    ('a4900000-0000-4000-8000-000000000007', 'legacy-admin49@example.invalid'),
    ('a4900000-0000-4000-8000-000000000008', 'outsider49@example.invalid');

INSERT INTO public.user_platform_role_assignments (id, user_id, role_id) VALUES
    ('49000000-0000-4000-8000-000000000001', 'a4900000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000001'),
    ('49000000-0000-4000-8000-000000000002', 'a4900000-0000-4000-8000-000000000002', '42000000-0000-4000-8000-000000000002'),
    ('49000000-0000-4000-8000-000000000003', 'a4900000-0000-4000-8000-000000000003', '42000000-0000-4000-8000-000000000002'),
    ('49000000-0000-4000-8000-000000000004', 'a4900000-0000-4000-8000-000000000004', '42000000-0000-4000-8000-000000000002'),
    ('49000000-0000-4000-8000-000000000005', 'a4900000-0000-4000-8000-000000000005', '42000000-0000-4000-8000-000000000002'),
    ('49000000-0000-4000-8000-000000000006', 'a4900000-0000-4000-8000-000000000006', '42000000-0000-4000-8000-000000000002'),
    ('49000000-0000-4000-8000-000000000007', 'a4900000-0000-4000-8000-000000000007', '42000000-0000-4000-8000-000000000002');

INSERT INTO public.countries (id, code, slug, name_en, name_ar) VALUES
    ('c4900000-0000-4000-8000-000000000001', 'SA', 'saudi-arabia-49', 'Saudi Arabia', 'السعودية');
INSERT INTO public.currencies (id, code, slug, name_en, name_ar) VALUES
    ('c4900000-0000-4000-8000-000000000002', 'SAR', 'saudi-riyal-49', 'Saudi Riyal', 'ريال سعودي');
INSERT INTO public.card_networks (id, slug, name_en, name_ar) VALUES
    ('c4900000-0000-4000-8000-000000000003', 'visa-49', 'Visa', 'فيزا');
INSERT INTO public.banks (id, country_id, slug, name_en, name_ar) VALUES
    ('b4900000-0000-4000-8000-000000000001', 'c4900000-0000-4000-8000-000000000001', 'bank-one-49', 'Bank One', 'البنك الأول'),
    ('b4900000-0000-4000-8000-000000000002', 'c4900000-0000-4000-8000-000000000001', 'bank-two-49', 'Bank Two', 'البنك الثاني');
INSERT INTO public.cards (id, bank_id, card_network_id, currency_id, slug, name_en, name_ar) VALUES
    ('ca490000-0000-4000-8000-000000000001', 'b4900000-0000-4000-8000-000000000001', 'c4900000-0000-4000-8000-000000000003', 'c4900000-0000-4000-8000-000000000002', 'bank-one-card-49', 'Bank One Card', 'بطاقة البنك الأول'),
    ('ca490000-0000-4000-8000-000000000002', 'b4900000-0000-4000-8000-000000000002', 'c4900000-0000-4000-8000-000000000003', 'c4900000-0000-4000-8000-000000000002', 'bank-two-card-49', 'Bank Two Card', 'بطاقة البنك الثاني');
INSERT INTO public.card_fees (id,card_id,fee_type,name_en,name_ar,amount) VALUES
    ('cf490000-0000-4000-8000-000000000001','ca490000-0000-4000-8000-000000000001','ANNUAL','Annual fee','رسوم سنوية',500);
INSERT INTO public.card_benefits (id,card_id,slug,name_en,name_ar) VALUES
    ('cb490000-0000-4000-8000-000000000001','ca490000-0000-4000-8000-000000000001','benefit-49','Benefit','ميزة');
INSERT INTO public.reward_rules (id,card_id,reward_type,calculation_method,reward_value) VALUES
    ('ee490000-0000-4000-8000-000000000001','ca490000-0000-4000-8000-000000000001','CASHBACK','PERCENTAGE',1);
INSERT INTO public.card_eligibility_requirements
    (id,card_id,requirement_type,name_en,name_ar,minimum_age) VALUES
    ('ce490000-0000-4000-8000-000000000001','ca490000-0000-4000-8000-000000000001','AGE','Minimum age','الحد الأدنى للعمر',18);
INSERT INTO public.loyalty_programs (id,slug,name_en,name_ar,type) VALUES
    ('aa490000-0000-4000-8000-000000000001','shared-loyalty-49','Shared Loyalty','ولاء مشترك','BANK_POINTS');

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000001';
SELECT lives_ok(
    $$INSERT INTO public.catalog_administrator_scope_assignments
        (id, role_assignment_id, scope_type, bank_id, assignment_reason)
      VALUES
        ('49100000-0000-4000-8000-000000000002','49000000-0000-4000-8000-000000000002','BANK','b4900000-0000-4000-8000-000000000001','Bank one catalog duties'),
        ('49100000-0000-4000-8000-000000000003','49000000-0000-4000-8000-000000000003','BANK','b4900000-0000-4000-8000-000000000001','Bank one review duties'),
        ('49100000-0000-4000-8000-000000000004','49000000-0000-4000-8000-000000000004','BANK','b4900000-0000-4000-8000-000000000001','Bank one approval duties'),
        ('49100000-0000-4000-8000-000000000005','49000000-0000-4000-8000-000000000005','BANK','b4900000-0000-4000-8000-000000000002','Bank two catalog duties'),
        ('49100000-0000-4000-8000-000000000006','49000000-0000-4000-8000-000000000006','GLOBAL',NULL,'Platform catalog duties')$$,
    'platform administrator can assign BANK and GLOBAL catalog scopes'
);
SELECT is((SELECT count(*)::integer FROM public.catalog_administrator_scope_assignments), 5,
    'platform administrator can read all catalog scope assignments');
RESET ROLE;

SELECT throws_ok(
    $$INSERT INTO public.catalog_administrator_scope_assignments
        (role_assignment_id, scope_type, assignment_reason)
      VALUES ('49000000-0000-4000-8000-000000000002','BANK','missing bank')$$,
    '23514', NULL, 'BANK scope requires a bank'
);
SELECT throws_ok(
    $$INSERT INTO public.catalog_administrator_scope_assignments
        (role_assignment_id, scope_type, bank_id, assignment_reason)
      VALUES ('49000000-0000-4000-8000-000000000002','GLOBAL','b4900000-0000-4000-8000-000000000001','bad global')$$,
    '23514', NULL, 'GLOBAL scope rejects a bank identifier'
);
SELECT throws_ok(
    $$INSERT INTO public.catalog_administrator_scope_assignments
        (role_assignment_id, scope_type, assignment_reason)
      VALUES ('49000000-0000-4000-8000-000000000001','GLOBAL','wrong parent role')$$,
    '23514', NULL, 'scope assignment requires the CATALOG_ADMINISTRATOR role'
);

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000002';
SELECT is((SELECT count(*)::integer FROM public.catalog_administrator_scope_assignments), 0,
    'bank-scoped administrator cannot inspect scope assignments');
SELECT throws_ok(
    $$INSERT INTO public.catalog_administrator_scope_assignments
        (role_assignment_id, scope_type, assignment_reason)
      VALUES ('49000000-0000-4000-8000-000000000007','GLOBAL','self escalation')$$,
    '42501', NULL, 'bank-scoped administrator cannot assign GLOBAL scope');
SELECT ok(public.has_active_catalog_scope('b4900000-0000-4000-8000-000000000001'),
    'BANK scope authorizes its bank');
SELECT ok(NOT public.has_active_catalog_scope('b4900000-0000-4000-8000-000000000002'),
    'BANK scope rejects another bank');
SELECT ok(NOT public.has_active_catalog_scope(NULL),
    'BANK scope does not authorize GLOBAL resources');
SELECT ok(public.has_catalog_target_access('CARD','ca490000-0000-4000-8000-000000000001'),
    'card ownership resolves through the card bank foreign key');
SELECT ok(public.has_catalog_target_access('CARD_FEE','cf490000-0000-4000-8000-000000000001'),
    'card fee ownership resolves through its card and bank');
SELECT ok(public.has_catalog_target_access('CARD_BENEFIT','cb490000-0000-4000-8000-000000000001'),
    'card benefit ownership resolves through its card and bank');
SELECT ok(public.has_catalog_target_access('REWARD_RULE','ee490000-0000-4000-8000-000000000001'),
    'reward rule ownership resolves through its card and bank');
SELECT ok(public.has_catalog_target_access('CARD_ELIGIBILITY_REQUIREMENT','ce490000-0000-4000-8000-000000000001'),
    'eligibility ownership resolves through its card and bank');
SELECT ok(NOT public.has_catalog_target_access('LOYALTY_PROGRAM','aa490000-0000-4000-8000-000000000001'),
    'BANK scope cannot manage a shared loyalty program');
SELECT ok(NOT public.has_catalog_target_access('CARD','ca490000-0000-4000-8000-000000000002'),
    'card ownership rejects another bank');
SELECT ok(NOT public.has_catalog_target_access('ARBITRARY','ca490000-0000-4000-8000-000000000001'),
    'arbitrary entity types fail closed');
SELECT lives_ok(
    $$INSERT INTO public.catalog_source_provenance
        (id,target_entity_type,card_id,source_type,authority_level,source_locator,source_title,source_owner)
      VALUES ('49200000-0000-4000-8000-000000000001','CARD','ca490000-0000-4000-8000-000000000001','OFFICIAL_PRODUCT_PAGE','OFFICIAL_PRIMARY','https://bank-one.example/card','Bank One Card','Bank One')$$,
    'BANK scope can create provenance for its card');
SELECT throws_ok(
    $$INSERT INTO public.catalog_source_provenance
        (target_entity_type,card_id,source_type,authority_level,source_locator,source_title,source_owner)
      VALUES ('CARD','ca490000-0000-4000-8000-000000000002','OFFICIAL_PRODUCT_PAGE','OFFICIAL_PRIMARY','https://bank-two.example/card','Bank Two Card','Bank Two')$$,
    '42501', NULL, 'BANK scope cannot create provenance for another bank card');
SELECT throws_ok(
    $$INSERT INTO public.merchants(slug,display_name_en,display_name_ar)
      VALUES('bank-admin-merchant-49','Unauthorized Merchant','تاجر غير مصرح')$$,
    '42501', NULL, 'BANK scope cannot write GLOBAL merchant data');
SELECT throws_ok(
    $$UPDATE public.banks SET name_en='Direct write' WHERE id='b4900000-0000-4000-8000-000000000001'$$,
    '42501', NULL, '0049 does not grant direct writes to core catalog tables');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000006';
SELECT ok(public.has_active_catalog_scope(NULL), 'GLOBAL scope authorizes shared resources');
SELECT ok(public.has_active_catalog_scope('b4900000-0000-4000-8000-000000000002'),
    'GLOBAL scope authorizes every bank');
SELECT ok(public.has_catalog_target_access('LOYALTY_PROGRAM','aa490000-0000-4000-8000-000000000001'),
    'GLOBAL scope authorizes shared loyalty programs');
SELECT lives_ok(
    $$INSERT INTO public.merchants(id,slug,display_name_en,display_name_ar)
      VALUES('49300000-0000-4000-8000-000000000001','global-merchant-49','Global Merchant','تاجر عالمي')$$,
    'GLOBAL scope can create shared merchant data');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000007';
SELECT ok(NOT public.has_active_catalog_scope(NULL),
    'legacy unscoped CATALOG_ADMINISTRATOR assignment fails closed');
SELECT ok(NOT public.has_active_catalog_scope('b4900000-0000-4000-8000-000000000001'),
    'legacy unscoped assignment grants no bank access');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000001';
SELECT ok(public.has_active_catalog_scope(NULL),
    'PLATFORM_ADMINISTRATOR remains explicitly GLOBAL');
SELECT ok(public.has_active_catalog_scope('b4900000-0000-4000-8000-000000000002'),
    'PLATFORM_ADMINISTRATOR retains cross-bank access');
RESET ROLE;

-- Bank-scoped publication workflow, including scoped reviewer and approver.
SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000002';
SELECT lives_ok(
    $$INSERT INTO public.catalog_publication_versions
        (id,target_entity_type,card_id,version_number,content_snapshot,change_summary)
      VALUES('49400000-0000-4000-8000-000000000001','CARD','ca490000-0000-4000-8000-000000000001',1,'{"name":"bank-one-v1"}','Bank one publication')$$,
    'BANK scope can create a publication version for its card');
SELECT throws_ok(
    $$INSERT INTO public.catalog_publication_versions
        (target_entity_type,card_id,version_number,content_snapshot,change_summary)
      VALUES('CARD','ca490000-0000-4000-8000-000000000002',1,'{}','Other bank publication')$$,
    '42501', NULL, 'BANK scope cannot create another bank publication version');
SELECT throws_ok(
    $$SELECT public.submit_catalog_publication(
        '49400000-0000-4000-8000-000000000001',
        'a4900000-0000-4000-8000-000000000008',
        'a4900000-0000-4000-8000-000000000004')$$,
    '23514', NULL, 'requester cannot assign a reviewer without target scope');
SELECT lives_ok(
    $$SELECT public.submit_catalog_publication(
        '49400000-0000-4000-8000-000000000001',
        'a4900000-0000-4000-8000-000000000003',
        'a4900000-0000-4000-8000-000000000004')$$,
    'BANK-scoped requester can submit its publication');
RESET ROLE;

SELECT id AS request_id
FROM public.catalog_publication_requests
WHERE publication_version_id = '49400000-0000-4000-8000-000000000001'
\gset

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000005';
SELECT throws_ok(
    format(
        'SELECT public.decide_catalog_publication(%L::uuid,''APPROVED'',''cross-bank attempt'')',
        :'request_id'
    ),
    '42501', NULL, 'another bank administrator cannot act on the workflow');
SELECT is((SELECT count(*)::integer FROM public.catalog_publication_requests), 0,
    'another bank administrator cannot read publication requests');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000003';
SELECT is(
    public.decide_catalog_publication(
        (SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='49400000-0000-4000-8000-000000000001'),
        'APPROVED','reviewed'),
    'IN_REVIEW', 'BANK-scoped reviewer can complete review');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000004';
SELECT is(
    public.decide_catalog_publication(
        (SELECT id FROM public.catalog_publication_requests WHERE publication_version_id='49400000-0000-4000-8000-000000000001'),
        'APPROVED','approved'),
    'APPROVED', 'BANK-scoped final approver can approve');
SELECT is(public.publish_catalog_version('49400000-0000-4000-8000-000000000001'),
    'PUBLISHED', 'BANK-scoped administrator can publish its approved version');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000001';
SELECT lives_ok(
    $$UPDATE public.catalog_administrator_scope_assignments
         SET revoked_at=now(), revocation_reason='Bank assignment ended'
       WHERE id='49100000-0000-4000-8000-000000000005'$$,
    'platform administrator can revoke a catalog scope');
RESET ROLE;

SET ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'a4900000-0000-4000-8000-000000000005';
SELECT ok(NOT public.has_active_catalog_scope('b4900000-0000-4000-8000-000000000002'),
    'revoked BANK scope becomes inactive immediately');
RESET ROLE;

SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
         WHERE entity_type = 'catalog_administrator_scope_assignments'
           AND entity_id = '49100000-0000-4000-8000-000000000005'
           AND event_action = 'REVOKE'
    ),
    'scope revocation is centrally audited'
);

SELECT ok(
    EXISTS (
        SELECT 1 FROM public.audit_events
         WHERE entity_type = 'catalog_administrator_scope_assignments'
           AND entity_id = '49100000-0000-4000-8000-000000000002'
           AND event_action = 'CREATE'
    ),
    'scope assignment creation is centrally audited'
);
SELECT ok(
    (SELECT assigned_by_user_id = 'a4900000-0000-4000-8000-000000000001'
       FROM public.catalog_administrator_scope_assignments
      WHERE id = '49100000-0000-4000-8000-000000000002'),
    'scope assignment actor is database-stamped'
);
SELECT ok(
    (SELECT prosecdef AND proconfig @> ARRAY['search_path=pg_catalog']
       FROM pg_catalog.pg_proc
      WHERE oid = 'public.has_active_catalog_scope(uuid)'::regprocedure),
    'scope helper is hardened SECURITY DEFINER'
);
SELECT ok(
    NOT has_function_privilege('anon','public.has_active_catalog_scope(uuid)','EXECUTE'),
    'anonymous callers cannot execute the scope helper'
);
SELECT ok(
    NOT has_function_privilege('authenticated','public.catalog_target_bank_id(text,uuid)','EXECUTE'),
    'internal target resolver is not directly executable by authenticated users'
);

SELECT * FROM finish();
ROLLBACK;

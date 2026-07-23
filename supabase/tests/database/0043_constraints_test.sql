-- Migration 0043 — feature flag schema and validation coverage.
BEGIN;

SELECT plan(12);

SELECT has_table('public', 'feature_flags', 'feature_flags table exists');
SELECT col_is_pk('public', 'feature_flags', 'id', 'feature_flags.id is the primary key');
SELECT ok(
    (SELECT relrowsecurity FROM pg_catalog.pg_class WHERE oid = 'public.feature_flags'::regclass),
    'row-level security is enabled on feature_flags'
);

SELECT throws_ok(
    $$INSERT INTO public.feature_flags (flag_key, display_name, administrative_reason)
      VALUES ('Invalid Key', 'Invalid key', 'constraint test')$$,
    '23514', NULL, 'invalid machine-readable keys are rejected'
);

INSERT INTO public.feature_flags (
    flag_key, display_name, lifecycle_status, rollout_percentage, administrative_reason
) VALUES ('tests.valid-key', 'Valid key', 'ACTIVE', 0.00, 'constraint test');

SELECT throws_ok(
    $$INSERT INTO public.feature_flags (flag_key, display_name, administrative_reason)
      VALUES ('tests.valid-key', 'Duplicate key', 'constraint test')$$,
    '23505', NULL, 'duplicate flag keys are rejected'
);

SELECT lives_ok(
    $$INSERT INTO public.feature_flags
        (flag_key, display_name, lifecycle_status, rollout_percentage, administrative_reason)
      VALUES ('tests.rollout-zero', 'Zero rollout', 'ACTIVE', 0.00, 'constraint test')$$,
    'zero percent is a valid rollout boundary'
);

SELECT lives_ok(
    $$INSERT INTO public.feature_flags
        (flag_key, display_name, lifecycle_status, rollout_percentage, administrative_reason)
      VALUES ('tests.rollout-full', 'Full rollout', 'ACTIVE', 100.00, 'constraint test')$$,
    'one hundred percent is a valid rollout boundary'
);

SELECT throws_ok(
    $$INSERT INTO public.feature_flags
        (flag_key, display_name, rollout_percentage, administrative_reason)
      VALUES ('tests.rollout-negative', 'Negative rollout', -0.01, 'constraint test')$$,
    '23514', NULL, 'negative rollout percentages are rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.feature_flags
        (flag_key, display_name, rollout_percentage, administrative_reason)
      VALUES ('tests.rollout-over', 'Over rollout', 100.01, 'constraint test')$$,
    '23514', NULL, 'rollout percentages over one hundred are rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.feature_flags
        (flag_key, display_name, activates_at, expires_at, administrative_reason)
      VALUES ('tests.bad-window', 'Bad window', now(), now(), 'constraint test')$$,
    '23514', NULL, 'an expiry at activation is rejected'
);

SELECT throws_ok(
    $$INSERT INTO public.feature_flags
        (flag_key, display_name, activates_at, expires_at, administrative_reason)
      VALUES ('tests.reverse-window', 'Reverse window', now(), now() - interval '1 second', 'constraint test')$$,
    '23514', NULL, 'an expiry before activation is rejected'
);

SELECT lives_ok(
    $$INSERT INTO public.feature_flags
        (flag_key, display_name, activates_at, expires_at, administrative_reason)
      VALUES ('tests.valid-window', 'Valid window', now(), now() + interval '1 day', 'constraint test')$$,
    'a strictly increasing schedule window is accepted'
);

SELECT * FROM finish();
ROLLBACK;

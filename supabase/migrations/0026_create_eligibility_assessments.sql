CREATE TABLE public.eligibility_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    financial_profile_id UUID NOT NULL
        REFERENCES public.customer_financial_profiles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    assessment_status public.eligibility_assessment_status
        NOT NULL DEFAULT 'insufficient_information',

    confidence_level public.recommendation_confidence_level
        NOT NULL DEFAULT 'very_low',

    confidence_score NUMERIC(5, 2),

    eligibility_score NUMERIC(5, 2),

    requirements_total INTEGER NOT NULL DEFAULT 0,

    requirements_passed INTEGER NOT NULL DEFAULT 0,

    requirements_failed INTEGER NOT NULL DEFAULT 0,

    requirements_conditionally_passed INTEGER NOT NULL DEFAULT 0,

    requirements_unknown INTEGER NOT NULL DEFAULT 0,

    requirements_not_applicable INTEGER NOT NULL DEFAULT 0,

    hard_requirements_total INTEGER NOT NULL DEFAULT 0,

    hard_requirements_passed INTEGER NOT NULL DEFAULT 0,

    hard_requirements_failed INTEGER NOT NULL DEFAULT 0,

    primary_exclusion_reason public.recommendation_exclusion_reason,

    monthly_income_used NUMERIC(14, 2),

    minimum_required_income NUMERIC(14, 2),

    income_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    calculated_age SMALLINT,

    minimum_required_age SMALLINT,

    maximum_allowed_age SMALLINT,

    salary_transfer_satisfied BOOLEAN,

    employment_requirement_satisfied BOOLEAN,

    nationality_requirement_satisfied BOOLEAN,

    residency_requirement_satisfied BOOLEAN,

    customer_segment_requirement_satisfied BOOLEAN,

    banking_relationship_requirement_satisfied BOOLEAN,

    income_requirement_satisfied BOOLEAN,

    age_requirement_satisfied BOOLEAN,

    manual_review_required BOOLEAN NOT NULL DEFAULT FALSE,

    manual_review_reason_en TEXT,

    manual_review_reason_ar TEXT,

    assessed_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    assessment_version TEXT NOT NULL DEFAULT '1.0',

    assessment_method TEXT NOT NULL DEFAULT 'RULE_BASED',

    expires_at TIMESTAMPTZ,

    source_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    input_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_eligibility_assessments_confidence_score
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_eligibility_assessments_eligibility_score
        CHECK (
            eligibility_score IS NULL
            OR eligibility_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_eligibility_assessments_requirement_counts
        CHECK (
            requirements_total >= 0
            AND requirements_passed >= 0
            AND requirements_failed >= 0
            AND requirements_conditionally_passed >= 0
            AND requirements_unknown >= 0
            AND requirements_not_applicable >= 0
            AND hard_requirements_total >= 0
            AND hard_requirements_passed >= 0
            AND hard_requirements_failed >= 0
        ),

    CONSTRAINT chk_eligibility_assessments_requirement_count_total
        CHECK (
            requirements_passed
            + requirements_failed
            + requirements_conditionally_passed
            + requirements_unknown
            + requirements_not_applicable
            <= requirements_total
        ),

    CONSTRAINT chk_eligibility_assessments_hard_requirement_total
        CHECK (
            hard_requirements_passed
            + hard_requirements_failed
            <= hard_requirements_total
        ),

    CONSTRAINT chk_eligibility_assessments_hard_vs_all
        CHECK (
            hard_requirements_total <= requirements_total
        ),

    CONSTRAINT chk_eligibility_assessments_income_values
        CHECK (
            (
                monthly_income_used IS NULL
                OR monthly_income_used >= 0
            )
            AND
            (
                minimum_required_income IS NULL
                OR minimum_required_income >= 0
            )
        ),

    CONSTRAINT chk_eligibility_assessments_income_currency
        CHECK (
            (
                monthly_income_used IS NULL
                AND minimum_required_income IS NULL
                AND income_currency_id IS NULL
            )
            OR
            (
                income_currency_id IS NOT NULL
                AND (
                    monthly_income_used IS NOT NULL
                    OR minimum_required_income IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_eligibility_assessments_age
        CHECK (
            (
                calculated_age IS NULL
                OR calculated_age BETWEEN 0 AND 130
            )
            AND
            (
                minimum_required_age IS NULL
                OR minimum_required_age BETWEEN 0 AND 130
            )
            AND
            (
                maximum_allowed_age IS NULL
                OR maximum_allowed_age BETWEEN 0 AND 130
            )
        ),

    CONSTRAINT chk_eligibility_assessments_age_range
        CHECK (
            minimum_required_age IS NULL
            OR maximum_allowed_age IS NULL
            OR maximum_allowed_age >= minimum_required_age
        ),

    CONSTRAINT chk_eligibility_assessments_manual_review
        CHECK (
            manual_review_required = FALSE
            OR assessment_status = 'manual_review_required'
        ),

    CONSTRAINT chk_eligibility_assessments_manual_review_reason
        CHECK (
            manual_review_required = FALSE
            OR manual_review_reason_en IS NOT NULL
            OR manual_review_reason_ar IS NOT NULL
        ),

    CONSTRAINT chk_eligibility_assessments_version
        CHECK (
            length(trim(assessment_version)) > 0
        ),

    CONSTRAINT chk_eligibility_assessments_method
        CHECK (
            assessment_method IN (
                'RULE_BASED',
                'MANUAL',
                'HYBRID',
                'IMPORTED',
                'TEST'
            )
        ),

    CONSTRAINT chk_eligibility_assessments_expiry
        CHECK (
            expires_at IS NULL
            OR expires_at >= assessed_at
        ),

    CONSTRAINT chk_eligibility_assessments_source_snapshot
        CHECK (
            jsonb_typeof(source_snapshot) = 'object'
        ),

    CONSTRAINT chk_eligibility_assessments_input_snapshot
        CHECK (
            jsonb_typeof(input_snapshot) = 'object'
        ),

    CONSTRAINT chk_eligibility_assessments_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.eligibility_requirement_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    eligibility_assessment_id UUID NOT NULL
        REFERENCES public.eligibility_assessments(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    eligibility_requirement_id UUID
        REFERENCES public.card_eligibility_requirements(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    requirement_code TEXT NOT NULL,

    requirement_type TEXT NOT NULL,

    requirement_result public.eligibility_requirement_result
        NOT NULL DEFAULT 'unknown',

    is_hard_requirement BOOLEAN NOT NULL DEFAULT FALSE,

    is_exclusion_trigger BOOLEAN NOT NULL DEFAULT FALSE,

    exclusion_reason public.recommendation_exclusion_reason,

    customer_value_numeric NUMERIC(18, 6),

    required_minimum_numeric NUMERIC(18, 6),

    required_maximum_numeric NUMERIC(18, 6),

    customer_value_text TEXT,

    required_value_text TEXT,

    customer_values JSONB,

    required_values JSONB,

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    matched BOOLEAN,

    result_score NUMERIC(5, 2),

    confidence_score NUMERIC(5, 2),

    explanation_en TEXT,

    explanation_ar TEXT,

    missing_information_en TEXT,

    missing_information_ar TEXT,

    evaluation_method TEXT NOT NULL DEFAULT 'RULE_BASED',

    evaluated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    rule_version TEXT NOT NULL DEFAULT '1.0',

    evaluation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_eligibility_requirement_assessments
        UNIQUE (
            eligibility_assessment_id,
            requirement_code
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_code
        CHECK (
            requirement_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_type
        CHECK (
            requirement_type IN (
                'MINIMUM_INCOME',
                'MAXIMUM_INCOME',
                'SALARY_TRANSFER',
                'EMPLOYMENT_STATUS',
                'EMPLOYMENT_SECTOR',
                'EMPLOYER',
                'EMPLOYMENT_TENURE',
                'MINIMUM_AGE',
                'MAXIMUM_AGE',
                'NATIONALITY',
                'RESIDENCY',
                'CUSTOMER_SEGMENT',
                'BANKING_RELATIONSHIP',
                'MINIMUM_ASSETS',
                'MINIMUM_NET_WORTH',
                'EXISTING_ACCOUNT',
                'INVITATION_ONLY',
                'CREDIT_ASSESSMENT',
                'DOCUMENTATION',
                'OTHER'
            )
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_exclusion
        CHECK (
            is_exclusion_trigger = FALSE
            OR is_hard_requirement = TRUE
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_exclusion_reason
        CHECK (
            exclusion_reason IS NULL
            OR requirement_result = 'failed'
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_numeric_range
        CHECK (
            required_minimum_numeric IS NULL
            OR required_maximum_numeric IS NULL
            OR required_maximum_numeric >= required_minimum_numeric
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_customer_minimum
        CHECK (
            customer_value_numeric IS NULL
            OR required_minimum_numeric IS NULL
            OR matched IS DISTINCT FROM TRUE
            OR customer_value_numeric >= required_minimum_numeric
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_customer_maximum
        CHECK (
            customer_value_numeric IS NULL
            OR required_maximum_numeric IS NULL
            OR matched IS DISTINCT FROM TRUE
            OR customer_value_numeric <= required_maximum_numeric
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_numeric_currency
        CHECK (
            currency_id IS NULL
            OR customer_value_numeric IS NOT NULL
            OR required_minimum_numeric IS NOT NULL
            OR required_maximum_numeric IS NOT NULL
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_customer_values
        CHECK (
            customer_values IS NULL
            OR jsonb_typeof(customer_values) IN (
                'array',
                'object',
                'string',
                'number',
                'boolean'
            )
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_required_values
        CHECK (
            required_values IS NULL
            OR jsonb_typeof(required_values) IN (
                'array',
                'object',
                'string',
                'number',
                'boolean'
            )
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_result_score
        CHECK (
            result_score IS NULL
            OR result_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_matched_result
        CHECK (
            matched IS NULL
            OR (
                matched = TRUE
                AND requirement_result IN (
                    'passed',
                    'conditionally_passed',
                    'not_applicable'
                )
            )
            OR (
                matched = FALSE
                AND requirement_result IN (
                    'failed',
                    'unknown'
                )
            )
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_evaluation_method
        CHECK (
            evaluation_method IN (
                'RULE_BASED',
                'MANUAL',
                'HYBRID',
                'IMPORTED',
                'TEST'
            )
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_rule_version
        CHECK (
            length(trim(rule_version)) > 0
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_details
        CHECK (
            jsonb_typeof(evaluation_details) = 'object'
        ),

    CONSTRAINT chk_eligibility_requirement_assessments_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE INDEX idx_eligibility_assessments_financial_profile
ON public.eligibility_assessments(financial_profile_id);

CREATE INDEX idx_eligibility_assessments_card
ON public.eligibility_assessments(card_id);

CREATE INDEX idx_eligibility_assessments_profile_card
ON public.eligibility_assessments(
    financial_profile_id,
    card_id,
    assessed_at DESC
);

CREATE INDEX idx_eligibility_assessments_status
ON public.eligibility_assessments(
    assessment_status,
    confidence_level
);

CREATE INDEX idx_eligibility_assessments_score
ON public.eligibility_assessments(
    eligibility_score DESC
)
WHERE eligibility_score IS NOT NULL;

CREATE INDEX idx_eligibility_assessments_manual_review
ON public.eligibility_assessments(assessed_at DESC)
WHERE manual_review_required = TRUE;

CREATE INDEX idx_eligibility_assessments_current
ON public.eligibility_assessments(
    financial_profile_id,
    card_id,
    assessed_at DESC
)
WHERE is_current = TRUE;

CREATE UNIQUE INDEX uq_eligibility_assessments_current_profile_card
ON public.eligibility_assessments(
    financial_profile_id,
    card_id
)
WHERE is_current = TRUE;

CREATE INDEX idx_eligibility_assessments_source_snapshot
ON public.eligibility_assessments
USING GIN (source_snapshot);

CREATE INDEX idx_eligibility_assessments_input_snapshot
ON public.eligibility_assessments
USING GIN (input_snapshot);

CREATE INDEX idx_eligibility_assessments_metadata
ON public.eligibility_assessments
USING GIN (metadata);

CREATE INDEX idx_eligibility_requirement_assessments_assessment
ON public.eligibility_requirement_assessments(
    eligibility_assessment_id
);

CREATE INDEX idx_eligibility_requirement_assessments_requirement
ON public.eligibility_requirement_assessments(
    eligibility_requirement_id
)
WHERE eligibility_requirement_id IS NOT NULL;

CREATE INDEX idx_eligibility_requirement_assessments_code
ON public.eligibility_requirement_assessments(
    requirement_code
);

CREATE INDEX idx_eligibility_requirement_assessments_type_result
ON public.eligibility_requirement_assessments(
    requirement_type,
    requirement_result
);

CREATE INDEX idx_eligibility_requirement_assessments_failed
ON public.eligibility_requirement_assessments(
    eligibility_assessment_id,
    requirement_code
)
WHERE requirement_result = 'failed';

CREATE INDEX idx_eligibility_requirement_assessments_unknown
ON public.eligibility_requirement_assessments(
    eligibility_assessment_id,
    requirement_code
)
WHERE requirement_result = 'unknown';

CREATE INDEX idx_eligibility_requirement_assessments_hard
ON public.eligibility_requirement_assessments(
    eligibility_assessment_id,
    requirement_code
)
WHERE is_hard_requirement = TRUE;

CREATE INDEX idx_eligibility_requirement_assessments_details
ON public.eligibility_requirement_assessments
USING GIN (evaluation_details);

CREATE INDEX idx_eligibility_requirement_assessments_metadata
ON public.eligibility_requirement_assessments
USING GIN (metadata);

CREATE TRIGGER trg_eligibility_assessments_updated_at
BEFORE UPDATE
ON public.eligibility_assessments
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_eligibility_requirement_assessments_updated_at
BEFORE UPDATE
ON public.eligibility_requirement_assessments
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.eligibility_assessments IS
'Overall assessment of whether a customer financial profile satisfies the eligibility requirements of a card.';

COMMENT ON TABLE public.eligibility_requirement_assessments IS
'Requirement-level evaluation results supporting the overall card eligibility assessment.';

COMMENT ON COLUMN public.eligibility_assessments.assessment_status IS
'Overall eligibility conclusion after evaluating all available card requirements.';

COMMENT ON COLUMN public.eligibility_assessments.eligibility_score IS
'Normalized eligibility score between zero and one hundred. It does not replace mandatory eligibility rules.';

COMMENT ON COLUMN public.eligibility_assessments.is_current IS
'Identifies the current eligibility assessment for a financial profile and card. Historical assessments remain available with this value set to false.';

COMMENT ON COLUMN public.eligibility_assessments.source_snapshot IS
'Snapshot of card eligibility rules and source information used when the assessment was performed.';

COMMENT ON COLUMN public.eligibility_assessments.input_snapshot IS
'Snapshot of relevant customer inputs used to produce the assessment.';

COMMENT ON COLUMN public.eligibility_requirement_assessments.is_hard_requirement IS
'Indicates that failure of this requirement can prevent the card from being recommended.';

COMMENT ON COLUMN public.eligibility_requirement_assessments.is_exclusion_trigger IS
'Indicates that failure of this mandatory requirement should exclude the card from recommendation results.';

COMMENT ON COLUMN public.eligibility_requirement_assessments.matched IS
'Indicates whether the available customer value matched the corresponding requirement. Null means the comparison could not be determined.';

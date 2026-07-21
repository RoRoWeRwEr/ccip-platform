CREATE TABLE public.card_comparisons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    financial_profile_id UUID
        REFERENCES public.customer_financial_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    spending_profile_id UUID
        REFERENCES public.customer_spending_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    preference_profile_id UUID
        REFERENCES public.customer_preferences(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_run_id UUID
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    source_collection_id UUID
        REFERENCES public.user_card_collections(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    comparison_reference TEXT NOT NULL,

    comparison_name TEXT,

    comparison_name_ar TEXT,

    comparison_type TEXT NOT NULL DEFAULT 'STANDARD',

    comparison_status TEXT NOT NULL DEFAULT 'DRAFT',

    comparison_source TEXT NOT NULL DEFAULT 'CARD_COMPARISON',

    comparison_context TEXT,

    comparison_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    primary_card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    winning_card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    selected_card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    winner_selection_method TEXT,

    winner_confidence_score NUMERIC(5, 2),

    card_count INTEGER NOT NULL DEFAULT 0,

    maximum_card_count INTEGER NOT NULL DEFAULT 5,

    active_item_count INTEGER NOT NULL DEFAULT 0,

    evaluation_method TEXT NOT NULL DEFAULT 'WEIGHTED_SCORE',

    evaluation_version TEXT NOT NULL DEFAULT '1.0',

    overall_comparison_score NUMERIC(9, 4),

    estimated_best_first_year_value NUMERIC(18, 6),

    estimated_best_ongoing_value NUMERIC(18, 6),

    estimated_value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    estimated_annual_savings NUMERIC(18, 6),

    estimated_savings_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    customer_decision TEXT,

    customer_decision_reason_code TEXT,

    customer_decision_notes TEXT,

    advisor_recommendation TEXT,

    advisor_notes TEXT,

    session_reference TEXT,

    journey_reference TEXT,

    correlation_id TEXT,

    share_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    share_token TEXT,

    share_expires_at TIMESTAMPTZ,

    is_public BOOLEAN NOT NULL DEFAULT FALSE,

    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,

    is_locked BOOLEAN NOT NULL DEFAULT FALSE,

    locked_at TIMESTAMPTZ,

    locked_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    is_archived BOOLEAN NOT NULL DEFAULT FALSE,

    archived_at TIMESTAMPTZ,

    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    deleted_at TIMESTAMPTZ,

    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    last_viewed_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    comparison_criteria JSONB NOT NULL DEFAULT '{}'::JSONB,

    customer_priorities JSONB NOT NULL DEFAULT '{}'::JSONB,

    scoring_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    comparison_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    decision_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    display_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    snapshot_data JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_comparisons_reference
        UNIQUE (
            comparison_reference
        ),

    CONSTRAINT uq_card_comparisons_share_token
        UNIQUE (
            share_token
        ),

    CONSTRAINT chk_card_comparisons_reference
        CHECK (
            comparison_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_card_comparisons_name
        CHECK (
            comparison_name IS NULL
            OR length(trim(comparison_name)) > 0
        ),

    CONSTRAINT chk_card_comparisons_name_ar
        CHECK (
            comparison_name_ar IS NULL
            OR length(trim(comparison_name_ar)) > 0
        ),

    CONSTRAINT chk_card_comparisons_type
        CHECK (
            comparison_type IN (
                'STANDARD',
                'PERSONALIZED',
                'RECOMMENDATION_BASED',
                'TRAVEL',
                'CASHBACK',
                'REWARDS',
                'LOW_FEE',
                'PREMIUM',
                'ELIGIBILITY',
                'APPLICATION',
                'ADVISOR',
                'CUSTOM',
                'TEST'
            )
        ),

    CONSTRAINT chk_card_comparisons_status
        CHECK (
            comparison_status IN (
                'DRAFT',
                'ACTIVE',
                'EVALUATING',
                'COMPLETED',
                'DECIDED',
                'EXPIRED',
                'ARCHIVED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_card_comparisons_source
        CHECK (
            comparison_source IN (
                'CARD_COMPARISON',
                'RECOMMENDATION_LIST',
                'RECOMMENDATION_DETAIL',
                'CARD_DETAIL',
                'SAVED_CARDS',
                'COLLECTION',
                'SEARCH_RESULTS',
                'ADVISOR',
                'ADMIN',
                'API',
                'IMPORT',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_comparisons_context
        CHECK (
            comparison_context IS NULL
            OR comparison_context IN (
                'RESEARCH',
                'SHORTLISTING',
                'APPLICATION_DECISION',
                'CARD_REPLACEMENT',
                'PORTFOLIO_OPTIMIZATION',
                'ADVISOR_REVIEW',
                'BENEFIT_ANALYSIS',
                'FEE_ANALYSIS',
                'REWARD_ANALYSIS',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_comparisons_winner_method
        CHECK (
            winner_selection_method IS NULL
            OR winner_selection_method IN (
                'HIGHEST_SCORE',
                'HIGHEST_NET_VALUE',
                'LOWEST_COST',
                'BEST_ELIGIBILITY',
                'BEST_PREFERENCE_MATCH',
                'CUSTOMER_SELECTED',
                'ADVISOR_SELECTED',
                'MANUAL',
                'HYBRID',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_comparisons_winner_confidence
        CHECK (
            winner_confidence_score IS NULL
            OR winner_confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparisons_card_count
        CHECK (
            card_count >= 0
        ),

    CONSTRAINT chk_card_comparisons_maximum_card_count
        CHECK (
            maximum_card_count BETWEEN 2 AND 20
        ),

    CONSTRAINT chk_card_comparisons_active_item_count
        CHECK (
            active_item_count >= 0
            AND active_item_count <= card_count
        ),

    CONSTRAINT chk_card_comparisons_card_limit
        CHECK (
            card_count <= maximum_card_count
        ),

    CONSTRAINT chk_card_comparisons_evaluation_method
        CHECK (
            evaluation_method IN (
                'WEIGHTED_SCORE',
                'NET_VALUE',
                'MULTI_CRITERIA',
                'RECOMMENDATION_SCORE',
                'CUSTOMER_PRIORITY',
                'ADVISOR_ASSESSMENT',
                'HYBRID',
                'MANUAL',
                'NONE'
            )
        ),

    CONSTRAINT chk_card_comparisons_evaluation_version
        CHECK (
            length(trim(evaluation_version)) > 0
        ),

    CONSTRAINT chk_card_comparisons_overall_score
        CHECK (
            overall_comparison_score IS NULL
            OR overall_comparison_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparisons_best_value_currency
        CHECK (
            (
                estimated_best_first_year_value IS NULL
                AND estimated_best_ongoing_value IS NULL
                AND estimated_value_currency_id IS NULL
            )
            OR
            (
                estimated_value_currency_id IS NOT NULL
                AND (
                    estimated_best_first_year_value IS NOT NULL
                    OR estimated_best_ongoing_value IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_card_comparisons_savings_currency
        CHECK (
            (
                estimated_annual_savings IS NULL
                AND estimated_savings_currency_id IS NULL
            )
            OR
            (
                estimated_annual_savings IS NOT NULL
                AND estimated_savings_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_comparisons_customer_decision
        CHECK (
            customer_decision IS NULL
            OR customer_decision IN (
                'SELECTED_WINNER',
                'SELECTED_ALTERNATIVE',
                'NEEDS_MORE_RESEARCH',
                'NO_SUITABLE_CARD',
                'DEFERRED',
                'APPLIED',
                'ACQUIRED',
                'REJECTED_ALL',
                'UNDECIDED'
            )
        ),

    CONSTRAINT chk_card_comparisons_decision_reason
        CHECK (
            customer_decision_reason_code IS NULL
            OR customer_decision_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_card_comparisons_decision_notes
        CHECK (
            customer_decision_notes IS NULL
            OR length(trim(customer_decision_notes)) > 0
        ),

    CONSTRAINT chk_card_comparisons_advisor_notes
        CHECK (
            advisor_notes IS NULL
            OR length(trim(advisor_notes)) > 0
        ),

    CONSTRAINT chk_card_comparisons_share
        CHECK (
            share_enabled = FALSE
            OR share_token IS NOT NULL
        ),

    CONSTRAINT chk_card_comparisons_share_token
        CHECK (
            share_token IS NULL
            OR share_token ~ '^[A-Za-z0-9_-]{16,128}$'
        ),

    CONSTRAINT chk_card_comparisons_share_expiry
        CHECK (
            share_expires_at IS NULL
            OR share_enabled = TRUE
        ),

    CONSTRAINT chk_card_comparisons_public
        CHECK (
            is_public = FALSE
            OR share_enabled = TRUE
        ),

    CONSTRAINT chk_card_comparisons_anonymous
        CHECK (
            is_anonymous = FALSE
            OR user_id IS NULL
        ),

    CONSTRAINT chk_card_comparisons_locked
        CHECK (
            (
                is_locked = FALSE
                AND locked_at IS NULL
                AND locked_by IS NULL
            )
            OR
            (
                is_locked = TRUE
                AND locked_at IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_comparisons_archived
        CHECK (
            (
                is_archived = FALSE
                AND archived_at IS NULL
            )
            OR
            (
                is_archived = TRUE
                AND archived_at IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_comparisons_deleted
        CHECK (
            (
                is_deleted = FALSE
                AND deleted_at IS NULL
            )
            OR
            (
                is_deleted = TRUE
                AND deleted_at IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_comparisons_deleted_archived
        CHECK (
            is_deleted = FALSE
            OR is_archived = TRUE
        ),

    CONSTRAINT chk_card_comparisons_last_viewed
        CHECK (
            last_viewed_at IS NULL
            OR last_viewed_at >= started_at
        ),

    CONSTRAINT chk_card_comparisons_completed
        CHECK (
            completed_at IS NULL
            OR completed_at >= started_at
        ),

    CONSTRAINT chk_card_comparisons_expiry
        CHECK (
            expires_at IS NULL
            OR expires_at >= started_at
        ),

    CONSTRAINT chk_card_comparisons_criteria
        CHECK (
            jsonb_typeof(comparison_criteria) = 'object'
        ),

    CONSTRAINT chk_card_comparisons_priorities
        CHECK (
            jsonb_typeof(customer_priorities) = 'object'
        ),

    CONSTRAINT chk_card_comparisons_scoring
        CHECK (
            jsonb_typeof(scoring_configuration) = 'object'
        ),

    CONSTRAINT chk_card_comparisons_summary
        CHECK (
            jsonb_typeof(comparison_summary) = 'object'
        ),

    CONSTRAINT chk_card_comparisons_decision_summary
        CHECK (
            jsonb_typeof(decision_summary) = 'object'
        ),

    CONSTRAINT chk_card_comparisons_display
        CHECK (
            jsonb_typeof(display_configuration) = 'object'
        ),

    CONSTRAINT chk_card_comparisons_snapshot
        CHECK (
            jsonb_typeof(snapshot_data) = 'object'
        ),

    CONSTRAINT chk_card_comparisons_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.card_comparison_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    comparison_id UUID NOT NULL
        REFERENCES public.card_comparisons(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_result_id UUID
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_run_card_id UUID
        REFERENCES public.recommendation_run_cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    saved_card_id UUID
        REFERENCES public.user_saved_cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    item_reference TEXT NOT NULL,

    item_status TEXT NOT NULL DEFAULT 'ACTIVE',

    item_source TEXT NOT NULL DEFAULT 'MANUAL',

    display_position INTEGER NOT NULL DEFAULT 1,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    is_winner BOOLEAN NOT NULL DEFAULT FALSE,

    is_selected BOOLEAN NOT NULL DEFAULT FALSE,

    is_eliminated BOOLEAN NOT NULL DEFAULT FALSE,

    elimination_reason_code TEXT,

    elimination_reason_text TEXT,

    recommendation_rank NUMERIC(9, 4),

    recommendation_score NUMERIC(9, 4),

    eligibility_status TEXT,

    eligibility_score NUMERIC(5, 2),

    eligibility_confidence_score NUMERIC(5, 2),

    estimated_first_year_reward_value NUMERIC(18, 6),

    estimated_first_year_benefit_value NUMERIC(18, 6),

    estimated_first_year_cost NUMERIC(18, 6),

    estimated_first_year_net_value NUMERIC(18, 6),

    estimated_ongoing_annual_value NUMERIC(18, 6),

    value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    annual_fee NUMERIC(18, 6),

    annual_fee_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    welcome_offer_value NUMERIC(18, 6),

    welcome_offer_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    total_score NUMERIC(9, 4),

    value_score NUMERIC(9, 4),

    rewards_score NUMERIC(9, 4),

    fees_score NUMERIC(9, 4),

    eligibility_score_component NUMERIC(9, 4),

    preference_score NUMERIC(9, 4),

    travel_score NUMERIC(9, 4),

    lifestyle_score NUMERIC(9, 4),

    simplicity_score NUMERIC(9, 4),

    confidence_score NUMERIC(5, 2),

    score_rank INTEGER,

    value_rank INTEGER,

    fee_rank INTEGER,

    eligibility_rank INTEGER,

    preference_rank INTEGER,

    strengths JSONB NOT NULL DEFAULT '[]'::JSONB,

    weaknesses JSONB NOT NULL DEFAULT '[]'::JSONB,

    differentiators JSONB NOT NULL DEFAULT '[]'::JSONB,

    missing_data JSONB NOT NULL DEFAULT '[]'::JSONB,

    comparison_values JSONB NOT NULL DEFAULT '{}'::JSONB,

    score_breakdown JSONB NOT NULL DEFAULT '{}'::JSONB,

    card_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    evaluation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    customer_notes TEXT,

    advisor_notes TEXT,

    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    evaluated_at TIMESTAMPTZ,

    removed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    CONSTRAINT uq_card_comparison_items_comparison_card
        UNIQUE (
            comparison_id,
            card_id
        ),

    CONSTRAINT uq_card_comparison_items_reference
        UNIQUE (
            item_reference
        ),

    CONSTRAINT chk_card_comparison_items_reference
        CHECK (
            item_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_card_comparison_items_status
        CHECK (
            item_status IN (
                'ACTIVE',
                'EVALUATING',
                'EVALUATED',
                'ELIMINATED',
                'SELECTED',
                'REMOVED',
                'ERROR'
            )
        ),

    CONSTRAINT chk_card_comparison_items_source
        CHECK (
            item_source IN (
                'MANUAL',
                'RECOMMENDATION',
                'SAVED_CARD',
                'COLLECTION',
                'SEARCH',
                'ADVISOR',
                'ADMIN',
                'API',
                'IMPORT',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_card_comparison_items_position
        CHECK (
            display_position > 0
        ),

    CONSTRAINT chk_card_comparison_items_primary
        CHECK (
            is_primary = FALSE
            OR item_status <> 'REMOVED'
        ),

    CONSTRAINT chk_card_comparison_items_winner
        CHECK (
            is_winner = FALSE
            OR (
                item_status IN (
                    'EVALUATED',
                    'SELECTED'
                )
                AND is_eliminated = FALSE
            )
        ),

    CONSTRAINT chk_card_comparison_items_selected
        CHECK (
            is_selected = FALSE
            OR (
                item_status = 'SELECTED'
                AND is_eliminated = FALSE
            )
        ),

    CONSTRAINT chk_card_comparison_items_eliminated
        CHECK (
            is_eliminated = FALSE
            OR item_status = 'ELIMINATED'
        ),

    CONSTRAINT chk_card_comparison_items_elimination_reason
        CHECK (
            elimination_reason_code IS NULL
            OR elimination_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_card_comparison_items_elimination_text
        CHECK (
            elimination_reason_text IS NULL
            OR length(trim(elimination_reason_text)) > 0
        ),

    CONSTRAINT chk_card_comparison_items_recommendation_rank
        CHECK (
            recommendation_rank IS NULL
            OR recommendation_rank > 0
        ),

    CONSTRAINT chk_card_comparison_items_recommendation_score
        CHECK (
            recommendation_score IS NULL
            OR recommendation_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_items_eligibility_status
        CHECK (
            eligibility_status IS NULL
            OR eligibility_status IN (
                'ELIGIBLE',
                'LIKELY_ELIGIBLE',
                'CONDITIONALLY_ELIGIBLE',
                'INSUFFICIENT_DATA',
                'LIKELY_INELIGIBLE',
                'INELIGIBLE',
                'NOT_ASSESSED'
            )
        ),

    CONSTRAINT chk_card_comparison_items_eligibility_score
        CHECK (
            eligibility_score IS NULL
            OR eligibility_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_items_eligibility_confidence
        CHECK (
            eligibility_confidence_score IS NULL
            OR eligibility_confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_items_value_currency
        CHECK (
            (
                estimated_first_year_reward_value IS NULL
                AND estimated_first_year_benefit_value IS NULL
                AND estimated_first_year_cost IS NULL
                AND estimated_first_year_net_value IS NULL
                AND estimated_ongoing_annual_value IS NULL
                AND value_currency_id IS NULL
            )
            OR
            (
                value_currency_id IS NOT NULL
                AND (
                    estimated_first_year_reward_value IS NOT NULL
                    OR estimated_first_year_benefit_value IS NOT NULL
                    OR estimated_first_year_cost IS NOT NULL
                    OR estimated_first_year_net_value IS NOT NULL
                    OR estimated_ongoing_annual_value IS NOT NULL
                )
            )
        ),

    CONSTRAINT chk_card_comparison_items_nonnegative_values
        CHECK (
            (
                estimated_first_year_reward_value IS NULL
                OR estimated_first_year_reward_value >= 0
            )
            AND
            (
                estimated_first_year_benefit_value IS NULL
                OR estimated_first_year_benefit_value >= 0
            )
            AND
            (
                estimated_first_year_cost IS NULL
                OR estimated_first_year_cost >= 0
            )
        ),

    CONSTRAINT chk_card_comparison_items_annual_fee
        CHECK (
            annual_fee IS NULL
            OR annual_fee >= 0
        ),

    CONSTRAINT chk_card_comparison_items_annual_fee_currency
        CHECK (
            (
                annual_fee IS NULL
                AND annual_fee_currency_id IS NULL
            )
            OR
            (
                annual_fee IS NOT NULL
                AND annual_fee_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_comparison_items_welcome_offer
        CHECK (
            welcome_offer_value IS NULL
            OR welcome_offer_value >= 0
        ),

    CONSTRAINT chk_card_comparison_items_welcome_offer_currency
        CHECK (
            (
                welcome_offer_value IS NULL
                AND welcome_offer_currency_id IS NULL
            )
            OR
            (
                welcome_offer_value IS NOT NULL
                AND welcome_offer_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_card_comparison_items_scores
        CHECK (
            (
                total_score IS NULL
                OR total_score BETWEEN 0 AND 100
            )
            AND
            (
                value_score IS NULL
                OR value_score BETWEEN 0 AND 100
            )
            AND
            (
                rewards_score IS NULL
                OR rewards_score BETWEEN 0 AND 100
            )
            AND
            (
                fees_score IS NULL
                OR fees_score BETWEEN 0 AND 100
            )
            AND
            (
                eligibility_score_component IS NULL
                OR eligibility_score_component BETWEEN 0 AND 100
            )
            AND
            (
                preference_score IS NULL
                OR preference_score BETWEEN 0 AND 100
            )
            AND
            (
                travel_score IS NULL
                OR travel_score BETWEEN 0 AND 100
            )
            AND
            (
                lifestyle_score IS NULL
                OR lifestyle_score BETWEEN 0 AND 100
            )
            AND
            (
                simplicity_score IS NULL
                OR simplicity_score BETWEEN 0 AND 100
            )
            AND
            (
                confidence_score IS NULL
                OR confidence_score BETWEEN 0 AND 100
            )
        ),

    CONSTRAINT chk_card_comparison_items_ranks
        CHECK (
            (
                score_rank IS NULL
                OR score_rank > 0
            )
            AND
            (
                value_rank IS NULL
                OR value_rank > 0
            )
            AND
            (
                fee_rank IS NULL
                OR fee_rank > 0
            )
            AND
            (
                eligibility_rank IS NULL
                OR eligibility_rank > 0
            )
            AND
            (
                preference_rank IS NULL
                OR preference_rank > 0
            )
        ),

    CONSTRAINT chk_card_comparison_items_strengths
        CHECK (
            jsonb_typeof(strengths) = 'array'
        ),

    CONSTRAINT chk_card_comparison_items_weaknesses
        CHECK (
            jsonb_typeof(weaknesses) = 'array'
        ),

    CONSTRAINT chk_card_comparison_items_differentiators
        CHECK (
            jsonb_typeof(differentiators) = 'array'
        ),

    CONSTRAINT chk_card_comparison_items_missing_data
        CHECK (
            jsonb_typeof(missing_data) = 'array'
        ),

    CONSTRAINT chk_card_comparison_items_values
        CHECK (
            jsonb_typeof(comparison_values) = 'object'
        ),

    CONSTRAINT chk_card_comparison_items_score_breakdown
        CHECK (
            jsonb_typeof(score_breakdown) = 'object'
        ),

    CONSTRAINT chk_card_comparison_items_snapshot
        CHECK (
            jsonb_typeof(card_snapshot) = 'object'
        ),

    CONSTRAINT chk_card_comparison_items_evaluation_details
        CHECK (
            jsonb_typeof(evaluation_details) = 'object'
        ),

    CONSTRAINT chk_card_comparison_items_customer_notes
        CHECK (
            customer_notes IS NULL
            OR length(trim(customer_notes)) > 0
        ),

    CONSTRAINT chk_card_comparison_items_advisor_notes
        CHECK (
            advisor_notes IS NULL
            OR length(trim(advisor_notes)) > 0
        ),

    CONSTRAINT chk_card_comparison_items_evaluated
        CHECK (
            evaluated_at IS NULL
            OR evaluated_at >= added_at
        ),

    CONSTRAINT chk_card_comparison_items_removed
        CHECK (
            removed_at IS NULL
            OR (
                item_status = 'REMOVED'
                AND removed_at >= added_at
            )
        ),

    CONSTRAINT chk_card_comparison_items_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.card_comparison_criteria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    comparison_id UUID NOT NULL
        REFERENCES public.card_comparisons(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    criterion_code TEXT NOT NULL,

    criterion_category TEXT NOT NULL,

    criterion_name_en TEXT NOT NULL,

    criterion_name_ar TEXT,

    criterion_type TEXT NOT NULL,

    evaluation_direction TEXT NOT NULL DEFAULT 'HIGHER_IS_BETTER',

    weight NUMERIC(9, 6) NOT NULL DEFAULT 1,

    importance_level TEXT NOT NULL DEFAULT 'MEDIUM',

    display_order INTEGER NOT NULL DEFAULT 1,

    source_entity TEXT,

    source_field TEXT,

    target_value_numeric NUMERIC(18, 6),

    target_value_text TEXT,

    target_value_boolean BOOLEAN,

    minimum_acceptable_value NUMERIC(18, 6),

    maximum_acceptable_value NUMERIC(18, 6),

    currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    is_required BOOLEAN NOT NULL DEFAULT FALSE,

    is_visible BOOLEAN NOT NULL DEFAULT TRUE,

    is_customer_editable BOOLEAN NOT NULL DEFAULT TRUE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_comparison_criteria_code
        UNIQUE (
            comparison_id,
            criterion_code
        ),

    CONSTRAINT chk_card_comparison_criteria_code
        CHECK (
            criterion_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_card_comparison_criteria_category
        CHECK (
            criterion_category IN (
                'ELIGIBILITY',
                'ANNUAL_FEE',
                'FOREIGN_TRANSACTION_FEE',
                'REWARDS',
                'CASHBACK',
                'WELCOME_OFFER',
                'LOUNGE',
                'TRAVEL',
                'DINING',
                'INSURANCE',
                'INSTALLMENTS',
                'NETWORK_BENEFITS',
                'FINANCIAL_VALUE',
                'BANK_RELATIONSHIP',
                'PREFERENCES',
                'SIMPLICITY',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_card_comparison_criteria_name_en
        CHECK (
            length(trim(criterion_name_en)) > 0
        ),

    CONSTRAINT chk_card_comparison_criteria_name_ar
        CHECK (
            criterion_name_ar IS NULL
            OR length(trim(criterion_name_ar)) > 0
        ),

    CONSTRAINT chk_card_comparison_criteria_type
        CHECK (
            criterion_type IN (
                'NUMERIC',
                'CURRENCY',
                'PERCENTAGE',
                'BOOLEAN',
                'TEXT',
                'ENUM',
                'COUNT',
                'RATING',
                'CALCULATED',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_card_comparison_criteria_direction
        CHECK (
            evaluation_direction IN (
                'HIGHER_IS_BETTER',
                'LOWER_IS_BETTER',
                'TARGET_IS_BETTER',
                'TRUE_IS_BETTER',
                'FALSE_IS_BETTER',
                'MATCH_IS_BETTER',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_card_comparison_criteria_weight
        CHECK (
            weight BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_criteria_importance
        CHECK (
            importance_level IN (
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_card_comparison_criteria_display_order
        CHECK (
            display_order > 0
        ),

    CONSTRAINT chk_card_comparison_criteria_target_value
        CHECK (
            (
                target_value_numeric IS NOT NULL
            )::INTEGER
            +
            (
                target_value_text IS NOT NULL
            )::INTEGER
            +
            (
                target_value_boolean IS NOT NULL
            )::INTEGER
            <= 1
        ),

    CONSTRAINT chk_card_comparison_criteria_range
        CHECK (
            minimum_acceptable_value IS NULL
            OR maximum_acceptable_value IS NULL
            OR maximum_acceptable_value >= minimum_acceptable_value
        ),

    CONSTRAINT chk_card_comparison_criteria_currency
        CHECK (
            currency_id IS NULL
            OR criterion_type = 'CURRENCY'
        ),

    CONSTRAINT chk_card_comparison_criteria_configuration
        CHECK (
            jsonb_typeof(configuration) = 'object'
        ),

    CONSTRAINT chk_card_comparison_criteria_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.card_comparison_item_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    comparison_item_id UUID NOT NULL
        REFERENCES public.card_comparison_items(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    comparison_criterion_id UUID NOT NULL
        REFERENCES public.card_comparison_criteria(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    raw_numeric_value NUMERIC(18, 6),

    raw_text_value TEXT,

    raw_boolean_value BOOLEAN,

    normalized_value NUMERIC(9, 4),

    raw_score NUMERIC(9, 4),

    weighted_score NUMERIC(12, 6),

    rank_within_criterion INTEGER,

    criterion_satisfied BOOLEAN,

    requirement_failed BOOLEAN NOT NULL DEFAULT FALSE,

    data_available BOOLEAN NOT NULL DEFAULT TRUE,

    confidence_score NUMERIC(5, 2),

    evaluation_status TEXT NOT NULL DEFAULT 'COMPLETED',

    evaluation_notes TEXT,

    evidence JSONB NOT NULL DEFAULT '[]'::JSONB,

    calculation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    evaluated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_card_comparison_item_scores_item_criterion
        UNIQUE (
            comparison_item_id,
            comparison_criterion_id
        ),

    CONSTRAINT chk_card_comparison_item_scores_raw_value
        CHECK (
            (
                raw_numeric_value IS NOT NULL
            )::INTEGER
            +
            (
                raw_text_value IS NOT NULL
            )::INTEGER
            +
            (
                raw_boolean_value IS NOT NULL
            )::INTEGER
            <= 1
        ),

    CONSTRAINT chk_card_comparison_item_scores_normalized
        CHECK (
            normalized_value IS NULL
            OR normalized_value BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_item_scores_raw_score
        CHECK (
            raw_score IS NULL
            OR raw_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_item_scores_rank
        CHECK (
            rank_within_criterion IS NULL
            OR rank_within_criterion > 0
        ),

    CONSTRAINT chk_card_comparison_item_scores_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_card_comparison_item_scores_status
        CHECK (
            evaluation_status IN (
                'PENDING',
                'PROCESSING',
                'COMPLETED',
                'PARTIALLY_COMPLETED',
                'SKIPPED',
                'FAILED'
            )
        ),

    CONSTRAINT chk_card_comparison_item_scores_notes
        CHECK (
            evaluation_notes IS NULL
            OR length(trim(evaluation_notes)) > 0
        ),

    CONSTRAINT chk_card_comparison_item_scores_evidence
        CHECK (
            jsonb_typeof(evidence) = 'array'
        ),

    CONSTRAINT chk_card_comparison_item_scores_calculation
        CHECK (
            jsonb_typeof(calculation_details) = 'object'
        ),

    CONSTRAINT chk_card_comparison_item_scores_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE UNIQUE INDEX uq_card_comparisons_active_share_token
ON public.card_comparisons(share_token)
WHERE share_enabled = TRUE
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_user
ON public.card_comparisons(
    user_id,
    updated_at DESC
)
WHERE is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_user_status
ON public.card_comparisons(
    user_id,
    comparison_status,
    updated_at DESC
)
WHERE is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_profile
ON public.card_comparisons(
    financial_profile_id,
    updated_at DESC
)
WHERE financial_profile_id IS NOT NULL
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_recommendation_run
ON public.card_comparisons(
    recommendation_run_id,
    updated_at DESC
)
WHERE recommendation_run_id IS NOT NULL;

CREATE INDEX idx_card_comparisons_collection
ON public.card_comparisons(
    source_collection_id,
    updated_at DESC
)
WHERE source_collection_id IS NOT NULL;

CREATE INDEX idx_card_comparisons_primary_card
ON public.card_comparisons(primary_card_id)
WHERE primary_card_id IS NOT NULL
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_winning_card
ON public.card_comparisons(winning_card_id)
WHERE winning_card_id IS NOT NULL
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_selected_card
ON public.card_comparisons(selected_card_id)
WHERE selected_card_id IS NOT NULL
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_active
ON public.card_comparisons(
    comparison_status,
    updated_at DESC
)
WHERE comparison_status IN (
    'DRAFT',
    'ACTIVE',
    'EVALUATING'
)
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_completed
ON public.card_comparisons(
    completed_at DESC
)
WHERE completed_at IS NOT NULL
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_expiring
ON public.card_comparisons(expires_at)
WHERE expires_at IS NOT NULL
  AND comparison_status NOT IN (
      'EXPIRED',
      'ARCHIVED',
      'CANCELLED'
  )
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_shared
ON public.card_comparisons(
    share_token,
    share_expires_at
)
WHERE share_enabled = TRUE
  AND is_deleted = FALSE;

CREATE INDEX idx_card_comparisons_session
ON public.card_comparisons(
    session_reference,
    updated_at DESC
)
WHERE session_reference IS NOT NULL;

CREATE INDEX idx_card_comparisons_journey
ON public.card_comparisons(
    journey_reference,
    updated_at DESC
)
WHERE journey_reference IS NOT NULL;

CREATE INDEX idx_card_comparisons_correlation
ON public.card_comparisons(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_card_comparisons_criteria_json
ON public.card_comparisons
USING GIN (comparison_criteria);

CREATE INDEX idx_card_comparisons_priorities_json
ON public.card_comparisons
USING GIN (customer_priorities);

CREATE INDEX idx_card_comparisons_summary_json
ON public.card_comparisons
USING GIN (comparison_summary);

CREATE INDEX idx_card_comparisons_snapshot_json
ON public.card_comparisons
USING GIN (snapshot_data);

CREATE INDEX idx_card_comparisons_metadata
ON public.card_comparisons
USING GIN (metadata);

CREATE UNIQUE INDEX uq_card_comparison_items_primary
ON public.card_comparison_items(comparison_id)
WHERE is_primary = TRUE
  AND item_status <> 'REMOVED';

CREATE UNIQUE INDEX uq_card_comparison_items_winner
ON public.card_comparison_items(comparison_id)
WHERE is_winner = TRUE
  AND item_status <> 'REMOVED';

CREATE UNIQUE INDEX uq_card_comparison_items_selected
ON public.card_comparison_items(comparison_id)
WHERE is_selected = TRUE
  AND item_status <> 'REMOVED';

CREATE UNIQUE INDEX uq_card_comparison_items_position
ON public.card_comparison_items(
    comparison_id,
    display_position
)
WHERE item_status <> 'REMOVED';

CREATE INDEX idx_card_comparison_items_comparison
ON public.card_comparison_items(
    comparison_id,
    display_position
)
WHERE item_status <> 'REMOVED';

CREATE INDEX idx_card_comparison_items_card
ON public.card_comparison_items(
    card_id,
    added_at DESC
)
WHERE item_status <> 'REMOVED';

CREATE INDEX idx_card_comparison_items_recommendation_result
ON public.card_comparison_items(recommendation_result_id)
WHERE recommendation_result_id IS NOT NULL;

CREATE INDEX idx_card_comparison_items_saved_card
ON public.card_comparison_items(saved_card_id)
WHERE saved_card_id IS NOT NULL;

CREATE INDEX idx_card_comparison_items_score
ON public.card_comparison_items(
    comparison_id,
    total_score DESC
)
WHERE total_score IS NOT NULL
  AND item_status <> 'REMOVED';

CREATE INDEX idx_card_comparison_items_value
ON public.card_comparison_items(
    comparison_id,
    estimated_first_year_net_value DESC
)
WHERE estimated_first_year_net_value IS NOT NULL
  AND item_status <> 'REMOVED';

CREATE INDEX idx_card_comparison_items_eligibility
ON public.card_comparison_items(
    comparison_id,
    eligibility_score DESC
)
WHERE eligibility_score IS NOT NULL
  AND item_status <> 'REMOVED';

CREATE INDEX idx_card_comparison_items_eliminated
ON public.card_comparison_items(
    comparison_id,
    elimination_reason_code
)
WHERE is_eliminated = TRUE;

CREATE INDEX idx_card_comparison_items_strengths
ON public.card_comparison_items
USING GIN (strengths);

CREATE INDEX idx_card_comparison_items_weaknesses
ON public.card_comparison_items
USING GIN (weaknesses);

CREATE INDEX idx_card_comparison_items_differentiators
ON public.card_comparison_items
USING GIN (differentiators);

CREATE INDEX idx_card_comparison_items_values_json
ON public.card_comparison_items
USING GIN (comparison_values);

CREATE INDEX idx_card_comparison_items_score_breakdown
ON public.card_comparison_items
USING GIN (score_breakdown);

CREATE INDEX idx_card_comparison_items_snapshot
ON public.card_comparison_items
USING GIN (card_snapshot);

CREATE INDEX idx_card_comparison_items_metadata
ON public.card_comparison_items
USING GIN (metadata);

CREATE INDEX idx_card_comparison_criteria_comparison
ON public.card_comparison_criteria(
    comparison_id,
    display_order
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_comparison_criteria_category
ON public.card_comparison_criteria(
    comparison_id,
    criterion_category,
    display_order
)
WHERE is_active = TRUE;

CREATE INDEX idx_card_comparison_criteria_required
ON public.card_comparison_criteria(
    comparison_id,
    display_order
)
WHERE is_required = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_card_comparison_criteria_configuration
ON public.card_comparison_criteria
USING GIN (configuration);

CREATE INDEX idx_card_comparison_criteria_metadata
ON public.card_comparison_criteria
USING GIN (metadata);

CREATE INDEX idx_card_comparison_item_scores_item
ON public.card_comparison_item_scores(
    comparison_item_id,
    evaluated_at DESC
);

CREATE INDEX idx_card_comparison_item_scores_criterion
ON public.card_comparison_item_scores(
    comparison_criterion_id,
    weighted_score DESC
);

CREATE INDEX idx_card_comparison_item_scores_rank
ON public.card_comparison_item_scores(
    comparison_criterion_id,
    rank_within_criterion
)
WHERE rank_within_criterion IS NOT NULL;

CREATE INDEX idx_card_comparison_item_scores_failed
ON public.card_comparison_item_scores(
    comparison_item_id,
    evaluation_status
)
WHERE evaluation_status = 'FAILED'
   OR requirement_failed = TRUE;

CREATE INDEX idx_card_comparison_item_scores_evidence
ON public.card_comparison_item_scores
USING GIN (evidence);

CREATE INDEX idx_card_comparison_item_scores_calculation
ON public.card_comparison_item_scores
USING GIN (calculation_details);

CREATE INDEX idx_card_comparison_item_scores_metadata
ON public.card_comparison_item_scores
USING GIN (metadata);

CREATE TRIGGER trg_card_comparisons_updated_at
BEFORE UPDATE
ON public.card_comparisons
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_card_comparison_items_updated_at
BEFORE UPDATE
ON public.card_comparison_items
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_card_comparison_criteria_updated_at
BEFORE UPDATE
ON public.card_comparison_criteria
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_card_comparison_item_scores_updated_at
BEFORE UPDATE
ON public.card_comparison_item_scores
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.card_comparisons IS
'Saved or temporary card-comparison sessions containing customer context, selected cards, comparison settings, winner selection, and final customer decision.';

COMMENT ON COLUMN public.card_comparisons.comparison_reference IS
'Unique public-safe identifier for the comparison session.';

COMMENT ON COLUMN public.card_comparisons.comparison_type IS
'Business purpose or predefined comparison mode, such as travel, rewards, low-fee, personalized, or advisor comparison.';

COMMENT ON COLUMN public.card_comparisons.primary_card_id IS
'Optional baseline card against which the other cards are compared.';

COMMENT ON COLUMN public.card_comparisons.winning_card_id IS
'Card selected by the comparison engine or reviewer as the strongest option.';

COMMENT ON COLUMN public.card_comparisons.selected_card_id IS
'Card ultimately selected by the customer, which may differ from the calculated winning card.';

COMMENT ON COLUMN public.card_comparisons.comparison_criteria IS
'Summary of the criteria applied to the comparison; normalized criterion definitions are stored in card_comparison_criteria.';

COMMENT ON COLUMN public.card_comparisons.customer_priorities IS
'Snapshot of the customer priorities and relative importance used during comparison.';

COMMENT ON COLUMN public.card_comparisons.snapshot_data IS
'Historical snapshot of important comparison and card data used to preserve the displayed result.';

COMMENT ON TABLE public.card_comparison_items IS
'Cards participating in a comparison, including their ranks, scores, estimated values, strengths, weaknesses, and selection status.';

COMMENT ON COLUMN public.card_comparison_items.is_primary IS
'Indicates that the card is the baseline product against which other comparison items are evaluated.';

COMMENT ON COLUMN public.card_comparison_items.is_winner IS
'Indicates that the comparison engine or reviewer identified the card as the best option.';

COMMENT ON COLUMN public.card_comparison_items.is_selected IS
'Indicates that the customer ultimately selected this card.';

COMMENT ON COLUMN public.card_comparison_items.estimated_first_year_net_value IS
'Estimated first-year financial value after rewards, benefits, fees, and other costs.';

COMMENT ON COLUMN public.card_comparison_items.total_score IS
'Overall normalized comparison score for the card.';

COMMENT ON COLUMN public.card_comparison_items.card_snapshot IS
'Snapshot of important card attributes at the time of comparison.';

COMMENT ON TABLE public.card_comparison_criteria IS
'Normalized customer-defined or system-defined criteria used to evaluate cards within a comparison session.';

COMMENT ON COLUMN public.card_comparison_criteria.weight IS
'Relative weight assigned to the criterion in the comparison score.';

COMMENT ON COLUMN public.card_comparison_criteria.is_required IS
'Indicates that failure to satisfy this criterion may eliminate a card from the comparison.';

COMMENT ON TABLE public.card_comparison_item_scores IS
'Criterion-level scoring results for each card participating in a comparison.';

COMMENT ON COLUMN public.card_comparison_item_scores.raw_score IS
'Unweighted normalized criterion score assigned to the comparison item.';

COMMENT ON COLUMN public.card_comparison_item_scores.weighted_score IS
'Criterion score after applying the configured comparison weight.';

COMMENT ON COLUMN public.card_comparison_item_scores.requirement_failed IS
'Indicates that the card failed a required comparison criterion.';

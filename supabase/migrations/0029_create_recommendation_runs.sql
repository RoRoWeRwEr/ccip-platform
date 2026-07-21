CREATE TABLE public.recommendation_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    financial_profile_id UUID NOT NULL
        REFERENCES public.customer_financial_profiles(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    spending_profile_id UUID
        REFERENCES public.customer_spending_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    preference_profile_id UUID
        REFERENCES public.customer_preference_profiles(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_model_id UUID NOT NULL
        REFERENCES public.recommendation_models(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    run_status public.recommendation_run_status
        NOT NULL DEFAULT 'pending',

    run_name TEXT,

    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    completed_at TIMESTAMPTZ,

    execution_time_ms INTEGER,

    cards_evaluated INTEGER NOT NULL DEFAULT 0,

    cards_recommended INTEGER NOT NULL DEFAULT 0,

    cards_excluded INTEGER NOT NULL DEFAULT 0,

    cards_failed INTEGER NOT NULL DEFAULT 0,

    top_recommendation_card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    top_recommendation_score NUMERIC(9,4),

    overall_confidence NUMERIC(5,2),

    engine_version TEXT NOT NULL DEFAULT '1.0',

    input_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    configuration_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    execution_log JSONB NOT NULL DEFAULT '[]'::JSONB,

    warnings JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_recommendation_runs_execution_time
        CHECK (
            execution_time_ms IS NULL
            OR execution_time_ms >= 0
        ),

    CONSTRAINT chk_recommendation_runs_counts
        CHECK (
            cards_evaluated >= 0
            AND cards_recommended >= 0
            AND cards_excluded >= 0
            AND cards_failed >= 0
        ),

    CONSTRAINT chk_recommendation_runs_score
        CHECK (
            top_recommendation_score IS NULL
            OR top_recommendation_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_runs_confidence
        CHECK (
            overall_confidence IS NULL
            OR overall_confidence BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_runs_completed
        CHECK (
            completed_at IS NULL
            OR completed_at >= started_at
        ),

    CONSTRAINT chk_recommendation_runs_input_snapshot
        CHECK (
            jsonb_typeof(input_snapshot)='object'
        ),

    CONSTRAINT chk_recommendation_runs_configuration_snapshot
        CHECK (
            jsonb_typeof(configuration_snapshot)='object'
        ),

    CONSTRAINT chk_recommendation_runs_execution_log
        CHECK (
            jsonb_typeof(execution_log)='array'
        ),

    CONSTRAINT chk_recommendation_runs_warnings
        CHECK (
            jsonb_typeof(warnings)='array'
        ),

    CONSTRAINT chk_recommendation_runs_metadata
        CHECK (
            jsonb_typeof(metadata)='object'
        )
);

CREATE TABLE public.recommendation_run_cards (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    recommendation_run_id UUID NOT NULL
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    eligibility_assessment_id UUID
        REFERENCES public.eligibility_assessments(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    value_simulation_id UUID
        REFERENCES public.card_value_simulations(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_status public.recommendation_result_status
        NOT NULL DEFAULT 'recommended',

    recommendation_rank INTEGER,

    final_score NUMERIC(9,4),

    confidence_score NUMERIC(5,2),

    exclusion_reason public.recommendation_exclusion_reason,

    is_visible BOOLEAN NOT NULL DEFAULT TRUE,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_recommendation_run_cards
        UNIQUE (
            recommendation_run_id,
            card_id
        ),

    CONSTRAINT chk_recommendation_run_cards_rank
        CHECK (
            recommendation_rank IS NULL
            OR recommendation_rank > 0
        ),

    CONSTRAINT chk_recommendation_run_cards_score
        CHECK (
            final_score IS NULL
            OR final_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_run_cards_confidence
        CHECK (
            confidence_score IS NULL
            OR confidence_score BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_recommendation_run_cards_metadata
        CHECK (
            jsonb_typeof(metadata)='object'
        )
);

CREATE INDEX idx_recommendation_runs_profile
ON public.recommendation_runs(financial_profile_id);

CREATE INDEX idx_recommendation_runs_model
ON public.recommendation_runs(recommendation_model_id);

CREATE INDEX idx_recommendation_runs_status
ON public.recommendation_runs(run_status);

CREATE INDEX idx_recommendation_runs_started
ON public.recommendation_runs(started_at DESC);

CREATE INDEX idx_recommendation_runs_metadata
ON public.recommendation_runs
USING GIN(metadata);

CREATE INDEX idx_recommendation_run_cards_run
ON public.recommendation_run_cards(recommendation_run_id);

CREATE INDEX idx_recommendation_run_cards_card
ON public.recommendation_run_cards(card_id);

CREATE INDEX idx_recommendation_run_cards_rank
ON public.recommendation_run_cards(
    recommendation_run_id,
    recommendation_rank
);

CREATE INDEX idx_recommendation_run_cards_score
ON public.recommendation_run_cards(
    recommendation_run_id,
    final_score DESC
);

CREATE INDEX idx_recommendation_run_cards_metadata
ON public.recommendation_run_cards
USING GIN(metadata);

CREATE TRIGGER trg_recommendation_runs_updated_at
BEFORE UPDATE
ON public.recommendation_runs
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_recommendation_run_cards_updated_at
BEFORE UPDATE
ON public.recommendation_run_cards
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.recommendation_runs IS
'Stores every execution of the recommendation engine for auditability and reproducibility.';

COMMENT ON TABLE public.recommendation_run_cards IS
'Stores every evaluated card within a recommendation run together with its ranking and score.';

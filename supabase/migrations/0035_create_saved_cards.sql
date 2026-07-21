CREATE TABLE public.user_card_collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    collection_code TEXT NOT NULL,

    collection_name TEXT NOT NULL,

    collection_name_ar TEXT,

    collection_type TEXT NOT NULL DEFAULT 'CUSTOM',

    description TEXT,

    description_ar TEXT,

    icon_code TEXT,

    display_order INTEGER NOT NULL DEFAULT 1,

    is_system_collection BOOLEAN NOT NULL DEFAULT FALSE,

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    is_private BOOLEAN NOT NULL DEFAULT TRUE,

    is_archived BOOLEAN NOT NULL DEFAULT FALSE,

    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    sharing_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    sharing_token TEXT,

    sharing_expires_at TIMESTAMPTZ,

    card_count INTEGER NOT NULL DEFAULT 0,

    last_card_added_at TIMESTAMPTZ,

    archived_at TIMESTAMPTZ,

    deleted_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    CONSTRAINT uq_user_card_collections_user_code
        UNIQUE (
            user_id,
            collection_code
        ),

    CONSTRAINT uq_user_card_collections_sharing_token
        UNIQUE (
            sharing_token
        ),

    CONSTRAINT chk_user_card_collections_code
        CHECK (
            collection_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_user_card_collections_name
        CHECK (
            length(trim(collection_name)) > 0
        ),

    CONSTRAINT chk_user_card_collections_name_ar
        CHECK (
            collection_name_ar IS NULL
            OR length(trim(collection_name_ar)) > 0
        ),

    CONSTRAINT chk_user_card_collections_type
        CHECK (
            collection_type IN (
                'FAVORITES',
                'WATCHLIST',
                'SHORTLIST',
                'COMPARISON',
                'APPLIED',
                'OWNED',
                'REJECTED',
                'RECOMMENDED',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_user_card_collections_description
        CHECK (
            description IS NULL
            OR length(trim(description)) > 0
        ),

    CONSTRAINT chk_user_card_collections_description_ar
        CHECK (
            description_ar IS NULL
            OR length(trim(description_ar)) > 0
        ),

    CONSTRAINT chk_user_card_collections_icon
        CHECK (
            icon_code IS NULL
            OR icon_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_user_card_collections_display_order
        CHECK (
            display_order > 0
        ),

    CONSTRAINT chk_user_card_collections_card_count
        CHECK (
            card_count >= 0
        ),

    CONSTRAINT chk_user_card_collections_default
        CHECK (
            is_default = FALSE
            OR is_archived = FALSE
        ),

    CONSTRAINT chk_user_card_collections_system_type
        CHECK (
            is_system_collection = FALSE
            OR collection_type <> 'CUSTOM'
        ),

    CONSTRAINT chk_user_card_collections_sharing
        CHECK (
            sharing_enabled = FALSE
            OR sharing_token IS NOT NULL
        ),

    CONSTRAINT chk_user_card_collections_sharing_token
        CHECK (
            sharing_token IS NULL
            OR sharing_token
                ~ '^[A-Za-z0-9_-]{16,128}$'
        ),

    CONSTRAINT chk_user_card_collections_sharing_expiry
        CHECK (
            sharing_expires_at IS NULL
            OR sharing_enabled = TRUE
        ),

    CONSTRAINT chk_user_card_collections_archived
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

    CONSTRAINT chk_user_card_collections_deleted
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

    CONSTRAINT chk_user_card_collections_deleted_archived
        CHECK (
            is_deleted = FALSE
            OR is_archived = TRUE
        ),

    CONSTRAINT chk_user_card_collections_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.user_saved_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    collection_id UUID NOT NULL
        REFERENCES public.user_card_collections(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    card_id UUID NOT NULL
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    recommendation_run_id UUID
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_result_id UUID
        REFERENCES public.recommendation_results(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_run_card_id UUID
        REFERENCES public.recommendation_run_cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    source_interaction_id UUID
        REFERENCES public.recommendation_interactions(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    saved_reference TEXT NOT NULL,

    saved_source TEXT NOT NULL DEFAULT 'CARD_DETAIL',

    saved_reason_code TEXT,

    saved_reason_text TEXT,

    personal_note TEXT,

    priority_level TEXT NOT NULL DEFAULT 'NORMAL',

    interest_status TEXT NOT NULL DEFAULT 'INTERESTED',

    application_intent TEXT,

    position INTEGER NOT NULL DEFAULT 1,

    reminder_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    reminder_at TIMESTAMPTZ,

    target_application_date DATE,

    target_credit_limit NUMERIC(18, 6),

    target_credit_limit_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    expected_annual_value NUMERIC(18, 6),

    expected_annual_value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    score_at_save NUMERIC(9, 4),

    rank_at_save INTEGER,

    annual_fee_at_save NUMERIC(18, 6),

    annual_fee_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    promotional_offer_at_save BOOLEAN,

    offer_reference TEXT,

    offer_expires_at TIMESTAMPTZ,

    saved_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    last_viewed_at TIMESTAMPTZ,

    last_compared_at TIMESTAMPTZ,

    last_updated_from_card_at TIMESTAMPTZ,

    archived_at TIMESTAMPTZ,

    removed_at TIMESTAMPTZ,

    is_pinned BOOLEAN NOT NULL DEFAULT FALSE,

    is_archived BOOLEAN NOT NULL DEFAULT FALSE,

    is_removed BOOLEAN NOT NULL DEFAULT FALSE,

    is_application_candidate BOOLEAN NOT NULL DEFAULT FALSE,

    notification_preferences JSONB NOT NULL DEFAULT '{}'::JSONB,

    card_snapshot JSONB NOT NULL DEFAULT '{}'::JSONB,

    saved_context JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_user_saved_cards_collection_card
        UNIQUE (
            collection_id,
            card_id
        ),

    CONSTRAINT uq_user_saved_cards_reference
        UNIQUE (
            saved_reference
        ),

    CONSTRAINT chk_user_saved_cards_reference
        CHECK (
            saved_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_user_saved_cards_source
        CHECK (
            saved_source IN (
                'RECOMMENDATION_LIST',
                'RECOMMENDATION_DETAIL',
                'CARD_DETAIL',
                'CARD_COMPARISON',
                'SEARCH_RESULTS',
                'BANK_PAGE',
                'OFFER_PAGE',
                'ADVISOR',
                'ADMIN',
                'IMPORT',
                'API',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_user_saved_cards_reason_code
        CHECK (
            saved_reason_code IS NULL
            OR saved_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_user_saved_cards_reason_text
        CHECK (
            saved_reason_text IS NULL
            OR length(trim(saved_reason_text)) > 0
        ),

    CONSTRAINT chk_user_saved_cards_personal_note
        CHECK (
            personal_note IS NULL
            OR length(trim(personal_note)) > 0
        ),

    CONSTRAINT chk_user_saved_cards_priority
        CHECK (
            priority_level IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT'
            )
        ),

    CONSTRAINT chk_user_saved_cards_interest_status
        CHECK (
            interest_status IN (
                'INTERESTED',
                'CONSIDERING',
                'HIGHLY_INTERESTED',
                'PLANNING_TO_APPLY',
                'APPLIED',
                'APPROVED',
                'REJECTED',
                'ACQUIRED',
                'NO_LONGER_INTERESTED',
                'ON_HOLD'
            )
        ),

    CONSTRAINT chk_user_saved_cards_application_intent
        CHECK (
            application_intent IS NULL
            OR application_intent IN (
                'IMMEDIATE',
                'WITHIN_7_DAYS',
                'WITHIN_30_DAYS',
                'WITHIN_90_DAYS',
                'THIS_YEAR',
                'RESEARCH_ONLY',
                'UNDECIDED'
            )
        ),

    CONSTRAINT chk_user_saved_cards_position
        CHECK (
            position > 0
        ),

    CONSTRAINT chk_user_saved_cards_reminder
        CHECK (
            reminder_enabled = FALSE
            OR reminder_at IS NOT NULL
        ),

    CONSTRAINT chk_user_saved_cards_target_credit_limit
        CHECK (
            target_credit_limit IS NULL
            OR target_credit_limit >= 0
        ),

    CONSTRAINT chk_user_saved_cards_target_credit_limit_currency
        CHECK (
            (
                target_credit_limit IS NULL
                AND target_credit_limit_currency_id IS NULL
            )
            OR
            (
                target_credit_limit IS NOT NULL
                AND target_credit_limit_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_user_saved_cards_expected_value_currency
        CHECK (
            (
                expected_annual_value IS NULL
                AND expected_annual_value_currency_id IS NULL
            )
            OR
            (
                expected_annual_value IS NOT NULL
                AND expected_annual_value_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_user_saved_cards_score
        CHECK (
            score_at_save IS NULL
            OR score_at_save BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_user_saved_cards_rank
        CHECK (
            rank_at_save IS NULL
            OR rank_at_save > 0
        ),

    CONSTRAINT chk_user_saved_cards_annual_fee
        CHECK (
            annual_fee_at_save IS NULL
            OR annual_fee_at_save >= 0
        ),

    CONSTRAINT chk_user_saved_cards_annual_fee_currency
        CHECK (
            (
                annual_fee_at_save IS NULL
                AND annual_fee_currency_id IS NULL
            )
            OR
            (
                annual_fee_at_save IS NOT NULL
                AND annual_fee_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_user_saved_cards_offer_reference
        CHECK (
            offer_reference IS NULL
            OR length(trim(offer_reference)) > 0
        ),

    CONSTRAINT chk_user_saved_cards_offer_expiry
        CHECK (
            offer_expires_at IS NULL
            OR promotional_offer_at_save = TRUE
        ),

    CONSTRAINT chk_user_saved_cards_last_viewed
        CHECK (
            last_viewed_at IS NULL
            OR last_viewed_at >= saved_at
        ),

    CONSTRAINT chk_user_saved_cards_last_compared
        CHECK (
            last_compared_at IS NULL
            OR last_compared_at >= saved_at
        ),

    CONSTRAINT chk_user_saved_cards_archived
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

    CONSTRAINT chk_user_saved_cards_removed
        CHECK (
            (
                is_removed = FALSE
                AND removed_at IS NULL
            )
            OR
            (
                is_removed = TRUE
                AND removed_at IS NOT NULL
            )
        ),

    CONSTRAINT chk_user_saved_cards_removed_archived
        CHECK (
            is_removed = FALSE
            OR is_archived = TRUE
        ),

    CONSTRAINT chk_user_saved_cards_notification_preferences
        CHECK (
            jsonb_typeof(notification_preferences) = 'object'
        ),

    CONSTRAINT chk_user_saved_cards_card_snapshot
        CHECK (
            jsonb_typeof(card_snapshot) = 'object'
        ),

    CONSTRAINT chk_user_saved_cards_saved_context
        CHECK (
            jsonb_typeof(saved_context) = 'object'
        ),

    CONSTRAINT chk_user_saved_cards_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE UNIQUE INDEX uq_user_card_collections_default_type
ON public.user_card_collections(
    user_id,
    collection_type
)
WHERE is_default = TRUE
  AND is_deleted = FALSE;

CREATE UNIQUE INDEX uq_user_card_collections_active_system_type
ON public.user_card_collections(
    user_id,
    collection_type
)
WHERE is_system_collection = TRUE
  AND is_deleted = FALSE;

CREATE INDEX idx_user_card_collections_user
ON public.user_card_collections(
    user_id,
    display_order,
    created_at
)
WHERE is_deleted = FALSE;

CREATE INDEX idx_user_card_collections_user_type
ON public.user_card_collections(
    user_id,
    collection_type
)
WHERE is_deleted = FALSE;

CREATE INDEX idx_user_card_collections_active
ON public.user_card_collections(
    user_id,
    display_order
)
WHERE is_archived = FALSE
  AND is_deleted = FALSE;

CREATE INDEX idx_user_card_collections_archived
ON public.user_card_collections(
    user_id,
    archived_at DESC
)
WHERE is_archived = TRUE
  AND is_deleted = FALSE;

CREATE INDEX idx_user_card_collections_shared
ON public.user_card_collections(
    sharing_token,
    sharing_expires_at
)
WHERE sharing_enabled = TRUE
  AND is_deleted = FALSE;

CREATE INDEX idx_user_card_collections_metadata
ON public.user_card_collections
USING GIN (metadata);

CREATE INDEX idx_user_saved_cards_user
ON public.user_saved_cards(
    user_id,
    saved_at DESC
)
WHERE is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_collection
ON public.user_saved_cards(
    collection_id,
    is_pinned DESC,
    position,
    saved_at DESC
)
WHERE is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_card
ON public.user_saved_cards(
    card_id,
    saved_at DESC
)
WHERE is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_user_card
ON public.user_saved_cards(
    user_id,
    card_id
)
WHERE is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_recommendation_run
ON public.user_saved_cards(
    recommendation_run_id,
    saved_at DESC
)
WHERE recommendation_run_id IS NOT NULL;

CREATE INDEX idx_user_saved_cards_recommendation_result
ON public.user_saved_cards(
    recommendation_result_id,
    saved_at DESC
)
WHERE recommendation_result_id IS NOT NULL;

CREATE INDEX idx_user_saved_cards_source_interaction
ON public.user_saved_cards(source_interaction_id)
WHERE source_interaction_id IS NOT NULL;

CREATE INDEX idx_user_saved_cards_interest
ON public.user_saved_cards(
    user_id,
    interest_status,
    priority_level,
    saved_at DESC
)
WHERE is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_application_candidates
ON public.user_saved_cards(
    user_id,
    priority_level,
    target_application_date
)
WHERE is_application_candidate = TRUE
  AND is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_pinned
ON public.user_saved_cards(
    user_id,
    collection_id,
    position
)
WHERE is_pinned = TRUE
  AND is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_reminders
ON public.user_saved_cards(
    reminder_at,
    user_id
)
WHERE reminder_enabled = TRUE
  AND is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_target_application
ON public.user_saved_cards(
    target_application_date,
    user_id
)
WHERE target_application_date IS NOT NULL
  AND is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_offer_expiry
ON public.user_saved_cards(
    offer_expires_at,
    user_id
)
WHERE promotional_offer_at_save = TRUE
  AND offer_expires_at IS NOT NULL
  AND is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_archived
ON public.user_saved_cards(
    user_id,
    archived_at DESC
)
WHERE is_archived = TRUE
  AND is_removed = FALSE;

CREATE INDEX idx_user_saved_cards_notification_preferences
ON public.user_saved_cards
USING GIN (notification_preferences);

CREATE INDEX idx_user_saved_cards_card_snapshot
ON public.user_saved_cards
USING GIN (card_snapshot);

CREATE INDEX idx_user_saved_cards_saved_context
ON public.user_saved_cards
USING GIN (saved_context);

CREATE INDEX idx_user_saved_cards_metadata
ON public.user_saved_cards
USING GIN (metadata);

CREATE TRIGGER trg_user_card_collections_updated_at
BEFORE UPDATE
ON public.user_card_collections
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_saved_cards_updated_at
BEFORE UPDATE
ON public.user_saved_cards
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.user_card_collections IS
'User-owned card collections including favorites, watchlists, shortlists, comparison lists, application lists, and custom collections.';

COMMENT ON COLUMN public.user_card_collections.collection_code IS
'Stable user-scoped code identifying the collection.';

COMMENT ON COLUMN public.user_card_collections.collection_type IS
'Business purpose of the collection, such as favorites, watchlist, shortlist, applied cards, owned cards, or a custom list.';

COMMENT ON COLUMN public.user_card_collections.is_system_collection IS
'Indicates that the collection was created automatically by the platform rather than manually by the user.';

COMMENT ON COLUMN public.user_card_collections.is_default IS
'Identifies the default collection for its collection type.';

COMMENT ON COLUMN public.user_card_collections.card_count IS
'Cached number of active saved-card records assigned to the collection.';

COMMENT ON COLUMN public.user_card_collections.sharing_token IS
'Optional public-safe token used to access a shared collection without exposing its internal identifier.';

COMMENT ON TABLE public.user_saved_cards IS
'Cards saved by users in favorites, watchlists, shortlists, comparisons, application lists, and custom collections.';

COMMENT ON COLUMN public.user_saved_cards.saved_reference IS
'Unique public-safe identifier for the saved-card record.';

COMMENT ON COLUMN public.user_saved_cards.saved_source IS
'Application area or workflow from which the user saved the card.';

COMMENT ON COLUMN public.user_saved_cards.recommendation_result_id IS
'Recommendation result that influenced the user to save the card.';

COMMENT ON COLUMN public.user_saved_cards.personal_note IS
'Private user-entered note about the saved card.';

COMMENT ON COLUMN public.user_saved_cards.interest_status IS
'Current user interest or application status associated with the saved card.';

COMMENT ON COLUMN public.user_saved_cards.priority_level IS
'User-assigned priority indicating the relative importance of the saved card.';

COMMENT ON COLUMN public.user_saved_cards.score_at_save IS
'Recommendation score displayed at the time the card was saved.';

COMMENT ON COLUMN public.user_saved_cards.annual_fee_at_save IS
'Annual fee displayed at the time the card was saved, retained as a historical snapshot.';

COMMENT ON COLUMN public.user_saved_cards.card_snapshot IS
'Snapshot of important card data at the time it was saved, allowing later detection of product changes.';

COMMENT ON COLUMN public.user_saved_cards.notification_preferences IS
'User-specific alert preferences for fee changes, offers, eligibility changes, reward changes, and application reminders.';

CREATE TABLE public.notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    template_code TEXT NOT NULL,

    template_name TEXT NOT NULL,

    notification_type TEXT NOT NULL,

    channel TEXT NOT NULL,

    language_code TEXT NOT NULL DEFAULT 'en',

    subject_template TEXT,

    title_template TEXT NOT NULL,

    body_template TEXT NOT NULL,

    short_body_template TEXT,

    action_label_template TEXT,

    action_url_template TEXT,

    icon_code TEXT,

    image_url_template TEXT,

    template_version INTEGER NOT NULL DEFAULT 1,

    template_status TEXT NOT NULL DEFAULT 'DRAFT',

    priority_level TEXT NOT NULL DEFAULT 'NORMAL',

    supports_batching BOOLEAN NOT NULL DEFAULT FALSE,

    supports_digest BOOLEAN NOT NULL DEFAULT FALSE,

    supports_personalization BOOLEAN NOT NULL DEFAULT TRUE,

    requires_user_consent BOOLEAN NOT NULL DEFAULT FALSE,

    is_transactional BOOLEAN NOT NULL DEFAULT FALSE,

    is_marketing BOOLEAN NOT NULL DEFAULT FALSE,

    is_system_template BOOLEAN NOT NULL DEFAULT FALSE,

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    valid_from TIMESTAMPTZ,

    valid_until TIMESTAMPTZ,

    required_variables JSONB NOT NULL DEFAULT '[]'::JSONB,

    optional_variables JSONB NOT NULL DEFAULT '[]'::JSONB,

    sample_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    channel_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_notification_templates_code_version_language_channel
        UNIQUE (
            template_code,
            template_version,
            language_code,
            channel
        ),

    CONSTRAINT chk_notification_templates_code
        CHECK (
            template_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_notification_templates_name
        CHECK (
            length(trim(template_name)) > 0
        ),

    CONSTRAINT chk_notification_templates_type
        CHECK (
            notification_type IN (
                'CARD_UPDATE',
                'CARD_NEW',
                'CARD_DISCONTINUED',
                'ANNUAL_FEE_CHANGE',
                'FOREIGN_FEE_CHANGE',
                'CASH_WITHDRAWAL_FEE_CHANGE',
                'REWARD_RATE_CHANGE',
                'REDEMPTION_VALUE_CHANGE',
                'BENEFIT_CHANGE',
                'LOUNGE_CHANGE',
                'TRAVEL_BENEFIT_CHANGE',
                'INSURANCE_CHANGE',
                'INSTALLMENT_CHANGE',
                'NETWORK_BENEFIT_CHANGE',
                'WELCOME_OFFER_NEW',
                'OFFER_UPDATED',
                'OFFER_EXPIRING',
                'OFFER_EXPIRED',
                'ELIGIBILITY_CHANGE',
                'RECOMMENDATION_READY',
                'RECOMMENDATION_UPDATED',
                'COMPARISON_READY',
                'SAVED_CARD_UPDATE',
                'WATCHLIST_ALERT',
                'PRICE_OR_VALUE_ALERT',
                'APPLICATION_UPDATE',
                'APPLICATION_DOCUMENT_REQUIRED',
                'APPLICATION_APPROVED',
                'APPLICATION_REJECTED',
                'APPLICATION_EXPIRED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATION_REMINDER',
                'FIRST_TRANSACTION_REMINDER',
                'COMMISSION_UPDATE',
                'SECURITY_ALERT',
                'ACCOUNT_ALERT',
                'SYSTEM_ANNOUNCEMENT',
                'MARKETING_CAMPAIGN',
                'DIGEST',
                'REMINDER',
                'CUSTOM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_notification_templates_channel
        CHECK (
            channel IN (
                'IN_APP',
                'EMAIL',
                'PUSH',
                'SMS',
                'WHATSAPP',
                'WEBHOOK'
            )
        ),

    CONSTRAINT chk_notification_templates_language
        CHECK (
            language_code ~ '^[a-z]{2}(?:-[A-Z]{2})?$'
        ),

    CONSTRAINT chk_notification_templates_subject
        CHECK (
            subject_template IS NULL
            OR length(trim(subject_template)) > 0
        ),

    CONSTRAINT chk_notification_templates_title
        CHECK (
            length(trim(title_template)) > 0
        ),

    CONSTRAINT chk_notification_templates_body
        CHECK (
            length(trim(body_template)) > 0
        ),

    CONSTRAINT chk_notification_templates_short_body
        CHECK (
            short_body_template IS NULL
            OR length(trim(short_body_template)) > 0
        ),

    CONSTRAINT chk_notification_templates_action_label
        CHECK (
            action_label_template IS NULL
            OR length(trim(action_label_template)) > 0
        ),

    CONSTRAINT chk_notification_templates_icon
        CHECK (
            icon_code IS NULL
            OR icon_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_notification_templates_version
        CHECK (
            template_version > 0
        ),

    CONSTRAINT chk_notification_templates_status
        CHECK (
            template_status IN (
                'DRAFT',
                'UNDER_REVIEW',
                'APPROVED',
                'PUBLISHED',
                'SUSPENDED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_notification_templates_priority
        CHECK (
            priority_level IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_notification_templates_marketing_transactional
        CHECK (
            NOT (
                is_marketing = TRUE
                AND is_transactional = TRUE
            )
        ),

    CONSTRAINT chk_notification_templates_default_active
        CHECK (
            is_default = FALSE
            OR is_active = TRUE
        ),

    CONSTRAINT chk_notification_templates_validity
        CHECK (
            valid_until IS NULL
            OR valid_from IS NULL
            OR valid_until >= valid_from
        ),

    CONSTRAINT chk_notification_templates_approved
        CHECK (
            approved_by IS NULL
            OR approved_at IS NOT NULL
        ),

    CONSTRAINT chk_notification_templates_required_variables
        CHECK (
            jsonb_typeof(required_variables) = 'array'
        ),

    CONSTRAINT chk_notification_templates_optional_variables
        CHECK (
            jsonb_typeof(optional_variables) = 'array'
        ),

    CONSTRAINT chk_notification_templates_sample_payload
        CHECK (
            jsonb_typeof(sample_payload) = 'object'
        ),

    CONSTRAINT chk_notification_templates_channel_configuration
        CHECK (
            jsonb_typeof(channel_configuration) = 'object'
        ),

    CONSTRAINT chk_notification_templates_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.user_notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    preference_reference TEXT NOT NULL,

    preferred_language_code TEXT NOT NULL DEFAULT 'en',

    timezone_name TEXT NOT NULL DEFAULT 'Asia/Riyadh',

    notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    transactional_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    marketing_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    in_app_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    email_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    push_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    sms_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    whatsapp_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    digest_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    digest_frequency TEXT NOT NULL DEFAULT 'WEEKLY',

    digest_day_of_week INTEGER,

    digest_hour_local INTEGER NOT NULL DEFAULT 9,

    quiet_hours_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    quiet_hours_start TIME,

    quiet_hours_end TIME,

    quiet_hours_allow_urgent BOOLEAN NOT NULL DEFAULT TRUE,

    maximum_notifications_per_day INTEGER,

    maximum_marketing_notifications_per_week INTEGER,

    minimum_priority TEXT NOT NULL DEFAULT 'LOW',

    card_updates_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    fee_changes_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    reward_changes_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    benefit_changes_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    offers_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    offer_expiry_reminders_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    eligibility_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    recommendation_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    comparison_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    saved_card_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    application_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    security_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    product_announcements_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    consent_status TEXT NOT NULL DEFAULT 'NOT_REQUIRED',

    marketing_consent_at TIMESTAMPTZ,

    marketing_consent_withdrawn_at TIMESTAMPTZ,

    last_preferences_reviewed_at TIMESTAMPTZ,

    channel_preferences JSONB NOT NULL DEFAULT '{}'::JSONB,

    notification_type_preferences JSONB NOT NULL DEFAULT '{}'::JSONB,

    digest_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    consent_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_user_notification_preferences_user
        UNIQUE (
            user_id
        ),

    CONSTRAINT uq_user_notification_preferences_reference
        UNIQUE (
            preference_reference
        ),

    CONSTRAINT chk_user_notification_preferences_reference
        CHECK (
            preference_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_user_notification_preferences_language
        CHECK (
            preferred_language_code
                ~ '^[a-z]{2}(?:-[A-Z]{2})?$'
        ),

    CONSTRAINT chk_user_notification_preferences_timezone
        CHECK (
            length(trim(timezone_name)) > 0
        ),

    CONSTRAINT chk_user_notification_preferences_digest_frequency
        CHECK (
            digest_frequency IN (
                'IMMEDIATE',
                'DAILY',
                'WEEKLY',
                'MONTHLY',
                'NEVER'
            )
        ),

    CONSTRAINT chk_user_notification_preferences_digest_day
        CHECK (
            digest_day_of_week IS NULL
            OR digest_day_of_week BETWEEN 1 AND 7
        ),

    CONSTRAINT chk_user_notification_preferences_digest_hour
        CHECK (
            digest_hour_local BETWEEN 0 AND 23
        ),

    CONSTRAINT chk_user_notification_preferences_quiet_hours
        CHECK (
            quiet_hours_enabled = FALSE
            OR (
                quiet_hours_start IS NOT NULL
                AND quiet_hours_end IS NOT NULL
            )
        ),

    CONSTRAINT chk_user_notification_preferences_daily_limit
        CHECK (
            maximum_notifications_per_day IS NULL
            OR maximum_notifications_per_day > 0
        ),

    CONSTRAINT chk_user_notification_preferences_marketing_limit
        CHECK (
            maximum_marketing_notifications_per_week IS NULL
            OR maximum_marketing_notifications_per_week > 0
        ),

    CONSTRAINT chk_user_notification_preferences_priority
        CHECK (
            minimum_priority IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_user_notification_preferences_consent_status
        CHECK (
            consent_status IN (
                'NOT_REQUIRED',
                'PENDING',
                'GRANTED',
                'WITHDRAWN',
                'EXPIRED',
                'REJECTED'
            )
        ),

    CONSTRAINT chk_user_notification_preferences_marketing_consent
        CHECK (
            marketing_enabled = FALSE
            OR consent_status = 'GRANTED'
        ),

    CONSTRAINT chk_user_notification_preferences_consent_timeline
        CHECK (
            marketing_consent_withdrawn_at IS NULL
            OR marketing_consent_at IS NULL
            OR marketing_consent_withdrawn_at >= marketing_consent_at
        ),

    CONSTRAINT chk_user_notification_preferences_channel_preferences
        CHECK (
            jsonb_typeof(channel_preferences) = 'object'
        ),

    CONSTRAINT chk_user_notification_preferences_type_preferences
        CHECK (
            jsonb_typeof(notification_type_preferences) = 'object'
        ),

    CONSTRAINT chk_user_notification_preferences_digest_configuration
        CHECK (
            jsonb_typeof(digest_configuration) = 'object'
        ),

    CONSTRAINT chk_user_notification_preferences_consent_details
        CHECK (
            jsonb_typeof(consent_details) = 'object'
        ),

    CONSTRAINT chk_user_notification_preferences_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.notification_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    subscription_reference TEXT NOT NULL,

    subscription_type TEXT NOT NULL,

    target_entity_type TEXT NOT NULL,

    target_entity_id UUID,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    saved_card_id UUID
        REFERENCES public.user_saved_cards(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    collection_id UUID
        REFERENCES public.user_card_collections(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    comparison_id UUID
        REFERENCES public.card_comparisons(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    notification_type TEXT,

    event_category TEXT,

    delivery_mode TEXT NOT NULL DEFAULT 'IMMEDIATE',

    preferred_channel TEXT,

    minimum_priority TEXT NOT NULL DEFAULT 'LOW',

    threshold_operator TEXT,

    threshold_numeric_value NUMERIC(18, 6),

    threshold_percentage NUMERIC(9, 4),

    threshold_text_value TEXT,

    baseline_numeric_value NUMERIC(18, 6),

    cooldown_minutes INTEGER NOT NULL DEFAULT 0,

    maximum_alerts_per_day INTEGER,

    maximum_alerts_per_week INTEGER,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    is_paused BOOLEAN NOT NULL DEFAULT FALSE,

    paused_until TIMESTAMPTZ,

    starts_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    expires_at TIMESTAMPTZ,

    last_triggered_at TIMESTAMPTZ,

    last_notified_at TIMESTAMPTZ,

    trigger_count INTEGER NOT NULL DEFAULT 0,

    notification_count INTEGER NOT NULL DEFAULT 0,

    filter_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    threshold_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    channel_overrides JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_notification_subscriptions_reference
        UNIQUE (
            subscription_reference
        ),

    CONSTRAINT chk_notification_subscriptions_reference
        CHECK (
            subscription_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_notification_subscriptions_type
        CHECK (
            subscription_type IN (
                'ENTITY',
                'EVENT_TYPE',
                'CATEGORY',
                'THRESHOLD',
                'WATCHLIST',
                'COLLECTION',
                'SAVED_CARD',
                'COMPARISON',
                'APPLICATION',
                'SYSTEM',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_notification_subscriptions_target_type
        CHECK (
            target_entity_type IN (
                'CARD',
                'BANK',
                'CARD_CATEGORY',
                'CARD_PROGRAM',
                'REWARD_PROGRAM',
                'SAVED_CARD',
                'COLLECTION',
                'COMPARISON',
                'RECOMMENDATION',
                'APPLICATION',
                'USER',
                'SYSTEM',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_notification_subscriptions_notification_type
        CHECK (
            notification_type IS NULL
            OR notification_type IN (
                'CARD_UPDATE',
                'CARD_NEW',
                'CARD_DISCONTINUED',
                'ANNUAL_FEE_CHANGE',
                'FOREIGN_FEE_CHANGE',
                'CASH_WITHDRAWAL_FEE_CHANGE',
                'REWARD_RATE_CHANGE',
                'REDEMPTION_VALUE_CHANGE',
                'BENEFIT_CHANGE',
                'LOUNGE_CHANGE',
                'TRAVEL_BENEFIT_CHANGE',
                'INSURANCE_CHANGE',
                'INSTALLMENT_CHANGE',
                'NETWORK_BENEFIT_CHANGE',
                'WELCOME_OFFER_NEW',
                'OFFER_UPDATED',
                'OFFER_EXPIRING',
                'OFFER_EXPIRED',
                'ELIGIBILITY_CHANGE',
                'RECOMMENDATION_READY',
                'RECOMMENDATION_UPDATED',
                'COMPARISON_READY',
                'SAVED_CARD_UPDATE',
                'WATCHLIST_ALERT',
                'PRICE_OR_VALUE_ALERT',
                'APPLICATION_UPDATE',
                'APPLICATION_DOCUMENT_REQUIRED',
                'APPLICATION_APPROVED',
                'APPLICATION_REJECTED',
                'APPLICATION_EXPIRED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATION_REMINDER',
                'FIRST_TRANSACTION_REMINDER',
                'COMMISSION_UPDATE',
                'SECURITY_ALERT',
                'ACCOUNT_ALERT',
                'SYSTEM_ANNOUNCEMENT',
                'MARKETING_CAMPAIGN',
                'DIGEST',
                'REMINDER',
                'CUSTOM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_notification_subscriptions_delivery_mode
        CHECK (
            delivery_mode IN (
                'IMMEDIATE',
                'BATCHED',
                'DAILY_DIGEST',
                'WEEKLY_DIGEST',
                'MONTHLY_DIGEST'
            )
        ),

    CONSTRAINT chk_notification_subscriptions_channel
        CHECK (
            preferred_channel IS NULL
            OR preferred_channel IN (
                'IN_APP',
                'EMAIL',
                'PUSH',
                'SMS',
                'WHATSAPP',
                'WEBHOOK'
            )
        ),

    CONSTRAINT chk_notification_subscriptions_priority
        CHECK (
            minimum_priority IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_notification_subscriptions_threshold_operator
        CHECK (
            threshold_operator IS NULL
            OR threshold_operator IN (
                'EQUALS',
                'NOT_EQUALS',
                'GREATER_THAN',
                'GREATER_THAN_OR_EQUAL',
                'LESS_THAN',
                'LESS_THAN_OR_EQUAL',
                'INCREASED_BY',
                'DECREASED_BY',
                'INCREASED_BY_PERCENTAGE',
                'DECREASED_BY_PERCENTAGE',
                'CHANGED',
                'BECAME_TRUE',
                'BECAME_FALSE',
                'CONTAINS',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_notification_subscriptions_threshold_percentage
        CHECK (
            threshold_percentage IS NULL
            OR threshold_percentage BETWEEN 0 AND 100000
        ),

    CONSTRAINT chk_notification_subscriptions_cooldown
        CHECK (
            cooldown_minutes >= 0
        ),

    CONSTRAINT chk_notification_subscriptions_daily_limit
        CHECK (
            maximum_alerts_per_day IS NULL
            OR maximum_alerts_per_day > 0
        ),

    CONSTRAINT chk_notification_subscriptions_weekly_limit
        CHECK (
            maximum_alerts_per_week IS NULL
            OR maximum_alerts_per_week > 0
        ),

    CONSTRAINT chk_notification_subscriptions_paused
        CHECK (
            is_paused = FALSE
            OR paused_until IS NOT NULL
        ),

    CONSTRAINT chk_notification_subscriptions_validity
        CHECK (
            expires_at IS NULL
            OR expires_at >= starts_at
        ),

    CONSTRAINT chk_notification_subscriptions_trigger_count
        CHECK (
            trigger_count >= 0
        ),

    CONSTRAINT chk_notification_subscriptions_notification_count
        CHECK (
            notification_count >= 0
        ),

    CONSTRAINT chk_notification_subscriptions_target_reference
        CHECK (
            card_id IS NOT NULL
            OR bank_id IS NOT NULL
            OR saved_card_id IS NOT NULL
            OR collection_id IS NOT NULL
            OR comparison_id IS NOT NULL
            OR target_entity_id IS NOT NULL
            OR target_entity_type IN (
                'USER',
                'SYSTEM',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_notification_subscriptions_filter_configuration
        CHECK (
            jsonb_typeof(filter_configuration) = 'object'
        ),

    CONSTRAINT chk_notification_subscriptions_threshold_configuration
        CHECK (
            jsonb_typeof(threshold_configuration) = 'object'
        ),

    CONSTRAINT chk_notification_subscriptions_channel_overrides
        CHECK (
            jsonb_typeof(channel_overrides) = 'object'
        ),

    CONSTRAINT chk_notification_subscriptions_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.alert_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    alert_reference TEXT NOT NULL,

    event_type TEXT NOT NULL,

    event_category TEXT NOT NULL,

    event_source TEXT NOT NULL DEFAULT 'PLATFORM',

    severity TEXT NOT NULL DEFAULT 'NORMAL',

    target_entity_type TEXT NOT NULL,

    target_entity_id UUID,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_run_id UUID
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    comparison_id UUID
        REFERENCES public.card_comparisons(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    saved_card_id UUID
        REFERENCES public.user_saved_cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    source_reference TEXT,

    correlation_id TEXT,

    deduplication_key TEXT,

    event_status TEXT NOT NULL DEFAULT 'DETECTED',

    title TEXT,

    description TEXT,

    previous_numeric_value NUMERIC(18, 6),

    current_numeric_value NUMERIC(18, 6),

    numeric_change NUMERIC(18, 6),

    percentage_change NUMERIC(12, 6),

    previous_text_value TEXT,

    current_text_value TEXT,

    previous_boolean_value BOOLEAN,

    current_boolean_value BOOLEAN,

    effective_at TIMESTAMPTZ,

    detected_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    processing_started_at TIMESTAMPTZ,

    processed_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    matched_subscription_count INTEGER NOT NULL DEFAULT 0,

    generated_notification_count INTEGER NOT NULL DEFAULT 0,

    suppressed_notification_count INTEGER NOT NULL DEFAULT 0,

    processing_attempts INTEGER NOT NULL DEFAULT 0,

    last_processing_error TEXT,

    source_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    change_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    matching_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    processing_errors JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_alert_events_reference
        UNIQUE (
            alert_reference
        ),

    CONSTRAINT uq_alert_events_deduplication_key
        UNIQUE (
            deduplication_key
        ),

    CONSTRAINT chk_alert_events_reference
        CHECK (
            alert_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_alert_events_type
        CHECK (
            event_type IN (
                'CARD_CREATED',
                'CARD_UPDATED',
                'CARD_DISCONTINUED',
                'ANNUAL_FEE_INCREASED',
                'ANNUAL_FEE_DECREASED',
                'FOREIGN_FEE_INCREASED',
                'FOREIGN_FEE_DECREASED',
                'CASH_WITHDRAWAL_FEE_CHANGED',
                'REWARD_RATE_INCREASED',
                'REWARD_RATE_DECREASED',
                'REDEMPTION_VALUE_CHANGED',
                'BENEFIT_ADDED',
                'BENEFIT_UPDATED',
                'BENEFIT_REMOVED',
                'LOUNGE_BENEFIT_CHANGED',
                'TRAVEL_BENEFIT_CHANGED',
                'INSURANCE_BENEFIT_CHANGED',
                'INSTALLMENT_PLAN_CHANGED',
                'NETWORK_BENEFIT_CHANGED',
                'OFFER_CREATED',
                'OFFER_UPDATED',
                'OFFER_EXPIRING',
                'OFFER_EXPIRED',
                'ELIGIBILITY_CHANGED',
                'RECOMMENDATION_COMPLETED',
                'RECOMMENDATION_CHANGED',
                'COMPARISON_COMPLETED',
                'SAVED_CARD_CHANGED',
                'APPLICATION_STATUS_CHANGED',
                'APPLICATION_DOCUMENT_REQUIRED',
                'APPLICATION_APPROVED',
                'APPLICATION_REJECTED',
                'APPLICATION_EXPIRED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATED',
                'COMMISSION_STATUS_CHANGED',
                'SECURITY_EVENT',
                'ACCOUNT_EVENT',
                'SYSTEM_EVENT',
                'SCHEDULED_REMINDER',
                'CUSTOM_EVENT'
            )
        ),

    CONSTRAINT chk_alert_events_category
        CHECK (
            event_category IN (
                'CARD',
                'FEE',
                'REWARD',
                'BENEFIT',
                'OFFER',
                'ELIGIBILITY',
                'RECOMMENDATION',
                'COMPARISON',
                'SAVED_CARD',
                'APPLICATION',
                'COMMISSION',
                'SECURITY',
                'ACCOUNT',
                'SYSTEM',
                'REMINDER',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_alert_events_source
        CHECK (
            event_source IN (
                'PLATFORM',
                'ADMIN',
                'BANK',
                'PARTNER',
                'API',
                'WEBHOOK',
                'BATCH_IMPORT',
                'SCHEDULED_JOB',
                'CHANGE_DETECTION',
                'USER_ACTION',
                'RECOMMENDATION_ENGINE',
                'COMPARISON_ENGINE',
                'APPLICATION_ENGINE',
                'MANUAL',
                'TEST',
                'OTHER'
            )
        ),

    CONSTRAINT chk_alert_events_severity
        CHECK (
            severity IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_alert_events_target_entity_type
        CHECK (
            target_entity_type IN (
                'CARD',
                'BANK',
                'CARD_CATEGORY',
                'CARD_PROGRAM',
                'REWARD_PROGRAM',
                'SAVED_CARD',
                'COLLECTION',
                'COMPARISON',
                'RECOMMENDATION',
                'APPLICATION',
                'USER',
                'SYSTEM',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_alert_events_status
        CHECK (
            event_status IN (
                'DETECTED',
                'PENDING',
                'PROCESSING',
                'PROCESSED',
                'PARTIALLY_PROCESSED',
                'SUPPRESSED',
                'FAILED',
                'EXPIRED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_alert_events_percentage_change
        CHECK (
            percentage_change IS NULL
            OR percentage_change BETWEEN -100000 AND 100000
        ),

    CONSTRAINT chk_alert_events_processing_timeline
        CHECK (
            processing_started_at IS NULL
            OR processing_started_at >= detected_at
        ),

    CONSTRAINT chk_alert_events_processed_timeline
        CHECK (
            processed_at IS NULL
            OR processed_at >= detected_at
        ),

    CONSTRAINT chk_alert_events_expiry
        CHECK (
            expires_at IS NULL
            OR expires_at >= detected_at
        ),

    CONSTRAINT chk_alert_events_subscription_count
        CHECK (
            matched_subscription_count >= 0
        ),

    CONSTRAINT chk_alert_events_notification_count
        CHECK (
            generated_notification_count >= 0
        ),

    CONSTRAINT chk_alert_events_suppressed_count
        CHECK (
            suppressed_notification_count >= 0
        ),

    CONSTRAINT chk_alert_events_processing_attempts
        CHECK (
            processing_attempts >= 0
        ),

    CONSTRAINT chk_alert_events_source_payload
        CHECK (
            jsonb_typeof(source_payload) = 'object'
        ),

    CONSTRAINT chk_alert_events_change_details
        CHECK (
            jsonb_typeof(change_details) = 'object'
        ),

    CONSTRAINT chk_alert_events_matching_details
        CHECK (
            jsonb_typeof(matching_details) = 'object'
        ),

    CONSTRAINT chk_alert_events_processing_errors
        CHECK (
            jsonb_typeof(processing_errors) = 'array'
        ),

    CONSTRAINT chk_alert_events_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    alert_event_id UUID
        REFERENCES public.alert_events(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    subscription_id UUID
        REFERENCES public.notification_subscriptions(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    template_id UUID
        REFERENCES public.notification_templates(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    notification_reference TEXT NOT NULL,

    notification_type TEXT NOT NULL,

    notification_category TEXT NOT NULL,

    notification_status TEXT NOT NULL DEFAULT 'QUEUED',

    priority_level TEXT NOT NULL DEFAULT 'NORMAL',

    language_code TEXT NOT NULL DEFAULT 'en',

    title TEXT NOT NULL,

    body TEXT NOT NULL,

    short_body TEXT,

    action_label TEXT,

    action_url TEXT,

    icon_code TEXT,

    image_url TEXT,

    target_entity_type TEXT,

    target_entity_id UUID,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    bank_id UUID
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    recommendation_run_id UUID
        REFERENCES public.recommendation_runs(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    comparison_id UUID
        REFERENCES public.card_comparisons(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    saved_card_id UUID
        REFERENCES public.user_saved_cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    correlation_id TEXT,

    deduplication_key TEXT,

    batch_reference TEXT,

    digest_reference TEXT,

    scheduled_for TIMESTAMPTZ NOT NULL DEFAULT now(),

    queued_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    processing_started_at TIMESTAMPTZ,

    sent_at TIMESTAMPTZ,

    first_delivered_at TIMESTAMPTZ,

    first_opened_at TIMESTAMPTZ,

    first_clicked_at TIMESTAMPTZ,

    read_at TIMESTAMPTZ,

    dismissed_at TIMESTAMPTZ,

    archived_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    cancelled_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    retry_count INTEGER NOT NULL DEFAULT 0,

    maximum_retry_count INTEGER NOT NULL DEFAULT 3,

    next_retry_at TIMESTAMPTZ,

    failure_code TEXT,

    failure_message TEXT,

    is_read BOOLEAN NOT NULL DEFAULT FALSE,

    is_opened BOOLEAN NOT NULL DEFAULT FALSE,

    is_clicked BOOLEAN NOT NULL DEFAULT FALSE,

    is_dismissed BOOLEAN NOT NULL DEFAULT FALSE,

    is_archived BOOLEAN NOT NULL DEFAULT FALSE,

    is_silent BOOLEAN NOT NULL DEFAULT FALSE,

    is_transactional BOOLEAN NOT NULL DEFAULT FALSE,

    is_marketing BOOLEAN NOT NULL DEFAULT FALSE,

    requires_acknowledgement BOOLEAN NOT NULL DEFAULT FALSE,

    acknowledged_at TIMESTAMPTZ,

    payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    rendered_content JSONB NOT NULL DEFAULT '{}'::JSONB,

    channel_plan JSONB NOT NULL DEFAULT '[]'::JSONB,

    delivery_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    personalization_context JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_notifications_reference
        UNIQUE (
            notification_reference
        ),

    CONSTRAINT uq_notifications_deduplication
        UNIQUE (
            user_id,
            deduplication_key
        ),

    CONSTRAINT chk_notifications_reference
        CHECK (
            notification_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_notifications_type
        CHECK (
            notification_type IN (
                'CARD_UPDATE',
                'CARD_NEW',
                'CARD_DISCONTINUED',
                'ANNUAL_FEE_CHANGE',
                'FOREIGN_FEE_CHANGE',
                'CASH_WITHDRAWAL_FEE_CHANGE',
                'REWARD_RATE_CHANGE',
                'REDEMPTION_VALUE_CHANGE',
                'BENEFIT_CHANGE',
                'LOUNGE_CHANGE',
                'TRAVEL_BENEFIT_CHANGE',
                'INSURANCE_CHANGE',
                'INSTALLMENT_CHANGE',
                'NETWORK_BENEFIT_CHANGE',
                'WELCOME_OFFER_NEW',
                'OFFER_UPDATED',
                'OFFER_EXPIRING',
                'OFFER_EXPIRED',
                'ELIGIBILITY_CHANGE',
                'RECOMMENDATION_READY',
                'RECOMMENDATION_UPDATED',
                'COMPARISON_READY',
                'SAVED_CARD_UPDATE',
                'WATCHLIST_ALERT',
                'PRICE_OR_VALUE_ALERT',
                'APPLICATION_UPDATE',
                'APPLICATION_DOCUMENT_REQUIRED',
                'APPLICATION_APPROVED',
                'APPLICATION_REJECTED',
                'APPLICATION_EXPIRED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATION_REMINDER',
                'FIRST_TRANSACTION_REMINDER',
                'COMMISSION_UPDATE',
                'SECURITY_ALERT',
                'ACCOUNT_ALERT',
                'SYSTEM_ANNOUNCEMENT',
                'MARKETING_CAMPAIGN',
                'DIGEST',
                'REMINDER',
                'CUSTOM',
                'OTHER'
            )
        ),

    CONSTRAINT chk_notifications_category
        CHECK (
            notification_category IN (
                'CARD',
                'FEE',
                'REWARD',
                'BENEFIT',
                'OFFER',
                'ELIGIBILITY',
                'RECOMMENDATION',
                'COMPARISON',
                'SAVED_CARD',
                'APPLICATION',
                'COMMISSION',
                'SECURITY',
                'ACCOUNT',
                'SYSTEM',
                'MARKETING',
                'REMINDER',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_notifications_status
        CHECK (
            notification_status IN (
                'DRAFT',
                'SCHEDULED',
                'QUEUED',
                'PROCESSING',
                'SENT',
                'PARTIALLY_SENT',
                'DELIVERED',
                'OPENED',
                'CLICKED',
                'READ',
                'DISMISSED',
                'FAILED',
                'RETRY_PENDING',
                'SUPPRESSED',
                'EXPIRED',
                'CANCELLED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_notifications_priority
        CHECK (
            priority_level IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_notifications_language
        CHECK (
            language_code ~ '^[a-z]{2}(?:-[A-Z]{2})?$'
        ),

    CONSTRAINT chk_notifications_title
        CHECK (
            length(trim(title)) > 0
        ),

    CONSTRAINT chk_notifications_body
        CHECK (
            length(trim(body)) > 0
        ),

    CONSTRAINT chk_notifications_short_body
        CHECK (
            short_body IS NULL
            OR length(trim(short_body)) > 0
        ),

    CONSTRAINT chk_notifications_icon
        CHECK (
            icon_code IS NULL
            OR icon_code ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_notifications_retry_count
        CHECK (
            retry_count >= 0
        ),

    CONSTRAINT chk_notifications_maximum_retry
        CHECK (
            maximum_retry_count >= 0
        ),

    CONSTRAINT chk_notifications_retry_limit
        CHECK (
            retry_count <= maximum_retry_count
        ),

    CONSTRAINT chk_notifications_scheduling
        CHECK (
            queued_at >= created_at
        ),

    CONSTRAINT chk_notifications_processing
        CHECK (
            processing_started_at IS NULL
            OR processing_started_at >= queued_at
        ),

    CONSTRAINT chk_notifications_sent
        CHECK (
            sent_at IS NULL
            OR sent_at >= queued_at
        ),

    CONSTRAINT chk_notifications_delivered
        CHECK (
            first_delivered_at IS NULL
            OR sent_at IS NULL
            OR first_delivered_at >= sent_at
        ),

    CONSTRAINT chk_notifications_opened
        CHECK (
            first_opened_at IS NULL
            OR first_delivered_at IS NULL
            OR first_opened_at >= first_delivered_at
        ),

    CONSTRAINT chk_notifications_clicked
        CHECK (
            first_clicked_at IS NULL
            OR first_opened_at IS NULL
            OR first_clicked_at >= first_opened_at
        ),

    CONSTRAINT chk_notifications_read
        CHECK (
            is_read = FALSE
            OR read_at IS NOT NULL
        ),

    CONSTRAINT chk_notifications_dismissed
        CHECK (
            is_dismissed = FALSE
            OR dismissed_at IS NOT NULL
        ),

    CONSTRAINT chk_notifications_archived
        CHECK (
            is_archived = FALSE
            OR archived_at IS NOT NULL
        ),

    CONSTRAINT chk_notifications_opened_flag
        CHECK (
            is_opened = FALSE
            OR first_opened_at IS NOT NULL
        ),

    CONSTRAINT chk_notifications_clicked_flag
        CHECK (
            is_clicked = FALSE
            OR first_clicked_at IS NOT NULL
        ),

    CONSTRAINT chk_notifications_acknowledged
        CHECK (
            acknowledged_at IS NULL
            OR requires_acknowledgement = TRUE
        ),

    CONSTRAINT chk_notifications_marketing_transactional
        CHECK (
            NOT (
                is_marketing = TRUE
                AND is_transactional = TRUE
            )
        ),

    CONSTRAINT chk_notifications_expiry
        CHECK (
            expires_at IS NULL
            OR expires_at >= scheduled_for
        ),

    CONSTRAINT chk_notifications_payload
        CHECK (
            jsonb_typeof(payload) = 'object'
        ),

    CONSTRAINT chk_notifications_rendered_content
        CHECK (
            jsonb_typeof(rendered_content) = 'object'
        ),

    CONSTRAINT chk_notifications_channel_plan
        CHECK (
            jsonb_typeof(channel_plan) = 'array'
        ),

    CONSTRAINT chk_notifications_delivery_summary
        CHECK (
            jsonb_typeof(delivery_summary) = 'object'
        ),

    CONSTRAINT chk_notifications_personalization
        CHECK (
            jsonb_typeof(personalization_context) = 'object'
        ),

    CONSTRAINT chk_notifications_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.notification_deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    notification_id UUID NOT NULL
        REFERENCES public.notifications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    delivery_reference TEXT NOT NULL,

    channel TEXT NOT NULL,

    recipient_address TEXT,

    provider_code TEXT,

    provider_message_reference TEXT,

    delivery_status TEXT NOT NULL DEFAULT 'QUEUED',

    delivery_priority TEXT NOT NULL DEFAULT 'NORMAL',

    sequence_number INTEGER NOT NULL DEFAULT 1,

    attempt_number INTEGER NOT NULL DEFAULT 1,

    maximum_attempts INTEGER NOT NULL DEFAULT 3,

    scheduled_for TIMESTAMPTZ NOT NULL DEFAULT now(),

    queued_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    sending_started_at TIMESTAMPTZ,

    sent_at TIMESTAMPTZ,

    accepted_at TIMESTAMPTZ,

    delivered_at TIMESTAMPTZ,

    opened_at TIMESTAMPTZ,

    clicked_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    bounced_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    complained_at TIMESTAMPTZ,

    unsubscribed_at TIMESTAMPTZ,

    next_retry_at TIMESTAMPTZ,

    provider_status_code TEXT,

    failure_code TEXT,

    failure_category TEXT,

    failure_message TEXT,

    latency_milliseconds BIGINT,

    cost_amount NUMERIC(18, 6),

    cost_currency_code TEXT,

    provider_request JSONB NOT NULL DEFAULT '{}'::JSONB,

    provider_response JSONB NOT NULL DEFAULT '{}'::JSONB,

    tracking_data JSONB NOT NULL DEFAULT '{}'::JSONB,

    delivery_metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_notification_deliveries_reference
        UNIQUE (
            delivery_reference
        ),

    CONSTRAINT uq_notification_deliveries_attempt
        UNIQUE (
            notification_id,
            channel,
            attempt_number
        ),

    CONSTRAINT chk_notification_deliveries_reference
        CHECK (
            delivery_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_notification_deliveries_channel
        CHECK (
            channel IN (
                'IN_APP',
                'EMAIL',
                'PUSH',
                'SMS',
                'WHATSAPP',
                'WEBHOOK'
            )
        ),

    CONSTRAINT chk_notification_deliveries_status
        CHECK (
            delivery_status IN (
                'SCHEDULED',
                'QUEUED',
                'SENDING',
                'SENT',
                'ACCEPTED',
                'DELIVERED',
                'OPENED',
                'CLICKED',
                'FAILED',
                'BOUNCED',
                'REJECTED',
                'COMPLAINED',
                'UNSUBSCRIBED',
                'CANCELLED',
                'EXPIRED'
            )
        ),

    CONSTRAINT chk_notification_deliveries_priority
        CHECK (
            delivery_priority IN (
                'LOW',
                'NORMAL',
                'HIGH',
                'URGENT',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_notification_deliveries_sequence
        CHECK (
            sequence_number > 0
        ),

    CONSTRAINT chk_notification_deliveries_attempt
        CHECK (
            attempt_number > 0
        ),

    CONSTRAINT chk_notification_deliveries_maximum_attempts
        CHECK (
            maximum_attempts > 0
        ),

    CONSTRAINT chk_notification_deliveries_attempt_limit
        CHECK (
            attempt_number <= maximum_attempts
        ),

    CONSTRAINT chk_notification_deliveries_sending
        CHECK (
            sending_started_at IS NULL
            OR sending_started_at >= queued_at
        ),

    CONSTRAINT chk_notification_deliveries_sent
        CHECK (
            sent_at IS NULL
            OR sent_at >= queued_at
        ),

    CONSTRAINT chk_notification_deliveries_accepted
        CHECK (
            accepted_at IS NULL
            OR sent_at IS NULL
            OR accepted_at >= sent_at
        ),

    CONSTRAINT chk_notification_deliveries_delivered
        CHECK (
            delivered_at IS NULL
            OR sent_at IS NULL
            OR delivered_at >= sent_at
        ),

    CONSTRAINT chk_notification_deliveries_opened
        CHECK (
            opened_at IS NULL
            OR delivered_at IS NULL
            OR opened_at >= delivered_at
        ),

    CONSTRAINT chk_notification_deliveries_clicked
        CHECK (
            clicked_at IS NULL
            OR opened_at IS NULL
            OR clicked_at >= opened_at
        ),

    CONSTRAINT chk_notification_deliveries_latency
        CHECK (
            latency_milliseconds IS NULL
            OR latency_milliseconds >= 0
        ),

    CONSTRAINT chk_notification_deliveries_cost
        CHECK (
            cost_amount IS NULL
            OR cost_amount >= 0
        ),

    CONSTRAINT chk_notification_deliveries_cost_currency
        CHECK (
            (
                cost_amount IS NULL
                AND cost_currency_code IS NULL
            )
            OR
            (
                cost_amount IS NOT NULL
                AND cost_currency_code IS NOT NULL
                AND cost_currency_code ~ '^[A-Z]{3}$'
            )
        ),

    CONSTRAINT chk_notification_deliveries_provider_request
        CHECK (
            jsonb_typeof(provider_request) = 'object'
        ),

    CONSTRAINT chk_notification_deliveries_provider_response
        CHECK (
            jsonb_typeof(provider_response) = 'object'
        ),

    CONSTRAINT chk_notification_deliveries_tracking_data
        CHECK (
            jsonb_typeof(tracking_data) = 'object'
        ),

    CONSTRAINT chk_notification_deliveries_metadata
        CHECK (
            jsonb_typeof(delivery_metadata) = 'object'
        )
);

CREATE UNIQUE INDEX uq_notification_templates_default
ON public.notification_templates(
    notification_type,
    channel,
    language_code
)
WHERE is_default = TRUE
  AND is_active = TRUE;

CREATE INDEX idx_notification_templates_lookup
ON public.notification_templates(
    notification_type,
    channel,
    language_code,
    template_status,
    template_version DESC
)
WHERE is_active = TRUE;

CREATE INDEX idx_notification_templates_status
ON public.notification_templates(
    template_status,
    updated_at DESC
);

CREATE INDEX idx_notification_templates_validity
ON public.notification_templates(
    valid_from,
    valid_until
)
WHERE is_active = TRUE;

CREATE INDEX idx_notification_templates_required_variables
ON public.notification_templates
USING GIN (required_variables);

CREATE INDEX idx_notification_templates_metadata
ON public.notification_templates
USING GIN (metadata);

CREATE INDEX idx_user_notification_preferences_enabled
ON public.user_notification_preferences(
    user_id,
    notifications_enabled
);

CREATE INDEX idx_user_notification_preferences_digest
ON public.user_notification_preferences(
    digest_frequency,
    digest_day_of_week,
    digest_hour_local
)
WHERE digest_enabled = TRUE
  AND notifications_enabled = TRUE;

CREATE INDEX idx_user_notification_preferences_marketing
ON public.user_notification_preferences(user_id)
WHERE marketing_enabled = TRUE
  AND consent_status = 'GRANTED';

CREATE INDEX idx_user_notification_preferences_type_preferences
ON public.user_notification_preferences
USING GIN (notification_type_preferences);

CREATE INDEX idx_user_notification_preferences_metadata
ON public.user_notification_preferences
USING GIN (metadata);

CREATE INDEX idx_notification_subscriptions_user
ON public.notification_subscriptions(
    user_id,
    created_at DESC
)
WHERE is_active = TRUE;

CREATE INDEX idx_notification_subscriptions_target
ON public.notification_subscriptions(
    target_entity_type,
    target_entity_id
)
WHERE is_active = TRUE
  AND is_paused = FALSE;

CREATE INDEX idx_notification_subscriptions_card
ON public.notification_subscriptions(
    card_id,
    notification_type
)
WHERE card_id IS NOT NULL
  AND is_active = TRUE
  AND is_paused = FALSE;

CREATE INDEX idx_notification_subscriptions_bank
ON public.notification_subscriptions(
    bank_id,
    notification_type
)
WHERE bank_id IS NOT NULL
  AND is_active = TRUE
  AND is_paused = FALSE;

CREATE INDEX idx_notification_subscriptions_saved_card
ON public.notification_subscriptions(saved_card_id)
WHERE saved_card_id IS NOT NULL
  AND is_active = TRUE;

CREATE INDEX idx_notification_subscriptions_collection
ON public.notification_subscriptions(collection_id)
WHERE collection_id IS NOT NULL
  AND is_active = TRUE;

CREATE INDEX idx_notification_subscriptions_comparison
ON public.notification_subscriptions(comparison_id)
WHERE comparison_id IS NOT NULL
  AND is_active = TRUE;

CREATE INDEX idx_notification_subscriptions_event_type
ON public.notification_subscriptions(
    notification_type,
    event_category,
    delivery_mode
)
WHERE is_active = TRUE
  AND is_paused = FALSE;

CREATE INDEX idx_notification_subscriptions_paused
ON public.notification_subscriptions(paused_until)
WHERE is_paused = TRUE;

CREATE INDEX idx_notification_subscriptions_expiring
ON public.notification_subscriptions(expires_at)
WHERE expires_at IS NOT NULL
  AND is_active = TRUE;

CREATE INDEX idx_notification_subscriptions_filter
ON public.notification_subscriptions
USING GIN (filter_configuration);

CREATE INDEX idx_notification_subscriptions_threshold
ON public.notification_subscriptions
USING GIN (threshold_configuration);

CREATE INDEX idx_notification_subscriptions_metadata
ON public.notification_subscriptions
USING GIN (metadata);

CREATE INDEX idx_alert_events_pending
ON public.alert_events(
    severity DESC,
    detected_at
)
WHERE event_status IN (
    'DETECTED',
    'PENDING',
    'PROCESSING',
    'PARTIALLY_PROCESSED'
);

CREATE INDEX idx_alert_events_type
ON public.alert_events(
    event_type,
    detected_at DESC
);

CREATE INDEX idx_alert_events_category
ON public.alert_events(
    event_category,
    detected_at DESC
);

CREATE INDEX idx_alert_events_target
ON public.alert_events(
    target_entity_type,
    target_entity_id,
    detected_at DESC
);

CREATE INDEX idx_alert_events_card
ON public.alert_events(
    card_id,
    detected_at DESC
)
WHERE card_id IS NOT NULL;

CREATE INDEX idx_alert_events_bank
ON public.alert_events(
    bank_id,
    detected_at DESC
)
WHERE bank_id IS NOT NULL;

CREATE INDEX idx_alert_events_recommendation
ON public.alert_events(
    recommendation_run_id,
    detected_at DESC
)
WHERE recommendation_run_id IS NOT NULL;

CREATE INDEX idx_alert_events_comparison
ON public.alert_events(
    comparison_id,
    detected_at DESC
)
WHERE comparison_id IS NOT NULL;

CREATE INDEX idx_alert_events_correlation
ON public.alert_events(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_alert_events_expiring
ON public.alert_events(expires_at)
WHERE expires_at IS NOT NULL
  AND event_status NOT IN (
      'PROCESSED',
      'SUPPRESSED',
      'FAILED',
      'EXPIRED',
      'CANCELLED'
  );

CREATE INDEX idx_alert_events_source_payload
ON public.alert_events
USING GIN (source_payload);

CREATE INDEX idx_alert_events_change_details
ON public.alert_events
USING GIN (change_details);

CREATE INDEX idx_alert_events_processing_errors
ON public.alert_events
USING GIN (processing_errors);

CREATE INDEX idx_alert_events_metadata
ON public.alert_events
USING GIN (metadata);

CREATE INDEX idx_notifications_user
ON public.notifications(
    user_id,
    created_at DESC
);

CREATE INDEX idx_notifications_user_unread
ON public.notifications(
    user_id,
    priority_level,
    created_at DESC
)
WHERE is_read = FALSE
  AND is_archived = FALSE
  AND notification_status NOT IN (
      'CANCELLED',
      'EXPIRED',
      'FAILED',
      'SUPPRESSED'
  );

CREATE INDEX idx_notifications_queue
ON public.notifications(
    priority_level,
    scheduled_for,
    queued_at
)
WHERE notification_status IN (
    'SCHEDULED',
    'QUEUED',
    'RETRY_PENDING'
);

CREATE INDEX idx_notifications_processing
ON public.notifications(processing_started_at)
WHERE notification_status = 'PROCESSING';

CREATE INDEX idx_notifications_retry
ON public.notifications(
    next_retry_at,
    priority_level
)
WHERE notification_status = 'RETRY_PENDING'
  AND retry_count < maximum_retry_count;

CREATE INDEX idx_notifications_alert_event
ON public.notifications(
    alert_event_id,
    created_at DESC
)
WHERE alert_event_id IS NOT NULL;

CREATE INDEX idx_notifications_subscription
ON public.notifications(
    subscription_id,
    created_at DESC
)
WHERE subscription_id IS NOT NULL;

CREATE INDEX idx_notifications_template
ON public.notifications(
    template_id,
    created_at DESC
)
WHERE template_id IS NOT NULL;

CREATE INDEX idx_notifications_card
ON public.notifications(
    card_id,
    created_at DESC
)
WHERE card_id IS NOT NULL;

CREATE INDEX idx_notifications_bank
ON public.notifications(
    bank_id,
    created_at DESC
)
WHERE bank_id IS NOT NULL;

CREATE INDEX idx_notifications_recommendation
ON public.notifications(
    recommendation_run_id,
    created_at DESC
)
WHERE recommendation_run_id IS NOT NULL;

CREATE INDEX idx_notifications_comparison
ON public.notifications(
    comparison_id,
    created_at DESC
)
WHERE comparison_id IS NOT NULL;

CREATE INDEX idx_notifications_expiring
ON public.notifications(expires_at)
WHERE expires_at IS NOT NULL
  AND notification_status NOT IN (
      'EXPIRED',
      'CANCELLED',
      'ARCHIVED'
  );

CREATE INDEX idx_notifications_batch
ON public.notifications(
    batch_reference,
    created_at DESC
)
WHERE batch_reference IS NOT NULL;

CREATE INDEX idx_notifications_digest
ON public.notifications(
    digest_reference,
    created_at DESC
)
WHERE digest_reference IS NOT NULL;

CREATE INDEX idx_notifications_correlation
ON public.notifications(correlation_id)
WHERE correlation_id IS NOT NULL;

CREATE INDEX idx_notifications_payload
ON public.notifications
USING GIN (payload);

CREATE INDEX idx_notifications_delivery_summary
ON public.notifications
USING GIN (delivery_summary);

CREATE INDEX idx_notifications_metadata
ON public.notifications
USING GIN (metadata);

CREATE INDEX idx_notification_deliveries_notification
ON public.notification_deliveries(
    notification_id,
    sequence_number,
    attempt_number
);

CREATE INDEX idx_notification_deliveries_queue
ON public.notification_deliveries(
    delivery_priority,
    scheduled_for,
    queued_at
)
WHERE delivery_status IN (
    'SCHEDULED',
    'QUEUED'
);

CREATE INDEX idx_notification_deliveries_status
ON public.notification_deliveries(
    channel,
    delivery_status,
    created_at DESC
);

CREATE INDEX idx_notification_deliveries_provider_reference
ON public.notification_deliveries(
    provider_code,
    provider_message_reference
)
WHERE provider_message_reference IS NOT NULL;

CREATE INDEX idx_notification_deliveries_retry
ON public.notification_deliveries(
    next_retry_at,
    channel
)
WHERE next_retry_at IS NOT NULL
  AND delivery_status = 'FAILED'
  AND attempt_number < maximum_attempts;

CREATE INDEX idx_notification_deliveries_failed
ON public.notification_deliveries(
    failure_category,
    failure_code,
    failed_at DESC
)
WHERE delivery_status IN (
    'FAILED',
    'BOUNCED',
    'REJECTED'
);

CREATE INDEX idx_notification_deliveries_delivered
ON public.notification_deliveries(
    channel,
    delivered_at DESC
)
WHERE delivered_at IS NOT NULL;

CREATE INDEX idx_notification_deliveries_opened
ON public.notification_deliveries(
    channel,
    opened_at DESC
)
WHERE opened_at IS NOT NULL;

CREATE INDEX idx_notification_deliveries_clicked
ON public.notification_deliveries(
    channel,
    clicked_at DESC
)
WHERE clicked_at IS NOT NULL;

CREATE INDEX idx_notification_deliveries_provider_response
ON public.notification_deliveries
USING GIN (provider_response);

CREATE INDEX idx_notification_deliveries_tracking
ON public.notification_deliveries
USING GIN (tracking_data);

CREATE INDEX idx_notification_deliveries_metadata
ON public.notification_deliveries
USING GIN (delivery_metadata);

CREATE TRIGGER trg_notification_templates_updated_at
BEFORE UPDATE
ON public.notification_templates
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_notification_preferences_updated_at
BEFORE UPDATE
ON public.user_notification_preferences
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_notification_subscriptions_updated_at
BEFORE UPDATE
ON public.notification_subscriptions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_alert_events_updated_at
BEFORE UPDATE
ON public.alert_events
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_notifications_updated_at
BEFORE UPDATE
ON public.notifications
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_notification_deliveries_updated_at
BEFORE UPDATE
ON public.notification_deliveries
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.notification_templates IS
'Versioned multilingual templates used to render in-app, email, push, SMS, WhatsApp, and webhook notifications.';

COMMENT ON COLUMN public.notification_templates.template_code IS
'Stable business code identifying a notification template across versions and languages.';

COMMENT ON COLUMN public.notification_templates.required_variables IS
'Variables that must be provided when rendering the template.';

COMMENT ON COLUMN public.notification_templates.channel_configuration IS
'Channel-specific rendering and provider configuration such as email layout, push options, or SMS limits.';

COMMENT ON TABLE public.user_notification_preferences IS
'Global user preferences governing notification channels, quiet hours, digests, consent, and notification categories.';

COMMENT ON COLUMN public.user_notification_preferences.timezone_name IS
'IANA timezone used when evaluating quiet hours and digest schedules.';

COMMENT ON COLUMN public.user_notification_preferences.notification_type_preferences IS
'Per-notification-type overrides that supplement the normalized preference columns.';

COMMENT ON TABLE public.notification_subscriptions IS
'User subscriptions to cards, banks, saved cards, collections, comparisons, event types, categories, and threshold-based alerts.';

COMMENT ON COLUMN public.notification_subscriptions.target_entity_type IS
'Business entity monitored by the subscription, such as a card, bank, collection, application, or system category.';

COMMENT ON COLUMN public.notification_subscriptions.cooldown_minutes IS
'Minimum period between notifications generated from repeated matching events.';

COMMENT ON TABLE public.alert_events IS
'Normalized business events detected by the platform and evaluated against user notification subscriptions.';

COMMENT ON COLUMN public.alert_events.deduplication_key IS
'Optional unique key preventing the same business change from being processed more than once.';

COMMENT ON COLUMN public.alert_events.change_details IS
'Structured description of fields, values, rules, or source records that changed.';

COMMENT ON TABLE public.notifications IS
'User-facing notification records containing rendered content, scheduling, read state, retry state, and aggregate delivery information.';

COMMENT ON COLUMN public.notifications.channel_plan IS
'Ordered list of channels selected for delivery based on user preferences, priority, consent, and fallback rules.';

COMMENT ON COLUMN public.notifications.delivery_summary IS
'Aggregated delivery state across all channel delivery attempts.';

COMMENT ON COLUMN public.notifications.deduplication_key IS
'User-scoped key preventing duplicate notification creation for the same event or business condition.';

COMMENT ON TABLE public.notification_deliveries IS
'Channel-level notification delivery attempts including provider references, tracking events, retries, failures, cost, and response payloads.';

COMMENT ON COLUMN public.notification_deliveries.provider_message_reference IS
'External identifier returned by the email, push, SMS, WhatsApp, or webhook provider.';

COMMENT ON COLUMN public.notification_deliveries.latency_milliseconds IS
'Elapsed delivery processing time measured in milliseconds.';

COMMENT ON COLUMN public.notification_deliveries.tracking_data IS
'Structured provider or platform tracking information for delivery, open, click, bounce, complaint, and unsubscribe events.';

CREATE TABLE public.bank_partnerships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    partnership_reference TEXT NOT NULL,

    partnership_name TEXT NOT NULL,

    partnership_type TEXT NOT NULL DEFAULT 'REFERRAL',

    partnership_status TEXT NOT NULL DEFAULT 'DRAFT',

    commercial_model TEXT NOT NULL DEFAULT 'CPA',

    integration_model TEXT NOT NULL DEFAULT 'REDIRECT',

    agreement_reference TEXT,

    agreement_version TEXT,

    agreement_signed_at TIMESTAMPTZ,

    agreement_effective_from TIMESTAMPTZ,

    agreement_effective_until TIMESTAMPTZ,

    automatic_renewal BOOLEAN NOT NULL DEFAULT FALSE,

    renewal_notice_days INTEGER,

    termination_notice_days INTEGER,

    default_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    default_attribution_window_days INTEGER NOT NULL DEFAULT 30,

    default_cookie_window_days INTEGER NOT NULL DEFAULT 30,

    default_application_window_days INTEGER NOT NULL DEFAULT 90,

    supports_deep_linking BOOLEAN NOT NULL DEFAULT FALSE,

    supports_api_submission BOOLEAN NOT NULL DEFAULT FALSE,

    supports_application_status_api BOOLEAN NOT NULL DEFAULT FALSE,

    supports_conversion_webhooks BOOLEAN NOT NULL DEFAULT FALSE,

    supports_commission_reports BOOLEAN NOT NULL DEFAULT FALSE,

    supports_reconciliation_files BOOLEAN NOT NULL DEFAULT FALSE,

    supports_open_banking BOOLEAN NOT NULL DEFAULT FALSE,

    requires_customer_consent BOOLEAN NOT NULL DEFAULT TRUE,

    requires_bank_disclosure BOOLEAN NOT NULL DEFAULT TRUE,

    requires_marketing_approval BOOLEAN NOT NULL DEFAULT TRUE,

    referral_disclosure_text TEXT,

    customer_terms_url TEXT,

    privacy_policy_url TEXT,

    bank_portal_url TEXT,

    api_base_url TEXT,

    webhook_url TEXT,

    technical_contact_name TEXT,

    technical_contact_email TEXT,

    commercial_contact_name TEXT,

    commercial_contact_email TEXT,

    finance_contact_name TEXT,

    finance_contact_email TEXT,

    account_manager_user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_at TIMESTAMPTZ,

    suspended_at TIMESTAMPTZ,

    suspended_reason TEXT,

    terminated_at TIMESTAMPTZ,

    termination_reason TEXT,

    contract_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    integration_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    attribution_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    compliance_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    settlement_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_partnerships_reference
        UNIQUE (
            partnership_reference
        ),

    CONSTRAINT uq_bank_partnerships_bank_name
        UNIQUE (
            bank_id,
            partnership_name
        ),

    CONSTRAINT chk_bank_partnerships_reference
        CHECK (
            partnership_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_bank_partnerships_name
        CHECK (
            length(trim(partnership_name)) > 0
        ),

    CONSTRAINT chk_bank_partnerships_type
        CHECK (
            partnership_type IN (
                'REFERRAL',
                'AFFILIATE',
                'LEAD_GENERATION',
                'APPLICATION_PROCESSING',
                'API_DISTRIBUTION',
                'WHITE_LABEL',
                'MARKETPLACE',
                'OPEN_BANKING',
                'DATA_PARTNERSHIP',
                'STRATEGIC',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_partnerships_status
        CHECK (
            partnership_status IN (
                'DRAFT',
                'UNDER_REVIEW',
                'PENDING_APPROVAL',
                'APPROVED',
                'ACTIVE',
                'SUSPENDED',
                'EXPIRED',
                'TERMINATED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_bank_partnerships_commercial_model
        CHECK (
            commercial_model IN (
                'CPA',
                'CPL',
                'CPC',
                'CPI',
                'REVENUE_SHARE',
                'FIXED_FEE',
                'HYBRID',
                'NO_COMMISSION',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_bank_partnerships_integration_model
        CHECK (
            integration_model IN (
                'REDIRECT',
                'DEEPLINK',
                'TRACKING_LINK',
                'BANK_API',
                'PARTNER_API',
                'EMBEDDED_APPLICATION',
                'LEAD_TRANSFER',
                'FILE_TRANSFER',
                'MANUAL',
                'HYBRID',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_partnerships_agreement_dates
        CHECK (
            agreement_effective_until IS NULL
            OR agreement_effective_from IS NULL
            OR agreement_effective_until >= agreement_effective_from
        ),

    CONSTRAINT chk_bank_partnerships_renewal_notice
        CHECK (
            renewal_notice_days IS NULL
            OR renewal_notice_days >= 0
        ),

    CONSTRAINT chk_bank_partnerships_termination_notice
        CHECK (
            termination_notice_days IS NULL
            OR termination_notice_days >= 0
        ),

    CONSTRAINT chk_bank_partnerships_attribution_window
        CHECK (
            default_attribution_window_days >= 0
        ),

    CONSTRAINT chk_bank_partnerships_cookie_window
        CHECK (
            default_cookie_window_days >= 0
        ),

    CONSTRAINT chk_bank_partnerships_application_window
        CHECK (
            default_application_window_days >= 0
        ),

    CONSTRAINT chk_bank_partnerships_technical_email
        CHECK (
            technical_contact_email IS NULL
            OR technical_contact_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
        ),

    CONSTRAINT chk_bank_partnerships_commercial_email
        CHECK (
            commercial_contact_email IS NULL
            OR commercial_contact_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
        ),

    CONSTRAINT chk_bank_partnerships_finance_email
        CHECK (
            finance_contact_email IS NULL
            OR finance_contact_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
        ),

    CONSTRAINT chk_bank_partnerships_approval
        CHECK (
            approved_by IS NULL
            OR approved_at IS NOT NULL
        ),

    CONSTRAINT chk_bank_partnerships_suspension
        CHECK (
            suspended_at IS NULL
            OR partnership_status IN (
                'SUSPENDED',
                'TERMINATED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_bank_partnerships_termination
        CHECK (
            terminated_at IS NULL
            OR partnership_status IN (
                'TERMINATED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_bank_partnerships_contract_configuration
        CHECK (
            jsonb_typeof(contract_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_partnerships_integration_configuration
        CHECK (
            jsonb_typeof(integration_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_partnerships_attribution_configuration
        CHECK (
            jsonb_typeof(attribution_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_partnerships_compliance_configuration
        CHECK (
            jsonb_typeof(compliance_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_partnerships_settlement_configuration
        CHECK (
            jsonb_typeof(settlement_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_partnerships_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.bank_partner_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    partnership_id UUID NOT NULL
        REFERENCES public.bank_partnerships(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    partner_product_reference TEXT NOT NULL,

    bank_product_reference TEXT,

    product_name TEXT NOT NULL,

    product_type TEXT NOT NULL DEFAULT 'CREDIT_CARD',

    product_status TEXT NOT NULL DEFAULT 'DRAFT',

    distribution_status TEXT NOT NULL DEFAULT 'DISABLED',

    application_method TEXT NOT NULL DEFAULT 'REDIRECT',

    destination_url TEXT,

    deep_link_template TEXT,

    application_api_operation_code TEXT,

    eligibility_api_operation_code TEXT,

    status_api_operation_code TEXT,

    product_rank INTEGER,

    is_featured BOOLEAN NOT NULL DEFAULT FALSE,

    is_exclusive BOOLEAN NOT NULL DEFAULT FALSE,

    is_preapproval_supported BOOLEAN NOT NULL DEFAULT FALSE,

    is_instant_decision_supported BOOLEAN NOT NULL DEFAULT FALSE,

    is_existing_customer_only BOOLEAN NOT NULL DEFAULT FALSE,

    is_new_to_bank_only BOOLEAN NOT NULL DEFAULT FALSE,

    minimum_monthly_income NUMERIC(18, 6),

    minimum_income_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    minimum_age INTEGER,

    maximum_age INTEGER,

    eligible_nationality_codes JSONB NOT NULL DEFAULT '[]'::JSONB,

    eligible_residency_codes JSONB NOT NULL DEFAULT '[]'::JSONB,

    eligible_employment_types JSONB NOT NULL DEFAULT '[]'::JSONB,

    excluded_customer_segments JSONB NOT NULL DEFAULT '[]'::JSONB,

    attribution_window_days INTEGER,

    cookie_window_days INTEGER,

    application_window_days INTEGER,

    available_from TIMESTAMPTZ,

    available_until TIMESTAMPTZ,

    approved_marketing_copy JSONB NOT NULL DEFAULT '{}'::JSONB,

    eligibility_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    application_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    tracking_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_bank_partner_products_reference
        UNIQUE (
            partner_product_reference
        ),

    CONSTRAINT uq_bank_partner_products_partnership_card
        UNIQUE (
            partnership_id,
            card_id
        ),

    CONSTRAINT chk_bank_partner_products_reference
        CHECK (
            partner_product_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_bank_partner_products_name
        CHECK (
            length(trim(product_name)) > 0
        ),

    CONSTRAINT chk_bank_partner_products_type
        CHECK (
            product_type IN (
                'CREDIT_CARD',
                'CHARGE_CARD',
                'DEBIT_CARD',
                'PREPAID_CARD',
                'BANK_ACCOUNT',
                'PERSONAL_FINANCE',
                'AUTO_FINANCE',
                'MORTGAGE',
                'SAVINGS_PRODUCT',
                'INVESTMENT_PRODUCT',
                'INSURANCE_PRODUCT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_partner_products_status
        CHECK (
            product_status IN (
                'DRAFT',
                'UNDER_REVIEW',
                'APPROVED',
                'ACTIVE',
                'SUSPENDED',
                'DISCONTINUED',
                'EXPIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_bank_partner_products_distribution_status
        CHECK (
            distribution_status IN (
                'DISABLED',
                'TESTING',
                'ENABLED',
                'PAUSED',
                'LIMITED',
                'CLOSED'
            )
        ),

    CONSTRAINT chk_bank_partner_products_application_method
        CHECK (
            application_method IN (
                'REDIRECT',
                'DEEPLINK',
                'TRACKING_LINK',
                'BANK_API',
                'PARTNER_API',
                'EMBEDDED_FORM',
                'LEAD_FORM',
                'BRANCH_REFERRAL',
                'CALL_CENTER',
                'MANUAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_bank_partner_products_rank
        CHECK (
            product_rank IS NULL
            OR product_rank > 0
        ),

    CONSTRAINT chk_bank_partner_products_income
        CHECK (
            minimum_monthly_income IS NULL
            OR minimum_monthly_income >= 0
        ),

    CONSTRAINT chk_bank_partner_products_income_currency
        CHECK (
            (
                minimum_monthly_income IS NULL
                AND minimum_income_currency_id IS NULL
            )
            OR
            (
                minimum_monthly_income IS NOT NULL
                AND minimum_income_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_bank_partner_products_age
        CHECK (
            (
                minimum_age IS NULL
                OR minimum_age >= 18
            )
            AND
            (
                maximum_age IS NULL
                OR maximum_age >= 18
            )
            AND
            (
                minimum_age IS NULL
                OR maximum_age IS NULL
                OR maximum_age >= minimum_age
            )
        ),

    CONSTRAINT chk_bank_partner_products_attribution_window
        CHECK (
            attribution_window_days IS NULL
            OR attribution_window_days >= 0
        ),

    CONSTRAINT chk_bank_partner_products_cookie_window
        CHECK (
            cookie_window_days IS NULL
            OR cookie_window_days >= 0
        ),

    CONSTRAINT chk_bank_partner_products_application_window
        CHECK (
            application_window_days IS NULL
            OR application_window_days >= 0
        ),

    CONSTRAINT chk_bank_partner_products_availability
        CHECK (
            available_until IS NULL
            OR available_from IS NULL
            OR available_until >= available_from
        ),

    CONSTRAINT chk_bank_partner_products_nationalities
        CHECK (
            jsonb_typeof(eligible_nationality_codes) = 'array'
        ),

    CONSTRAINT chk_bank_partner_products_residencies
        CHECK (
            jsonb_typeof(eligible_residency_codes) = 'array'
        ),

    CONSTRAINT chk_bank_partner_products_employment
        CHECK (
            jsonb_typeof(eligible_employment_types) = 'array'
        ),

    CONSTRAINT chk_bank_partner_products_excluded_segments
        CHECK (
            jsonb_typeof(excluded_customer_segments) = 'array'
        ),

    CONSTRAINT chk_bank_partner_products_marketing_copy
        CHECK (
            jsonb_typeof(approved_marketing_copy) = 'object'
        ),

    CONSTRAINT chk_bank_partner_products_eligibility
        CHECK (
            jsonb_typeof(eligibility_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_partner_products_application
        CHECK (
            jsonb_typeof(application_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_partner_products_tracking
        CHECK (
            jsonb_typeof(tracking_configuration) = 'object'
        ),

    CONSTRAINT chk_bank_partner_products_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.referral_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    partnership_id UUID NOT NULL
        REFERENCES public.bank_partnerships(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    partner_product_id UUID
        REFERENCES public.bank_partner_products(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    referral_link_reference TEXT NOT NULL,

    referral_code TEXT NOT NULL,

    link_name TEXT NOT NULL,

    destination_url TEXT NOT NULL,

    short_url TEXT,

    deep_link_url TEXT,

    link_status TEXT NOT NULL DEFAULT 'DRAFT',

    link_type TEXT NOT NULL DEFAULT 'PRODUCT',

    channel TEXT NOT NULL DEFAULT 'WEB',

    campaign_reference TEXT,

    placement_reference TEXT,

    creative_reference TEXT,

    source_code TEXT,

    medium_code TEXT,

    campaign_code TEXT,

    content_code TEXT,

    term_code TEXT,

    attribution_model TEXT NOT NULL DEFAULT 'LAST_CLICK',

    attribution_window_days INTEGER,

    cookie_window_days INTEGER,

    maximum_clicks INTEGER,

    maximum_conversions INTEGER,

    click_count BIGINT NOT NULL DEFAULT 0,

    unique_click_count BIGINT NOT NULL DEFAULT 0,

    application_count BIGINT NOT NULL DEFAULT 0,

    approved_application_count BIGINT NOT NULL DEFAULT 0,

    conversion_count BIGINT NOT NULL DEFAULT 0,

    starts_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    expires_at TIMESTAMPTZ,

    last_clicked_at TIMESTAMPTZ,

    last_converted_at TIMESTAMPTZ,

    is_test_link BOOLEAN NOT NULL DEFAULT FALSE,

    tracking_parameters JSONB NOT NULL DEFAULT '{}'::JSONB,

    routing_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_referral_links_reference
        UNIQUE (
            referral_link_reference
        ),

    CONSTRAINT uq_referral_links_code
        UNIQUE (
            referral_code
        ),

    CONSTRAINT chk_referral_links_reference
        CHECK (
            referral_link_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_referral_links_code
        CHECK (
            referral_code
                ~ '^[A-Za-z0-9][A-Za-z0-9_-]*$'
        ),

    CONSTRAINT chk_referral_links_name
        CHECK (
            length(trim(link_name)) > 0
        ),

    CONSTRAINT chk_referral_links_destination
        CHECK (
            length(trim(destination_url)) > 0
        ),

    CONSTRAINT chk_referral_links_status
        CHECK (
            link_status IN (
                'DRAFT',
                'ACTIVE',
                'PAUSED',
                'EXPIRED',
                'DISABLED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_referral_links_type
        CHECK (
            link_type IN (
                'PRODUCT',
                'BANK',
                'CAMPAIGN',
                'COMPARISON',
                'RECOMMENDATION',
                'CONTENT',
                'ADVISOR',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_referral_links_channel
        CHECK (
            channel IN (
                'WEB',
                'MOBILE_APP',
                'EMAIL',
                'SMS',
                'WHATSAPP',
                'PUSH',
                'SOCIAL',
                'PAID_SEARCH',
                'DISPLAY',
                'AFFILIATE',
                'ADVISOR',
                'QR_CODE',
                'API',
                'OTHER'
            )
        ),

    CONSTRAINT chk_referral_links_attribution_model
        CHECK (
            attribution_model IN (
                'FIRST_CLICK',
                'LAST_CLICK',
                'LINEAR',
                'POSITION_BASED',
                'TIME_DECAY',
                'LAST_NON_DIRECT',
                'BANK_REPORTED',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_referral_links_attribution_window
        CHECK (
            attribution_window_days IS NULL
            OR attribution_window_days >= 0
        ),

    CONSTRAINT chk_referral_links_cookie_window
        CHECK (
            cookie_window_days IS NULL
            OR cookie_window_days >= 0
        ),

    CONSTRAINT chk_referral_links_maximum_clicks
        CHECK (
            maximum_clicks IS NULL
            OR maximum_clicks > 0
        ),

    CONSTRAINT chk_referral_links_maximum_conversions
        CHECK (
            maximum_conversions IS NULL
            OR maximum_conversions > 0
        ),

    CONSTRAINT chk_referral_links_counts
        CHECK (
            click_count >= 0
            AND unique_click_count >= 0
            AND application_count >= 0
            AND approved_application_count >= 0
            AND conversion_count >= 0
            AND unique_click_count <= click_count
            AND approved_application_count <= application_count
        ),

    CONSTRAINT chk_referral_links_validity
        CHECK (
            expires_at IS NULL
            OR expires_at >= starts_at
        ),

    CONSTRAINT chk_referral_links_tracking_parameters
        CHECK (
            jsonb_typeof(tracking_parameters) = 'object'
        ),

    CONSTRAINT chk_referral_links_routing_configuration
        CHECK (
            jsonb_typeof(routing_configuration) = 'object'
        ),

    CONSTRAINT chk_referral_links_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.referral_attributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    application_id UUID
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    partnership_id UUID NOT NULL
        REFERENCES public.bank_partnerships(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    partner_product_id UUID
        REFERENCES public.bank_partner_products(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    referral_link_id UUID
        REFERENCES public.referral_links(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    attribution_reference TEXT NOT NULL,

    attribution_status TEXT NOT NULL DEFAULT 'PENDING',

    attribution_type TEXT NOT NULL DEFAULT 'APPLICATION',

    attribution_model TEXT NOT NULL DEFAULT 'LAST_CLICK',

    touchpoint_type TEXT NOT NULL DEFAULT 'CLICK',

    session_reference TEXT,

    journey_reference TEXT,

    visitor_reference TEXT,

    device_reference TEXT,

    click_reference TEXT,

    bank_click_reference TEXT,

    partner_click_reference TEXT,

    external_attribution_reference TEXT,

    campaign_reference TEXT,

    placement_reference TEXT,

    creative_reference TEXT,

    source_code TEXT,

    medium_code TEXT,

    campaign_code TEXT,

    content_code TEXT,

    term_code TEXT,

    landing_page_url TEXT,

    referrer_url TEXT,

    ip_address_hash TEXT,

    user_agent_hash TEXT,

    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    attributed_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    converted_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    rejection_reason_code TEXT,

    rejection_reason_text TEXT,

    attribution_weight NUMERIC(9, 6) NOT NULL DEFAULT 1,

    attribution_confidence NUMERIC(5, 2),

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    is_final BOOLEAN NOT NULL DEFAULT FALSE,

    is_bank_confirmed BOOLEAN NOT NULL DEFAULT FALSE,

    bank_confirmed_at TIMESTAMPTZ,

    attribution_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    touchpoint_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    bank_confirmation_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_referral_attributions_reference
        UNIQUE (
            attribution_reference
        ),

    CONSTRAINT chk_referral_attributions_reference
        CHECK (
            attribution_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_referral_attributions_status
        CHECK (
            attribution_status IN (
                'PENDING',
                'ATTRIBUTED',
                'CONFIRMED',
                'CONVERTED',
                'REJECTED',
                'EXPIRED',
                'REVERSED',
                'DISPUTED'
            )
        ),

    CONSTRAINT chk_referral_attributions_type
        CHECK (
            attribution_type IN (
                'CLICK',
                'LEAD',
                'APPLICATION',
                'APPROVAL',
                'ISSUANCE',
                'ACTIVATION',
                'TRANSACTION',
                'REVENUE',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_referral_attributions_model
        CHECK (
            attribution_model IN (
                'FIRST_CLICK',
                'LAST_CLICK',
                'LINEAR',
                'POSITION_BASED',
                'TIME_DECAY',
                'LAST_NON_DIRECT',
                'BANK_REPORTED',
                'MANUAL',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_referral_attributions_touchpoint
        CHECK (
            touchpoint_type IN (
                'IMPRESSION',
                'CLICK',
                'DEEPLINK',
                'QR_SCAN',
                'APPLICATION_START',
                'APPLICATION_SUBMIT',
                'BANK_REDIRECT',
                'API_SUBMISSION',
                'ADVISOR_REFERRAL',
                'MANUAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_referral_attributions_timeline
        CHECK (
            attributed_at IS NULL
            OR attributed_at >= occurred_at
        ),

    CONSTRAINT chk_referral_attributions_expiry
        CHECK (
            expires_at IS NULL
            OR expires_at >= occurred_at
        ),

    CONSTRAINT chk_referral_attributions_conversion
        CHECK (
            converted_at IS NULL
            OR converted_at >= occurred_at
        ),

    CONSTRAINT chk_referral_attributions_rejection
        CHECK (
            rejected_at IS NULL
            OR rejected_at >= occurred_at
        ),

    CONSTRAINT chk_referral_attributions_rejection_code
        CHECK (
            rejection_reason_code IS NULL
            OR rejection_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_referral_attributions_weight
        CHECK (
            attribution_weight BETWEEN 0 AND 1
        ),

    CONSTRAINT chk_referral_attributions_confidence
        CHECK (
            attribution_confidence IS NULL
            OR attribution_confidence BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_referral_attributions_bank_confirmation
        CHECK (
            is_bank_confirmed = FALSE
            OR bank_confirmed_at IS NOT NULL
        ),

    CONSTRAINT chk_referral_attributions_details
        CHECK (
            jsonb_typeof(attribution_details) = 'object'
        ),

    CONSTRAINT chk_referral_attributions_touchpoint_details
        CHECK (
            jsonb_typeof(touchpoint_details) = 'object'
        ),

    CONSTRAINT chk_referral_attributions_bank_payload
        CHECK (
            jsonb_typeof(bank_confirmation_payload) = 'object'
        ),

    CONSTRAINT chk_referral_attributions_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.commission_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    partnership_id UUID NOT NULL
        REFERENCES public.bank_partnerships(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    partner_product_id UUID
        REFERENCES public.bank_partner_products(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    commission_rule_reference TEXT NOT NULL,

    rule_name TEXT NOT NULL,

    rule_status TEXT NOT NULL DEFAULT 'DRAFT',

    commission_model TEXT NOT NULL,

    qualifying_event TEXT NOT NULL,

    commission_amount NUMERIC(18, 6),

    commission_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    commission_percentage NUMERIC(9, 6),

    percentage_basis TEXT,

    minimum_commission_amount NUMERIC(18, 6),

    maximum_commission_amount NUMERIC(18, 6),

    tier_sequence INTEGER NOT NULL DEFAULT 1,

    minimum_qualifying_value NUMERIC(18, 6),

    maximum_qualifying_value NUMERIC(18, 6),

    minimum_monthly_volume INTEGER,

    maximum_monthly_volume INTEGER,

    approval_required BOOLEAN NOT NULL DEFAULT FALSE,

    customer_activation_required BOOLEAN NOT NULL DEFAULT FALSE,

    first_transaction_required BOOLEAN NOT NULL DEFAULT FALSE,

    minimum_first_transaction_amount NUMERIC(18, 6),

    minimum_first_transaction_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    cooling_off_days INTEGER NOT NULL DEFAULT 0,

    validation_window_days INTEGER,

    clawback_window_days INTEGER,

    payment_delay_days INTEGER NOT NULL DEFAULT 0,

    tax_rate_percentage NUMERIC(9, 6),

    withholding_rate_percentage NUMERIC(9, 6),

    valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),

    valid_until TIMESTAMPTZ,

    rule_conditions JSONB NOT NULL DEFAULT '[]'::JSONB,

    tier_configuration JSONB NOT NULL DEFAULT '[]'::JSONB,

    qualification_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    clawback_configuration JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_commission_rules_reference
        UNIQUE (
            commission_rule_reference
        ),

    CONSTRAINT chk_commission_rules_reference
        CHECK (
            commission_rule_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_commission_rules_name
        CHECK (
            length(trim(rule_name)) > 0
        ),

    CONSTRAINT chk_commission_rules_status
        CHECK (
            rule_status IN (
                'DRAFT',
                'UNDER_REVIEW',
                'APPROVED',
                'ACTIVE',
                'SUSPENDED',
                'EXPIRED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_commission_rules_model
        CHECK (
            commission_model IN (
                'FIXED',
                'PERCENTAGE',
                'TIERED_FIXED',
                'TIERED_PERCENTAGE',
                'HYBRID',
                'REVENUE_SHARE',
                'BONUS',
                'NO_COMMISSION',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_commission_rules_qualifying_event
        CHECK (
            qualifying_event IN (
                'CLICK',
                'QUALIFIED_LEAD',
                'APPLICATION_STARTED',
                'APPLICATION_SUBMITTED',
                'APPLICATION_RECEIVED',
                'PREAPPROVED',
                'APPROVED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATED',
                'FIRST_TRANSACTION',
                'SPEND_THRESHOLD_REACHED',
                'ACCOUNT_FUNDED',
                'CUSTOMER_RETAINED',
                'BANK_CONFIRMED',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_commission_rules_amount
        CHECK (
            commission_amount IS NULL
            OR commission_amount >= 0
        ),

    CONSTRAINT chk_commission_rules_amount_currency
        CHECK (
            (
                commission_amount IS NULL
                AND commission_currency_id IS NULL
            )
            OR
            (
                commission_amount IS NOT NULL
                AND commission_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_commission_rules_percentage
        CHECK (
            commission_percentage IS NULL
            OR commission_percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_commission_rules_percentage_basis
        CHECK (
            percentage_basis IS NULL
            OR percentage_basis IN (
                'APPROVED_LIMIT',
                'FIRST_TRANSACTION',
                'CUSTOMER_SPEND',
                'BANK_REVENUE',
                'ANNUAL_FEE',
                'INTERCHANGE',
                'NET_REVENUE',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_commission_rules_minimum_amount
        CHECK (
            minimum_commission_amount IS NULL
            OR minimum_commission_amount >= 0
        ),

    CONSTRAINT chk_commission_rules_maximum_amount
        CHECK (
            maximum_commission_amount IS NULL
            OR maximum_commission_amount >= 0
        ),

    CONSTRAINT chk_commission_rules_amount_range
        CHECK (
            maximum_commission_amount IS NULL
            OR minimum_commission_amount IS NULL
            OR maximum_commission_amount >= minimum_commission_amount
        ),

    CONSTRAINT chk_commission_rules_tier
        CHECK (
            tier_sequence > 0
        ),

    CONSTRAINT chk_commission_rules_qualifying_range
        CHECK (
            (
                minimum_qualifying_value IS NULL
                OR minimum_qualifying_value >= 0
            )
            AND
            (
                maximum_qualifying_value IS NULL
                OR maximum_qualifying_value >= 0
            )
            AND
            (
                minimum_qualifying_value IS NULL
                OR maximum_qualifying_value IS NULL
                OR maximum_qualifying_value >= minimum_qualifying_value
            )
        ),

    CONSTRAINT chk_commission_rules_volume_range
        CHECK (
            (
                minimum_monthly_volume IS NULL
                OR minimum_monthly_volume >= 0
            )
            AND
            (
                maximum_monthly_volume IS NULL
                OR maximum_monthly_volume >= 0
            )
            AND
            (
                minimum_monthly_volume IS NULL
                OR maximum_monthly_volume IS NULL
                OR maximum_monthly_volume >= minimum_monthly_volume
            )
        ),

    CONSTRAINT chk_commission_rules_first_transaction
        CHECK (
            minimum_first_transaction_amount IS NULL
            OR minimum_first_transaction_amount >= 0
        ),

    CONSTRAINT chk_commission_rules_first_transaction_currency
        CHECK (
            (
                minimum_first_transaction_amount IS NULL
                AND minimum_first_transaction_currency_id IS NULL
            )
            OR
            (
                minimum_first_transaction_amount IS NOT NULL
                AND minimum_first_transaction_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_commission_rules_cooling_off
        CHECK (
            cooling_off_days >= 0
        ),

    CONSTRAINT chk_commission_rules_validation_window
        CHECK (
            validation_window_days IS NULL
            OR validation_window_days >= 0
        ),

    CONSTRAINT chk_commission_rules_clawback_window
        CHECK (
            clawback_window_days IS NULL
            OR clawback_window_days >= 0
        ),

    CONSTRAINT chk_commission_rules_payment_delay
        CHECK (
            payment_delay_days >= 0
        ),

    CONSTRAINT chk_commission_rules_tax
        CHECK (
            tax_rate_percentage IS NULL
            OR tax_rate_percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_commission_rules_withholding
        CHECK (
            withholding_rate_percentage IS NULL
            OR withholding_rate_percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_commission_rules_validity
        CHECK (
            valid_until IS NULL
            OR valid_until >= valid_from
        ),

    CONSTRAINT chk_commission_rules_model_values
        CHECK (
            commission_model = 'NO_COMMISSION'
            OR commission_amount IS NOT NULL
            OR commission_percentage IS NOT NULL
            OR jsonb_array_length(tier_configuration) > 0
        ),

    CONSTRAINT chk_commission_rules_conditions
        CHECK (
            jsonb_typeof(rule_conditions) = 'array'
        ),

    CONSTRAINT chk_commission_rules_tiers
        CHECK (
            jsonb_typeof(tier_configuration) = 'array'
        ),

    CONSTRAINT chk_commission_rules_qualification
        CHECK (
            jsonb_typeof(qualification_configuration) = 'object'
        ),

    CONSTRAINT chk_commission_rules_clawback
        CHECK (
            jsonb_typeof(clawback_configuration) = 'object'
        ),

    CONSTRAINT chk_commission_rules_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.commission_accruals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    partnership_id UUID NOT NULL
        REFERENCES public.bank_partnerships(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    partner_product_id UUID
        REFERENCES public.bank_partner_products(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    commission_rule_id UUID NOT NULL
        REFERENCES public.commission_rules(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    attribution_id UUID
        REFERENCES public.referral_attributions(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    application_id UUID
        REFERENCES public.bank_applications(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    card_id UUID
        REFERENCES public.cards(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    commission_reference TEXT NOT NULL,

    bank_commission_reference TEXT,

    qualifying_event_reference TEXT,

    qualifying_event_type TEXT NOT NULL,

    commission_status TEXT NOT NULL DEFAULT 'PENDING',

    qualification_status TEXT NOT NULL DEFAULT 'PENDING',

    commission_amount_gross NUMERIC(18, 6) NOT NULL DEFAULT 0,

    tax_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    withholding_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    adjustment_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    commission_amount_net NUMERIC(18, 6) NOT NULL DEFAULT 0,

    commission_currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    qualifying_value NUMERIC(18, 6),

    qualifying_value_currency_id UUID
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    commission_rate NUMERIC(18, 8),

    commission_rate_type TEXT,

    earned_at TIMESTAMPTZ,

    qualification_due_at TIMESTAMPTZ,

    qualified_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    approved_at TIMESTAMPTZ,

    payable_at TIMESTAMPTZ,

    invoiced_at TIMESTAMPTZ,

    paid_at TIMESTAMPTZ,

    reversed_at TIMESTAMPTZ,

    clawback_due_at TIMESTAMPTZ,

    clawed_back_at TIMESTAMPTZ,

    rejection_reason_code TEXT,

    rejection_reason_text TEXT,

    reversal_reason_code TEXT,

    reversal_reason_text TEXT,

    dispute_status TEXT NOT NULL DEFAULT 'NONE',

    disputed_at TIMESTAMPTZ,

    dispute_resolved_at TIMESTAMPTZ,

    settlement_reference TEXT,

    calculation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    qualification_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    bank_confirmation_payload JSONB NOT NULL DEFAULT '{}'::JSONB,

    adjustment_details JSONB NOT NULL DEFAULT '[]'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_commission_accruals_reference
        UNIQUE (
            commission_reference
        ),

    CONSTRAINT uq_commission_accruals_event_rule
        UNIQUE (
            commission_rule_id,
            qualifying_event_reference
        ),

    CONSTRAINT chk_commission_accruals_reference
        CHECK (
            commission_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_commission_accruals_event_reference
        CHECK (
            length(trim(qualifying_event_reference)) > 0
        ),

    CONSTRAINT chk_commission_accruals_event_type
        CHECK (
            qualifying_event_type IN (
                'CLICK',
                'QUALIFIED_LEAD',
                'APPLICATION_STARTED',
                'APPLICATION_SUBMITTED',
                'APPLICATION_RECEIVED',
                'PREAPPROVED',
                'APPROVED',
                'CARD_ISSUED',
                'CARD_DELIVERED',
                'CARD_ACTIVATED',
                'FIRST_TRANSACTION',
                'SPEND_THRESHOLD_REACHED',
                'ACCOUNT_FUNDED',
                'CUSTOMER_RETAINED',
                'BANK_CONFIRMED',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_commission_accruals_status
        CHECK (
            commission_status IN (
                'PENDING',
                'CALCULATED',
                'QUALIFIED',
                'APPROVED',
                'PAYABLE',
                'INVOICED',
                'PARTIALLY_PAID',
                'PAID',
                'REJECTED',
                'DISPUTED',
                'REVERSED',
                'CLAWBACK_PENDING',
                'CLAWED_BACK',
                'CANCELLED',
                'EXPIRED'
            )
        ),

    CONSTRAINT chk_commission_accruals_qualification_status
        CHECK (
            qualification_status IN (
                'PENDING',
                'UNDER_REVIEW',
                'QUALIFIED',
                'CONDITIONALLY_QUALIFIED',
                'NOT_QUALIFIED',
                'BANK_CONFIRMED',
                'BANK_REJECTED',
                'EXPIRED'
            )
        ),

    CONSTRAINT chk_commission_accruals_amounts
        CHECK (
            commission_amount_gross >= 0
            AND tax_amount >= 0
            AND withholding_amount >= 0
        ),

    CONSTRAINT chk_commission_accruals_net_amount
        CHECK (
            commission_amount_net =
                commission_amount_gross
                - tax_amount
                - withholding_amount
                + adjustment_amount
        ),

    CONSTRAINT chk_commission_accruals_qualifying_value
        CHECK (
            qualifying_value IS NULL
            OR qualifying_value >= 0
        ),

    CONSTRAINT chk_commission_accruals_qualifying_currency
        CHECK (
            (
                qualifying_value IS NULL
                AND qualifying_value_currency_id IS NULL
            )
            OR
            (
                qualifying_value IS NOT NULL
                AND qualifying_value_currency_id IS NOT NULL
            )
        ),

    CONSTRAINT chk_commission_accruals_rate
        CHECK (
            commission_rate IS NULL
            OR commission_rate >= 0
        ),

    CONSTRAINT chk_commission_accruals_rate_type
        CHECK (
            commission_rate_type IS NULL
            OR commission_rate_type IN (
                'FIXED',
                'PERCENTAGE',
                'TIERED_FIXED',
                'TIERED_PERCENTAGE',
                'HYBRID',
                'REVENUE_SHARE',
                'BONUS',
                'CUSTOM'
            )
        ),

    CONSTRAINT chk_commission_accruals_qualification_timeline
        CHECK (
            qualified_at IS NULL
            OR earned_at IS NULL
            OR qualified_at >= earned_at
        ),

    CONSTRAINT chk_commission_accruals_approval_timeline
        CHECK (
            approved_at IS NULL
            OR qualified_at IS NULL
            OR approved_at >= qualified_at
        ),

    CONSTRAINT chk_commission_accruals_payable_timeline
        CHECK (
            payable_at IS NULL
            OR earned_at IS NULL
            OR payable_at >= earned_at
        ),

    CONSTRAINT chk_commission_accruals_paid_timeline
        CHECK (
            paid_at IS NULL
            OR payable_at IS NULL
            OR paid_at >= payable_at
        ),

    CONSTRAINT chk_commission_accruals_clawback_timeline
        CHECK (
            clawed_back_at IS NULL
            OR paid_at IS NULL
            OR clawed_back_at >= paid_at
        ),

    CONSTRAINT chk_commission_accruals_rejection_code
        CHECK (
            rejection_reason_code IS NULL
            OR rejection_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_commission_accruals_reversal_code
        CHECK (
            reversal_reason_code IS NULL
            OR reversal_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_commission_accruals_dispute_status
        CHECK (
            dispute_status IN (
                'NONE',
                'OPEN',
                'UNDER_REVIEW',
                'ACCEPTED',
                'PARTIALLY_ACCEPTED',
                'REJECTED',
                'RESOLVED',
                'WITHDRAWN'
            )
        ),

    CONSTRAINT chk_commission_accruals_dispute_timeline
        CHECK (
            dispute_resolved_at IS NULL
            OR disputed_at IS NULL
            OR dispute_resolved_at >= disputed_at
        ),

    CONSTRAINT chk_commission_accruals_calculation
        CHECK (
            jsonb_typeof(calculation_details) = 'object'
        ),

    CONSTRAINT chk_commission_accruals_qualification
        CHECK (
            jsonb_typeof(qualification_details) = 'object'
        ),

    CONSTRAINT chk_commission_accruals_bank_payload
        CHECK (
            jsonb_typeof(bank_confirmation_payload) = 'object'
        ),

    CONSTRAINT chk_commission_accruals_adjustments
        CHECK (
            jsonb_typeof(adjustment_details) = 'array'
        ),

    CONSTRAINT chk_commission_accruals_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.commission_settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    partnership_id UUID NOT NULL
        REFERENCES public.bank_partnerships(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    bank_id UUID NOT NULL
        REFERENCES public.banks(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    settlement_reference TEXT NOT NULL,

    bank_settlement_reference TEXT,

    invoice_reference TEXT,

    credit_note_reference TEXT,

    settlement_status TEXT NOT NULL DEFAULT 'DRAFT',

    settlement_type TEXT NOT NULL DEFAULT 'REGULAR',

    settlement_period_start DATE NOT NULL,

    settlement_period_end DATE NOT NULL,

    settlement_currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    accrual_count INTEGER NOT NULL DEFAULT 0,

    qualified_accrual_count INTEGER NOT NULL DEFAULT 0,

    rejected_accrual_count INTEGER NOT NULL DEFAULT 0,

    disputed_accrual_count INTEGER NOT NULL DEFAULT 0,

    gross_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    tax_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    withholding_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    adjustment_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    clawback_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    net_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    amount_paid NUMERIC(18, 6) NOT NULL DEFAULT 0,

    amount_outstanding NUMERIC(18, 6) NOT NULL DEFAULT 0,

    prepared_at TIMESTAMPTZ,

    submitted_to_bank_at TIMESTAMPTZ,

    acknowledged_by_bank_at TIMESTAMPTZ,

    approved_by_bank_at TIMESTAMPTZ,

    disputed_at TIMESTAMPTZ,

    dispute_resolved_at TIMESTAMPTZ,

    invoiced_at TIMESTAMPTZ,

    payment_due_at TIMESTAMPTZ,

    partially_paid_at TIMESTAMPTZ,

    paid_at TIMESTAMPTZ,

    closed_at TIMESTAMPTZ,

    prepared_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    approved_by UUID
        REFERENCES auth.users(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    payment_method TEXT,

    bank_payment_reference TEXT,

    reconciliation_status TEXT NOT NULL DEFAULT 'NOT_STARTED',

    reconciliation_completed_at TIMESTAMPTZ,

    reconciliation_difference_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    notes TEXT,

    settlement_summary JSONB NOT NULL DEFAULT '{}'::JSONB,

    bank_statement_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    reconciliation_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_commission_settlements_reference
        UNIQUE (
            settlement_reference
        ),

    CONSTRAINT uq_commission_settlements_bank_reference
        UNIQUE (
            bank_id,
            bank_settlement_reference
        ),

    CONSTRAINT chk_commission_settlements_reference
        CHECK (
            settlement_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_commission_settlements_status
        CHECK (
            settlement_status IN (
                'DRAFT',
                'PREPARED',
                'UNDER_REVIEW',
                'SUBMITTED',
                'ACKNOWLEDGED',
                'APPROVED',
                'DISPUTED',
                'PARTIALLY_APPROVED',
                'INVOICED',
                'PARTIALLY_PAID',
                'PAID',
                'REJECTED',
                'CANCELLED',
                'CLOSED'
            )
        ),

    CONSTRAINT chk_commission_settlements_type
        CHECK (
            settlement_type IN (
                'REGULAR',
                'ADJUSTMENT',
                'CLAWBACK',
                'BONUS',
                'TRUE_UP',
                'FINAL',
                'MANUAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_commission_settlements_period
        CHECK (
            settlement_period_end >= settlement_period_start
        ),

    CONSTRAINT chk_commission_settlements_counts
        CHECK (
            accrual_count >= 0
            AND qualified_accrual_count >= 0
            AND rejected_accrual_count >= 0
            AND disputed_accrual_count >= 0
            AND qualified_accrual_count <= accrual_count
            AND rejected_accrual_count <= accrual_count
            AND disputed_accrual_count <= accrual_count
        ),

    CONSTRAINT chk_commission_settlements_amounts
        CHECK (
            gross_amount >= 0
            AND tax_amount >= 0
            AND withholding_amount >= 0
            AND clawback_amount >= 0
            AND amount_paid >= 0
        ),

    CONSTRAINT chk_commission_settlements_net_amount
        CHECK (
            net_amount =
                gross_amount
                - tax_amount
                - withholding_amount
                + adjustment_amount
                - clawback_amount
        ),

    CONSTRAINT chk_commission_settlements_outstanding
        CHECK (
            amount_outstanding = net_amount - amount_paid
        ),

    CONSTRAINT chk_commission_settlements_paid_limit
        CHECK (
            amount_paid <= net_amount
        ),

    CONSTRAINT chk_commission_settlements_submission_timeline
        CHECK (
            submitted_to_bank_at IS NULL
            OR prepared_at IS NULL
            OR submitted_to_bank_at >= prepared_at
        ),

    CONSTRAINT chk_commission_settlements_acknowledgement_timeline
        CHECK (
            acknowledged_by_bank_at IS NULL
            OR submitted_to_bank_at IS NULL
            OR acknowledged_by_bank_at >= submitted_to_bank_at
        ),

    CONSTRAINT chk_commission_settlements_approval_timeline
        CHECK (
            approved_by_bank_at IS NULL
            OR submitted_to_bank_at IS NULL
            OR approved_by_bank_at >= submitted_to_bank_at
        ),

    CONSTRAINT chk_commission_settlements_dispute_timeline
        CHECK (
            dispute_resolved_at IS NULL
            OR disputed_at IS NULL
            OR dispute_resolved_at >= disputed_at
        ),

    CONSTRAINT chk_commission_settlements_payment_timeline
        CHECK (
            paid_at IS NULL
            OR invoiced_at IS NULL
            OR paid_at >= invoiced_at
        ),

    CONSTRAINT chk_commission_settlements_closed_timeline
        CHECK (
            closed_at IS NULL
            OR created_at IS NULL
            OR closed_at >= created_at
        ),

    CONSTRAINT chk_commission_settlements_payment_method
        CHECK (
            payment_method IS NULL
            OR payment_method IN (
                'BANK_TRANSFER',
                'DIRECT_DEBIT',
                'CHEQUE',
                'OFFSET',
                'WALLET',
                'CREDIT_NOTE',
                'MANUAL',
                'OTHER'
            )
        ),

    CONSTRAINT chk_commission_settlements_reconciliation_status
        CHECK (
            reconciliation_status IN (
                'NOT_STARTED',
                'IN_PROGRESS',
                'MATCHED',
                'PARTIALLY_MATCHED',
                'UNMATCHED',
                'DISPUTED',
                'RESOLVED',
                'COMPLETED'
            )
        ),

    CONSTRAINT chk_commission_settlements_reconciliation_timeline
        CHECK (
            reconciliation_completed_at IS NULL
            OR reconciliation_status IN (
                'MATCHED',
                'PARTIALLY_MATCHED',
                'UNMATCHED',
                'RESOLVED',
                'COMPLETED'
            )
        ),

    CONSTRAINT chk_commission_settlements_summary
        CHECK (
            jsonb_typeof(settlement_summary) = 'object'
        ),

    CONSTRAINT chk_commission_settlements_bank_statement
        CHECK (
            jsonb_typeof(bank_statement_details) = 'object'
        ),

    CONSTRAINT chk_commission_settlements_reconciliation
        CHECK (
            jsonb_typeof(reconciliation_details) = 'object'
        ),

    CONSTRAINT chk_commission_settlements_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE TABLE public.commission_settlement_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    settlement_id UUID NOT NULL
        REFERENCES public.commission_settlements(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    commission_accrual_id UUID NOT NULL
        REFERENCES public.commission_accruals(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    settlement_item_reference TEXT NOT NULL,

    item_status TEXT NOT NULL DEFAULT 'INCLUDED',

    gross_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    tax_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    withholding_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    adjustment_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    clawback_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    net_amount NUMERIC(18, 6) NOT NULL DEFAULT 0,

    currency_id UUID NOT NULL
        REFERENCES public.currencies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    bank_confirmed_amount NUMERIC(18, 6),

    difference_amount NUMERIC(18, 6),

    difference_reason_code TEXT,

    difference_reason_text TEXT,

    included_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    confirmed_at TIMESTAMPTZ,

    rejected_at TIMESTAMPTZ,

    disputed_at TIMESTAMPTZ,

    resolved_at TIMESTAMPTZ,

    item_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    bank_response_details JSONB NOT NULL DEFAULT '{}'::JSONB,

    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_commission_settlement_items_reference
        UNIQUE (
            settlement_item_reference
        ),

    CONSTRAINT uq_commission_settlement_items_accrual
        UNIQUE (
            settlement_id,
            commission_accrual_id
        ),

    CONSTRAINT chk_commission_settlement_items_reference
        CHECK (
            settlement_item_reference
                ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
        ),

    CONSTRAINT chk_commission_settlement_items_status
        CHECK (
            item_status IN (
                'INCLUDED',
                'CONFIRMED',
                'PARTIALLY_CONFIRMED',
                'REJECTED',
                'DISPUTED',
                'ADJUSTED',
                'REMOVED',
                'PAID',
                'CLAWED_BACK'
            )
        ),

    CONSTRAINT chk_commission_settlement_items_amounts
        CHECK (
            gross_amount >= 0
            AND tax_amount >= 0
            AND withholding_amount >= 0
            AND clawback_amount >= 0
        ),

    CONSTRAINT chk_commission_settlement_items_net
        CHECK (
            net_amount =
                gross_amount
                - tax_amount
                - withholding_amount
                + adjustment_amount
                - clawback_amount
        ),

    CONSTRAINT chk_commission_settlement_items_bank_amount
        CHECK (
            bank_confirmed_amount IS NULL
            OR bank_confirmed_amount >= 0
        ),

    CONSTRAINT chk_commission_settlement_items_difference_code
        CHECK (
            difference_reason_code IS NULL
            OR difference_reason_code
                ~ '^[A-Z0-9]+(?:_[A-Z0-9]+)*$'
        ),

    CONSTRAINT chk_commission_settlement_items_confirmation
        CHECK (
            confirmed_at IS NULL
            OR confirmed_at >= included_at
        ),

    CONSTRAINT chk_commission_settlement_items_rejection
        CHECK (
            rejected_at IS NULL
            OR rejected_at >= included_at
        ),

    CONSTRAINT chk_commission_settlement_items_resolution
        CHECK (
            resolved_at IS NULL
            OR disputed_at IS NULL
            OR resolved_at >= disputed_at
        ),

    CONSTRAINT chk_commission_settlement_items_details
        CHECK (
            jsonb_typeof(item_details) = 'object'
        ),

    CONSTRAINT chk_commission_settlement_items_bank_response
        CHECK (
            jsonb_typeof(bank_response_details) = 'object'
        ),

    CONSTRAINT chk_commission_settlement_items_metadata
        CHECK (
            jsonb_typeof(metadata) = 'object'
        )
);

CREATE UNIQUE INDEX uq_bank_partnerships_active_bank_type
ON public.bank_partnerships(
    bank_id,
    partnership_type
)
WHERE partnership_status = 'ACTIVE';

CREATE INDEX idx_bank_partnerships_bank
ON public.bank_partnerships(
    bank_id,
    partnership_status,
    updated_at DESC
);

CREATE INDEX idx_bank_partnerships_active
ON public.bank_partnerships(
    partnership_type,
    commercial_model,
    agreement_effective_until
)
WHERE partnership_status = 'ACTIVE';

CREATE INDEX idx_bank_partnerships_expiring
ON public.bank_partnerships(agreement_effective_until)
WHERE agreement_effective_until IS NOT NULL
  AND partnership_status IN (
      'APPROVED',
      'ACTIVE',
      'SUSPENDED'
  );

CREATE INDEX idx_bank_partnerships_account_manager
ON public.bank_partnerships(
    account_manager_user_id,
    partnership_status
)
WHERE account_manager_user_id IS NOT NULL;

CREATE INDEX idx_bank_partnerships_contract_configuration
ON public.bank_partnerships
USING GIN (contract_configuration);

CREATE INDEX idx_bank_partnerships_integration_configuration
ON public.bank_partnerships
USING GIN (integration_configuration);

CREATE INDEX idx_bank_partnerships_metadata
ON public.bank_partnerships
USING GIN (metadata);

CREATE INDEX idx_bank_partner_products_partnership
ON public.bank_partner_products(
    partnership_id,
    product_status,
    distribution_status
);

CREATE INDEX idx_bank_partner_products_bank
ON public.bank_partner_products(
    bank_id,
    product_status,
    product_rank
);

CREATE INDEX idx_bank_partner_products_card
ON public.bank_partner_products(
    card_id,
    distribution_status
)
WHERE card_id IS NOT NULL;

CREATE INDEX idx_bank_partner_products_active
ON public.bank_partner_products(
    is_featured DESC,
    product_rank,
    available_until
)
WHERE product_status = 'ACTIVE'
  AND distribution_status = 'ENABLED';

CREATE INDEX idx_bank_partner_products_available
ON public.bank_partner_products(
    available_from,
    available_until
)
WHERE distribution_status IN (
    'ENABLED',
    'LIMITED'
);

CREATE INDEX idx_bank_partner_products_eligibility
ON public.bank_partner_products
USING GIN (eligibility_configuration);

CREATE INDEX idx_bank_partner_products_metadata
ON public.bank_partner_products
USING GIN (metadata);

CREATE INDEX idx_referral_links_partnership
ON public.referral_links(
    partnership_id,
    link_status,
    created_at DESC
);

CREATE INDEX idx_referral_links_product
ON public.referral_links(
    partner_product_id,
    link_status
)
WHERE partner_product_id IS NOT NULL;

CREATE INDEX idx_referral_links_bank
ON public.referral_links(
    bank_id,
    link_status,
    created_at DESC
);

CREATE INDEX idx_referral_links_card
ON public.referral_links(
    card_id,
    link_status
)
WHERE card_id IS NOT NULL;

CREATE INDEX idx_referral_links_active
ON public.referral_links(
    channel,
    starts_at,
    expires_at
)
WHERE link_status = 'ACTIVE';

CREATE INDEX idx_referral_links_campaign
ON public.referral_links(
    campaign_reference,
    placement_reference,
    creative_reference
)
WHERE campaign_reference IS NOT NULL;

CREATE INDEX idx_referral_links_tracking
ON public.referral_links
USING GIN (tracking_parameters);

CREATE INDEX idx_referral_links_metadata
ON public.referral_links
USING GIN (metadata);

CREATE UNIQUE INDEX uq_referral_attributions_primary_application
ON public.referral_attributions(application_id)
WHERE application_id IS NOT NULL
  AND is_primary = TRUE;

CREATE INDEX idx_referral_attributions_user
ON public.referral_attributions(
    user_id,
    occurred_at DESC
)
WHERE user_id IS NOT NULL;

CREATE INDEX idx_referral_attributions_application
ON public.referral_attributions(
    application_id,
    occurred_at DESC
)
WHERE application_id IS NOT NULL;

CREATE INDEX idx_referral_attributions_partnership
ON public.referral_attributions(
    partnership_id,
    attribution_status,
    occurred_at DESC
);

CREATE INDEX idx_referral_attributions_link
ON public.referral_attributions(
    referral_link_id,
    occurred_at DESC
)
WHERE referral_link_id IS NOT NULL;

CREATE INDEX idx_referral_attributions_click
ON public.referral_attributions(click_reference)
WHERE click_reference IS NOT NULL;

CREATE INDEX idx_referral_attributions_external
ON public.referral_attributions(external_attribution_reference)
WHERE external_attribution_reference IS NOT NULL;

CREATE INDEX idx_referral_attributions_pending
ON public.referral_attributions(
    expires_at,
    attribution_confidence DESC
)
WHERE attribution_status IN (
    'PENDING',
    'ATTRIBUTED'
);

CREATE INDEX idx_referral_attributions_confirmed
ON public.referral_attributions(
    bank_id,
    bank_confirmed_at DESC
)
WHERE is_bank_confirmed = TRUE;

CREATE INDEX idx_referral_attributions_details
ON public.referral_attributions
USING GIN (attribution_details);

CREATE INDEX idx_referral_attributions_metadata
ON public.referral_attributions
USING GIN (metadata);

CREATE INDEX idx_commission_rules_partnership
ON public.commission_rules(
    partnership_id,
    rule_status,
    qualifying_event
);

CREATE INDEX idx_commission_rules_product
ON public.commission_rules(
    partner_product_id,
    rule_status,
    valid_from,
    valid_until
)
WHERE partner_product_id IS NOT NULL;

CREATE INDEX idx_commission_rules_card
ON public.commission_rules(
    card_id,
    qualifying_event,
    rule_status
)
WHERE card_id IS NOT NULL;

CREATE INDEX idx_commission_rules_active
ON public.commission_rules(
    bank_id,
    qualifying_event,
    tier_sequence,
    valid_until
)
WHERE rule_status = 'ACTIVE';

CREATE INDEX idx_commission_rules_conditions
ON public.commission_rules
USING GIN (rule_conditions);

CREATE INDEX idx_commission_rules_tiers
ON public.commission_rules
USING GIN (tier_configuration);

CREATE INDEX idx_commission_rules_metadata
ON public.commission_rules
USING GIN (metadata);

CREATE INDEX idx_commission_accruals_partnership
ON public.commission_accruals(
    partnership_id,
    commission_status,
    created_at DESC
);

CREATE INDEX idx_commission_accruals_application
ON public.commission_accruals(
    application_id,
    created_at DESC
)
WHERE application_id IS NOT NULL;

CREATE INDEX idx_commission_accruals_attribution
ON public.commission_accruals(
    attribution_id,
    created_at DESC
)
WHERE attribution_id IS NOT NULL;

CREATE INDEX idx_commission_accruals_bank
ON public.commission_accruals(
    bank_id,
    commission_status,
    payable_at
);

CREATE INDEX idx_commission_accruals_pending
ON public.commission_accruals(
    qualification_due_at,
    created_at
)
WHERE qualification_status IN (
    'PENDING',
    'UNDER_REVIEW',
    'CONDITIONALLY_QUALIFIED'
);

CREATE INDEX idx_commission_accruals_payable
ON public.commission_accruals(
    payable_at,
    commission_currency_id
)
WHERE commission_status IN (
    'QUALIFIED',
    'APPROVED',
    'PAYABLE'
);

CREATE INDEX idx_commission_accruals_disputed
ON public.commission_accruals(
    disputed_at,
    bank_id
)
WHERE dispute_status IN (
    'OPEN',
    'UNDER_REVIEW'
);

CREATE INDEX idx_commission_accruals_clawback
ON public.commission_accruals(
    clawback_due_at,
    bank_id
)
WHERE commission_status = 'CLAWBACK_PENDING';

CREATE INDEX idx_commission_accruals_settlement
ON public.commission_accruals(settlement_reference)
WHERE settlement_reference IS NOT NULL;

CREATE INDEX idx_commission_accruals_calculation
ON public.commission_accruals
USING GIN (calculation_details);

CREATE INDEX idx_commission_accruals_metadata
ON public.commission_accruals
USING GIN (metadata);

CREATE INDEX idx_commission_settlements_partnership
ON public.commission_settlements(
    partnership_id,
    settlement_period_end DESC
);

CREATE INDEX idx_commission_settlements_bank
ON public.commission_settlements(
    bank_id,
    settlement_status,
    payment_due_at
);

CREATE INDEX idx_commission_settlements_open
ON public.commission_settlements(
    payment_due_at,
    net_amount DESC
)
WHERE settlement_status IN (
    'PREPARED',
    'UNDER_REVIEW',
    'SUBMITTED',
    'ACKNOWLEDGED',
    'APPROVED',
    'DISPUTED',
    'PARTIALLY_APPROVED',
    'INVOICED',
    'PARTIALLY_PAID'
);

CREATE INDEX idx_commission_settlements_overdue
ON public.commission_settlements(
    payment_due_at,
    bank_id
)
WHERE amount_outstanding > 0
  AND settlement_status NOT IN (
      'PAID',
      'CANCELLED',
      'CLOSED'
  );

CREATE INDEX idx_commission_settlements_reconciliation
ON public.commission_settlements(
    reconciliation_status,
    settlement_period_end DESC
);

CREATE INDEX idx_commission_settlements_summary
ON public.commission_settlements
USING GIN (settlement_summary);

CREATE INDEX idx_commission_settlements_metadata
ON public.commission_settlements
USING GIN (metadata);

CREATE INDEX idx_commission_settlement_items_settlement
ON public.commission_settlement_items(
    settlement_id,
    item_status,
    included_at
);

CREATE INDEX idx_commission_settlement_items_accrual
ON public.commission_settlement_items(commission_accrual_id);

CREATE INDEX idx_commission_settlement_items_disputed
ON public.commission_settlement_items(
    settlement_id,
    disputed_at
)
WHERE item_status = 'DISPUTED';

CREATE INDEX idx_commission_settlement_items_difference
ON public.commission_settlement_items(
    difference_reason_code,
    difference_amount
)
WHERE difference_amount IS NOT NULL
  AND difference_amount <> 0;

CREATE INDEX idx_commission_settlement_items_details
ON public.commission_settlement_items
USING GIN (item_details);

CREATE INDEX idx_commission_settlement_items_metadata
ON public.commission_settlement_items
USING GIN (metadata);

CREATE TRIGGER trg_bank_partnerships_updated_at
BEFORE UPDATE
ON public.bank_partnerships
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_bank_partner_products_updated_at
BEFORE UPDATE
ON public.bank_partner_products
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_referral_links_updated_at
BEFORE UPDATE
ON public.referral_links
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_referral_attributions_updated_at
BEFORE UPDATE
ON public.referral_attributions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_commission_rules_updated_at
BEFORE UPDATE
ON public.commission_rules
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_commission_accruals_updated_at
BEFORE UPDATE
ON public.commission_accruals
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_commission_settlements_updated_at
BEFORE UPDATE
ON public.commission_settlements
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_commission_settlement_items_updated_at
BEFORE UPDATE
ON public.commission_settlement_items
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMENT ON TABLE public.bank_partnerships IS
'Commercial and technical partnership agreements between the platform and banks, including referral, affiliate, API, marketplace, and strategic distribution models.';

COMMENT ON COLUMN public.bank_partnerships.commercial_model IS
'Primary revenue model agreed with the bank, such as cost per acquisition, cost per lead, revenue share, fixed fee, or hybrid.';

COMMENT ON COLUMN public.bank_partnerships.attribution_configuration IS
'Partnership-level rules governing attribution windows, deduplication, source priority, and conversion confirmation.';

COMMENT ON TABLE public.bank_partner_products IS
'Bank products enabled for referral, application submission, lead transfer, embedded distribution, or API-based acquisition under a partnership.';

COMMENT ON COLUMN public.bank_partner_products.distribution_status IS
'Operational availability of the partner product on the platform, independent from the bank product lifecycle status.';

COMMENT ON TABLE public.referral_links IS
'Trackable referral, affiliate, campaign, recommendation, and product links used to route customers to bank products.';

COMMENT ON COLUMN public.referral_links.referral_code IS
'Unique code carried through customer journeys and bank redirects to support attribution.';

COMMENT ON TABLE public.referral_attributions IS
'Customer and application attribution records connecting marketing touchpoints, referral links, bank products, applications, and confirmed conversions.';

COMMENT ON COLUMN public.referral_attributions.attribution_weight IS
'Fraction of conversion credit allocated to the touchpoint under the selected attribution model.';

COMMENT ON TABLE public.commission_rules IS
'Versioned commercial rules defining when commissions qualify, how they are calculated, and when they become payable or subject to clawback.';

COMMENT ON COLUMN public.commission_rules.qualifying_event IS
'Business event that may generate commission, such as submitted application, approval, issuance, activation, or first transaction.';

COMMENT ON TABLE public.commission_accruals IS
'Calculated commission earnings generated from qualifying application and conversion events, including qualification, approval, payment, dispute, reversal, and clawback states.';

COMMENT ON COLUMN public.commission_accruals.qualifying_event_reference IS
'Stable event identifier used with the commission rule to prevent duplicate commission accruals.';

COMMENT ON COLUMN public.commission_accruals.commission_amount_net IS
'Net commission after tax, withholding, and signed adjustments.';

COMMENT ON TABLE public.commission_settlements IS
'Periodic bank settlement and invoice records aggregating qualified commission accruals for reconciliation and payment.';

COMMENT ON COLUMN public.commission_settlements.amount_outstanding IS
'Remaining amount due from the bank after recorded payments.';

COMMENT ON TABLE public.commission_settlement_items IS
'Line-level association between commission accruals and bank settlement records, including confirmation, differences, disputes, adjustments, and clawbacks.';

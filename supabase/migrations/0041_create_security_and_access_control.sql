-- Lock down the API-facing schema before granting narrowly scoped access.
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM anon, authenticated;
GRANT USAGE ON SCHEMA public TO anon, authenticated;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC, anon, authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE ALL ON TABLES FROM anon, authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE ALL ON SEQUENCES FROM anon, authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;

-- The trusted Supabase service role requires explicit privileges in addition
-- to its platform-managed BYPASSRLS attribute.
GRANT USAGE ON SCHEMA public TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO service_role;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- RLS is enabled on every API-facing table, including internal tables for
-- which no client policy is intentionally defined.
ALTER TABLE public.alert_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_application_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_application_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_application_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_application_integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_application_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_loyalty_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_partner_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_partnerships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.banks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_comparison_criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_comparison_item_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_comparison_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_comparison_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_comparisons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_dining_benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_eligibility_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_installment_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_insurance_benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_lounge_benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_network_benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_networks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_travel_benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_value_simulation_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.card_value_simulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_accruals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_settlement_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_settlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compliance_case_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compliance_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consent_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_financial_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_preference_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_spending_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_spending_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_access_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_classification_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_export_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_retention_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_retention_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.eligibility_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.eligibility_requirement_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.governance_control_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.governance_controls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_hold_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_holds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_explanations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_factor_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_model_factors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_model_segments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_run_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_attributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_exclusions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_redemption_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_card_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_saved_cards ENABLE ROW LEVEL SECURITY;

-- Public catalog access is read-only and limited to published, active data.
GRANT SELECT ON TABLE
    public.countries,
    public.currencies,
    public.merchant_categories,
    public.reward_categories,
    public.card_networks,
    public.loyalty_programs,
    public.banks,
    public.bank_loyalty_programs,
    public.cards,
    public.card_fees,
    public.card_benefits,
    public.card_offers,
    public.card_insurance_benefits,
    public.card_lounge_benefits,
    public.card_travel_benefits,
    public.card_dining_benefits,
    public.card_installment_plans,
    public.card_network_benefits,
    public.card_comparison_profiles
TO anon, authenticated;

CREATE POLICY catalog_read_active_countries
ON public.countries FOR SELECT TO anon, authenticated
USING (is_active = TRUE);

CREATE POLICY catalog_read_active_currencies
ON public.currencies FOR SELECT TO anon, authenticated
USING (is_active = TRUE);

CREATE POLICY catalog_read_active_merchant_categories
ON public.merchant_categories FOR SELECT TO anon, authenticated
USING (is_active = TRUE);

CREATE POLICY catalog_read_active_reward_categories
ON public.reward_categories FOR SELECT TO anon, authenticated
USING (is_active = TRUE);

CREATE POLICY catalog_read_active_card_networks
ON public.card_networks FOR SELECT TO anon, authenticated
USING (is_active = TRUE);

CREATE POLICY catalog_read_active_loyalty_programs
ON public.loyalty_programs FOR SELECT TO anon, authenticated
USING (is_active = TRUE);

CREATE POLICY catalog_read_active_banks
ON public.banks FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND EXISTS (
        SELECT 1
        FROM public.countries
        WHERE countries.id = banks.country_id
          AND countries.is_active = TRUE
    )
);

CREATE POLICY catalog_read_active_bank_loyalty_programs
ON public.bank_loyalty_programs FOR SELECT TO anon, authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.banks
        WHERE banks.id = bank_loyalty_programs.bank_id
          AND banks.is_active = TRUE
    )
    AND EXISTS (
        SELECT 1 FROM public.loyalty_programs
        WHERE loyalty_programs.id = bank_loyalty_programs.loyalty_program_id
          AND loyalty_programs.is_active = TRUE
    )
);

CREATE POLICY catalog_read_published_cards
ON public.cards FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND availability_status = 'AVAILABLE'
    AND published_at IS NOT NULL
    AND published_at <= now()
    AND EXISTS (
        SELECT 1 FROM public.banks
        WHERE banks.id = cards.bank_id
          AND banks.is_active = TRUE
    )
    AND EXISTS (
        SELECT 1 FROM public.currencies
        WHERE currencies.id = cards.currency_id
          AND currencies.is_active = TRUE
    )
    AND EXISTS (
        SELECT 1 FROM public.card_networks
        WHERE card_networks.id = cards.card_network_id
          AND card_networks.is_active = TRUE
    )
    AND (
        loyalty_program_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.loyalty_programs
            WHERE loyalty_programs.id = cards.loyalty_program_id
              AND loyalty_programs.is_active = TRUE
        )
    )
);

CREATE POLICY catalog_read_active_card_fees
ON public.card_fees FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND EXISTS (
        SELECT 1 FROM public.cards
        WHERE cards.id = card_fees.card_id
    )
);

CREATE POLICY catalog_read_active_card_benefits
ON public.card_benefits FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= CURRENT_DATE)
    AND (valid_to IS NULL OR valid_to >= CURRENT_DATE)
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_benefits.card_id)
);

CREATE POLICY catalog_read_active_card_offers
ON public.card_offers FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= now())
    AND (valid_to IS NULL OR valid_to >= now())
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_offers.card_id)
);

CREATE POLICY catalog_read_active_card_insurance_benefits
ON public.card_insurance_benefits FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= CURRENT_DATE)
    AND (valid_to IS NULL OR valid_to >= CURRENT_DATE)
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_insurance_benefits.card_id)
);

CREATE POLICY catalog_read_active_card_lounge_benefits
ON public.card_lounge_benefits FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= CURRENT_DATE)
    AND (valid_to IS NULL OR valid_to >= CURRENT_DATE)
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_lounge_benefits.card_id)
);

CREATE POLICY catalog_read_active_card_travel_benefits
ON public.card_travel_benefits FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= CURRENT_DATE)
    AND (valid_to IS NULL OR valid_to >= CURRENT_DATE)
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_travel_benefits.card_id)
);

CREATE POLICY catalog_read_active_card_dining_benefits
ON public.card_dining_benefits FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= now())
    AND (valid_to IS NULL OR valid_to >= now())
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_dining_benefits.card_id)
);

CREATE POLICY catalog_read_active_card_installment_plans
ON public.card_installment_plans FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= now())
    AND (valid_to IS NULL OR valid_to >= now())
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_installment_plans.card_id)
);

CREATE POLICY catalog_read_active_card_network_benefits
ON public.card_network_benefits FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= CURRENT_DATE)
    AND (valid_to IS NULL OR valid_to >= CURRENT_DATE)
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_network_benefits.card_id)
);

CREATE POLICY catalog_read_active_card_comparison_profiles
ON public.card_comparison_profiles FOR SELECT TO anon, authenticated
USING (
    is_active = TRUE
    AND (valid_from IS NULL OR valid_from <= CURRENT_DATE)
    AND (valid_to IS NULL OR valid_to >= CURRENT_DATE)
    AND EXISTS (SELECT 1 FROM public.cards WHERE cards.id = card_comparison_profiles.card_id)
);

-- Authenticated customers may read, create, and update only records rooted in
-- their auth user. Hard deletion remains service-only so customer actions
-- cannot cascade into recommendation, audit, or historical records.
GRANT SELECT, INSERT, UPDATE ON TABLE
    public.customer_financial_profiles,
    public.customer_spending_profiles,
    public.customer_spending_categories,
    public.customer_preference_profiles,
    public.customer_preferences,
    public.user_card_collections,
    public.user_saved_cards,
    public.user_notification_preferences,
    public.notification_subscriptions
TO authenticated;

CREATE POLICY customer_read_financial_profiles
ON public.customer_financial_profiles FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_create_financial_profiles
ON public.customer_financial_profiles FOR INSERT TO authenticated
WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY customer_update_financial_profiles
ON public.customer_financial_profiles FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()))
WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_spending_profiles
ON public.customer_spending_profiles FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = customer_spending_profiles.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_create_spending_profiles
ON public.customer_spending_profiles FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = customer_spending_profiles.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_update_spending_profiles
ON public.customer_spending_profiles FOR UPDATE TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = customer_spending_profiles.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = customer_spending_profiles.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_spending_categories
ON public.customer_spending_categories FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.customer_spending_profiles
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = customer_spending_profiles.financial_profile_id
        WHERE customer_spending_profiles.id = customer_spending_categories.spending_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_create_spending_categories
ON public.customer_spending_categories FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.customer_spending_profiles
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = customer_spending_profiles.financial_profile_id
        WHERE customer_spending_profiles.id = customer_spending_categories.spending_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_update_spending_categories
ON public.customer_spending_categories FOR UPDATE TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.customer_spending_profiles
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = customer_spending_profiles.financial_profile_id
        WHERE customer_spending_profiles.id = customer_spending_categories.spending_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.customer_spending_profiles
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = customer_spending_profiles.financial_profile_id
        WHERE customer_spending_profiles.id = customer_spending_categories.spending_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_preference_profiles
ON public.customer_preference_profiles FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = customer_preference_profiles.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_create_preference_profiles
ON public.customer_preference_profiles FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = customer_preference_profiles.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_update_preference_profiles
ON public.customer_preference_profiles FOR UPDATE TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = customer_preference_profiles.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = customer_preference_profiles.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_preferences
ON public.customer_preferences FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.customer_preference_profiles
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = customer_preference_profiles.financial_profile_id
        WHERE customer_preference_profiles.id = customer_preferences.preference_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_create_preferences
ON public.customer_preferences FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.customer_preference_profiles
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = customer_preference_profiles.financial_profile_id
        WHERE customer_preference_profiles.id = customer_preferences.preference_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_update_preferences
ON public.customer_preferences FOR UPDATE TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.customer_preference_profiles
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = customer_preference_profiles.financial_profile_id
        WHERE customer_preference_profiles.id = customer_preferences.preference_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.customer_preference_profiles
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = customer_preference_profiles.financial_profile_id
        WHERE customer_preference_profiles.id = customer_preferences.preference_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_card_collections
ON public.user_card_collections FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_create_card_collections
ON public.user_card_collections FOR INSERT TO authenticated
WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY customer_update_card_collections
ON public.user_card_collections FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()))
WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_saved_cards
ON public.user_saved_cards FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_create_saved_cards
ON public.user_saved_cards FOR INSERT TO authenticated
WITH CHECK (
    user_id = (SELECT auth.uid())
    AND EXISTS (
        SELECT 1 FROM public.user_card_collections
        WHERE user_card_collections.id = user_saved_cards.collection_id
          AND user_card_collections.user_id = (SELECT auth.uid())
    )
    AND (
        recommendation_run_id IS NULL
        OR EXISTS (
            SELECT 1
            FROM public.recommendation_runs
            JOIN public.customer_financial_profiles
              ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
            WHERE recommendation_runs.id = user_saved_cards.recommendation_run_id
              AND customer_financial_profiles.user_id = (SELECT auth.uid())
        )
    )
    AND (
        recommendation_result_id IS NULL
        OR EXISTS (
            SELECT 1
            FROM public.recommendation_results
            JOIN public.recommendation_runs
              ON recommendation_runs.id = recommendation_results.recommendation_run_id
            JOIN public.customer_financial_profiles
              ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
            WHERE recommendation_results.id = user_saved_cards.recommendation_result_id
              AND customer_financial_profiles.user_id = (SELECT auth.uid())
        )
    )
    AND (
        recommendation_run_card_id IS NULL
        OR EXISTS (
            SELECT 1
            FROM public.recommendation_run_cards
            JOIN public.recommendation_runs
              ON recommendation_runs.id = recommendation_run_cards.recommendation_run_id
            JOIN public.customer_financial_profiles
              ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
            WHERE recommendation_run_cards.id = user_saved_cards.recommendation_run_card_id
              AND customer_financial_profiles.user_id = (SELECT auth.uid())
        )
    )
    AND (
        source_interaction_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.recommendation_interactions
            WHERE recommendation_interactions.id = user_saved_cards.source_interaction_id
              AND recommendation_interactions.user_id = (SELECT auth.uid())
        )
    )
);

CREATE POLICY customer_update_saved_cards
ON public.user_saved_cards FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()))
WITH CHECK (
    user_id = (SELECT auth.uid())
    AND EXISTS (
        SELECT 1 FROM public.user_card_collections
        WHERE user_card_collections.id = user_saved_cards.collection_id
          AND user_card_collections.user_id = (SELECT auth.uid())
    )
    AND (
        recommendation_run_id IS NULL
        OR EXISTS (
            SELECT 1
            FROM public.recommendation_runs
            JOIN public.customer_financial_profiles
              ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
            WHERE recommendation_runs.id = user_saved_cards.recommendation_run_id
              AND customer_financial_profiles.user_id = (SELECT auth.uid())
        )
    )
    AND (
        recommendation_result_id IS NULL
        OR EXISTS (
            SELECT 1
            FROM public.recommendation_results
            JOIN public.recommendation_runs
              ON recommendation_runs.id = recommendation_results.recommendation_run_id
            JOIN public.customer_financial_profiles
              ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
            WHERE recommendation_results.id = user_saved_cards.recommendation_result_id
              AND customer_financial_profiles.user_id = (SELECT auth.uid())
        )
    )
    AND (
        recommendation_run_card_id IS NULL
        OR EXISTS (
            SELECT 1
            FROM public.recommendation_run_cards
            JOIN public.recommendation_runs
              ON recommendation_runs.id = recommendation_run_cards.recommendation_run_id
            JOIN public.customer_financial_profiles
              ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
            WHERE recommendation_run_cards.id = user_saved_cards.recommendation_run_card_id
              AND customer_financial_profiles.user_id = (SELECT auth.uid())
        )
    )
    AND (
        source_interaction_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.recommendation_interactions
            WHERE recommendation_interactions.id = user_saved_cards.source_interaction_id
              AND recommendation_interactions.user_id = (SELECT auth.uid())
        )
    )
);

CREATE POLICY customer_read_card_comparisons
ON public.card_comparisons FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_card_comparison_items
ON public.card_comparison_items FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.card_comparisons
        WHERE card_comparisons.id = card_comparison_items.comparison_id
          AND card_comparisons.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_card_comparison_criteria
ON public.card_comparison_criteria FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.card_comparisons
        WHERE card_comparisons.id = card_comparison_criteria.comparison_id
          AND card_comparisons.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_card_comparison_item_scores
ON public.card_comparison_item_scores FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.card_comparison_items
        JOIN public.card_comparisons
          ON card_comparisons.id = card_comparison_items.comparison_id
        WHERE card_comparison_items.id = card_comparison_item_scores.comparison_item_id
          AND card_comparisons.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_notification_preferences
ON public.user_notification_preferences FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_create_notification_preferences
ON public.user_notification_preferences FOR INSERT TO authenticated
WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY customer_update_notification_preferences
ON public.user_notification_preferences FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()))
WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_notification_subscriptions
ON public.notification_subscriptions FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_create_notification_subscriptions
ON public.notification_subscriptions FOR INSERT TO authenticated
WITH CHECK (
    user_id = (SELECT auth.uid())
    AND (
        saved_card_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.user_saved_cards
            WHERE user_saved_cards.id = notification_subscriptions.saved_card_id
              AND user_saved_cards.user_id = (SELECT auth.uid())
        )
    )
    AND (
        collection_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.user_card_collections
            WHERE user_card_collections.id = notification_subscriptions.collection_id
              AND user_card_collections.user_id = (SELECT auth.uid())
        )
    )
    AND (
        comparison_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.card_comparisons
            WHERE card_comparisons.id = notification_subscriptions.comparison_id
              AND card_comparisons.user_id = (SELECT auth.uid())
        )
    )
);

CREATE POLICY customer_update_notification_subscriptions
ON public.notification_subscriptions FOR UPDATE TO authenticated
USING (user_id = (SELECT auth.uid()))
WITH CHECK (
    user_id = (SELECT auth.uid())
    AND (
        saved_card_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.user_saved_cards
            WHERE user_saved_cards.id = notification_subscriptions.saved_card_id
              AND user_saved_cards.user_id = (SELECT auth.uid())
        )
    )
    AND (
        collection_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.user_card_collections
            WHERE user_card_collections.id = notification_subscriptions.collection_id
              AND user_card_collections.user_id = (SELECT auth.uid())
        )
    )
    AND (
        comparison_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.card_comparisons
            WHERE card_comparisons.id = notification_subscriptions.comparison_id
              AND card_comparisons.user_id = (SELECT auth.uid())
        )
    )
);

-- Engine-generated customer results are readable by their owner but writable
-- only through trusted server-side code using the service role.
GRANT SELECT ON TABLE
    public.eligibility_assessments,
    public.eligibility_requirement_assessments,
    public.card_value_simulations,
    public.card_value_simulation_components,
    public.recommendation_runs,
    public.recommendation_run_cards,
    public.recommendation_results,
    public.recommendation_explanations,
    public.recommendation_factor_scores,
    public.recommendation_interactions,
    public.recommendation_feedback,
    public.recommendation_outcomes,
    public.card_comparisons,
    public.card_comparison_items,
    public.card_comparison_criteria,
    public.card_comparison_item_scores,
    public.notifications,
    public.notification_deliveries,
    public.bank_applications,
    public.bank_application_documents,
    public.bank_application_events,
    public.referral_attributions,
    public.consent_records,
    public.data_export_requests
TO authenticated;

CREATE POLICY customer_read_eligibility_assessments
ON public.eligibility_assessments FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = eligibility_assessments.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_eligibility_requirement_assessments
ON public.eligibility_requirement_assessments FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.eligibility_assessments
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = eligibility_assessments.financial_profile_id
        WHERE eligibility_assessments.id = eligibility_requirement_assessments.eligibility_assessment_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_value_simulations
ON public.card_value_simulations FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = card_value_simulations.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_value_simulation_components
ON public.card_value_simulation_components FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.card_value_simulations
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = card_value_simulations.financial_profile_id
        WHERE card_value_simulations.id = card_value_simulation_components.simulation_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_recommendation_runs
ON public.recommendation_runs FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.customer_financial_profiles
        WHERE customer_financial_profiles.id = recommendation_runs.financial_profile_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_recommendation_run_cards
ON public.recommendation_run_cards FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.recommendation_runs
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
        WHERE recommendation_runs.id = recommendation_run_cards.recommendation_run_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_recommendation_results
ON public.recommendation_results FOR SELECT TO authenticated
USING (
    is_visible = TRUE
    AND EXISTS (
        SELECT 1
        FROM public.recommendation_runs
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
        WHERE recommendation_runs.id = recommendation_results.recommendation_run_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_recommendation_explanations
ON public.recommendation_explanations FOR SELECT TO authenticated
USING (
    is_customer_visible = TRUE
    AND EXISTS (
        SELECT 1
        FROM public.recommendation_runs
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
        WHERE recommendation_runs.id = recommendation_explanations.recommendation_run_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_recommendation_factor_scores
ON public.recommendation_factor_scores FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.recommendation_runs
        JOIN public.customer_financial_profiles
          ON customer_financial_profiles.id = recommendation_runs.financial_profile_id
        WHERE recommendation_runs.id = recommendation_factor_scores.recommendation_run_id
          AND customer_financial_profiles.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_recommendation_outcomes
ON public.recommendation_outcomes FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_notifications
ON public.notifications FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_notification_deliveries
ON public.notification_deliveries FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.notifications
        WHERE notifications.id = notification_deliveries.notification_id
          AND notifications.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_bank_applications
ON public.bank_applications FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_bank_application_documents
ON public.bank_application_documents FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.bank_applications
        WHERE bank_applications.id = bank_application_documents.application_id
          AND bank_applications.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_bank_application_events
ON public.bank_application_events FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.bank_applications
        WHERE bank_applications.id = bank_application_events.application_id
          AND bank_applications.user_id = (SELECT auth.uid())
    )
);

CREATE POLICY customer_read_referral_attributions
ON public.referral_attributions FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_consent_records
ON public.consent_records FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_data_export_requests
ON public.data_export_requests FOR SELECT TO authenticated
USING (
    requested_by_user_id = (SELECT auth.uid())
    AND subject_user_id = (SELECT auth.uid())
);

CREATE POLICY customer_read_recommendation_interactions
ON public.recommendation_interactions FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

CREATE POLICY customer_read_recommendation_feedback
ON public.recommendation_feedback FOR SELECT TO authenticated
USING (user_id = (SELECT auth.uid()));

COMMENT ON SCHEMA public IS
'Application schema protected by explicit grants and row-level security; privileged writes require trusted service-role access.';

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      alert_events: {
        Row: {
          alert_reference: string
          bank_id: string | null
          card_id: string | null
          change_details: Json
          comparison_id: string | null
          correlation_id: string | null
          created_at: string
          current_boolean_value: boolean | null
          current_numeric_value: number | null
          current_text_value: string | null
          deduplication_key: string | null
          description: string | null
          detected_at: string
          effective_at: string | null
          event_category: string
          event_source: string
          event_status: string
          event_type: string
          expires_at: string | null
          generated_notification_count: number
          id: string
          last_processing_error: string | null
          matched_subscription_count: number
          matching_details: Json
          metadata: Json
          numeric_change: number | null
          percentage_change: number | null
          previous_boolean_value: boolean | null
          previous_numeric_value: number | null
          previous_text_value: string | null
          processed_at: string | null
          processing_attempts: number
          processing_errors: Json
          processing_started_at: string | null
          recommendation_run_id: string | null
          saved_card_id: string | null
          severity: string
          source_payload: Json
          source_reference: string | null
          suppressed_notification_count: number
          target_entity_id: string | null
          target_entity_type: string
          title: string | null
          updated_at: string
        }
        Insert: {
          alert_reference: string
          bank_id?: string | null
          card_id?: string | null
          change_details?: Json
          comparison_id?: string | null
          correlation_id?: string | null
          created_at?: string
          current_boolean_value?: boolean | null
          current_numeric_value?: number | null
          current_text_value?: string | null
          deduplication_key?: string | null
          description?: string | null
          detected_at?: string
          effective_at?: string | null
          event_category: string
          event_source?: string
          event_status?: string
          event_type: string
          expires_at?: string | null
          generated_notification_count?: number
          id?: string
          last_processing_error?: string | null
          matched_subscription_count?: number
          matching_details?: Json
          metadata?: Json
          numeric_change?: number | null
          percentage_change?: number | null
          previous_boolean_value?: boolean | null
          previous_numeric_value?: number | null
          previous_text_value?: string | null
          processed_at?: string | null
          processing_attempts?: number
          processing_errors?: Json
          processing_started_at?: string | null
          recommendation_run_id?: string | null
          saved_card_id?: string | null
          severity?: string
          source_payload?: Json
          source_reference?: string | null
          suppressed_notification_count?: number
          target_entity_id?: string | null
          target_entity_type: string
          title?: string | null
          updated_at?: string
        }
        Update: {
          alert_reference?: string
          bank_id?: string | null
          card_id?: string | null
          change_details?: Json
          comparison_id?: string | null
          correlation_id?: string | null
          created_at?: string
          current_boolean_value?: boolean | null
          current_numeric_value?: number | null
          current_text_value?: string | null
          deduplication_key?: string | null
          description?: string | null
          detected_at?: string
          effective_at?: string | null
          event_category?: string
          event_source?: string
          event_status?: string
          event_type?: string
          expires_at?: string | null
          generated_notification_count?: number
          id?: string
          last_processing_error?: string | null
          matched_subscription_count?: number
          matching_details?: Json
          metadata?: Json
          numeric_change?: number | null
          percentage_change?: number | null
          previous_boolean_value?: boolean | null
          previous_numeric_value?: number | null
          previous_text_value?: string | null
          processed_at?: string | null
          processing_attempts?: number
          processing_errors?: Json
          processing_started_at?: string | null
          recommendation_run_id?: string | null
          saved_card_id?: string | null
          severity?: string
          source_payload?: Json
          source_reference?: string | null
          suppressed_notification_count?: number
          target_entity_id?: string | null
          target_entity_type?: string
          title?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "alert_events_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "alert_events_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "alert_events_comparison_id_fkey"
            columns: ["comparison_id"]
            isOneToOne: false
            referencedRelation: "card_comparisons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "alert_events_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "alert_events_saved_card_id_fkey"
            columns: ["saved_card_id"]
            isOneToOne: false
            referencedRelation: "user_saved_cards"
            referencedColumns: ["id"]
          },
        ]
      }
      api_client_rate_limit_assignments: {
        Row: {
          assigned_at: string
          assigned_by_user_id: string | null
          assignment_reason: string
          client_id: string
          created_at: string
          id: string
          policy_id: string
          revocation_reason: string | null
          revoked_at: string | null
          revoked_by_user_id: string | null
          updated_at: string
          valid_from: string
          valid_until: string | null
        }
        Insert: {
          assigned_at?: string
          assigned_by_user_id?: string | null
          assignment_reason: string
          client_id: string
          created_at?: string
          id?: string
          policy_id: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
        }
        Update: {
          assigned_at?: string
          assigned_by_user_id?: string | null
          assignment_reason?: string
          client_id?: string
          created_at?: string
          id?: string
          policy_id?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "api_client_rate_limit_assignments_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "api_clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "api_client_rate_limit_assignments_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "api_rate_limit_policies"
            referencedColumns: ["id"]
          },
        ]
      }
      api_client_scope_assignments: {
        Row: {
          client_id: string
          created_at: string
          grant_reason: string
          granted_at: string
          granted_by_user_id: string | null
          id: string
          revocation_reason: string | null
          revoked_at: string | null
          revoked_by_user_id: string | null
          scope_id: string
          updated_at: string
          valid_from: string
          valid_until: string | null
        }
        Insert: {
          client_id: string
          created_at?: string
          grant_reason: string
          granted_at?: string
          granted_by_user_id?: string | null
          id?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          scope_id: string
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
        }
        Update: {
          client_id?: string
          created_at?: string
          grant_reason?: string
          granted_at?: string
          granted_by_user_id?: string | null
          id?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          scope_id?: string
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "api_client_scope_assignments_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "api_clients"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "api_client_scope_assignments_scope_id_fkey"
            columns: ["scope_id"]
            isOneToOne: false
            referencedRelation: "api_scopes"
            referencedColumns: ["id"]
          },
        ]
      }
      api_clients: {
        Row: {
          activated_at: string | null
          client_code: string
          client_type: string
          created_at: string
          created_by_user_id: string | null
          deactivated_at: string | null
          description: string | null
          display_name: string
          id: string
          lifecycle_status: string
          metadata: Json
          suspended_at: string | null
          suspension_reason: string | null
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          activated_at?: string | null
          client_code: string
          client_type?: string
          created_at?: string
          created_by_user_id?: string | null
          deactivated_at?: string | null
          description?: string | null
          display_name: string
          id?: string
          lifecycle_status?: string
          metadata?: Json
          suspended_at?: string | null
          suspension_reason?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          activated_at?: string | null
          client_code?: string
          client_type?: string
          created_at?: string
          created_by_user_id?: string | null
          deactivated_at?: string | null
          description?: string | null
          display_name?: string
          id?: string
          lifecycle_status?: string
          metadata?: Json
          suspended_at?: string | null
          suspension_reason?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: []
      }
      api_keys: {
        Row: {
          client_id: string
          created_at: string
          created_by_user_id: string | null
          expires_at: string | null
          id: string
          key_name: string
          key_prefix: string
          last_used_at: string | null
          lifecycle_status: string
          revocation_reason: string | null
          revoked_at: string | null
          revoked_by_user_id: string | null
          secret_hash: string
          updated_at: string
          valid_from: string
        }
        Insert: {
          client_id: string
          created_at?: string
          created_by_user_id?: string | null
          expires_at?: string | null
          id?: string
          key_name: string
          key_prefix: string
          last_used_at?: string | null
          lifecycle_status?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          secret_hash: string
          updated_at?: string
          valid_from?: string
        }
        Update: {
          client_id?: string
          created_at?: string
          created_by_user_id?: string | null
          expires_at?: string | null
          id?: string
          key_name?: string
          key_prefix?: string
          last_used_at?: string | null
          lifecycle_status?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          secret_hash?: string
          updated_at?: string
          valid_from?: string
        }
        Relationships: [
          {
            foreignKeyName: "api_keys_client_id_fkey"
            columns: ["client_id"]
            isOneToOne: false
            referencedRelation: "api_clients"
            referencedColumns: ["id"]
          },
        ]
      }
      api_rate_limit_policies: {
        Row: {
          activated_at: string | null
          burst_limit: number | null
          created_at: string
          created_by_user_id: string | null
          description: string | null
          display_name: string
          id: string
          lifecycle_status: string
          policy_code: string
          request_limit: number
          retired_at: string | null
          updated_at: string
          updated_by_user_id: string | null
          window_seconds: number
        }
        Insert: {
          activated_at?: string | null
          burst_limit?: number | null
          created_at?: string
          created_by_user_id?: string | null
          description?: string | null
          display_name: string
          id?: string
          lifecycle_status?: string
          policy_code: string
          request_limit: number
          retired_at?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
          window_seconds: number
        }
        Update: {
          activated_at?: string | null
          burst_limit?: number | null
          created_at?: string
          created_by_user_id?: string | null
          description?: string | null
          display_name?: string
          id?: string
          lifecycle_status?: string
          policy_code?: string
          request_limit?: number
          retired_at?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
          window_seconds?: number
        }
        Relationships: []
      }
      api_scopes: {
        Row: {
          created_at: string
          created_by_user_id: string | null
          description: string
          display_name: string
          id: string
          is_active: boolean
          is_system_managed: boolean
          scope_code: string
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          created_at?: string
          created_by_user_id?: string | null
          description: string
          display_name: string
          id?: string
          is_active?: boolean
          is_system_managed?: boolean
          scope_code: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          created_at?: string
          created_by_user_id?: string | null
          description?: string
          display_name?: string
          id?: string
          is_active?: boolean
          is_system_managed?: boolean
          scope_code?: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: []
      }
      approval_decisions: {
        Row: {
          approval_request_id: string
          approval_step: number
          approver_role_reference: string | null
          approver_user_id: string | null
          assigned_at: string
          conditions: Json
          created_at: string
          decided_at: string | null
          decision_context: Json
          decision_reason_code: string | null
          decision_reason_text: string | null
          decision_reference: string
          decision_sequence: number
          decision_status: string
          delegated_by_user_id: string | null
          due_at: string | null
          id: string
          metadata: Json
          opened_at: string | null
          updated_at: string
        }
        Insert: {
          approval_request_id: string
          approval_step?: number
          approver_role_reference?: string | null
          approver_user_id?: string | null
          assigned_at?: string
          conditions?: Json
          created_at?: string
          decided_at?: string | null
          decision_context?: Json
          decision_reason_code?: string | null
          decision_reason_text?: string | null
          decision_reference: string
          decision_sequence?: number
          decision_status?: string
          delegated_by_user_id?: string | null
          due_at?: string | null
          id?: string
          metadata?: Json
          opened_at?: string | null
          updated_at?: string
        }
        Update: {
          approval_request_id?: string
          approval_step?: number
          approver_role_reference?: string | null
          approver_user_id?: string | null
          assigned_at?: string
          conditions?: Json
          created_at?: string
          decided_at?: string | null
          decision_context?: Json
          decision_reason_code?: string | null
          decision_reason_text?: string | null
          decision_reference?: string
          decision_sequence?: number
          decision_status?: string
          delegated_by_user_id?: string | null
          due_at?: string | null
          id?: string
          metadata?: Json
          opened_at?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "approval_decisions_approval_request_id_fkey"
            columns: ["approval_request_id"]
            isOneToOne: false
            referencedRelation: "approval_requests"
            referencedColumns: ["id"]
          },
        ]
      }
      approval_requests: {
        Row: {
          allow_self_approval: boolean
          approval_configuration: Json
          approval_priority: string
          approval_reference: string
          approval_status: string
          approval_type: string
          approvals_received: number
          business_justification: string | null
          cancelled_at: string | null
          completed_at: string | null
          created_at: string
          current_approval_step: number
          due_at: string | null
          entity_id: string | null
          entity_reference: string | null
          entity_type: string
          escalation_after_minutes: number | null
          escalation_enabled: boolean
          escalation_level: number
          expired_at: string | null
          id: string
          metadata: Json
          minimum_approvals_required: number
          rejections_received: number
          request_description: string | null
          request_title: string
          requested_at: string | null
          requested_by_actor_type: string
          requested_by_user_id: string | null
          requested_changes: Json
          require_sequential_approval: boolean
          require_unanimous_approval: boolean
          risk_summary: string | null
          submitted_at: string | null
          supporting_evidence: Json
          total_approval_steps: number
          updated_at: string
        }
        Insert: {
          allow_self_approval?: boolean
          approval_configuration?: Json
          approval_priority?: string
          approval_reference: string
          approval_status?: string
          approval_type: string
          approvals_received?: number
          business_justification?: string | null
          cancelled_at?: string | null
          completed_at?: string | null
          created_at?: string
          current_approval_step?: number
          due_at?: string | null
          entity_id?: string | null
          entity_reference?: string | null
          entity_type: string
          escalation_after_minutes?: number | null
          escalation_enabled?: boolean
          escalation_level?: number
          expired_at?: string | null
          id?: string
          metadata?: Json
          minimum_approvals_required?: number
          rejections_received?: number
          request_description?: string | null
          request_title: string
          requested_at?: string | null
          requested_by_actor_type?: string
          requested_by_user_id?: string | null
          requested_changes?: Json
          require_sequential_approval?: boolean
          require_unanimous_approval?: boolean
          risk_summary?: string | null
          submitted_at?: string | null
          supporting_evidence?: Json
          total_approval_steps?: number
          updated_at?: string
        }
        Update: {
          allow_self_approval?: boolean
          approval_configuration?: Json
          approval_priority?: string
          approval_reference?: string
          approval_status?: string
          approval_type?: string
          approvals_received?: number
          business_justification?: string | null
          cancelled_at?: string | null
          completed_at?: string | null
          created_at?: string
          current_approval_step?: number
          due_at?: string | null
          entity_id?: string | null
          entity_reference?: string | null
          entity_type?: string
          escalation_after_minutes?: number | null
          escalation_enabled?: boolean
          escalation_level?: number
          expired_at?: string | null
          id?: string
          metadata?: Json
          minimum_approvals_required?: number
          rejections_received?: number
          request_description?: string | null
          request_title?: string
          requested_at?: string | null
          requested_by_actor_type?: string
          requested_by_user_id?: string | null
          requested_changes?: Json
          require_sequential_approval?: boolean
          require_unanimous_approval?: boolean
          risk_summary?: string | null
          submitted_at?: string | null
          supporting_evidence?: Json
          total_approval_steps?: number
          updated_at?: string
        }
        Relationships: []
      }
      audit_events: {
        Row: {
          actor_display_name: string | null
          actor_reference: string | null
          actor_type: string
          actor_user_id: string | null
          after_values: Json | null
          approval_reference: string | null
          audit_reference: string
          before_values: Json | null
          changed_fields: Json
          compliance_context: Json
          contains_authentication_data: boolean
          contains_financial_data: boolean
          contains_personal_data: boolean
          contains_sensitive_data: boolean
          correlation_id: string | null
          created_at: string
          data_classification: string | null
          device_reference: string | null
          entity_id: string | null
          entity_reference: string | null
          entity_type: string | null
          event_action: string
          event_category: string
          event_details: Json
          event_outcome: string
          event_type: string
          exported_at: string | null
          id: string
          impersonated_user_id: string | null
          integrity_hash: string | null
          is_exported: boolean
          legal_hold_applied: boolean
          metadata: Json
          occurred_at: string
          operation_name: string | null
          parent_entity_id: string | null
          parent_entity_type: string | null
          previous_integrity_hash: string | null
          reason_code: string | null
          reason_text: string | null
          received_at: string
          request_reference: string | null
          retention_until: string | null
          security_context: Json
          session_reference: string | null
          severity: string
          source_component: string | null
          source_environment: string | null
          source_ip_hash: string | null
          source_service: string | null
          trace_id: string | null
          user_agent_hash: string | null
        }
        Insert: {
          actor_display_name?: string | null
          actor_reference?: string | null
          actor_type?: string
          actor_user_id?: string | null
          after_values?: Json | null
          approval_reference?: string | null
          audit_reference: string
          before_values?: Json | null
          changed_fields?: Json
          compliance_context?: Json
          contains_authentication_data?: boolean
          contains_financial_data?: boolean
          contains_personal_data?: boolean
          contains_sensitive_data?: boolean
          correlation_id?: string | null
          created_at?: string
          data_classification?: string | null
          device_reference?: string | null
          entity_id?: string | null
          entity_reference?: string | null
          entity_type?: string | null
          event_action: string
          event_category: string
          event_details?: Json
          event_outcome?: string
          event_type: string
          exported_at?: string | null
          id?: string
          impersonated_user_id?: string | null
          integrity_hash?: string | null
          is_exported?: boolean
          legal_hold_applied?: boolean
          metadata?: Json
          occurred_at?: string
          operation_name?: string | null
          parent_entity_id?: string | null
          parent_entity_type?: string | null
          previous_integrity_hash?: string | null
          reason_code?: string | null
          reason_text?: string | null
          received_at?: string
          request_reference?: string | null
          retention_until?: string | null
          security_context?: Json
          session_reference?: string | null
          severity?: string
          source_component?: string | null
          source_environment?: string | null
          source_ip_hash?: string | null
          source_service?: string | null
          trace_id?: string | null
          user_agent_hash?: string | null
        }
        Update: {
          actor_display_name?: string | null
          actor_reference?: string | null
          actor_type?: string
          actor_user_id?: string | null
          after_values?: Json | null
          approval_reference?: string | null
          audit_reference?: string
          before_values?: Json | null
          changed_fields?: Json
          compliance_context?: Json
          contains_authentication_data?: boolean
          contains_financial_data?: boolean
          contains_personal_data?: boolean
          contains_sensitive_data?: boolean
          correlation_id?: string | null
          created_at?: string
          data_classification?: string | null
          device_reference?: string | null
          entity_id?: string | null
          entity_reference?: string | null
          entity_type?: string | null
          event_action?: string
          event_category?: string
          event_details?: Json
          event_outcome?: string
          event_type?: string
          exported_at?: string | null
          id?: string
          impersonated_user_id?: string | null
          integrity_hash?: string | null
          is_exported?: boolean
          legal_hold_applied?: boolean
          metadata?: Json
          occurred_at?: string
          operation_name?: string | null
          parent_entity_id?: string | null
          parent_entity_type?: string | null
          previous_integrity_hash?: string | null
          reason_code?: string | null
          reason_text?: string | null
          received_at?: string
          request_reference?: string | null
          retention_until?: string | null
          security_context?: Json
          session_reference?: string | null
          severity?: string
          source_component?: string | null
          source_environment?: string | null
          source_ip_hash?: string | null
          source_service?: string | null
          trace_id?: string | null
          user_agent_hash?: string | null
        }
        Relationships: []
      }
      background_job_definitions: {
        Row: {
          consumer_type: string
          created_at: string
          created_by_user_id: string | null
          default_priority: number
          description: string
          display_name: string
          execution_timeout_seconds: number
          heartbeat_timeout_seconds: number
          id: string
          job_code: string
          lease_duration_seconds: number
          lifecycle_status: string
          maximum_attempts: number
          metadata: Json
          retry_backoff_strategy: string
          retry_base_delay_seconds: number
          retry_jitter_percent: number
          retry_max_delay_seconds: number
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          consumer_type: string
          created_at?: string
          created_by_user_id?: string | null
          default_priority?: number
          description: string
          display_name: string
          execution_timeout_seconds?: number
          heartbeat_timeout_seconds?: number
          id?: string
          job_code: string
          lease_duration_seconds?: number
          lifecycle_status?: string
          maximum_attempts?: number
          metadata?: Json
          retry_backoff_strategy?: string
          retry_base_delay_seconds?: number
          retry_jitter_percent?: number
          retry_max_delay_seconds?: number
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          consumer_type?: string
          created_at?: string
          created_by_user_id?: string | null
          default_priority?: number
          description?: string
          display_name?: string
          execution_timeout_seconds?: number
          heartbeat_timeout_seconds?: number
          id?: string
          job_code?: string
          lease_duration_seconds?: number
          lifecycle_status?: string
          maximum_attempts?: number
          metadata?: Json
          retry_backoff_strategy?: string
          retry_base_delay_seconds?: number
          retry_jitter_percent?: number
          retry_max_delay_seconds?: number
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: []
      }
      background_job_executions: {
        Row: {
          attempt_count: number
          available_at: string
          cancellation_reason: string | null
          cancellation_requested_at: string | null
          cancellation_requested_by_user_id: string | null
          cancelled_at: string | null
          commission_settlement_id: string | null
          completed_at: string | null
          created_at: string
          data_retention_execution_id: string | null
          execution_reference: string
          execution_status: string
          failed_at: string | null
          failure_code: string | null
          failure_details: Json | null
          failure_message: string | null
          heartbeat_at: string | null
          id: string
          idempotency_key: string | null
          job_definition_id: string
          lease_expires_at: string | null
          lease_token: string | null
          leased_at: string | null
          payload: Json
          priority: number
          queued_at: string
          result: Json | null
          retryable: boolean | null
          schedule_id: string | null
          scheduled_for: string | null
          started_at: string | null
          updated_at: string
          worker_id: string | null
        }
        Insert: {
          attempt_count?: number
          available_at?: string
          cancellation_reason?: string | null
          cancellation_requested_at?: string | null
          cancellation_requested_by_user_id?: string | null
          cancelled_at?: string | null
          commission_settlement_id?: string | null
          completed_at?: string | null
          created_at?: string
          data_retention_execution_id?: string | null
          execution_reference: string
          execution_status?: string
          failed_at?: string | null
          failure_code?: string | null
          failure_details?: Json | null
          failure_message?: string | null
          heartbeat_at?: string | null
          id?: string
          idempotency_key?: string | null
          job_definition_id: string
          lease_expires_at?: string | null
          lease_token?: string | null
          leased_at?: string | null
          payload?: Json
          priority: number
          queued_at?: string
          result?: Json | null
          retryable?: boolean | null
          schedule_id?: string | null
          scheduled_for?: string | null
          started_at?: string | null
          updated_at?: string
          worker_id?: string | null
        }
        Update: {
          attempt_count?: number
          available_at?: string
          cancellation_reason?: string | null
          cancellation_requested_at?: string | null
          cancellation_requested_by_user_id?: string | null
          cancelled_at?: string | null
          commission_settlement_id?: string | null
          completed_at?: string | null
          created_at?: string
          data_retention_execution_id?: string | null
          execution_reference?: string
          execution_status?: string
          failed_at?: string | null
          failure_code?: string | null
          failure_details?: Json | null
          failure_message?: string | null
          heartbeat_at?: string | null
          id?: string
          idempotency_key?: string | null
          job_definition_id?: string
          lease_expires_at?: string | null
          lease_token?: string | null
          leased_at?: string | null
          payload?: Json
          priority?: number
          queued_at?: string
          result?: Json | null
          retryable?: boolean | null
          schedule_id?: string | null
          scheduled_for?: string | null
          started_at?: string | null
          updated_at?: string
          worker_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "background_job_executions_commission_settlement_id_fkey"
            columns: ["commission_settlement_id"]
            isOneToOne: false
            referencedRelation: "commission_settlements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "background_job_executions_data_retention_execution_id_fkey"
            columns: ["data_retention_execution_id"]
            isOneToOne: false
            referencedRelation: "data_retention_executions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "background_job_executions_job_definition_id_fkey"
            columns: ["job_definition_id"]
            isOneToOne: false
            referencedRelation: "background_job_definitions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "background_job_executions_schedule_id_fkey"
            columns: ["schedule_id"]
            isOneToOne: false
            referencedRelation: "background_job_schedules"
            referencedColumns: ["id"]
          },
        ]
      }
      background_job_schedules: {
        Row: {
          commission_settlement_id: string | null
          created_at: string
          created_by_user_id: string | null
          data_retention_execution_id: string | null
          display_name: string
          id: string
          interval_seconds: number | null
          is_enabled: boolean
          job_definition_id: string
          last_materialized_at: string | null
          metadata: Json
          next_run_at: string
          payload: Json
          priority: number | null
          schedule_code: string
          schedule_type: string
          scheduled_once_at: string | null
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          commission_settlement_id?: string | null
          created_at?: string
          created_by_user_id?: string | null
          data_retention_execution_id?: string | null
          display_name: string
          id?: string
          interval_seconds?: number | null
          is_enabled?: boolean
          job_definition_id: string
          last_materialized_at?: string | null
          metadata?: Json
          next_run_at: string
          payload?: Json
          priority?: number | null
          schedule_code: string
          schedule_type: string
          scheduled_once_at?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          commission_settlement_id?: string | null
          created_at?: string
          created_by_user_id?: string | null
          data_retention_execution_id?: string | null
          display_name?: string
          id?: string
          interval_seconds?: number | null
          is_enabled?: boolean
          job_definition_id?: string
          last_materialized_at?: string | null
          metadata?: Json
          next_run_at?: string
          payload?: Json
          priority?: number | null
          schedule_code?: string
          schedule_type?: string
          scheduled_once_at?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "background_job_schedules_commission_settlement_id_fkey"
            columns: ["commission_settlement_id"]
            isOneToOne: false
            referencedRelation: "commission_settlements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "background_job_schedules_data_retention_execution_id_fkey"
            columns: ["data_retention_execution_id"]
            isOneToOne: false
            referencedRelation: "data_retention_executions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "background_job_schedules_job_definition_id_fkey"
            columns: ["job_definition_id"]
            isOneToOne: false
            referencedRelation: "background_job_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_application_decisions: {
        Row: {
          acknowledged_by_customer_at: string | null
          affordability_score: number | null
          application_id: string
          approval_probability: number | null
          approved_annual_fee: number | null
          approved_annual_fee_currency_id: string | null
          approved_credit_limit: number | null
          approved_credit_limit_currency_id: string | null
          communicated_to_customer_at: string | null
          conditions_due_at: string | null
          conditions_required: boolean
          confidence_score: number | null
          created_at: string
          decided_at: string
          decided_by_entity: string
          decided_by_user_id: string | null
          decision_code: string | null
          decision_conditions: Json
          decision_payload: Json
          decision_reason_category: string | null
          decision_reason_code: string | null
          decision_reason_text: string | null
          decision_reference: string
          decision_sequence: number
          decision_source: string
          decision_status: string
          decision_title: string | null
          decision_type: string
          decision_version: number
          eligibility_score: number | null
          fraud_score: number | null
          id: string
          is_final_decision: boolean
          metadata: Json
          policy_results: Json
          risk_score: number | null
          score_breakdown: Json
          updated_at: string
          valid_until: string | null
        }
        Insert: {
          acknowledged_by_customer_at?: string | null
          affordability_score?: number | null
          application_id: string
          approval_probability?: number | null
          approved_annual_fee?: number | null
          approved_annual_fee_currency_id?: string | null
          approved_credit_limit?: number | null
          approved_credit_limit_currency_id?: string | null
          communicated_to_customer_at?: string | null
          conditions_due_at?: string | null
          conditions_required?: boolean
          confidence_score?: number | null
          created_at?: string
          decided_at?: string
          decided_by_entity: string
          decided_by_user_id?: string | null
          decision_code?: string | null
          decision_conditions?: Json
          decision_payload?: Json
          decision_reason_category?: string | null
          decision_reason_code?: string | null
          decision_reason_text?: string | null
          decision_reference: string
          decision_sequence?: number
          decision_source: string
          decision_status: string
          decision_title?: string | null
          decision_type: string
          decision_version?: number
          eligibility_score?: number | null
          fraud_score?: number | null
          id?: string
          is_final_decision?: boolean
          metadata?: Json
          policy_results?: Json
          risk_score?: number | null
          score_breakdown?: Json
          updated_at?: string
          valid_until?: string | null
        }
        Update: {
          acknowledged_by_customer_at?: string | null
          affordability_score?: number | null
          application_id?: string
          approval_probability?: number | null
          approved_annual_fee?: number | null
          approved_annual_fee_currency_id?: string | null
          approved_credit_limit?: number | null
          approved_credit_limit_currency_id?: string | null
          communicated_to_customer_at?: string | null
          conditions_due_at?: string | null
          conditions_required?: boolean
          confidence_score?: number | null
          created_at?: string
          decided_at?: string
          decided_by_entity?: string
          decided_by_user_id?: string | null
          decision_code?: string | null
          decision_conditions?: Json
          decision_payload?: Json
          decision_reason_category?: string | null
          decision_reason_code?: string | null
          decision_reason_text?: string | null
          decision_reference?: string
          decision_sequence?: number
          decision_source?: string
          decision_status?: string
          decision_title?: string | null
          decision_type?: string
          decision_version?: number
          eligibility_score?: number | null
          fraud_score?: number | null
          id?: string
          is_final_decision?: boolean
          metadata?: Json
          policy_results?: Json
          risk_score?: number | null
          score_breakdown?: Json
          updated_at?: string
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bank_application_decisions_application_id_fkey"
            columns: ["application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_application_decisions_approved_annual_fee_currency_id_fkey"
            columns: ["approved_annual_fee_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_application_decisions_approved_credit_limit_currency__fkey"
            columns: ["approved_credit_limit_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_application_documents: {
        Row: {
          access_configuration: Json
          application_id: string
          confidence_score: number | null
          created_at: string
          document_category: string
          document_name: string | null
          document_number_masked: string | null
          document_reference: string
          document_status: string
          document_type: string
          expires_at: string | null
          extracted_data: Json
          file_extension: string | null
          file_hash: string | null
          file_size_bytes: number | null
          id: string
          is_current: boolean
          is_encrypted: boolean
          is_required: boolean
          is_sensitive: boolean
          issued_at: string | null
          issuing_country_code: string | null
          metadata: Json
          mime_type: string | null
          original_file_name: string | null
          received_at: string | null
          rejected_at: string | null
          rejection_reason_code: string | null
          rejection_reason_text: string | null
          requested_at: string
          requested_by_entity: string
          required_by: string | null
          storage_bucket: string | null
          storage_path: string | null
          storage_provider: string | null
          submitted_at: string | null
          superseded_at: string | null
          updated_at: string
          uploaded_at: string | null
          verification_provider: string | null
          verification_reference: string | null
          verification_results: Json
          verification_started_at: string | null
          verification_status: string
          verified_at: string | null
          verified_by: string | null
        }
        Insert: {
          access_configuration?: Json
          application_id: string
          confidence_score?: number | null
          created_at?: string
          document_category: string
          document_name?: string | null
          document_number_masked?: string | null
          document_reference: string
          document_status?: string
          document_type: string
          expires_at?: string | null
          extracted_data?: Json
          file_extension?: string | null
          file_hash?: string | null
          file_size_bytes?: number | null
          id?: string
          is_current?: boolean
          is_encrypted?: boolean
          is_required?: boolean
          is_sensitive?: boolean
          issued_at?: string | null
          issuing_country_code?: string | null
          metadata?: Json
          mime_type?: string | null
          original_file_name?: string | null
          received_at?: string | null
          rejected_at?: string | null
          rejection_reason_code?: string | null
          rejection_reason_text?: string | null
          requested_at?: string
          requested_by_entity?: string
          required_by?: string | null
          storage_bucket?: string | null
          storage_path?: string | null
          storage_provider?: string | null
          submitted_at?: string | null
          superseded_at?: string | null
          updated_at?: string
          uploaded_at?: string | null
          verification_provider?: string | null
          verification_reference?: string | null
          verification_results?: Json
          verification_started_at?: string | null
          verification_status?: string
          verified_at?: string | null
          verified_by?: string | null
        }
        Update: {
          access_configuration?: Json
          application_id?: string
          confidence_score?: number | null
          created_at?: string
          document_category?: string
          document_name?: string | null
          document_number_masked?: string | null
          document_reference?: string
          document_status?: string
          document_type?: string
          expires_at?: string | null
          extracted_data?: Json
          file_extension?: string | null
          file_hash?: string | null
          file_size_bytes?: number | null
          id?: string
          is_current?: boolean
          is_encrypted?: boolean
          is_required?: boolean
          is_sensitive?: boolean
          issued_at?: string | null
          issuing_country_code?: string | null
          metadata?: Json
          mime_type?: string | null
          original_file_name?: string | null
          received_at?: string | null
          rejected_at?: string | null
          rejection_reason_code?: string | null
          rejection_reason_text?: string | null
          requested_at?: string
          requested_by_entity?: string
          required_by?: string | null
          storage_bucket?: string | null
          storage_path?: string | null
          storage_provider?: string | null
          submitted_at?: string | null
          superseded_at?: string | null
          updated_at?: string
          uploaded_at?: string | null
          verification_provider?: string | null
          verification_reference?: string | null
          verification_results?: Json
          verification_started_at?: string | null
          verification_status?: string
          verified_at?: string | null
          verified_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bank_application_documents_application_id_fkey"
            columns: ["application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_application_events: {
        Row: {
          actor_type: string
          actor_user_id: string | null
          application_id: string
          change_details: Json
          correlation_id: string | null
          created_at: string
          description: string | null
          event_category: string
          event_payload: Json
          event_reference: string
          event_source: string
          event_status: string
          event_type: string
          external_reference: string | null
          id: string
          metadata: Json
          new_application_stage: string | null
          new_application_status: string | null
          occurred_at: string
          previous_application_stage: string | null
          previous_application_status: string | null
          processed_at: string | null
          reason_code: string | null
          reason_text: string | null
          received_at: string
          title: string | null
        }
        Insert: {
          actor_type?: string
          actor_user_id?: string | null
          application_id: string
          change_details?: Json
          correlation_id?: string | null
          created_at?: string
          description?: string | null
          event_category: string
          event_payload?: Json
          event_reference: string
          event_source?: string
          event_status?: string
          event_type: string
          external_reference?: string | null
          id?: string
          metadata?: Json
          new_application_stage?: string | null
          new_application_status?: string | null
          occurred_at?: string
          previous_application_stage?: string | null
          previous_application_status?: string | null
          processed_at?: string | null
          reason_code?: string | null
          reason_text?: string | null
          received_at?: string
          title?: string | null
        }
        Update: {
          actor_type?: string
          actor_user_id?: string | null
          application_id?: string
          change_details?: Json
          correlation_id?: string | null
          created_at?: string
          description?: string | null
          event_category?: string
          event_payload?: Json
          event_reference?: string
          event_source?: string
          event_status?: string
          event_type?: string
          external_reference?: string | null
          id?: string
          metadata?: Json
          new_application_stage?: string | null
          new_application_status?: string | null
          occurred_at?: string
          previous_application_stage?: string | null
          previous_application_status?: string | null
          processed_at?: string | null
          reason_code?: string | null
          reason_text?: string | null
          received_at?: string
          title?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bank_application_events_application_id_fkey"
            columns: ["application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_application_integrations: {
        Row: {
          application_id: string
          attempt_number: number
          created_at: string
          endpoint_reference: string | null
          error_category: string | null
          error_code: string | null
          error_details: Json
          error_message: string | null
          external_correlation_id: string | null
          http_method: string | null
          http_status_code: number | null
          id: string
          idempotency_key: string | null
          integration_direction: string
          integration_provider: string
          integration_reference: string
          integration_status: string
          integration_type: string
          maximum_attempts: number
          metadata: Json
          next_retry_at: string | null
          normalized_response: Json
          operation_code: string
          processing_completed_at: string | null
          provider_status_code: string | null
          provider_status_message: string | null
          request_duration_milliseconds: number | null
          request_headers: Json
          request_payload: Json
          request_reference: string | null
          request_sent_at: string | null
          response_headers: Json
          response_payload: Json
          response_received_at: string | null
          timeout_at: string | null
          updated_at: string
          webhook_event_reference: string | null
        }
        Insert: {
          application_id: string
          attempt_number?: number
          created_at?: string
          endpoint_reference?: string | null
          error_category?: string | null
          error_code?: string | null
          error_details?: Json
          error_message?: string | null
          external_correlation_id?: string | null
          http_method?: string | null
          http_status_code?: number | null
          id?: string
          idempotency_key?: string | null
          integration_direction: string
          integration_provider: string
          integration_reference: string
          integration_status?: string
          integration_type: string
          maximum_attempts?: number
          metadata?: Json
          next_retry_at?: string | null
          normalized_response?: Json
          operation_code: string
          processing_completed_at?: string | null
          provider_status_code?: string | null
          provider_status_message?: string | null
          request_duration_milliseconds?: number | null
          request_headers?: Json
          request_payload?: Json
          request_reference?: string | null
          request_sent_at?: string | null
          response_headers?: Json
          response_payload?: Json
          response_received_at?: string | null
          timeout_at?: string | null
          updated_at?: string
          webhook_event_reference?: string | null
        }
        Update: {
          application_id?: string
          attempt_number?: number
          created_at?: string
          endpoint_reference?: string | null
          error_category?: string | null
          error_code?: string | null
          error_details?: Json
          error_message?: string | null
          external_correlation_id?: string | null
          http_method?: string | null
          http_status_code?: number | null
          id?: string
          idempotency_key?: string | null
          integration_direction?: string
          integration_provider?: string
          integration_reference?: string
          integration_status?: string
          integration_type?: string
          maximum_attempts?: number
          metadata?: Json
          next_retry_at?: string | null
          normalized_response?: Json
          operation_code?: string
          processing_completed_at?: string | null
          provider_status_code?: string | null
          provider_status_message?: string | null
          request_duration_milliseconds?: number | null
          request_headers?: Json
          request_payload?: Json
          request_reference?: string | null
          request_sent_at?: string | null
          response_headers?: Json
          response_payload?: Json
          response_received_at?: string | null
          timeout_at?: string | null
          updated_at?: string
          webhook_event_reference?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bank_application_integrations_application_id_fkey"
            columns: ["application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_application_tasks: {
        Row: {
          action_url: string | null
          application_id: string
          assigned_entity_type: string
          assigned_user_id: string | null
          blocks_application_progress: boolean
          cancellation_reason_code: string | null
          cancellation_reason_text: string | null
          cancelled_at: string | null
          completed_at: string | null
          completion_code: string | null
          completion_method: string | null
          completion_notes: string | null
          completion_payload: Json
          created_at: string
          created_from_event_reference: string | null
          description: string | null
          document_id: string | null
          due_at: string | null
          expired_at: string | null
          external_task_reference: string | null
          id: string
          instructions: string | null
          is_mandatory: boolean
          maximum_reminder_count: number
          metadata: Json
          reminder_at: string | null
          reminder_count: number
          requires_customer_presence: boolean
          requires_document: boolean
          started_at: string | null
          starts_at: string
          task_category: string
          task_configuration: Json
          task_priority: string
          task_reference: string
          task_status: string
          task_type: string
          title: string
          updated_at: string
        }
        Insert: {
          action_url?: string | null
          application_id: string
          assigned_entity_type: string
          assigned_user_id?: string | null
          blocks_application_progress?: boolean
          cancellation_reason_code?: string | null
          cancellation_reason_text?: string | null
          cancelled_at?: string | null
          completed_at?: string | null
          completion_code?: string | null
          completion_method?: string | null
          completion_notes?: string | null
          completion_payload?: Json
          created_at?: string
          created_from_event_reference?: string | null
          description?: string | null
          document_id?: string | null
          due_at?: string | null
          expired_at?: string | null
          external_task_reference?: string | null
          id?: string
          instructions?: string | null
          is_mandatory?: boolean
          maximum_reminder_count?: number
          metadata?: Json
          reminder_at?: string | null
          reminder_count?: number
          requires_customer_presence?: boolean
          requires_document?: boolean
          started_at?: string | null
          starts_at?: string
          task_category: string
          task_configuration?: Json
          task_priority?: string
          task_reference: string
          task_status?: string
          task_type: string
          title: string
          updated_at?: string
        }
        Update: {
          action_url?: string | null
          application_id?: string
          assigned_entity_type?: string
          assigned_user_id?: string | null
          blocks_application_progress?: boolean
          cancellation_reason_code?: string | null
          cancellation_reason_text?: string | null
          cancelled_at?: string | null
          completed_at?: string | null
          completion_code?: string | null
          completion_method?: string | null
          completion_notes?: string | null
          completion_payload?: Json
          created_at?: string
          created_from_event_reference?: string | null
          description?: string | null
          document_id?: string | null
          due_at?: string | null
          expired_at?: string | null
          external_task_reference?: string | null
          id?: string
          instructions?: string | null
          is_mandatory?: boolean
          maximum_reminder_count?: number
          metadata?: Json
          reminder_at?: string | null
          reminder_count?: number
          requires_customer_presence?: boolean
          requires_document?: boolean
          started_at?: string | null
          starts_at?: string
          task_category?: string
          task_configuration?: Json
          task_priority?: string
          task_reference?: string
          task_status?: string
          task_type?: string
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "bank_application_tasks_application_id_fkey"
            columns: ["application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_application_tasks_document_id_fkey"
            columns: ["document_id"]
            isOneToOne: false
            referencedRelation: "bank_application_documents"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_applications: {
        Row: {
          aml_screening_completed_at: string | null
          aml_screening_reference: string | null
          aml_screening_status: string
          annual_fee_at_application: number | null
          annual_fee_currency_id: string | null
          applicant_snapshot: Json
          applicant_type: string
          application_channel: string
          application_payload: Json
          application_priority: string
          application_reference: string
          application_source: string
          application_stage: string
          application_status: string
          application_type: string
          approved_at: string | null
          approved_credit_limit: number | null
          approved_credit_limit_currency_id: string | null
          archived_at: string | null
          bank_application_reference: string | null
          bank_id: string
          bank_notes: string | null
          bank_response_summary: Json
          cancellation_reason_code: string | null
          cancellation_reason_text: string | null
          card_activated_at: string | null
          card_delivered_at: string | null
          card_id: string
          card_issued_at: string | null
          card_snapshot: Json
          comparison_id: string | null
          completed_at: string | null
          completed_task_count: number
          consent_details: Json
          consent_to_share_data: boolean
          consent_version: string | null
          correlation_id: string | null
          country_of_residence_code: string | null
          created_at: string
          customer_notes: string | null
          data_sharing_consent_at: string | null
          decision_at: string | null
          declared_debt_burden_ratio: number | null
          declared_monthly_income: number | null
          declared_monthly_obligations: number | null
          deleted_at: string | null
          document_status: string
          eligibility_confidence_at_application: number | null
          eligibility_score_at_application: number | null
          eligibility_snapshot: Json
          eligibility_status_at_application: string | null
          employment_sector: string | null
          employment_type: string | null
          estimated_approval_probability: number | null
          estimated_first_year_value: number | null
          estimated_ongoing_annual_value: number | null
          estimated_value_currency_id: string | null
          expected_decision_at: string | null
          expired_at: string | null
          expires_at: string | null
          financial_profile_id: string | null
          financial_snapshot: Json
          fraud_screening_completed_at: string | null
          fraud_screening_reference: string | null
          fraud_screening_status: string
          id: string
          identity_verification_reference: string | null
          identity_verification_status: string
          identity_verified_at: string | null
          income_currency_id: string | null
          internal_notes: string | null
          is_archived: boolean
          is_assisted_application: boolean
          is_deleted: boolean
          is_manual_application: boolean
          is_preapproved: boolean
          is_resubmission: boolean
          is_test_application: boolean
          journey_reference: string | null
          kyc_completed_at: string | null
          kyc_reference: string | null
          kyc_status: string
          last_bank_action_at: string | null
          last_customer_action_at: string | null
          last_platform_action_at: string | null
          last_status_changed_at: string
          marketing_consent: boolean
          metadata: Json
          nationality_code: string | null
          next_required_action: string | null
          next_required_action_due_at: string | null
          obligations_currency_id: string | null
          offer_expires_at: string | null
          offer_reference: string | null
          open_banking_consent_expires_at: string | null
          open_banking_consent_reference: string | null
          open_banking_consent_status: string | null
          partner_application_reference: string | null
          pending_task_count: number
          preference_profile_id: string | null
          preference_snapshot: Json
          preferred_contact_channel: string | null
          preferred_language_code: string
          previous_application_id: string | null
          privacy_policy_version: string | null
          promotional_offer_applied: boolean
          received_by_bank_at: string | null
          recommendation_rank_at_application: number | null
          recommendation_result_id: string | null
          recommendation_run_id: string | null
          recommendation_score_at_application: number | null
          recommendation_snapshot: Json
          referral_reference: string | null
          rejected_at: string | null
          rejected_document_count: number
          rejection_reason_category: string | null
          rejection_reason_code: string | null
          rejection_reason_text: string | null
          requested_credit_limit: number | null
          requested_credit_limit_currency_id: string | null
          required_document_count: number
          review_started_at: string | null
          risk_summary: Json
          saved_card_id: string | null
          session_reference: string | null
          sla_breached: boolean
          sla_completed_at: string | null
          sla_due_at: string | null
          sla_started_at: string | null
          sla_target_minutes: number | null
          spending_profile_id: string | null
          spending_snapshot: Json
          started_at: string
          submitted_at: string | null
          submitted_document_count: number
          terms_version: string | null
          updated_at: string
          user_id: string
          verified_document_count: number
          withdrawal_reason_code: string | null
          withdrawal_reason_text: string | null
          withdrawn_at: string | null
        }
        Insert: {
          aml_screening_completed_at?: string | null
          aml_screening_reference?: string | null
          aml_screening_status?: string
          annual_fee_at_application?: number | null
          annual_fee_currency_id?: string | null
          applicant_snapshot?: Json
          applicant_type?: string
          application_channel?: string
          application_payload?: Json
          application_priority?: string
          application_reference: string
          application_source?: string
          application_stage?: string
          application_status?: string
          application_type?: string
          approved_at?: string | null
          approved_credit_limit?: number | null
          approved_credit_limit_currency_id?: string | null
          archived_at?: string | null
          bank_application_reference?: string | null
          bank_id: string
          bank_notes?: string | null
          bank_response_summary?: Json
          cancellation_reason_code?: string | null
          cancellation_reason_text?: string | null
          card_activated_at?: string | null
          card_delivered_at?: string | null
          card_id: string
          card_issued_at?: string | null
          card_snapshot?: Json
          comparison_id?: string | null
          completed_at?: string | null
          completed_task_count?: number
          consent_details?: Json
          consent_to_share_data?: boolean
          consent_version?: string | null
          correlation_id?: string | null
          country_of_residence_code?: string | null
          created_at?: string
          customer_notes?: string | null
          data_sharing_consent_at?: string | null
          decision_at?: string | null
          declared_debt_burden_ratio?: number | null
          declared_monthly_income?: number | null
          declared_monthly_obligations?: number | null
          deleted_at?: string | null
          document_status?: string
          eligibility_confidence_at_application?: number | null
          eligibility_score_at_application?: number | null
          eligibility_snapshot?: Json
          eligibility_status_at_application?: string | null
          employment_sector?: string | null
          employment_type?: string | null
          estimated_approval_probability?: number | null
          estimated_first_year_value?: number | null
          estimated_ongoing_annual_value?: number | null
          estimated_value_currency_id?: string | null
          expected_decision_at?: string | null
          expired_at?: string | null
          expires_at?: string | null
          financial_profile_id?: string | null
          financial_snapshot?: Json
          fraud_screening_completed_at?: string | null
          fraud_screening_reference?: string | null
          fraud_screening_status?: string
          id?: string
          identity_verification_reference?: string | null
          identity_verification_status?: string
          identity_verified_at?: string | null
          income_currency_id?: string | null
          internal_notes?: string | null
          is_archived?: boolean
          is_assisted_application?: boolean
          is_deleted?: boolean
          is_manual_application?: boolean
          is_preapproved?: boolean
          is_resubmission?: boolean
          is_test_application?: boolean
          journey_reference?: string | null
          kyc_completed_at?: string | null
          kyc_reference?: string | null
          kyc_status?: string
          last_bank_action_at?: string | null
          last_customer_action_at?: string | null
          last_platform_action_at?: string | null
          last_status_changed_at?: string
          marketing_consent?: boolean
          metadata?: Json
          nationality_code?: string | null
          next_required_action?: string | null
          next_required_action_due_at?: string | null
          obligations_currency_id?: string | null
          offer_expires_at?: string | null
          offer_reference?: string | null
          open_banking_consent_expires_at?: string | null
          open_banking_consent_reference?: string | null
          open_banking_consent_status?: string | null
          partner_application_reference?: string | null
          pending_task_count?: number
          preference_profile_id?: string | null
          preference_snapshot?: Json
          preferred_contact_channel?: string | null
          preferred_language_code?: string
          previous_application_id?: string | null
          privacy_policy_version?: string | null
          promotional_offer_applied?: boolean
          received_by_bank_at?: string | null
          recommendation_rank_at_application?: number | null
          recommendation_result_id?: string | null
          recommendation_run_id?: string | null
          recommendation_score_at_application?: number | null
          recommendation_snapshot?: Json
          referral_reference?: string | null
          rejected_at?: string | null
          rejected_document_count?: number
          rejection_reason_category?: string | null
          rejection_reason_code?: string | null
          rejection_reason_text?: string | null
          requested_credit_limit?: number | null
          requested_credit_limit_currency_id?: string | null
          required_document_count?: number
          review_started_at?: string | null
          risk_summary?: Json
          saved_card_id?: string | null
          session_reference?: string | null
          sla_breached?: boolean
          sla_completed_at?: string | null
          sla_due_at?: string | null
          sla_started_at?: string | null
          sla_target_minutes?: number | null
          spending_profile_id?: string | null
          spending_snapshot?: Json
          started_at?: string
          submitted_at?: string | null
          submitted_document_count?: number
          terms_version?: string | null
          updated_at?: string
          user_id: string
          verified_document_count?: number
          withdrawal_reason_code?: string | null
          withdrawal_reason_text?: string | null
          withdrawn_at?: string | null
        }
        Update: {
          aml_screening_completed_at?: string | null
          aml_screening_reference?: string | null
          aml_screening_status?: string
          annual_fee_at_application?: number | null
          annual_fee_currency_id?: string | null
          applicant_snapshot?: Json
          applicant_type?: string
          application_channel?: string
          application_payload?: Json
          application_priority?: string
          application_reference?: string
          application_source?: string
          application_stage?: string
          application_status?: string
          application_type?: string
          approved_at?: string | null
          approved_credit_limit?: number | null
          approved_credit_limit_currency_id?: string | null
          archived_at?: string | null
          bank_application_reference?: string | null
          bank_id?: string
          bank_notes?: string | null
          bank_response_summary?: Json
          cancellation_reason_code?: string | null
          cancellation_reason_text?: string | null
          card_activated_at?: string | null
          card_delivered_at?: string | null
          card_id?: string
          card_issued_at?: string | null
          card_snapshot?: Json
          comparison_id?: string | null
          completed_at?: string | null
          completed_task_count?: number
          consent_details?: Json
          consent_to_share_data?: boolean
          consent_version?: string | null
          correlation_id?: string | null
          country_of_residence_code?: string | null
          created_at?: string
          customer_notes?: string | null
          data_sharing_consent_at?: string | null
          decision_at?: string | null
          declared_debt_burden_ratio?: number | null
          declared_monthly_income?: number | null
          declared_monthly_obligations?: number | null
          deleted_at?: string | null
          document_status?: string
          eligibility_confidence_at_application?: number | null
          eligibility_score_at_application?: number | null
          eligibility_snapshot?: Json
          eligibility_status_at_application?: string | null
          employment_sector?: string | null
          employment_type?: string | null
          estimated_approval_probability?: number | null
          estimated_first_year_value?: number | null
          estimated_ongoing_annual_value?: number | null
          estimated_value_currency_id?: string | null
          expected_decision_at?: string | null
          expired_at?: string | null
          expires_at?: string | null
          financial_profile_id?: string | null
          financial_snapshot?: Json
          fraud_screening_completed_at?: string | null
          fraud_screening_reference?: string | null
          fraud_screening_status?: string
          id?: string
          identity_verification_reference?: string | null
          identity_verification_status?: string
          identity_verified_at?: string | null
          income_currency_id?: string | null
          internal_notes?: string | null
          is_archived?: boolean
          is_assisted_application?: boolean
          is_deleted?: boolean
          is_manual_application?: boolean
          is_preapproved?: boolean
          is_resubmission?: boolean
          is_test_application?: boolean
          journey_reference?: string | null
          kyc_completed_at?: string | null
          kyc_reference?: string | null
          kyc_status?: string
          last_bank_action_at?: string | null
          last_customer_action_at?: string | null
          last_platform_action_at?: string | null
          last_status_changed_at?: string
          marketing_consent?: boolean
          metadata?: Json
          nationality_code?: string | null
          next_required_action?: string | null
          next_required_action_due_at?: string | null
          obligations_currency_id?: string | null
          offer_expires_at?: string | null
          offer_reference?: string | null
          open_banking_consent_expires_at?: string | null
          open_banking_consent_reference?: string | null
          open_banking_consent_status?: string | null
          partner_application_reference?: string | null
          pending_task_count?: number
          preference_profile_id?: string | null
          preference_snapshot?: Json
          preferred_contact_channel?: string | null
          preferred_language_code?: string
          previous_application_id?: string | null
          privacy_policy_version?: string | null
          promotional_offer_applied?: boolean
          received_by_bank_at?: string | null
          recommendation_rank_at_application?: number | null
          recommendation_result_id?: string | null
          recommendation_run_id?: string | null
          recommendation_score_at_application?: number | null
          recommendation_snapshot?: Json
          referral_reference?: string | null
          rejected_at?: string | null
          rejected_document_count?: number
          rejection_reason_category?: string | null
          rejection_reason_code?: string | null
          rejection_reason_text?: string | null
          requested_credit_limit?: number | null
          requested_credit_limit_currency_id?: string | null
          required_document_count?: number
          review_started_at?: string | null
          risk_summary?: Json
          saved_card_id?: string | null
          session_reference?: string | null
          sla_breached?: boolean
          sla_completed_at?: string | null
          sla_due_at?: string | null
          sla_started_at?: string | null
          sla_target_minutes?: number | null
          spending_profile_id?: string | null
          spending_snapshot?: Json
          started_at?: string
          submitted_at?: string | null
          submitted_document_count?: number
          terms_version?: string | null
          updated_at?: string
          user_id?: string
          verified_document_count?: number
          withdrawal_reason_code?: string | null
          withdrawal_reason_text?: string | null
          withdrawn_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bank_applications_annual_fee_currency_id_fkey"
            columns: ["annual_fee_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_approved_credit_limit_currency_id_fkey"
            columns: ["approved_credit_limit_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_comparison_id_fkey"
            columns: ["comparison_id"]
            isOneToOne: false
            referencedRelation: "card_comparisons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_estimated_value_currency_id_fkey"
            columns: ["estimated_value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_income_currency_id_fkey"
            columns: ["income_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_obligations_currency_id_fkey"
            columns: ["obligations_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_preference_profile_id_fkey"
            columns: ["preference_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_preferences"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_previous_application_id_fkey"
            columns: ["previous_application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_recommendation_result_id_fkey"
            columns: ["recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_requested_credit_limit_currency_id_fkey"
            columns: ["requested_credit_limit_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_saved_card_id_fkey"
            columns: ["saved_card_id"]
            isOneToOne: false
            referencedRelation: "user_saved_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_applications_spending_profile_id_fkey"
            columns: ["spending_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_spending_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_loyalty_programs: {
        Row: {
          bank_id: string
          created_at: string
          id: string
          is_primary: boolean
          loyalty_program_id: string
          updated_at: string
        }
        Insert: {
          bank_id: string
          created_at?: string
          id?: string
          is_primary?: boolean
          loyalty_program_id: string
          updated_at?: string
        }
        Update: {
          bank_id?: string
          created_at?: string
          id?: string
          is_primary?: boolean
          loyalty_program_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "bank_loyalty_programs_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_loyalty_programs_loyalty_program_id_fkey"
            columns: ["loyalty_program_id"]
            isOneToOne: false
            referencedRelation: "loyalty_programs"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_partner_products: {
        Row: {
          application_api_operation_code: string | null
          application_configuration: Json
          application_method: string
          application_window_days: number | null
          approved_marketing_copy: Json
          attribution_window_days: number | null
          available_from: string | null
          available_until: string | null
          bank_id: string
          bank_product_reference: string | null
          card_id: string | null
          cookie_window_days: number | null
          created_at: string
          deep_link_template: string | null
          destination_url: string | null
          distribution_status: string
          eligibility_api_operation_code: string | null
          eligibility_configuration: Json
          eligible_employment_types: Json
          eligible_nationality_codes: Json
          eligible_residency_codes: Json
          excluded_customer_segments: Json
          id: string
          is_exclusive: boolean
          is_existing_customer_only: boolean
          is_featured: boolean
          is_instant_decision_supported: boolean
          is_new_to_bank_only: boolean
          is_preapproval_supported: boolean
          maximum_age: number | null
          metadata: Json
          minimum_age: number | null
          minimum_income_currency_id: string | null
          minimum_monthly_income: number | null
          partner_product_reference: string
          partnership_id: string
          product_name: string
          product_rank: number | null
          product_status: string
          product_type: string
          status_api_operation_code: string | null
          tracking_configuration: Json
          updated_at: string
        }
        Insert: {
          application_api_operation_code?: string | null
          application_configuration?: Json
          application_method?: string
          application_window_days?: number | null
          approved_marketing_copy?: Json
          attribution_window_days?: number | null
          available_from?: string | null
          available_until?: string | null
          bank_id: string
          bank_product_reference?: string | null
          card_id?: string | null
          cookie_window_days?: number | null
          created_at?: string
          deep_link_template?: string | null
          destination_url?: string | null
          distribution_status?: string
          eligibility_api_operation_code?: string | null
          eligibility_configuration?: Json
          eligible_employment_types?: Json
          eligible_nationality_codes?: Json
          eligible_residency_codes?: Json
          excluded_customer_segments?: Json
          id?: string
          is_exclusive?: boolean
          is_existing_customer_only?: boolean
          is_featured?: boolean
          is_instant_decision_supported?: boolean
          is_new_to_bank_only?: boolean
          is_preapproval_supported?: boolean
          maximum_age?: number | null
          metadata?: Json
          minimum_age?: number | null
          minimum_income_currency_id?: string | null
          minimum_monthly_income?: number | null
          partner_product_reference: string
          partnership_id: string
          product_name: string
          product_rank?: number | null
          product_status?: string
          product_type?: string
          status_api_operation_code?: string | null
          tracking_configuration?: Json
          updated_at?: string
        }
        Update: {
          application_api_operation_code?: string | null
          application_configuration?: Json
          application_method?: string
          application_window_days?: number | null
          approved_marketing_copy?: Json
          attribution_window_days?: number | null
          available_from?: string | null
          available_until?: string | null
          bank_id?: string
          bank_product_reference?: string | null
          card_id?: string | null
          cookie_window_days?: number | null
          created_at?: string
          deep_link_template?: string | null
          destination_url?: string | null
          distribution_status?: string
          eligibility_api_operation_code?: string | null
          eligibility_configuration?: Json
          eligible_employment_types?: Json
          eligible_nationality_codes?: Json
          eligible_residency_codes?: Json
          excluded_customer_segments?: Json
          id?: string
          is_exclusive?: boolean
          is_existing_customer_only?: boolean
          is_featured?: boolean
          is_instant_decision_supported?: boolean
          is_new_to_bank_only?: boolean
          is_preapproval_supported?: boolean
          maximum_age?: number | null
          metadata?: Json
          minimum_age?: number | null
          minimum_income_currency_id?: string | null
          minimum_monthly_income?: number | null
          partner_product_reference?: string
          partnership_id?: string
          product_name?: string
          product_rank?: number | null
          product_status?: string
          product_type?: string
          status_api_operation_code?: string | null
          tracking_configuration?: Json
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "bank_partner_products_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_partner_products_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_partner_products_minimum_income_currency_id_fkey"
            columns: ["minimum_income_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_partner_products_partnership_id_fkey"
            columns: ["partnership_id"]
            isOneToOne: false
            referencedRelation: "bank_partnerships"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_partnerships: {
        Row: {
          account_manager_user_id: string | null
          agreement_effective_from: string | null
          agreement_effective_until: string | null
          agreement_reference: string | null
          agreement_signed_at: string | null
          agreement_version: string | null
          api_base_url: string | null
          approved_at: string | null
          approved_by: string | null
          attribution_configuration: Json
          automatic_renewal: boolean
          bank_id: string
          bank_portal_url: string | null
          commercial_contact_email: string | null
          commercial_contact_name: string | null
          commercial_model: string
          compliance_configuration: Json
          contract_configuration: Json
          created_at: string
          customer_terms_url: string | null
          default_application_window_days: number
          default_attribution_window_days: number
          default_cookie_window_days: number
          default_currency_id: string | null
          finance_contact_email: string | null
          finance_contact_name: string | null
          id: string
          integration_configuration: Json
          integration_model: string
          metadata: Json
          partnership_name: string
          partnership_reference: string
          partnership_status: string
          partnership_type: string
          privacy_policy_url: string | null
          referral_disclosure_text: string | null
          renewal_notice_days: number | null
          requires_bank_disclosure: boolean
          requires_customer_consent: boolean
          requires_marketing_approval: boolean
          settlement_configuration: Json
          supports_api_submission: boolean
          supports_application_status_api: boolean
          supports_commission_reports: boolean
          supports_conversion_webhooks: boolean
          supports_deep_linking: boolean
          supports_open_banking: boolean
          supports_reconciliation_files: boolean
          suspended_at: string | null
          suspended_reason: string | null
          technical_contact_email: string | null
          technical_contact_name: string | null
          terminated_at: string | null
          termination_notice_days: number | null
          termination_reason: string | null
          updated_at: string
          webhook_url: string | null
        }
        Insert: {
          account_manager_user_id?: string | null
          agreement_effective_from?: string | null
          agreement_effective_until?: string | null
          agreement_reference?: string | null
          agreement_signed_at?: string | null
          agreement_version?: string | null
          api_base_url?: string | null
          approved_at?: string | null
          approved_by?: string | null
          attribution_configuration?: Json
          automatic_renewal?: boolean
          bank_id: string
          bank_portal_url?: string | null
          commercial_contact_email?: string | null
          commercial_contact_name?: string | null
          commercial_model?: string
          compliance_configuration?: Json
          contract_configuration?: Json
          created_at?: string
          customer_terms_url?: string | null
          default_application_window_days?: number
          default_attribution_window_days?: number
          default_cookie_window_days?: number
          default_currency_id?: string | null
          finance_contact_email?: string | null
          finance_contact_name?: string | null
          id?: string
          integration_configuration?: Json
          integration_model?: string
          metadata?: Json
          partnership_name: string
          partnership_reference: string
          partnership_status?: string
          partnership_type?: string
          privacy_policy_url?: string | null
          referral_disclosure_text?: string | null
          renewal_notice_days?: number | null
          requires_bank_disclosure?: boolean
          requires_customer_consent?: boolean
          requires_marketing_approval?: boolean
          settlement_configuration?: Json
          supports_api_submission?: boolean
          supports_application_status_api?: boolean
          supports_commission_reports?: boolean
          supports_conversion_webhooks?: boolean
          supports_deep_linking?: boolean
          supports_open_banking?: boolean
          supports_reconciliation_files?: boolean
          suspended_at?: string | null
          suspended_reason?: string | null
          technical_contact_email?: string | null
          technical_contact_name?: string | null
          terminated_at?: string | null
          termination_notice_days?: number | null
          termination_reason?: string | null
          updated_at?: string
          webhook_url?: string | null
        }
        Update: {
          account_manager_user_id?: string | null
          agreement_effective_from?: string | null
          agreement_effective_until?: string | null
          agreement_reference?: string | null
          agreement_signed_at?: string | null
          agreement_version?: string | null
          api_base_url?: string | null
          approved_at?: string | null
          approved_by?: string | null
          attribution_configuration?: Json
          automatic_renewal?: boolean
          bank_id?: string
          bank_portal_url?: string | null
          commercial_contact_email?: string | null
          commercial_contact_name?: string | null
          commercial_model?: string
          compliance_configuration?: Json
          contract_configuration?: Json
          created_at?: string
          customer_terms_url?: string | null
          default_application_window_days?: number
          default_attribution_window_days?: number
          default_cookie_window_days?: number
          default_currency_id?: string | null
          finance_contact_email?: string | null
          finance_contact_name?: string | null
          id?: string
          integration_configuration?: Json
          integration_model?: string
          metadata?: Json
          partnership_name?: string
          partnership_reference?: string
          partnership_status?: string
          partnership_type?: string
          privacy_policy_url?: string | null
          referral_disclosure_text?: string | null
          renewal_notice_days?: number | null
          requires_bank_disclosure?: boolean
          requires_customer_consent?: boolean
          requires_marketing_approval?: boolean
          settlement_configuration?: Json
          supports_api_submission?: boolean
          supports_application_status_api?: boolean
          supports_commission_reports?: boolean
          supports_conversion_webhooks?: boolean
          supports_deep_linking?: boolean
          supports_open_banking?: boolean
          supports_reconciliation_files?: boolean
          suspended_at?: string | null
          suspended_reason?: string | null
          technical_contact_email?: string | null
          technical_contact_name?: string | null
          terminated_at?: string | null
          termination_notice_days?: number | null
          termination_reason?: string | null
          updated_at?: string
          webhook_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bank_partnerships_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_partnerships_default_currency_id_fkey"
            columns: ["default_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      banks: {
        Row: {
          country_id: string
          created_at: string
          id: string
          is_active: boolean
          logo_url: string | null
          name_ar: string
          name_en: string
          short_name_ar: string | null
          short_name_en: string | null
          slug: string
          updated_at: string
          website_url: string | null
        }
        Insert: {
          country_id: string
          created_at?: string
          id?: string
          is_active?: boolean
          logo_url?: string | null
          name_ar: string
          name_en: string
          short_name_ar?: string | null
          short_name_en?: string | null
          slug: string
          updated_at?: string
          website_url?: string | null
        }
        Update: {
          country_id?: string
          created_at?: string
          id?: string
          is_active?: boolean
          logo_url?: string | null
          name_ar?: string
          name_en?: string
          short_name_ar?: string | null
          short_name_en?: string | null
          slug?: string
          updated_at?: string
          website_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "banks_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
        ]
      }
      card_benefits: {
        Row: {
          benefit_unit: string | null
          benefit_value: number | null
          card_id: string
          created_at: string
          description_ar: string | null
          description_en: string | null
          display_order: number
          id: string
          is_active: boolean
          is_featured: boolean
          name_ar: string
          name_en: string
          slug: string
          terms_ar: string | null
          terms_en: string | null
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          benefit_unit?: string | null
          benefit_value?: number | null
          card_id: string
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          display_order?: number
          id?: string
          is_active?: boolean
          is_featured?: boolean
          name_ar: string
          name_en: string
          slug: string
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          benefit_unit?: string | null
          benefit_value?: number | null
          card_id?: string
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          display_order?: number
          id?: string
          is_active?: boolean
          is_featured?: boolean
          name_ar?: string
          name_en?: string
          slug?: string
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_benefits_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
        ]
      }
      card_comparison_criteria: {
        Row: {
          comparison_id: string
          configuration: Json
          created_at: string
          criterion_category: string
          criterion_code: string
          criterion_name_ar: string | null
          criterion_name_en: string
          criterion_type: string
          currency_id: string | null
          display_order: number
          evaluation_direction: string
          id: string
          importance_level: string
          is_active: boolean
          is_customer_editable: boolean
          is_required: boolean
          is_visible: boolean
          maximum_acceptable_value: number | null
          metadata: Json
          minimum_acceptable_value: number | null
          source_entity: string | null
          source_field: string | null
          target_value_boolean: boolean | null
          target_value_numeric: number | null
          target_value_text: string | null
          updated_at: string
          weight: number
        }
        Insert: {
          comparison_id: string
          configuration?: Json
          created_at?: string
          criterion_category: string
          criterion_code: string
          criterion_name_ar?: string | null
          criterion_name_en: string
          criterion_type: string
          currency_id?: string | null
          display_order?: number
          evaluation_direction?: string
          id?: string
          importance_level?: string
          is_active?: boolean
          is_customer_editable?: boolean
          is_required?: boolean
          is_visible?: boolean
          maximum_acceptable_value?: number | null
          metadata?: Json
          minimum_acceptable_value?: number | null
          source_entity?: string | null
          source_field?: string | null
          target_value_boolean?: boolean | null
          target_value_numeric?: number | null
          target_value_text?: string | null
          updated_at?: string
          weight?: number
        }
        Update: {
          comparison_id?: string
          configuration?: Json
          created_at?: string
          criterion_category?: string
          criterion_code?: string
          criterion_name_ar?: string | null
          criterion_name_en?: string
          criterion_type?: string
          currency_id?: string | null
          display_order?: number
          evaluation_direction?: string
          id?: string
          importance_level?: string
          is_active?: boolean
          is_customer_editable?: boolean
          is_required?: boolean
          is_visible?: boolean
          maximum_acceptable_value?: number | null
          metadata?: Json
          minimum_acceptable_value?: number | null
          source_entity?: string | null
          source_field?: string | null
          target_value_boolean?: boolean | null
          target_value_numeric?: number | null
          target_value_text?: string | null
          updated_at?: string
          weight?: number
        }
        Relationships: [
          {
            foreignKeyName: "card_comparison_criteria_comparison_id_fkey"
            columns: ["comparison_id"]
            isOneToOne: false
            referencedRelation: "card_comparisons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_criteria_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_comparison_item_scores: {
        Row: {
          calculation_details: Json
          comparison_criterion_id: string
          comparison_item_id: string
          confidence_score: number | null
          created_at: string
          criterion_satisfied: boolean | null
          data_available: boolean
          evaluated_at: string
          evaluation_notes: string | null
          evaluation_status: string
          evidence: Json
          id: string
          metadata: Json
          normalized_value: number | null
          rank_within_criterion: number | null
          raw_boolean_value: boolean | null
          raw_numeric_value: number | null
          raw_score: number | null
          raw_text_value: string | null
          requirement_failed: boolean
          updated_at: string
          weighted_score: number | null
        }
        Insert: {
          calculation_details?: Json
          comparison_criterion_id: string
          comparison_item_id: string
          confidence_score?: number | null
          created_at?: string
          criterion_satisfied?: boolean | null
          data_available?: boolean
          evaluated_at?: string
          evaluation_notes?: string | null
          evaluation_status?: string
          evidence?: Json
          id?: string
          metadata?: Json
          normalized_value?: number | null
          rank_within_criterion?: number | null
          raw_boolean_value?: boolean | null
          raw_numeric_value?: number | null
          raw_score?: number | null
          raw_text_value?: string | null
          requirement_failed?: boolean
          updated_at?: string
          weighted_score?: number | null
        }
        Update: {
          calculation_details?: Json
          comparison_criterion_id?: string
          comparison_item_id?: string
          confidence_score?: number | null
          created_at?: string
          criterion_satisfied?: boolean | null
          data_available?: boolean
          evaluated_at?: string
          evaluation_notes?: string | null
          evaluation_status?: string
          evidence?: Json
          id?: string
          metadata?: Json
          normalized_value?: number | null
          rank_within_criterion?: number | null
          raw_boolean_value?: boolean | null
          raw_numeric_value?: number | null
          raw_score?: number | null
          raw_text_value?: string | null
          requirement_failed?: boolean
          updated_at?: string
          weighted_score?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "card_comparison_item_scores_comparison_criterion_id_fkey"
            columns: ["comparison_criterion_id"]
            isOneToOne: false
            referencedRelation: "card_comparison_criteria"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_item_scores_comparison_item_id_fkey"
            columns: ["comparison_item_id"]
            isOneToOne: false
            referencedRelation: "card_comparison_items"
            referencedColumns: ["id"]
          },
        ]
      }
      card_comparison_items: {
        Row: {
          added_at: string
          advisor_notes: string | null
          annual_fee: number | null
          annual_fee_currency_id: string | null
          card_id: string
          card_snapshot: Json
          comparison_id: string
          comparison_values: Json
          confidence_score: number | null
          created_at: string
          customer_notes: string | null
          differentiators: Json
          display_position: number
          eligibility_confidence_score: number | null
          eligibility_rank: number | null
          eligibility_score: number | null
          eligibility_score_component: number | null
          eligibility_status: string | null
          elimination_reason_code: string | null
          elimination_reason_text: string | null
          estimated_first_year_benefit_value: number | null
          estimated_first_year_cost: number | null
          estimated_first_year_net_value: number | null
          estimated_first_year_reward_value: number | null
          estimated_ongoing_annual_value: number | null
          evaluated_at: string | null
          evaluation_details: Json
          fee_rank: number | null
          fees_score: number | null
          id: string
          is_eliminated: boolean
          is_primary: boolean
          is_selected: boolean
          is_winner: boolean
          item_reference: string
          item_source: string
          item_status: string
          lifestyle_score: number | null
          metadata: Json
          missing_data: Json
          preference_rank: number | null
          preference_score: number | null
          recommendation_rank: number | null
          recommendation_result_id: string | null
          recommendation_run_card_id: string | null
          recommendation_score: number | null
          removed_at: string | null
          rewards_score: number | null
          saved_card_id: string | null
          score_breakdown: Json
          score_rank: number | null
          simplicity_score: number | null
          strengths: Json
          total_score: number | null
          travel_score: number | null
          updated_at: string
          value_currency_id: string | null
          value_rank: number | null
          value_score: number | null
          weaknesses: Json
          welcome_offer_currency_id: string | null
          welcome_offer_value: number | null
        }
        Insert: {
          added_at?: string
          advisor_notes?: string | null
          annual_fee?: number | null
          annual_fee_currency_id?: string | null
          card_id: string
          card_snapshot?: Json
          comparison_id: string
          comparison_values?: Json
          confidence_score?: number | null
          created_at?: string
          customer_notes?: string | null
          differentiators?: Json
          display_position?: number
          eligibility_confidence_score?: number | null
          eligibility_rank?: number | null
          eligibility_score?: number | null
          eligibility_score_component?: number | null
          eligibility_status?: string | null
          elimination_reason_code?: string | null
          elimination_reason_text?: string | null
          estimated_first_year_benefit_value?: number | null
          estimated_first_year_cost?: number | null
          estimated_first_year_net_value?: number | null
          estimated_first_year_reward_value?: number | null
          estimated_ongoing_annual_value?: number | null
          evaluated_at?: string | null
          evaluation_details?: Json
          fee_rank?: number | null
          fees_score?: number | null
          id?: string
          is_eliminated?: boolean
          is_primary?: boolean
          is_selected?: boolean
          is_winner?: boolean
          item_reference: string
          item_source?: string
          item_status?: string
          lifestyle_score?: number | null
          metadata?: Json
          missing_data?: Json
          preference_rank?: number | null
          preference_score?: number | null
          recommendation_rank?: number | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_score?: number | null
          removed_at?: string | null
          rewards_score?: number | null
          saved_card_id?: string | null
          score_breakdown?: Json
          score_rank?: number | null
          simplicity_score?: number | null
          strengths?: Json
          total_score?: number | null
          travel_score?: number | null
          updated_at?: string
          value_currency_id?: string | null
          value_rank?: number | null
          value_score?: number | null
          weaknesses?: Json
          welcome_offer_currency_id?: string | null
          welcome_offer_value?: number | null
        }
        Update: {
          added_at?: string
          advisor_notes?: string | null
          annual_fee?: number | null
          annual_fee_currency_id?: string | null
          card_id?: string
          card_snapshot?: Json
          comparison_id?: string
          comparison_values?: Json
          confidence_score?: number | null
          created_at?: string
          customer_notes?: string | null
          differentiators?: Json
          display_position?: number
          eligibility_confidence_score?: number | null
          eligibility_rank?: number | null
          eligibility_score?: number | null
          eligibility_score_component?: number | null
          eligibility_status?: string | null
          elimination_reason_code?: string | null
          elimination_reason_text?: string | null
          estimated_first_year_benefit_value?: number | null
          estimated_first_year_cost?: number | null
          estimated_first_year_net_value?: number | null
          estimated_first_year_reward_value?: number | null
          estimated_ongoing_annual_value?: number | null
          evaluated_at?: string | null
          evaluation_details?: Json
          fee_rank?: number | null
          fees_score?: number | null
          id?: string
          is_eliminated?: boolean
          is_primary?: boolean
          is_selected?: boolean
          is_winner?: boolean
          item_reference?: string
          item_source?: string
          item_status?: string
          lifestyle_score?: number | null
          metadata?: Json
          missing_data?: Json
          preference_rank?: number | null
          preference_score?: number | null
          recommendation_rank?: number | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_score?: number | null
          removed_at?: string | null
          rewards_score?: number | null
          saved_card_id?: string | null
          score_breakdown?: Json
          score_rank?: number | null
          simplicity_score?: number | null
          strengths?: Json
          total_score?: number | null
          travel_score?: number | null
          updated_at?: string
          value_currency_id?: string | null
          value_rank?: number | null
          value_score?: number | null
          weaknesses?: Json
          welcome_offer_currency_id?: string | null
          welcome_offer_value?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "card_comparison_items_annual_fee_currency_id_fkey"
            columns: ["annual_fee_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_items_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_items_comparison_id_fkey"
            columns: ["comparison_id"]
            isOneToOne: false
            referencedRelation: "card_comparisons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_items_recommendation_result_id_fkey"
            columns: ["recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_items_recommendation_run_card_id_fkey"
            columns: ["recommendation_run_card_id"]
            isOneToOne: false
            referencedRelation: "recommendation_run_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_items_saved_card_id_fkey"
            columns: ["saved_card_id"]
            isOneToOne: false
            referencedRelation: "user_saved_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_items_value_currency_id_fkey"
            columns: ["value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_items_welcome_offer_currency_id_fkey"
            columns: ["welcome_offer_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_comparison_profiles: {
        Row: {
          business_score: number | null
          card_id: string
          cashback_score: number | null
          created_at: string
          currency_id: string | null
          description_ar: string | null
          description_en: string | null
          digital_score: number | null
          dining_score: number | null
          id: string
          insurance_score: number | null
          is_active: boolean
          is_default: boolean
          lifestyle_score: number | null
          lounge_score: number | null
          methodology_notes_ar: string | null
          methodology_notes_en: string | null
          overall_score: number | null
          priority: number
          profile_name_ar: string
          profile_name_en: string
          profile_slug: string
          recommended_minimum_salary: number | null
          rewards_score: number | null
          score_confidence: number | null
          scoring_method: string
          scoring_version: string
          shopping_score: number | null
          source_url: string | null
          travel_score: number | null
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          business_score?: number | null
          card_id: string
          cashback_score?: number | null
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          digital_score?: number | null
          dining_score?: number | null
          id?: string
          insurance_score?: number | null
          is_active?: boolean
          is_default?: boolean
          lifestyle_score?: number | null
          lounge_score?: number | null
          methodology_notes_ar?: string | null
          methodology_notes_en?: string | null
          overall_score?: number | null
          priority?: number
          profile_name_ar: string
          profile_name_en: string
          profile_slug: string
          recommended_minimum_salary?: number | null
          rewards_score?: number | null
          score_confidence?: number | null
          scoring_method?: string
          scoring_version?: string
          shopping_score?: number | null
          source_url?: string | null
          travel_score?: number | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          business_score?: number | null
          card_id?: string
          cashback_score?: number | null
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          digital_score?: number | null
          dining_score?: number | null
          id?: string
          insurance_score?: number | null
          is_active?: boolean
          is_default?: boolean
          lifestyle_score?: number | null
          lounge_score?: number | null
          methodology_notes_ar?: string | null
          methodology_notes_en?: string | null
          overall_score?: number | null
          priority?: number
          profile_name_ar?: string
          profile_name_en?: string
          profile_slug?: string
          recommended_minimum_salary?: number | null
          rewards_score?: number | null
          score_confidence?: number | null
          scoring_method?: string
          scoring_version?: string
          shopping_score?: number | null
          source_url?: string | null
          travel_score?: number | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_comparison_profiles_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparison_profiles_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_comparisons: {
        Row: {
          active_item_count: number
          advisor_notes: string | null
          advisor_recommendation: string | null
          archived_at: string | null
          card_count: number
          comparison_context: string | null
          comparison_criteria: Json
          comparison_currency_id: string | null
          comparison_name: string | null
          comparison_name_ar: string | null
          comparison_reference: string
          comparison_source: string
          comparison_status: string
          comparison_summary: Json
          comparison_type: string
          completed_at: string | null
          correlation_id: string | null
          created_at: string
          customer_decision: string | null
          customer_decision_notes: string | null
          customer_decision_reason_code: string | null
          customer_priorities: Json
          decision_summary: Json
          deleted_at: string | null
          display_configuration: Json
          estimated_annual_savings: number | null
          estimated_best_first_year_value: number | null
          estimated_best_ongoing_value: number | null
          estimated_savings_currency_id: string | null
          estimated_value_currency_id: string | null
          evaluation_method: string
          evaluation_version: string
          expires_at: string | null
          financial_profile_id: string | null
          id: string
          is_anonymous: boolean
          is_archived: boolean
          is_deleted: boolean
          is_locked: boolean
          is_public: boolean
          journey_reference: string | null
          last_viewed_at: string | null
          locked_at: string | null
          locked_by: string | null
          maximum_card_count: number
          metadata: Json
          overall_comparison_score: number | null
          preference_profile_id: string | null
          primary_card_id: string | null
          recommendation_run_id: string | null
          scoring_configuration: Json
          selected_card_id: string | null
          session_reference: string | null
          share_enabled: boolean
          share_expires_at: string | null
          share_token: string | null
          snapshot_data: Json
          source_collection_id: string | null
          spending_profile_id: string | null
          started_at: string
          updated_at: string
          user_id: string | null
          winner_confidence_score: number | null
          winner_selection_method: string | null
          winning_card_id: string | null
        }
        Insert: {
          active_item_count?: number
          advisor_notes?: string | null
          advisor_recommendation?: string | null
          archived_at?: string | null
          card_count?: number
          comparison_context?: string | null
          comparison_criteria?: Json
          comparison_currency_id?: string | null
          comparison_name?: string | null
          comparison_name_ar?: string | null
          comparison_reference: string
          comparison_source?: string
          comparison_status?: string
          comparison_summary?: Json
          comparison_type?: string
          completed_at?: string | null
          correlation_id?: string | null
          created_at?: string
          customer_decision?: string | null
          customer_decision_notes?: string | null
          customer_decision_reason_code?: string | null
          customer_priorities?: Json
          decision_summary?: Json
          deleted_at?: string | null
          display_configuration?: Json
          estimated_annual_savings?: number | null
          estimated_best_first_year_value?: number | null
          estimated_best_ongoing_value?: number | null
          estimated_savings_currency_id?: string | null
          estimated_value_currency_id?: string | null
          evaluation_method?: string
          evaluation_version?: string
          expires_at?: string | null
          financial_profile_id?: string | null
          id?: string
          is_anonymous?: boolean
          is_archived?: boolean
          is_deleted?: boolean
          is_locked?: boolean
          is_public?: boolean
          journey_reference?: string | null
          last_viewed_at?: string | null
          locked_at?: string | null
          locked_by?: string | null
          maximum_card_count?: number
          metadata?: Json
          overall_comparison_score?: number | null
          preference_profile_id?: string | null
          primary_card_id?: string | null
          recommendation_run_id?: string | null
          scoring_configuration?: Json
          selected_card_id?: string | null
          session_reference?: string | null
          share_enabled?: boolean
          share_expires_at?: string | null
          share_token?: string | null
          snapshot_data?: Json
          source_collection_id?: string | null
          spending_profile_id?: string | null
          started_at?: string
          updated_at?: string
          user_id?: string | null
          winner_confidence_score?: number | null
          winner_selection_method?: string | null
          winning_card_id?: string | null
        }
        Update: {
          active_item_count?: number
          advisor_notes?: string | null
          advisor_recommendation?: string | null
          archived_at?: string | null
          card_count?: number
          comparison_context?: string | null
          comparison_criteria?: Json
          comparison_currency_id?: string | null
          comparison_name?: string | null
          comparison_name_ar?: string | null
          comparison_reference?: string
          comparison_source?: string
          comparison_status?: string
          comparison_summary?: Json
          comparison_type?: string
          completed_at?: string | null
          correlation_id?: string | null
          created_at?: string
          customer_decision?: string | null
          customer_decision_notes?: string | null
          customer_decision_reason_code?: string | null
          customer_priorities?: Json
          decision_summary?: Json
          deleted_at?: string | null
          display_configuration?: Json
          estimated_annual_savings?: number | null
          estimated_best_first_year_value?: number | null
          estimated_best_ongoing_value?: number | null
          estimated_savings_currency_id?: string | null
          estimated_value_currency_id?: string | null
          evaluation_method?: string
          evaluation_version?: string
          expires_at?: string | null
          financial_profile_id?: string | null
          id?: string
          is_anonymous?: boolean
          is_archived?: boolean
          is_deleted?: boolean
          is_locked?: boolean
          is_public?: boolean
          journey_reference?: string | null
          last_viewed_at?: string | null
          locked_at?: string | null
          locked_by?: string | null
          maximum_card_count?: number
          metadata?: Json
          overall_comparison_score?: number | null
          preference_profile_id?: string | null
          primary_card_id?: string | null
          recommendation_run_id?: string | null
          scoring_configuration?: Json
          selected_card_id?: string | null
          session_reference?: string | null
          share_enabled?: boolean
          share_expires_at?: string | null
          share_token?: string | null
          snapshot_data?: Json
          source_collection_id?: string | null
          spending_profile_id?: string | null
          started_at?: string
          updated_at?: string
          user_id?: string | null
          winner_confidence_score?: number | null
          winner_selection_method?: string | null
          winning_card_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_comparisons_comparison_currency_id_fkey"
            columns: ["comparison_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_estimated_savings_currency_id_fkey"
            columns: ["estimated_savings_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_estimated_value_currency_id_fkey"
            columns: ["estimated_value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_preference_profile_id_fkey"
            columns: ["preference_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_preferences"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_primary_card_id_fkey"
            columns: ["primary_card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_selected_card_id_fkey"
            columns: ["selected_card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_source_collection_id_fkey"
            columns: ["source_collection_id"]
            isOneToOne: false
            referencedRelation: "user_card_collections"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_spending_profile_id_fkey"
            columns: ["spending_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_spending_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_comparisons_winning_card_id_fkey"
            columns: ["winning_card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
        ]
      }
      card_dining_benefits: {
        Row: {
          activation_required: boolean
          applicable_channels: Json | null
          applicable_days: number[] | null
          benefit_type: string
          booking_url: string | null
          card_id: string
          complimentary_items: number | null
          complimentary_uses: number | null
          created_at: string
          currency_id: string | null
          description_ar: string | null
          description_en: string | null
          discount_percentage: number | null
          eligible_cardholder_type: string
          fixed_discount_amount: number | null
          id: string
          is_active: boolean
          is_featured: boolean
          maximum_discount_amount: number | null
          merchant_name_ar: string | null
          merchant_name_en: string | null
          minimum_spend: number | null
          name_ar: string
          name_en: string
          priority: number
          promo_code: string | null
          provider_name_ar: string | null
          provider_name_en: string | null
          registration_required: boolean
          reservation_required: boolean
          slug: string
          source_url: string | null
          terms_ar: string | null
          terms_en: string | null
          updated_at: string
          usage_period: string | null
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          activation_required?: boolean
          applicable_channels?: Json | null
          applicable_days?: number[] | null
          benefit_type: string
          booking_url?: string | null
          card_id: string
          complimentary_items?: number | null
          complimentary_uses?: number | null
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          discount_percentage?: number | null
          eligible_cardholder_type?: string
          fixed_discount_amount?: number | null
          id?: string
          is_active?: boolean
          is_featured?: boolean
          maximum_discount_amount?: number | null
          merchant_name_ar?: string | null
          merchant_name_en?: string | null
          minimum_spend?: number | null
          name_ar: string
          name_en: string
          priority?: number
          promo_code?: string | null
          provider_name_ar?: string | null
          provider_name_en?: string | null
          registration_required?: boolean
          reservation_required?: boolean
          slug: string
          source_url?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          usage_period?: string | null
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          activation_required?: boolean
          applicable_channels?: Json | null
          applicable_days?: number[] | null
          benefit_type?: string
          booking_url?: string | null
          card_id?: string
          complimentary_items?: number | null
          complimentary_uses?: number | null
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          discount_percentage?: number | null
          eligible_cardholder_type?: string
          fixed_discount_amount?: number | null
          id?: string
          is_active?: boolean
          is_featured?: boolean
          maximum_discount_amount?: number | null
          merchant_name_ar?: string | null
          merchant_name_en?: string | null
          minimum_spend?: number | null
          name_ar?: string
          name_en?: string
          priority?: number
          promo_code?: string | null
          provider_name_ar?: string | null
          provider_name_en?: string | null
          registration_required?: boolean
          reservation_required?: boolean
          slug?: string
          source_url?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          usage_period?: string | null
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_dining_benefits_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_dining_benefits_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_eligibility_requirements: {
        Row: {
          allowed_values: Json | null
          card_id: string
          created_at: string
          credit_scoring_system: string | null
          currency_id: string | null
          description_ar: string | null
          description_en: string | null
          id: string
          is_active: boolean
          is_mandatory: boolean
          maximum_age: number | null
          maximum_amount: number | null
          maximum_credit_score: number | null
          minimum_age: number | null
          minimum_amount: number | null
          minimum_credit_score: number | null
          minimum_employment_months: number | null
          name_ar: string
          name_en: string
          priority: number
          required_boolean_value: boolean | null
          requirement_type: string
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          allowed_values?: Json | null
          card_id: string
          created_at?: string
          credit_scoring_system?: string | null
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          is_mandatory?: boolean
          maximum_age?: number | null
          maximum_amount?: number | null
          maximum_credit_score?: number | null
          minimum_age?: number | null
          minimum_amount?: number | null
          minimum_credit_score?: number | null
          minimum_employment_months?: number | null
          name_ar: string
          name_en: string
          priority?: number
          required_boolean_value?: boolean | null
          requirement_type: string
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          allowed_values?: Json | null
          card_id?: string
          created_at?: string
          credit_scoring_system?: string | null
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          is_mandatory?: boolean
          maximum_age?: number | null
          maximum_amount?: number | null
          maximum_credit_score?: number | null
          minimum_age?: number | null
          minimum_amount?: number | null
          minimum_credit_score?: number | null
          minimum_employment_months?: number | null
          name_ar?: string
          name_en?: string
          priority?: number
          required_boolean_value?: boolean | null
          requirement_type?: string
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_eligibility_requirements_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_eligibility_requirements_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_fees: {
        Row: {
          amount: number | null
          billing_period: Database["public"]["Enums"]["billing_period"]
          card_id: string
          created_at: string
          currency_id: string | null
          description_ar: string | null
          description_en: string | null
          fee_type: Database["public"]["Enums"]["fee_type"]
          id: string
          is_active: boolean
          name_ar: string
          name_en: string
          percentage: number | null
          updated_at: string
          waiver_threshold_amount: number | null
          waiver_threshold_period:
            | Database["public"]["Enums"]["threshold_period"]
            | null
          waiver_type: Database["public"]["Enums"]["fee_waiver_type"]
        }
        Insert: {
          amount?: number | null
          billing_period?: Database["public"]["Enums"]["billing_period"]
          card_id: string
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          fee_type: Database["public"]["Enums"]["fee_type"]
          id?: string
          is_active?: boolean
          name_ar: string
          name_en: string
          percentage?: number | null
          updated_at?: string
          waiver_threshold_amount?: number | null
          waiver_threshold_period?:
            | Database["public"]["Enums"]["threshold_period"]
            | null
          waiver_type?: Database["public"]["Enums"]["fee_waiver_type"]
        }
        Update: {
          amount?: number | null
          billing_period?: Database["public"]["Enums"]["billing_period"]
          card_id?: string
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          fee_type?: Database["public"]["Enums"]["fee_type"]
          id?: string
          is_active?: boolean
          name_ar?: string
          name_en?: string
          percentage?: number | null
          updated_at?: string
          waiver_threshold_amount?: number | null
          waiver_threshold_period?:
            | Database["public"]["Enums"]["threshold_period"]
            | null
          waiver_type?: Database["public"]["Enums"]["fee_waiver_type"]
        }
        Relationships: [
          {
            foreignKeyName: "card_fees_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_fees_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_installment_plans: {
        Row: {
          activation_deadline_days: number | null
          activation_method: string | null
          annual_percentage_rate: number | null
          available_tenures: number[]
          card_id: string
          created_at: string
          currency_id: string
          description_ar: string | null
          description_en: string | null
          early_settlement_fee_amount: number | null
          early_settlement_fee_percentage: number | null
          eligible_merchant_categories: Json | null
          eligible_transaction_channels: Json | null
          excluded_merchant_categories: Json | null
          flat_profit_rate: number | null
          id: string
          interest_free: boolean
          is_active: boolean
          is_featured: boolean
          late_payment_fee_amount: number | null
          maximum_processing_fee: number | null
          maximum_transaction_amount: number | null
          merchant_name_ar: string | null
          merchant_name_en: string | null
          merchant_restricted: boolean
          minimum_installments_paid_before_settlement: number | null
          minimum_processing_fee: number | null
          minimum_transaction_amount: number | null
          monthly_profit_rate: number | null
          name_ar: string
          name_en: string
          plan_type: string
          priority: number
          processing_fee_amount: number | null
          processing_fee_percentage: number | null
          provider_name_ar: string | null
          provider_name_en: string | null
          slug: string
          source_url: string | null
          terms_ar: string | null
          terms_en: string | null
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          activation_deadline_days?: number | null
          activation_method?: string | null
          annual_percentage_rate?: number | null
          available_tenures: number[]
          card_id: string
          created_at?: string
          currency_id: string
          description_ar?: string | null
          description_en?: string | null
          early_settlement_fee_amount?: number | null
          early_settlement_fee_percentage?: number | null
          eligible_merchant_categories?: Json | null
          eligible_transaction_channels?: Json | null
          excluded_merchant_categories?: Json | null
          flat_profit_rate?: number | null
          id?: string
          interest_free?: boolean
          is_active?: boolean
          is_featured?: boolean
          late_payment_fee_amount?: number | null
          maximum_processing_fee?: number | null
          maximum_transaction_amount?: number | null
          merchant_name_ar?: string | null
          merchant_name_en?: string | null
          merchant_restricted?: boolean
          minimum_installments_paid_before_settlement?: number | null
          minimum_processing_fee?: number | null
          minimum_transaction_amount?: number | null
          monthly_profit_rate?: number | null
          name_ar: string
          name_en: string
          plan_type: string
          priority?: number
          processing_fee_amount?: number | null
          processing_fee_percentage?: number | null
          provider_name_ar?: string | null
          provider_name_en?: string | null
          slug: string
          source_url?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          activation_deadline_days?: number | null
          activation_method?: string | null
          annual_percentage_rate?: number | null
          available_tenures?: number[]
          card_id?: string
          created_at?: string
          currency_id?: string
          description_ar?: string | null
          description_en?: string | null
          early_settlement_fee_amount?: number | null
          early_settlement_fee_percentage?: number | null
          eligible_merchant_categories?: Json | null
          eligible_transaction_channels?: Json | null
          excluded_merchant_categories?: Json | null
          flat_profit_rate?: number | null
          id?: string
          interest_free?: boolean
          is_active?: boolean
          is_featured?: boolean
          late_payment_fee_amount?: number | null
          maximum_processing_fee?: number | null
          maximum_transaction_amount?: number | null
          merchant_name_ar?: string | null
          merchant_name_en?: string | null
          merchant_restricted?: boolean
          minimum_installments_paid_before_settlement?: number | null
          minimum_processing_fee?: number | null
          minimum_transaction_amount?: number | null
          monthly_profit_rate?: number | null
          name_ar?: string
          name_en?: string
          plan_type?: string
          priority?: number
          processing_fee_amount?: number | null
          processing_fee_percentage?: number | null
          provider_name_ar?: string | null
          provider_name_en?: string | null
          slug?: string
          source_url?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_installment_plans_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_installment_plans_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_insurance_benefits: {
        Row: {
          activation_required: boolean
          card_id: string
          claim_limit: number | null
          coverage_amount: number | null
          coverage_period_days: number | null
          created_at: string
          currency_id: string | null
          deductible_amount: number | null
          description_ar: string | null
          description_en: string | null
          id: string
          insurance_type: string
          is_active: boolean
          maximum_trip_duration_days: number | null
          minimum_trip_duration_days: number | null
          name_ar: string
          name_en: string
          priority: number
          provider_name_ar: string | null
          provider_name_en: string | null
          terms_ar: string | null
          terms_en: string | null
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          activation_required?: boolean
          card_id: string
          claim_limit?: number | null
          coverage_amount?: number | null
          coverage_period_days?: number | null
          created_at?: string
          currency_id?: string | null
          deductible_amount?: number | null
          description_ar?: string | null
          description_en?: string | null
          id?: string
          insurance_type: string
          is_active?: boolean
          maximum_trip_duration_days?: number | null
          minimum_trip_duration_days?: number | null
          name_ar: string
          name_en: string
          priority?: number
          provider_name_ar?: string | null
          provider_name_en?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          activation_required?: boolean
          card_id?: string
          claim_limit?: number | null
          coverage_amount?: number | null
          coverage_period_days?: number | null
          created_at?: string
          currency_id?: string | null
          deductible_amount?: number | null
          description_ar?: string | null
          description_en?: string | null
          id?: string
          insurance_type?: string
          is_active?: boolean
          maximum_trip_duration_days?: number | null
          minimum_trip_duration_days?: number | null
          name_ar?: string
          name_en?: string
          priority?: number
          provider_name_ar?: string | null
          provider_name_en?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_insurance_benefits_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_insurance_benefits_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_lounge_benefits: {
        Row: {
          access_scope: string
          access_type: string
          activation_required: boolean
          additional_visit_fee: number | null
          advance_booking_required: boolean
          card_id: string
          complimentary_guest_visits_per_period: number | null
          complimentary_visits_per_period: number | null
          created_at: string
          currency_id: string | null
          digital_membership_required: boolean
          eligible_cardholder_type: string
          excluded_airports: Json | null
          guest_access_type: string
          guest_visit_fee: number | null
          id: string
          is_active: boolean
          minimum_spend_currency_id: string | null
          minimum_spend_period: string | null
          minimum_spend_required: number | null
          priority: number
          program_name_ar: string | null
          program_name_en: string | null
          provider_name_ar: string | null
          provider_name_en: string | null
          registration_required: boolean
          slug: string
          source_url: string | null
          supported_airports: Json | null
          supported_countries: Json | null
          terms_ar: string | null
          terms_en: string | null
          updated_at: string
          valid_from: string | null
          valid_to: string | null
          visit_period: string | null
        }
        Insert: {
          access_scope?: string
          access_type: string
          activation_required?: boolean
          additional_visit_fee?: number | null
          advance_booking_required?: boolean
          card_id: string
          complimentary_guest_visits_per_period?: number | null
          complimentary_visits_per_period?: number | null
          created_at?: string
          currency_id?: string | null
          digital_membership_required?: boolean
          eligible_cardholder_type?: string
          excluded_airports?: Json | null
          guest_access_type?: string
          guest_visit_fee?: number | null
          id?: string
          is_active?: boolean
          minimum_spend_currency_id?: string | null
          minimum_spend_period?: string | null
          minimum_spend_required?: number | null
          priority?: number
          program_name_ar?: string | null
          program_name_en?: string | null
          provider_name_ar?: string | null
          provider_name_en?: string | null
          registration_required?: boolean
          slug: string
          source_url?: string | null
          supported_airports?: Json | null
          supported_countries?: Json | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
          visit_period?: string | null
        }
        Update: {
          access_scope?: string
          access_type?: string
          activation_required?: boolean
          additional_visit_fee?: number | null
          advance_booking_required?: boolean
          card_id?: string
          complimentary_guest_visits_per_period?: number | null
          complimentary_visits_per_period?: number | null
          created_at?: string
          currency_id?: string | null
          digital_membership_required?: boolean
          eligible_cardholder_type?: string
          excluded_airports?: Json | null
          guest_access_type?: string
          guest_visit_fee?: number | null
          id?: string
          is_active?: boolean
          minimum_spend_currency_id?: string | null
          minimum_spend_period?: string | null
          minimum_spend_required?: number | null
          priority?: number
          program_name_ar?: string | null
          program_name_en?: string | null
          provider_name_ar?: string | null
          provider_name_en?: string | null
          registration_required?: boolean
          slug?: string
          source_url?: string | null
          supported_airports?: Json | null
          supported_countries?: Json | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
          visit_period?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_lounge_benefits_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_lounge_benefits_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_lounge_benefits_minimum_spend_currency_id_fkey"
            columns: ["minimum_spend_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_network_benefits: {
        Row: {
          activation_required: boolean
          benefit_category: string
          benefit_name_ar: string
          benefit_name_en: string
          card_id: string
          created_at: string
          description_ar: string | null
          description_en: string | null
          id: string
          is_active: boolean
          is_featured: boolean
          mobile_app_required: boolean
          network: Database["public"]["Enums"]["payment_network"]
          priority: number
          provider_name: string | null
          registration_required: boolean
          slug: string
          updated_at: string
          valid_from: string | null
          valid_to: string | null
          website_url: string | null
        }
        Insert: {
          activation_required?: boolean
          benefit_category: string
          benefit_name_ar: string
          benefit_name_en: string
          card_id: string
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          is_featured?: boolean
          mobile_app_required?: boolean
          network: Database["public"]["Enums"]["payment_network"]
          priority?: number
          provider_name?: string | null
          registration_required?: boolean
          slug: string
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
          website_url?: string | null
        }
        Update: {
          activation_required?: boolean
          benefit_category?: string
          benefit_name_ar?: string
          benefit_name_en?: string
          card_id?: string
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          is_featured?: boolean
          mobile_app_required?: boolean
          network?: Database["public"]["Enums"]["payment_network"]
          priority?: number
          provider_name?: string | null
          registration_required?: boolean
          slug?: string
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
          website_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_network_benefits_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
        ]
      }
      card_networks: {
        Row: {
          created_at: string
          id: string
          is_active: boolean
          logo_url: string | null
          name_ar: string
          name_en: string
          slug: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_active?: boolean
          logo_url?: string | null
          name_ar: string
          name_en: string
          slug: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          is_active?: boolean
          logo_url?: string | null
          name_ar?: string
          name_en?: string
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      card_offers: {
        Row: {
          applicable_channels: Json | null
          applicable_days: number[] | null
          bonus_points: number | null
          card_id: string
          created_at: string
          currency_id: string | null
          description_ar: string | null
          description_en: string | null
          fixed_amount: number | null
          id: string
          installment_months: number | null
          is_active: boolean
          is_featured: boolean
          maximum_discount_amount: number | null
          merchant_name_ar: string | null
          merchant_name_en: string | null
          merchant_website_url: string | null
          minimum_spend: number | null
          name_ar: string
          name_en: string
          offer_type: string
          percentage_value: number | null
          priority: number
          promo_code: string | null
          slug: string
          source_url: string | null
          terms_ar: string | null
          terms_en: string | null
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          applicable_channels?: Json | null
          applicable_days?: number[] | null
          bonus_points?: number | null
          card_id: string
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          fixed_amount?: number | null
          id?: string
          installment_months?: number | null
          is_active?: boolean
          is_featured?: boolean
          maximum_discount_amount?: number | null
          merchant_name_ar?: string | null
          merchant_name_en?: string | null
          merchant_website_url?: string | null
          minimum_spend?: number | null
          name_ar: string
          name_en: string
          offer_type: string
          percentage_value?: number | null
          priority?: number
          promo_code?: string | null
          slug: string
          source_url?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          applicable_channels?: Json | null
          applicable_days?: number[] | null
          bonus_points?: number | null
          card_id?: string
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          fixed_amount?: number | null
          id?: string
          installment_months?: number | null
          is_active?: boolean
          is_featured?: boolean
          maximum_discount_amount?: number | null
          merchant_name_ar?: string | null
          merchant_name_en?: string | null
          merchant_website_url?: string | null
          minimum_spend?: number | null
          name_ar?: string
          name_en?: string
          offer_type?: string
          percentage_value?: number | null
          priority?: number
          promo_code?: string | null
          slug?: string
          source_url?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_offers_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_offers_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_travel_benefits: {
        Row: {
          activation_required: boolean
          benefit_type: string
          benefit_value: number | null
          booking_url: string | null
          card_id: string
          complimentary_uses: number | null
          created_at: string
          currency_id: string | null
          description_ar: string | null
          description_en: string | null
          id: string
          is_active: boolean
          is_featured: boolean
          name_ar: string
          name_en: string
          priority: number
          promo_code: string | null
          provider_name_ar: string | null
          provider_name_en: string | null
          registration_required: boolean
          slug: string
          source_url: string | null
          terms_ar: string | null
          terms_en: string | null
          updated_at: string
          usage_period: string | null
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          activation_required?: boolean
          benefit_type: string
          benefit_value?: number | null
          booking_url?: string | null
          card_id: string
          complimentary_uses?: number | null
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          is_featured?: boolean
          name_ar: string
          name_en: string
          priority?: number
          promo_code?: string | null
          provider_name_ar?: string | null
          provider_name_en?: string | null
          registration_required?: boolean
          slug: string
          source_url?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          usage_period?: string | null
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          activation_required?: boolean
          benefit_type?: string
          benefit_value?: number | null
          booking_url?: string | null
          card_id?: string
          complimentary_uses?: number | null
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          is_featured?: boolean
          name_ar?: string
          name_en?: string
          priority?: number
          promo_code?: string | null
          provider_name_ar?: string | null
          provider_name_en?: string | null
          registration_required?: boolean
          slug?: string
          source_url?: string | null
          terms_ar?: string | null
          terms_en?: string | null
          updated_at?: string
          usage_period?: string | null
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "card_travel_benefits_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_travel_benefits_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      card_value_simulation_components: {
        Row: {
          adjusted_value: number
          assumptions: Json
          calculation_details: Json
          calculation_formula: string | null
          cap_amount: number | null
          cap_impact: number
          component_code: string
          component_name_ar: string | null
          component_name_en: string
          component_type: Database["public"]["Enums"]["value_simulation_component_type"]
          confidence_score: number | null
          created_at: string
          description_ar: string | null
          description_en: string | null
          direction: Database["public"]["Enums"]["value_component_direction"]
          eligible_spending_amount: number | null
          estimated_component: boolean
          excluded_spending_amount: number | null
          gross_value: number
          id: string
          is_active: boolean
          minimum_spend_achieved: boolean | null
          minimum_spend_required: number | null
          one_time_component: boolean
          priority: number
          recurring_component: boolean
          reward_quantity: number | null
          reward_rate: number | null
          reward_unit: string | null
          simulation_id: string
          source_record_id: string | null
          source_table: string | null
          spending_amount: number | null
          spending_category_code: string | null
          taxable_component: boolean
          unit_value: number | null
          updated_at: string
          utilization_rate: number | null
          warnings: Json
        }
        Insert: {
          adjusted_value?: number
          assumptions?: Json
          calculation_details?: Json
          calculation_formula?: string | null
          cap_amount?: number | null
          cap_impact?: number
          component_code: string
          component_name_ar?: string | null
          component_name_en: string
          component_type: Database["public"]["Enums"]["value_simulation_component_type"]
          confidence_score?: number | null
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          direction: Database["public"]["Enums"]["value_component_direction"]
          eligible_spending_amount?: number | null
          estimated_component?: boolean
          excluded_spending_amount?: number | null
          gross_value?: number
          id?: string
          is_active?: boolean
          minimum_spend_achieved?: boolean | null
          minimum_spend_required?: number | null
          one_time_component?: boolean
          priority?: number
          recurring_component?: boolean
          reward_quantity?: number | null
          reward_rate?: number | null
          reward_unit?: string | null
          simulation_id: string
          source_record_id?: string | null
          source_table?: string | null
          spending_amount?: number | null
          spending_category_code?: string | null
          taxable_component?: boolean
          unit_value?: number | null
          updated_at?: string
          utilization_rate?: number | null
          warnings?: Json
        }
        Update: {
          adjusted_value?: number
          assumptions?: Json
          calculation_details?: Json
          calculation_formula?: string | null
          cap_amount?: number | null
          cap_impact?: number
          component_code?: string
          component_name_ar?: string | null
          component_name_en?: string
          component_type?: Database["public"]["Enums"]["value_simulation_component_type"]
          confidence_score?: number | null
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          direction?: Database["public"]["Enums"]["value_component_direction"]
          eligible_spending_amount?: number | null
          estimated_component?: boolean
          excluded_spending_amount?: number | null
          gross_value?: number
          id?: string
          is_active?: boolean
          minimum_spend_achieved?: boolean | null
          minimum_spend_required?: number | null
          one_time_component?: boolean
          priority?: number
          recurring_component?: boolean
          reward_quantity?: number | null
          reward_rate?: number | null
          reward_unit?: string | null
          simulation_id?: string
          source_record_id?: string | null
          source_table?: string | null
          spending_amount?: number | null
          spending_category_code?: string | null
          taxable_component?: boolean
          unit_value?: number | null
          updated_at?: string
          utilization_rate?: number | null
          warnings?: Json
        }
        Relationships: [
          {
            foreignKeyName: "card_value_simulation_components_simulation_id_fkey"
            columns: ["simulation_id"]
            isOneToOne: false
            referencedRelation: "card_value_simulations"
            referencedColumns: ["id"]
          },
        ]
      }
      card_value_simulations: {
        Row: {
          annual_fee_cost: number
          assumptions: Json
          base_reward_value: number
          benefit_utilization_rate: number | null
          bonus_reward_value: number
          break_even_spend: number | null
          calculated_at: string
          card_id: string
          cash_advance_fee_cost: number
          cashback_value: number
          confidence_level: Database["public"]["Enums"]["recommendation_confidence_level"]
          confidence_score: number | null
          created_at: string
          currency_id: string
          dining_benefit_value: number
          effective_net_value_rate: number | null
          effective_reward_rate: number | null
          eligibility_assessment_id: string | null
          eligible_reward_spend: number | null
          excluded_reward_spend: number | null
          expected_spend: number | null
          expires_at: string | null
          financial_profile_id: string
          financing_cost: number
          foreign_transaction_fee_cost: number
          gross_reward_value: number
          id: string
          input_snapshot: Json
          installment_benefit_value: number
          insurance_benefit_value: number
          is_current: boolean
          lounge_value: number
          merchant_offer_value: number
          metadata: Json
          miles_value: number
          minimum_spend_shortfall: number
          net_value: number
          network_benefit_value: number
          opportunity_cost: number
          other_benefit_value: number
          other_cost_value: number
          period_end: string | null
          period_start: string | null
          points_value: number
          preference_profile_id: string | null
          product_snapshot: Json
          reward_cap_impact: number
          reward_redemption_cost: number
          reward_utilization_rate: number | null
          simulation_method: string
          simulation_name: string | null
          simulation_period: string
          simulation_status: string
          simulation_version: string
          spending_profile_id: string | null
          supplementary_card_fee_cost: number
          total_benefit_value: number
          total_cost_value: number
          travel_benefit_value: number
          updated_at: string
          warnings: Json
          welcome_bonus_value: number
        }
        Insert: {
          annual_fee_cost?: number
          assumptions?: Json
          base_reward_value?: number
          benefit_utilization_rate?: number | null
          bonus_reward_value?: number
          break_even_spend?: number | null
          calculated_at?: string
          card_id: string
          cash_advance_fee_cost?: number
          cashback_value?: number
          confidence_level?: Database["public"]["Enums"]["recommendation_confidence_level"]
          confidence_score?: number | null
          created_at?: string
          currency_id: string
          dining_benefit_value?: number
          effective_net_value_rate?: number | null
          effective_reward_rate?: number | null
          eligibility_assessment_id?: string | null
          eligible_reward_spend?: number | null
          excluded_reward_spend?: number | null
          expected_spend?: number | null
          expires_at?: string | null
          financial_profile_id: string
          financing_cost?: number
          foreign_transaction_fee_cost?: number
          gross_reward_value?: number
          id?: string
          input_snapshot?: Json
          installment_benefit_value?: number
          insurance_benefit_value?: number
          is_current?: boolean
          lounge_value?: number
          merchant_offer_value?: number
          metadata?: Json
          miles_value?: number
          minimum_spend_shortfall?: number
          net_value?: number
          network_benefit_value?: number
          opportunity_cost?: number
          other_benefit_value?: number
          other_cost_value?: number
          period_end?: string | null
          period_start?: string | null
          points_value?: number
          preference_profile_id?: string | null
          product_snapshot?: Json
          reward_cap_impact?: number
          reward_redemption_cost?: number
          reward_utilization_rate?: number | null
          simulation_method?: string
          simulation_name?: string | null
          simulation_period?: string
          simulation_status?: string
          simulation_version?: string
          spending_profile_id?: string | null
          supplementary_card_fee_cost?: number
          total_benefit_value?: number
          total_cost_value?: number
          travel_benefit_value?: number
          updated_at?: string
          warnings?: Json
          welcome_bonus_value?: number
        }
        Update: {
          annual_fee_cost?: number
          assumptions?: Json
          base_reward_value?: number
          benefit_utilization_rate?: number | null
          bonus_reward_value?: number
          break_even_spend?: number | null
          calculated_at?: string
          card_id?: string
          cash_advance_fee_cost?: number
          cashback_value?: number
          confidence_level?: Database["public"]["Enums"]["recommendation_confidence_level"]
          confidence_score?: number | null
          created_at?: string
          currency_id?: string
          dining_benefit_value?: number
          effective_net_value_rate?: number | null
          effective_reward_rate?: number | null
          eligibility_assessment_id?: string | null
          eligible_reward_spend?: number | null
          excluded_reward_spend?: number | null
          expected_spend?: number | null
          expires_at?: string | null
          financial_profile_id?: string
          financing_cost?: number
          foreign_transaction_fee_cost?: number
          gross_reward_value?: number
          id?: string
          input_snapshot?: Json
          installment_benefit_value?: number
          insurance_benefit_value?: number
          is_current?: boolean
          lounge_value?: number
          merchant_offer_value?: number
          metadata?: Json
          miles_value?: number
          minimum_spend_shortfall?: number
          net_value?: number
          network_benefit_value?: number
          opportunity_cost?: number
          other_benefit_value?: number
          other_cost_value?: number
          period_end?: string | null
          period_start?: string | null
          points_value?: number
          preference_profile_id?: string | null
          product_snapshot?: Json
          reward_cap_impact?: number
          reward_redemption_cost?: number
          reward_utilization_rate?: number | null
          simulation_method?: string
          simulation_name?: string | null
          simulation_period?: string
          simulation_status?: string
          simulation_version?: string
          spending_profile_id?: string | null
          supplementary_card_fee_cost?: number
          total_benefit_value?: number
          total_cost_value?: number
          travel_benefit_value?: number
          updated_at?: string
          warnings?: Json
          welcome_bonus_value?: number
        }
        Relationships: [
          {
            foreignKeyName: "card_value_simulations_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_value_simulations_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_value_simulations_eligibility_assessment_id_fkey"
            columns: ["eligibility_assessment_id"]
            isOneToOne: false
            referencedRelation: "eligibility_assessments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_value_simulations_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_value_simulations_preference_profile_id_fkey"
            columns: ["preference_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_preference_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "card_value_simulations_spending_profile_id_fkey"
            columns: ["spending_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_spending_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      cards: {
        Row: {
          annual_fee: number
          application_url: string | null
          availability_status: Database["public"]["Enums"]["card_availability_status"]
          bank_id: string
          card_network_id: string
          card_tier: string | null
          cash_advance_rate: number | null
          created_at: string
          credit_limit_max: number | null
          credit_limit_min: number | null
          currency_id: string
          description_ar: string | null
          description_en: string | null
          foreign_transaction_fee_rate: number | null
          id: string
          image_url: string | null
          is_active: boolean
          is_featured: boolean
          loyalty_program_id: string | null
          minimum_salary: number | null
          name_ar: string
          name_en: string
          published_at: string | null
          purchase_rate: number | null
          slug: string
          target_user: Database["public"]["Enums"]["target_user_type"]
          terms_url: string | null
          updated_at: string
        }
        Insert: {
          annual_fee?: number
          application_url?: string | null
          availability_status?: Database["public"]["Enums"]["card_availability_status"]
          bank_id: string
          card_network_id: string
          card_tier?: string | null
          cash_advance_rate?: number | null
          created_at?: string
          credit_limit_max?: number | null
          credit_limit_min?: number | null
          currency_id: string
          description_ar?: string | null
          description_en?: string | null
          foreign_transaction_fee_rate?: number | null
          id?: string
          image_url?: string | null
          is_active?: boolean
          is_featured?: boolean
          loyalty_program_id?: string | null
          minimum_salary?: number | null
          name_ar: string
          name_en: string
          published_at?: string | null
          purchase_rate?: number | null
          slug: string
          target_user?: Database["public"]["Enums"]["target_user_type"]
          terms_url?: string | null
          updated_at?: string
        }
        Update: {
          annual_fee?: number
          application_url?: string | null
          availability_status?: Database["public"]["Enums"]["card_availability_status"]
          bank_id?: string
          card_network_id?: string
          card_tier?: string | null
          cash_advance_rate?: number | null
          created_at?: string
          credit_limit_max?: number | null
          credit_limit_min?: number | null
          currency_id?: string
          description_ar?: string | null
          description_en?: string | null
          foreign_transaction_fee_rate?: number | null
          id?: string
          image_url?: string | null
          is_active?: boolean
          is_featured?: boolean
          loyalty_program_id?: string | null
          minimum_salary?: number | null
          name_ar?: string
          name_en?: string
          published_at?: string | null
          purchase_rate?: number | null
          slug?: string
          target_user?: Database["public"]["Enums"]["target_user_type"]
          terms_url?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "cards_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cards_card_network_id_fkey"
            columns: ["card_network_id"]
            isOneToOne: false
            referencedRelation: "card_networks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cards_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cards_loyalty_program_id_fkey"
            columns: ["loyalty_program_id"]
            isOneToOne: false
            referencedRelation: "loyalty_programs"
            referencedColumns: ["id"]
          },
        ]
      }
      catalog_administrator_scope_assignments: {
        Row: {
          assigned_at: string
          assigned_by_user_id: string | null
          assignment_reason: string
          assignment_reference: string | null
          bank_id: string | null
          created_at: string
          id: string
          revocation_reason: string | null
          revoked_at: string | null
          revoked_by_user_id: string | null
          role_assignment_id: string
          scope_type: string
          updated_at: string
          valid_from: string
          valid_until: string | null
        }
        Insert: {
          assigned_at?: string
          assigned_by_user_id?: string | null
          assignment_reason: string
          assignment_reference?: string | null
          bank_id?: string | null
          created_at?: string
          id?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          role_assignment_id: string
          scope_type: string
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
        }
        Update: {
          assigned_at?: string
          assigned_by_user_id?: string | null
          assignment_reason?: string
          assignment_reference?: string | null
          bank_id?: string | null
          created_at?: string
          id?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          role_assignment_id?: string
          scope_type?: string
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "catalog_administrator_scope_assignments_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_administrator_scope_assignments_role_assignment_id_fkey"
            columns: ["role_assignment_id"]
            isOneToOne: false
            referencedRelation: "user_platform_role_assignments"
            referencedColumns: ["id"]
          },
        ]
      }
      catalog_publication_events: {
        Row: {
          actor_user_id: string | null
          created_at: string
          event_comment: string | null
          event_details: Json
          event_sequence: number
          event_type: string
          from_status: string | null
          id: string
          occurred_at: string
          publication_request_id: string | null
          publication_version_id: string
          to_status: string | null
        }
        Insert: {
          actor_user_id?: string | null
          created_at?: string
          event_comment?: string | null
          event_details?: Json
          event_sequence?: never
          event_type: string
          from_status?: string | null
          id?: string
          occurred_at?: string
          publication_request_id?: string | null
          publication_version_id: string
          to_status?: string | null
        }
        Update: {
          actor_user_id?: string | null
          created_at?: string
          event_comment?: string | null
          event_details?: Json
          event_sequence?: never
          event_type?: string
          from_status?: string | null
          id?: string
          occurred_at?: string
          publication_request_id?: string | null
          publication_version_id?: string
          to_status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "catalog_publication_events_publication_request_id_fkey"
            columns: ["publication_request_id"]
            isOneToOne: false
            referencedRelation: "catalog_publication_requests"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_events_publication_version_id_fkey"
            columns: ["publication_version_id"]
            isOneToOne: false
            referencedRelation: "catalog_publication_versions"
            referencedColumns: ["id"]
          },
        ]
      }
      catalog_publication_requests: {
        Row: {
          approval_request_id: string
          created_at: string
          decided_at: string | null
          decision_comments: string | null
          final_approver_user_id: string
          id: string
          publication_version_id: string
          request_status: string
          requester_user_id: string
          reviewer_user_id: string
          submitted_at: string
          updated_at: string
        }
        Insert: {
          approval_request_id: string
          created_at?: string
          decided_at?: string | null
          decision_comments?: string | null
          final_approver_user_id: string
          id?: string
          publication_version_id: string
          request_status?: string
          requester_user_id: string
          reviewer_user_id: string
          submitted_at?: string
          updated_at?: string
        }
        Update: {
          approval_request_id?: string
          created_at?: string
          decided_at?: string | null
          decision_comments?: string | null
          final_approver_user_id?: string
          id?: string
          publication_version_id?: string
          request_status?: string
          requester_user_id?: string
          reviewer_user_id?: string
          submitted_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "catalog_publication_requests_approval_request_id_fkey"
            columns: ["approval_request_id"]
            isOneToOne: true
            referencedRelation: "approval_requests"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_requests_publication_version_id_fkey"
            columns: ["publication_version_id"]
            isOneToOne: true
            referencedRelation: "catalog_publication_versions"
            referencedColumns: ["id"]
          },
        ]
      }
      catalog_publication_versions: {
        Row: {
          archived_at: string | null
          bank_id: string | null
          card_benefit_id: string | null
          card_eligibility_requirement_id: string | null
          card_fee_id: string | null
          card_id: string | null
          change_summary: string
          content_snapshot: Json
          created_at: string
          created_by_user_id: string | null
          effective_from: string | null
          effective_until: string | null
          id: string
          lifecycle_status: string
          loyalty_program_id: string | null
          merchant_id: string | null
          published_at: string | null
          rejected_at: string | null
          rejection_reason: string | null
          reward_rule_id: string | null
          rollback_of_version_id: string | null
          scheduled_publish_at: string | null
          scheduled_unpublish_at: string | null
          source_provenance_id: string | null
          supersedes_version_id: string | null
          suspended_at: string | null
          suspension_reason: string | null
          target_entity_id: string | null
          target_entity_type: string
          unpublished_at: string | null
          updated_at: string
          version_number: number
        }
        Insert: {
          archived_at?: string | null
          bank_id?: string | null
          card_benefit_id?: string | null
          card_eligibility_requirement_id?: string | null
          card_fee_id?: string | null
          card_id?: string | null
          change_summary: string
          content_snapshot: Json
          created_at?: string
          created_by_user_id?: string | null
          effective_from?: string | null
          effective_until?: string | null
          id?: string
          lifecycle_status?: string
          loyalty_program_id?: string | null
          merchant_id?: string | null
          published_at?: string | null
          rejected_at?: string | null
          rejection_reason?: string | null
          reward_rule_id?: string | null
          rollback_of_version_id?: string | null
          scheduled_publish_at?: string | null
          scheduled_unpublish_at?: string | null
          source_provenance_id?: string | null
          supersedes_version_id?: string | null
          suspended_at?: string | null
          suspension_reason?: string | null
          target_entity_id?: string | null
          target_entity_type: string
          unpublished_at?: string | null
          updated_at?: string
          version_number: number
        }
        Update: {
          archived_at?: string | null
          bank_id?: string | null
          card_benefit_id?: string | null
          card_eligibility_requirement_id?: string | null
          card_fee_id?: string | null
          card_id?: string | null
          change_summary?: string
          content_snapshot?: Json
          created_at?: string
          created_by_user_id?: string | null
          effective_from?: string | null
          effective_until?: string | null
          id?: string
          lifecycle_status?: string
          loyalty_program_id?: string | null
          merchant_id?: string | null
          published_at?: string | null
          rejected_at?: string | null
          rejection_reason?: string | null
          reward_rule_id?: string | null
          rollback_of_version_id?: string | null
          scheduled_publish_at?: string | null
          scheduled_unpublish_at?: string | null
          source_provenance_id?: string | null
          supersedes_version_id?: string | null
          suspended_at?: string | null
          suspension_reason?: string | null
          target_entity_id?: string | null
          target_entity_type?: string
          unpublished_at?: string | null
          updated_at?: string
          version_number?: number
        }
        Relationships: [
          {
            foreignKeyName: "catalog_publication_versions_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_card_benefit_id_fkey"
            columns: ["card_benefit_id"]
            isOneToOne: false
            referencedRelation: "card_benefits"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_card_eligibility_requirement__fkey"
            columns: ["card_eligibility_requirement_id"]
            isOneToOne: false
            referencedRelation: "card_eligibility_requirements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_card_fee_id_fkey"
            columns: ["card_fee_id"]
            isOneToOne: false
            referencedRelation: "card_fees"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_loyalty_program_id_fkey"
            columns: ["loyalty_program_id"]
            isOneToOne: false
            referencedRelation: "loyalty_programs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_merchant_id_fkey"
            columns: ["merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_reward_rule_id_fkey"
            columns: ["reward_rule_id"]
            isOneToOne: false
            referencedRelation: "reward_rules"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_rollback_of_version_id_fkey"
            columns: ["rollback_of_version_id"]
            isOneToOne: false
            referencedRelation: "catalog_publication_versions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_source_provenance_id_fkey"
            columns: ["source_provenance_id"]
            isOneToOne: false
            referencedRelation: "catalog_source_provenance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_publication_versions_supersedes_version_id_fkey"
            columns: ["supersedes_version_id"]
            isOneToOne: false
            referencedRelation: "catalog_publication_versions"
            referencedColumns: ["id"]
          },
        ]
      }
      catalog_source_provenance: {
        Row: {
          archived_at: string | null
          archived_by_user_id: string | null
          authority_level: string
          bank_id: string | null
          card_benefit_id: string | null
          card_eligibility_requirement_id: string | null
          card_fee_id: string | null
          card_id: string | null
          content_hash: string | null
          created_at: string
          created_by_user_id: string | null
          effective_from: string | null
          effective_until: string | null
          id: string
          lifecycle_status: string
          loyalty_program_id: string | null
          merchant_id: string | null
          metadata: Json
          notes: string | null
          rejected_at: string | null
          rejected_by_user_id: string | null
          rejection_reason: string | null
          retrieved_at: string
          reward_rule_id: string | null
          source_locator: string
          source_locator_type: string
          source_owner: string
          source_title: string
          source_type: string
          source_version: string | null
          superseded_at: string | null
          superseded_by_provenance_id: string | null
          target_entity_id: string | null
          target_entity_type: string
          updated_at: string
          updated_by_user_id: string | null
          verification_status: string
          verified_at: string | null
          verified_by_user_id: string | null
        }
        Insert: {
          archived_at?: string | null
          archived_by_user_id?: string | null
          authority_level: string
          bank_id?: string | null
          card_benefit_id?: string | null
          card_eligibility_requirement_id?: string | null
          card_fee_id?: string | null
          card_id?: string | null
          content_hash?: string | null
          created_at?: string
          created_by_user_id?: string | null
          effective_from?: string | null
          effective_until?: string | null
          id?: string
          lifecycle_status?: string
          loyalty_program_id?: string | null
          merchant_id?: string | null
          metadata?: Json
          notes?: string | null
          rejected_at?: string | null
          rejected_by_user_id?: string | null
          rejection_reason?: string | null
          retrieved_at?: string
          reward_rule_id?: string | null
          source_locator: string
          source_locator_type?: string
          source_owner: string
          source_title: string
          source_type: string
          source_version?: string | null
          superseded_at?: string | null
          superseded_by_provenance_id?: string | null
          target_entity_id?: string | null
          target_entity_type: string
          updated_at?: string
          updated_by_user_id?: string | null
          verification_status?: string
          verified_at?: string | null
          verified_by_user_id?: string | null
        }
        Update: {
          archived_at?: string | null
          archived_by_user_id?: string | null
          authority_level?: string
          bank_id?: string | null
          card_benefit_id?: string | null
          card_eligibility_requirement_id?: string | null
          card_fee_id?: string | null
          card_id?: string | null
          content_hash?: string | null
          created_at?: string
          created_by_user_id?: string | null
          effective_from?: string | null
          effective_until?: string | null
          id?: string
          lifecycle_status?: string
          loyalty_program_id?: string | null
          merchant_id?: string | null
          metadata?: Json
          notes?: string | null
          rejected_at?: string | null
          rejected_by_user_id?: string | null
          rejection_reason?: string | null
          retrieved_at?: string
          reward_rule_id?: string | null
          source_locator?: string
          source_locator_type?: string
          source_owner?: string
          source_title?: string
          source_type?: string
          source_version?: string | null
          superseded_at?: string | null
          superseded_by_provenance_id?: string | null
          target_entity_id?: string | null
          target_entity_type?: string
          updated_at?: string
          updated_by_user_id?: string | null
          verification_status?: string
          verified_at?: string | null
          verified_by_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "catalog_source_provenance_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_source_provenance_card_benefit_id_fkey"
            columns: ["card_benefit_id"]
            isOneToOne: false
            referencedRelation: "card_benefits"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_source_provenance_card_eligibility_requirement_id_fkey"
            columns: ["card_eligibility_requirement_id"]
            isOneToOne: false
            referencedRelation: "card_eligibility_requirements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_source_provenance_card_fee_id_fkey"
            columns: ["card_fee_id"]
            isOneToOne: false
            referencedRelation: "card_fees"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_source_provenance_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_source_provenance_loyalty_program_id_fkey"
            columns: ["loyalty_program_id"]
            isOneToOne: false
            referencedRelation: "loyalty_programs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_source_provenance_merchant_id_fkey"
            columns: ["merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_source_provenance_reward_rule_id_fkey"
            columns: ["reward_rule_id"]
            isOneToOne: false
            referencedRelation: "reward_rules"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "catalog_source_provenance_superseded_by_provenance_id_fkey"
            columns: ["superseded_by_provenance_id"]
            isOneToOne: false
            referencedRelation: "catalog_source_provenance"
            referencedColumns: ["id"]
          },
        ]
      }
      commission_accruals: {
        Row: {
          adjustment_amount: number
          adjustment_details: Json
          application_id: string | null
          approved_at: string | null
          attribution_id: string | null
          bank_commission_reference: string | null
          bank_confirmation_payload: Json
          bank_id: string
          calculation_details: Json
          card_id: string | null
          clawback_due_at: string | null
          clawed_back_at: string | null
          commission_amount_gross: number
          commission_amount_net: number
          commission_currency_id: string
          commission_rate: number | null
          commission_rate_type: string | null
          commission_reference: string
          commission_rule_id: string
          commission_status: string
          created_at: string
          dispute_resolved_at: string | null
          dispute_status: string
          disputed_at: string | null
          earned_at: string | null
          id: string
          invoiced_at: string | null
          metadata: Json
          paid_at: string | null
          partner_product_id: string | null
          partnership_id: string
          payable_at: string | null
          qualification_details: Json
          qualification_due_at: string | null
          qualification_status: string
          qualified_at: string | null
          qualifying_event_reference: string | null
          qualifying_event_type: string
          qualifying_value: number | null
          qualifying_value_currency_id: string | null
          rejected_at: string | null
          rejection_reason_code: string | null
          rejection_reason_text: string | null
          reversal_reason_code: string | null
          reversal_reason_text: string | null
          reversed_at: string | null
          settlement_reference: string | null
          tax_amount: number
          updated_at: string
          withholding_amount: number
        }
        Insert: {
          adjustment_amount?: number
          adjustment_details?: Json
          application_id?: string | null
          approved_at?: string | null
          attribution_id?: string | null
          bank_commission_reference?: string | null
          bank_confirmation_payload?: Json
          bank_id: string
          calculation_details?: Json
          card_id?: string | null
          clawback_due_at?: string | null
          clawed_back_at?: string | null
          commission_amount_gross?: number
          commission_amount_net?: number
          commission_currency_id: string
          commission_rate?: number | null
          commission_rate_type?: string | null
          commission_reference: string
          commission_rule_id: string
          commission_status?: string
          created_at?: string
          dispute_resolved_at?: string | null
          dispute_status?: string
          disputed_at?: string | null
          earned_at?: string | null
          id?: string
          invoiced_at?: string | null
          metadata?: Json
          paid_at?: string | null
          partner_product_id?: string | null
          partnership_id: string
          payable_at?: string | null
          qualification_details?: Json
          qualification_due_at?: string | null
          qualification_status?: string
          qualified_at?: string | null
          qualifying_event_reference?: string | null
          qualifying_event_type: string
          qualifying_value?: number | null
          qualifying_value_currency_id?: string | null
          rejected_at?: string | null
          rejection_reason_code?: string | null
          rejection_reason_text?: string | null
          reversal_reason_code?: string | null
          reversal_reason_text?: string | null
          reversed_at?: string | null
          settlement_reference?: string | null
          tax_amount?: number
          updated_at?: string
          withholding_amount?: number
        }
        Update: {
          adjustment_amount?: number
          adjustment_details?: Json
          application_id?: string | null
          approved_at?: string | null
          attribution_id?: string | null
          bank_commission_reference?: string | null
          bank_confirmation_payload?: Json
          bank_id?: string
          calculation_details?: Json
          card_id?: string | null
          clawback_due_at?: string | null
          clawed_back_at?: string | null
          commission_amount_gross?: number
          commission_amount_net?: number
          commission_currency_id?: string
          commission_rate?: number | null
          commission_rate_type?: string | null
          commission_reference?: string
          commission_rule_id?: string
          commission_status?: string
          created_at?: string
          dispute_resolved_at?: string | null
          dispute_status?: string
          disputed_at?: string | null
          earned_at?: string | null
          id?: string
          invoiced_at?: string | null
          metadata?: Json
          paid_at?: string | null
          partner_product_id?: string | null
          partnership_id?: string
          payable_at?: string | null
          qualification_details?: Json
          qualification_due_at?: string | null
          qualification_status?: string
          qualified_at?: string | null
          qualifying_event_reference?: string | null
          qualifying_event_type?: string
          qualifying_value?: number | null
          qualifying_value_currency_id?: string | null
          rejected_at?: string | null
          rejection_reason_code?: string | null
          rejection_reason_text?: string | null
          reversal_reason_code?: string | null
          reversal_reason_text?: string | null
          reversed_at?: string | null
          settlement_reference?: string | null
          tax_amount?: number
          updated_at?: string
          withholding_amount?: number
        }
        Relationships: [
          {
            foreignKeyName: "commission_accruals_application_id_fkey"
            columns: ["application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_accruals_attribution_id_fkey"
            columns: ["attribution_id"]
            isOneToOne: false
            referencedRelation: "referral_attributions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_accruals_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_accruals_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_accruals_commission_currency_id_fkey"
            columns: ["commission_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_accruals_commission_rule_id_fkey"
            columns: ["commission_rule_id"]
            isOneToOne: false
            referencedRelation: "commission_rules"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_accruals_partner_product_id_fkey"
            columns: ["partner_product_id"]
            isOneToOne: false
            referencedRelation: "bank_partner_products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_accruals_partnership_id_fkey"
            columns: ["partnership_id"]
            isOneToOne: false
            referencedRelation: "bank_partnerships"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_accruals_qualifying_value_currency_id_fkey"
            columns: ["qualifying_value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      commission_rules: {
        Row: {
          approval_required: boolean
          bank_id: string
          card_id: string | null
          clawback_configuration: Json
          clawback_window_days: number | null
          commission_amount: number | null
          commission_currency_id: string | null
          commission_model: string
          commission_percentage: number | null
          commission_rule_reference: string
          cooling_off_days: number
          created_at: string
          customer_activation_required: boolean
          first_transaction_required: boolean
          id: string
          maximum_commission_amount: number | null
          maximum_monthly_volume: number | null
          maximum_qualifying_value: number | null
          metadata: Json
          minimum_commission_amount: number | null
          minimum_first_transaction_amount: number | null
          minimum_first_transaction_currency_id: string | null
          minimum_monthly_volume: number | null
          minimum_qualifying_value: number | null
          partner_product_id: string | null
          partnership_id: string
          payment_delay_days: number
          percentage_basis: string | null
          qualification_configuration: Json
          qualifying_event: string
          rule_conditions: Json
          rule_name: string
          rule_status: string
          tax_rate_percentage: number | null
          tier_configuration: Json
          tier_sequence: number
          updated_at: string
          valid_from: string
          valid_until: string | null
          validation_window_days: number | null
          withholding_rate_percentage: number | null
        }
        Insert: {
          approval_required?: boolean
          bank_id: string
          card_id?: string | null
          clawback_configuration?: Json
          clawback_window_days?: number | null
          commission_amount?: number | null
          commission_currency_id?: string | null
          commission_model: string
          commission_percentage?: number | null
          commission_rule_reference: string
          cooling_off_days?: number
          created_at?: string
          customer_activation_required?: boolean
          first_transaction_required?: boolean
          id?: string
          maximum_commission_amount?: number | null
          maximum_monthly_volume?: number | null
          maximum_qualifying_value?: number | null
          metadata?: Json
          minimum_commission_amount?: number | null
          minimum_first_transaction_amount?: number | null
          minimum_first_transaction_currency_id?: string | null
          minimum_monthly_volume?: number | null
          minimum_qualifying_value?: number | null
          partner_product_id?: string | null
          partnership_id: string
          payment_delay_days?: number
          percentage_basis?: string | null
          qualification_configuration?: Json
          qualifying_event: string
          rule_conditions?: Json
          rule_name: string
          rule_status?: string
          tax_rate_percentage?: number | null
          tier_configuration?: Json
          tier_sequence?: number
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
          validation_window_days?: number | null
          withholding_rate_percentage?: number | null
        }
        Update: {
          approval_required?: boolean
          bank_id?: string
          card_id?: string | null
          clawback_configuration?: Json
          clawback_window_days?: number | null
          commission_amount?: number | null
          commission_currency_id?: string | null
          commission_model?: string
          commission_percentage?: number | null
          commission_rule_reference?: string
          cooling_off_days?: number
          created_at?: string
          customer_activation_required?: boolean
          first_transaction_required?: boolean
          id?: string
          maximum_commission_amount?: number | null
          maximum_monthly_volume?: number | null
          maximum_qualifying_value?: number | null
          metadata?: Json
          minimum_commission_amount?: number | null
          minimum_first_transaction_amount?: number | null
          minimum_first_transaction_currency_id?: string | null
          minimum_monthly_volume?: number | null
          minimum_qualifying_value?: number | null
          partner_product_id?: string | null
          partnership_id?: string
          payment_delay_days?: number
          percentage_basis?: string | null
          qualification_configuration?: Json
          qualifying_event?: string
          rule_conditions?: Json
          rule_name?: string
          rule_status?: string
          tax_rate_percentage?: number | null
          tier_configuration?: Json
          tier_sequence?: number
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
          validation_window_days?: number | null
          withholding_rate_percentage?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "commission_rules_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_rules_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_rules_commission_currency_id_fkey"
            columns: ["commission_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_rules_minimum_first_transaction_currency_id_fkey"
            columns: ["minimum_first_transaction_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_rules_partner_product_id_fkey"
            columns: ["partner_product_id"]
            isOneToOne: false
            referencedRelation: "bank_partner_products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_rules_partnership_id_fkey"
            columns: ["partnership_id"]
            isOneToOne: false
            referencedRelation: "bank_partnerships"
            referencedColumns: ["id"]
          },
        ]
      }
      commission_settlement_items: {
        Row: {
          adjustment_amount: number
          bank_confirmed_amount: number | null
          bank_response_details: Json
          clawback_amount: number
          commission_accrual_id: string
          confirmed_at: string | null
          created_at: string
          currency_id: string
          difference_amount: number | null
          difference_reason_code: string | null
          difference_reason_text: string | null
          disputed_at: string | null
          gross_amount: number
          id: string
          included_at: string
          item_details: Json
          item_status: string
          metadata: Json
          net_amount: number
          rejected_at: string | null
          resolved_at: string | null
          settlement_id: string
          settlement_item_reference: string
          tax_amount: number
          updated_at: string
          withholding_amount: number
        }
        Insert: {
          adjustment_amount?: number
          bank_confirmed_amount?: number | null
          bank_response_details?: Json
          clawback_amount?: number
          commission_accrual_id: string
          confirmed_at?: string | null
          created_at?: string
          currency_id: string
          difference_amount?: number | null
          difference_reason_code?: string | null
          difference_reason_text?: string | null
          disputed_at?: string | null
          gross_amount?: number
          id?: string
          included_at?: string
          item_details?: Json
          item_status?: string
          metadata?: Json
          net_amount?: number
          rejected_at?: string | null
          resolved_at?: string | null
          settlement_id: string
          settlement_item_reference: string
          tax_amount?: number
          updated_at?: string
          withholding_amount?: number
        }
        Update: {
          adjustment_amount?: number
          bank_confirmed_amount?: number | null
          bank_response_details?: Json
          clawback_amount?: number
          commission_accrual_id?: string
          confirmed_at?: string | null
          created_at?: string
          currency_id?: string
          difference_amount?: number | null
          difference_reason_code?: string | null
          difference_reason_text?: string | null
          disputed_at?: string | null
          gross_amount?: number
          id?: string
          included_at?: string
          item_details?: Json
          item_status?: string
          metadata?: Json
          net_amount?: number
          rejected_at?: string | null
          resolved_at?: string | null
          settlement_id?: string
          settlement_item_reference?: string
          tax_amount?: number
          updated_at?: string
          withholding_amount?: number
        }
        Relationships: [
          {
            foreignKeyName: "commission_settlement_items_commission_accrual_id_fkey"
            columns: ["commission_accrual_id"]
            isOneToOne: false
            referencedRelation: "commission_accruals"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_settlement_items_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_settlement_items_settlement_id_fkey"
            columns: ["settlement_id"]
            isOneToOne: false
            referencedRelation: "commission_settlements"
            referencedColumns: ["id"]
          },
        ]
      }
      commission_settlements: {
        Row: {
          accrual_count: number
          acknowledged_by_bank_at: string | null
          adjustment_amount: number
          amount_outstanding: number
          amount_paid: number
          approved_by: string | null
          approved_by_bank_at: string | null
          bank_id: string
          bank_payment_reference: string | null
          bank_settlement_reference: string | null
          bank_statement_details: Json
          clawback_amount: number
          closed_at: string | null
          created_at: string
          credit_note_reference: string | null
          dispute_resolved_at: string | null
          disputed_accrual_count: number
          disputed_at: string | null
          gross_amount: number
          id: string
          invoice_reference: string | null
          invoiced_at: string | null
          metadata: Json
          net_amount: number
          notes: string | null
          paid_at: string | null
          partially_paid_at: string | null
          partnership_id: string
          payment_due_at: string | null
          payment_method: string | null
          prepared_at: string | null
          prepared_by: string | null
          qualified_accrual_count: number
          reconciliation_completed_at: string | null
          reconciliation_details: Json
          reconciliation_difference_amount: number
          reconciliation_status: string
          rejected_accrual_count: number
          settlement_currency_id: string
          settlement_period_end: string
          settlement_period_start: string
          settlement_reference: string
          settlement_status: string
          settlement_summary: Json
          settlement_type: string
          submitted_to_bank_at: string | null
          tax_amount: number
          updated_at: string
          withholding_amount: number
        }
        Insert: {
          accrual_count?: number
          acknowledged_by_bank_at?: string | null
          adjustment_amount?: number
          amount_outstanding?: number
          amount_paid?: number
          approved_by?: string | null
          approved_by_bank_at?: string | null
          bank_id: string
          bank_payment_reference?: string | null
          bank_settlement_reference?: string | null
          bank_statement_details?: Json
          clawback_amount?: number
          closed_at?: string | null
          created_at?: string
          credit_note_reference?: string | null
          dispute_resolved_at?: string | null
          disputed_accrual_count?: number
          disputed_at?: string | null
          gross_amount?: number
          id?: string
          invoice_reference?: string | null
          invoiced_at?: string | null
          metadata?: Json
          net_amount?: number
          notes?: string | null
          paid_at?: string | null
          partially_paid_at?: string | null
          partnership_id: string
          payment_due_at?: string | null
          payment_method?: string | null
          prepared_at?: string | null
          prepared_by?: string | null
          qualified_accrual_count?: number
          reconciliation_completed_at?: string | null
          reconciliation_details?: Json
          reconciliation_difference_amount?: number
          reconciliation_status?: string
          rejected_accrual_count?: number
          settlement_currency_id: string
          settlement_period_end: string
          settlement_period_start: string
          settlement_reference: string
          settlement_status?: string
          settlement_summary?: Json
          settlement_type?: string
          submitted_to_bank_at?: string | null
          tax_amount?: number
          updated_at?: string
          withholding_amount?: number
        }
        Update: {
          accrual_count?: number
          acknowledged_by_bank_at?: string | null
          adjustment_amount?: number
          amount_outstanding?: number
          amount_paid?: number
          approved_by?: string | null
          approved_by_bank_at?: string | null
          bank_id?: string
          bank_payment_reference?: string | null
          bank_settlement_reference?: string | null
          bank_statement_details?: Json
          clawback_amount?: number
          closed_at?: string | null
          created_at?: string
          credit_note_reference?: string | null
          dispute_resolved_at?: string | null
          disputed_accrual_count?: number
          disputed_at?: string | null
          gross_amount?: number
          id?: string
          invoice_reference?: string | null
          invoiced_at?: string | null
          metadata?: Json
          net_amount?: number
          notes?: string | null
          paid_at?: string | null
          partially_paid_at?: string | null
          partnership_id?: string
          payment_due_at?: string | null
          payment_method?: string | null
          prepared_at?: string | null
          prepared_by?: string | null
          qualified_accrual_count?: number
          reconciliation_completed_at?: string | null
          reconciliation_details?: Json
          reconciliation_difference_amount?: number
          reconciliation_status?: string
          rejected_accrual_count?: number
          settlement_currency_id?: string
          settlement_period_end?: string
          settlement_period_start?: string
          settlement_reference?: string
          settlement_status?: string
          settlement_summary?: Json
          settlement_type?: string
          submitted_to_bank_at?: string | null
          tax_amount?: number
          updated_at?: string
          withholding_amount?: number
        }
        Relationships: [
          {
            foreignKeyName: "commission_settlements_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_settlements_partnership_id_fkey"
            columns: ["partnership_id"]
            isOneToOne: false
            referencedRelation: "bank_partnerships"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "commission_settlements_settlement_currency_id_fkey"
            columns: ["settlement_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      compliance_case_events: {
        Row: {
          actor_type: string
          actor_user_id: string | null
          attachments: Json
          compliance_case_id: string
          created_at: string
          description: string | null
          event_details: Json
          event_reference: string
          event_status: string
          event_type: string
          id: string
          metadata: Json
          new_case_status: string | null
          occurred_at: string
          previous_case_status: string | null
          reason_code: string | null
          title: string | null
        }
        Insert: {
          actor_type?: string
          actor_user_id?: string | null
          attachments?: Json
          compliance_case_id: string
          created_at?: string
          description?: string | null
          event_details?: Json
          event_reference: string
          event_status?: string
          event_type: string
          id?: string
          metadata?: Json
          new_case_status?: string | null
          occurred_at?: string
          previous_case_status?: string | null
          reason_code?: string | null
          title?: string | null
        }
        Update: {
          actor_type?: string
          actor_user_id?: string | null
          attachments?: Json
          compliance_case_id?: string
          created_at?: string
          description?: string | null
          event_details?: Json
          event_reference?: string
          event_status?: string
          event_type?: string
          id?: string
          metadata?: Json
          new_case_status?: string | null
          occurred_at?: string
          previous_case_status?: string | null
          reason_code?: string | null
          title?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "compliance_case_events_compliance_case_id_fkey"
            columns: ["compliance_case_id"]
            isOneToOne: false
            referencedRelation: "compliance_cases"
            referencedColumns: ["id"]
          },
        ]
      }
      compliance_cases: {
        Row: {
          acknowledged_at: string | null
          affected_customer_count: number
          allegations: Json
          assigned_team_reference: string | null
          assigned_to_user_id: string | null
          bank_application_id: string | null
          bank_id: string | null
          case_description: string | null
          case_priority: string
          case_reference: string
          case_severity: string
          case_status: string
          case_title: string
          case_type: string
          closed_at: string | null
          created_at: string
          customer_notification_required: boolean
          customer_notified_at: string | null
          due_at: string | null
          escalated_at: string | null
          financial_impact_amount: number | null
          financial_impact_currency_id: string | null
          findings: Json
          id: string
          investigation_details: Json
          investigation_started_at: string | null
          metadata: Json
          opened_at: string
          regulatory_details: Json
          regulatory_report_due_at: string | null
          regulatory_report_required: boolean
          regulatory_reported_at: string | null
          related_controls: Json
          remediation_actions: Json
          resolution_code: string | null
          resolution_summary: string | null
          resolved_at: string | null
          root_cause_category: string | null
          source_reference: string | null
          source_type: string
          subject_id: string | null
          subject_reference: string | null
          subject_type: string | null
          subject_user_id: string | null
          updated_at: string
        }
        Insert: {
          acknowledged_at?: string | null
          affected_customer_count?: number
          allegations?: Json
          assigned_team_reference?: string | null
          assigned_to_user_id?: string | null
          bank_application_id?: string | null
          bank_id?: string | null
          case_description?: string | null
          case_priority?: string
          case_reference: string
          case_severity?: string
          case_status?: string
          case_title: string
          case_type: string
          closed_at?: string | null
          created_at?: string
          customer_notification_required?: boolean
          customer_notified_at?: string | null
          due_at?: string | null
          escalated_at?: string | null
          financial_impact_amount?: number | null
          financial_impact_currency_id?: string | null
          findings?: Json
          id?: string
          investigation_details?: Json
          investigation_started_at?: string | null
          metadata?: Json
          opened_at?: string
          regulatory_details?: Json
          regulatory_report_due_at?: string | null
          regulatory_report_required?: boolean
          regulatory_reported_at?: string | null
          related_controls?: Json
          remediation_actions?: Json
          resolution_code?: string | null
          resolution_summary?: string | null
          resolved_at?: string | null
          root_cause_category?: string | null
          source_reference?: string | null
          source_type: string
          subject_id?: string | null
          subject_reference?: string | null
          subject_type?: string | null
          subject_user_id?: string | null
          updated_at?: string
        }
        Update: {
          acknowledged_at?: string | null
          affected_customer_count?: number
          allegations?: Json
          assigned_team_reference?: string | null
          assigned_to_user_id?: string | null
          bank_application_id?: string | null
          bank_id?: string | null
          case_description?: string | null
          case_priority?: string
          case_reference?: string
          case_severity?: string
          case_status?: string
          case_title?: string
          case_type?: string
          closed_at?: string | null
          created_at?: string
          customer_notification_required?: boolean
          customer_notified_at?: string | null
          due_at?: string | null
          escalated_at?: string | null
          financial_impact_amount?: number | null
          financial_impact_currency_id?: string | null
          findings?: Json
          id?: string
          investigation_details?: Json
          investigation_started_at?: string | null
          metadata?: Json
          opened_at?: string
          regulatory_details?: Json
          regulatory_report_due_at?: string | null
          regulatory_report_required?: boolean
          regulatory_reported_at?: string | null
          related_controls?: Json
          remediation_actions?: Json
          resolution_code?: string | null
          resolution_summary?: string | null
          resolved_at?: string | null
          root_cause_category?: string | null
          source_reference?: string | null
          source_type?: string
          subject_id?: string | null
          subject_reference?: string | null
          subject_type?: string | null
          subject_user_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "compliance_cases_bank_application_id_fkey"
            columns: ["bank_application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "compliance_cases_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "compliance_cases_financial_impact_currency_id_fkey"
            columns: ["financial_impact_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      consent_records: {
        Row: {
          allows_automated_decisioning: boolean
          allows_cross_border_transfer: boolean
          allows_data_sharing: boolean
          allows_marketing: boolean
          allows_profiling: boolean
          bank_application_id: string | null
          bank_id: string | null
          collection_channel: string
          collection_method: string
          consent_details: Json
          consent_reference: string
          consent_scope: string
          consent_status: string
          consent_type: string
          consent_version: string
          controller_reference: string | null
          created_at: string
          data_categories: Json
          effective_from: string | null
          evidence_details: Json
          evidence_reference: string | null
          expires_at: string | null
          granted_at: string | null
          id: string
          is_mandatory: boolean
          language_code: string
          legal_basis: string | null
          metadata: Json
          policy_version: string | null
          processor_reference: string | null
          proof_hash: string | null
          purpose_details: Json
          purpose_reference: string | null
          recipient_categories: Json
          revocation_reason: string | null
          revoked_at: string | null
          session_reference: string | null
          source_ip_hash: string | null
          superseded_at: string | null
          terms_version: string | null
          updated_at: string
          user_agent_hash: string | null
          user_id: string | null
          withdrawal_reason: string | null
          withdrawn_at: string | null
        }
        Insert: {
          allows_automated_decisioning?: boolean
          allows_cross_border_transfer?: boolean
          allows_data_sharing?: boolean
          allows_marketing?: boolean
          allows_profiling?: boolean
          bank_application_id?: string | null
          bank_id?: string | null
          collection_channel?: string
          collection_method?: string
          consent_details?: Json
          consent_reference: string
          consent_scope: string
          consent_status?: string
          consent_type: string
          consent_version: string
          controller_reference?: string | null
          created_at?: string
          data_categories?: Json
          effective_from?: string | null
          evidence_details?: Json
          evidence_reference?: string | null
          expires_at?: string | null
          granted_at?: string | null
          id?: string
          is_mandatory?: boolean
          language_code?: string
          legal_basis?: string | null
          metadata?: Json
          policy_version?: string | null
          processor_reference?: string | null
          proof_hash?: string | null
          purpose_details?: Json
          purpose_reference?: string | null
          recipient_categories?: Json
          revocation_reason?: string | null
          revoked_at?: string | null
          session_reference?: string | null
          source_ip_hash?: string | null
          superseded_at?: string | null
          terms_version?: string | null
          updated_at?: string
          user_agent_hash?: string | null
          user_id?: string | null
          withdrawal_reason?: string | null
          withdrawn_at?: string | null
        }
        Update: {
          allows_automated_decisioning?: boolean
          allows_cross_border_transfer?: boolean
          allows_data_sharing?: boolean
          allows_marketing?: boolean
          allows_profiling?: boolean
          bank_application_id?: string | null
          bank_id?: string | null
          collection_channel?: string
          collection_method?: string
          consent_details?: Json
          consent_reference?: string
          consent_scope?: string
          consent_status?: string
          consent_type?: string
          consent_version?: string
          controller_reference?: string | null
          created_at?: string
          data_categories?: Json
          effective_from?: string | null
          evidence_details?: Json
          evidence_reference?: string | null
          expires_at?: string | null
          granted_at?: string | null
          id?: string
          is_mandatory?: boolean
          language_code?: string
          legal_basis?: string | null
          metadata?: Json
          policy_version?: string | null
          processor_reference?: string | null
          proof_hash?: string | null
          purpose_details?: Json
          purpose_reference?: string | null
          recipient_categories?: Json
          revocation_reason?: string | null
          revoked_at?: string | null
          session_reference?: string | null
          source_ip_hash?: string | null
          superseded_at?: string | null
          terms_version?: string | null
          updated_at?: string
          user_agent_hash?: string | null
          user_id?: string | null
          withdrawal_reason?: string | null
          withdrawn_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "consent_records_bank_application_id_fkey"
            columns: ["bank_application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "consent_records_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
        ]
      }
      countries: {
        Row: {
          code: string
          created_at: string
          id: string
          is_active: boolean
          name_ar: string
          name_en: string
          slug: string
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          id?: string
          is_active?: boolean
          name_ar: string
          name_en: string
          slug: string
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          id?: string
          is_active?: boolean
          name_ar?: string
          name_en?: string
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      currencies: {
        Row: {
          code: string
          created_at: string
          decimal_places: number
          id: string
          is_active: boolean
          name_ar: string
          name_en: string
          slug: string
          symbol: string | null
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          decimal_places?: number
          id?: string
          is_active?: boolean
          name_ar: string
          name_en: string
          slug: string
          symbol?: string | null
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          decimal_places?: number
          id?: string
          is_active?: boolean
          name_ar?: string
          name_en?: string
          slug?: string
          symbol?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      customer_financial_profiles: {
        Row: {
          annual_income: number | null
          average_monthly_card_payment: number | null
          consent_for_recommendation: boolean
          consent_recorded_at: string | null
          consent_version: string | null
          created_at: string
          currency_id: string
          current_customer_segment: string | null
          data_source: string
          date_of_birth: string | null
          employer_name: string | null
          employment_sector: string | null
          employment_start_date: string | null
          employment_status: string | null
          estimated_monthly_disposable_income: number | null
          estimated_net_worth: number | null
          existing_credit_card_count: number | null
          financial_data_completeness: number | null
          gross_monthly_salary: number | null
          has_recent_payment_defaults: boolean | null
          id: string
          is_active: boolean
          is_primary: boolean
          is_scenario: boolean
          job_title: string | null
          last_verified_at: string | null
          liquid_assets_value: number | null
          maximum_acceptable_annual_fee: number | null
          metadata: Json
          minimum_expected_annual_value: number | null
          monthly_debt_obligations: number | null
          monthly_fixed_expenses: number | null
          monthly_household_income: number | null
          monthly_housing_cost: number | null
          monthly_other_income: number | null
          months_with_current_employer: number | null
          nationality_country_code: string | null
          net_monthly_salary: number | null
          pays_balance_in_full: boolean | null
          preferred_customer_segment: string | null
          primary_bank_id: string | null
          profile_name: string
          profile_slug: string | null
          profile_type: string
          residence_country_code: string | null
          residence_status: string | null
          salary_transfer_bank_id: string | null
          salary_transfer_status: string
          total_assets_value: number | null
          total_credit_limit: number | null
          total_outstanding_debt: number | null
          updated_at: string
          user_id: string | null
          valid_from: string | null
          valid_to: string | null
          willing_to_open_new_bank_account: boolean | null
          willing_to_transfer_salary: boolean | null
        }
        Insert: {
          annual_income?: number | null
          average_monthly_card_payment?: number | null
          consent_for_recommendation?: boolean
          consent_recorded_at?: string | null
          consent_version?: string | null
          created_at?: string
          currency_id: string
          current_customer_segment?: string | null
          data_source?: string
          date_of_birth?: string | null
          employer_name?: string | null
          employment_sector?: string | null
          employment_start_date?: string | null
          employment_status?: string | null
          estimated_monthly_disposable_income?: number | null
          estimated_net_worth?: number | null
          existing_credit_card_count?: number | null
          financial_data_completeness?: number | null
          gross_monthly_salary?: number | null
          has_recent_payment_defaults?: boolean | null
          id?: string
          is_active?: boolean
          is_primary?: boolean
          is_scenario?: boolean
          job_title?: string | null
          last_verified_at?: string | null
          liquid_assets_value?: number | null
          maximum_acceptable_annual_fee?: number | null
          metadata?: Json
          minimum_expected_annual_value?: number | null
          monthly_debt_obligations?: number | null
          monthly_fixed_expenses?: number | null
          monthly_household_income?: number | null
          monthly_housing_cost?: number | null
          monthly_other_income?: number | null
          months_with_current_employer?: number | null
          nationality_country_code?: string | null
          net_monthly_salary?: number | null
          pays_balance_in_full?: boolean | null
          preferred_customer_segment?: string | null
          primary_bank_id?: string | null
          profile_name: string
          profile_slug?: string | null
          profile_type?: string
          residence_country_code?: string | null
          residence_status?: string | null
          salary_transfer_bank_id?: string | null
          salary_transfer_status?: string
          total_assets_value?: number | null
          total_credit_limit?: number | null
          total_outstanding_debt?: number | null
          updated_at?: string
          user_id?: string | null
          valid_from?: string | null
          valid_to?: string | null
          willing_to_open_new_bank_account?: boolean | null
          willing_to_transfer_salary?: boolean | null
        }
        Update: {
          annual_income?: number | null
          average_monthly_card_payment?: number | null
          consent_for_recommendation?: boolean
          consent_recorded_at?: string | null
          consent_version?: string | null
          created_at?: string
          currency_id?: string
          current_customer_segment?: string | null
          data_source?: string
          date_of_birth?: string | null
          employer_name?: string | null
          employment_sector?: string | null
          employment_start_date?: string | null
          employment_status?: string | null
          estimated_monthly_disposable_income?: number | null
          estimated_net_worth?: number | null
          existing_credit_card_count?: number | null
          financial_data_completeness?: number | null
          gross_monthly_salary?: number | null
          has_recent_payment_defaults?: boolean | null
          id?: string
          is_active?: boolean
          is_primary?: boolean
          is_scenario?: boolean
          job_title?: string | null
          last_verified_at?: string | null
          liquid_assets_value?: number | null
          maximum_acceptable_annual_fee?: number | null
          metadata?: Json
          minimum_expected_annual_value?: number | null
          monthly_debt_obligations?: number | null
          monthly_fixed_expenses?: number | null
          monthly_household_income?: number | null
          monthly_housing_cost?: number | null
          monthly_other_income?: number | null
          months_with_current_employer?: number | null
          nationality_country_code?: string | null
          net_monthly_salary?: number | null
          pays_balance_in_full?: boolean | null
          preferred_customer_segment?: string | null
          primary_bank_id?: string | null
          profile_name?: string
          profile_slug?: string | null
          profile_type?: string
          residence_country_code?: string | null
          residence_status?: string | null
          salary_transfer_bank_id?: string | null
          salary_transfer_status?: string
          total_assets_value?: number | null
          total_credit_limit?: number | null
          total_outstanding_debt?: number | null
          updated_at?: string
          user_id?: string | null
          valid_from?: string | null
          valid_to?: string | null
          willing_to_open_new_bank_account?: boolean | null
          willing_to_transfer_salary?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "customer_financial_profiles_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "customer_financial_profiles_primary_bank_id_fkey"
            columns: ["primary_bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "customer_financial_profiles_salary_transfer_bank_id_fkey"
            columns: ["salary_transfer_bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
        ]
      }
      customer_preference_profiles: {
        Row: {
          accepts_spending_conditions: boolean | null
          accepts_temporary_offers: boolean | null
          created_at: string
          data_source: string
          desired_annual_airport_transfers: number | null
          desired_annual_concierge_requests: number | null
          desired_annual_golf_rounds: number | null
          desired_annual_lounge_visits: number | null
          desired_supplementary_card_count: number | null
          excluded_bank_ids: string[] | null
          excluded_card_ids: string[] | null
          financial_profile_id: string
          id: string
          is_active: boolean
          is_primary: boolean
          last_verified_at: string | null
          maximum_acceptable_annual_fee: number | null
          maximum_acceptable_foreign_transaction_fee: number | null
          maximum_acceptable_minimum_spend: number | null
          metadata: Json
          minimum_required_net_annual_value: number | null
          minimum_required_reward_rate: number | null
          preference_data_completeness: number | null
          preference_data_confidence: number | null
          preference_strategy: string
          preferred_airline_programs: string[] | null
          preferred_bank_id: string | null
          preferred_card_ids: string[] | null
          preferred_digital_wallets: string[] | null
          preferred_hotel_programs: string[] | null
          preferred_languages: string[] | null
          preferred_lounge_programs: string[] | null
          preferred_payment_network:
            | Database["public"]["Enums"]["payment_network"]
            | null
          preferred_reward_type: string | null
          prefers_airline_miles: boolean | null
          prefers_automatic_redemption: boolean | null
          prefers_cashback: boolean | null
          prefers_dining_benefits: boolean | null
          prefers_fee_waiver: boolean | null
          prefers_installment_plans: boolean | null
          prefers_lounge_access: boolean | null
          prefers_no_foreign_transaction_fee: boolean | null
          prefers_simple_rewards: boolean | null
          prefers_transferable_points: boolean | null
          prefers_travel_insurance: boolean | null
          prefers_welcome_bonus: boolean | null
          profile_name: string
          profile_slug: string | null
          updated_at: string
          wants_salary_transfer_products: boolean | null
          wants_shariah_compliant_products: boolean | null
          willing_to_pay_annual_fee: boolean | null
        }
        Insert: {
          accepts_spending_conditions?: boolean | null
          accepts_temporary_offers?: boolean | null
          created_at?: string
          data_source?: string
          desired_annual_airport_transfers?: number | null
          desired_annual_concierge_requests?: number | null
          desired_annual_golf_rounds?: number | null
          desired_annual_lounge_visits?: number | null
          desired_supplementary_card_count?: number | null
          excluded_bank_ids?: string[] | null
          excluded_card_ids?: string[] | null
          financial_profile_id: string
          id?: string
          is_active?: boolean
          is_primary?: boolean
          last_verified_at?: string | null
          maximum_acceptable_annual_fee?: number | null
          maximum_acceptable_foreign_transaction_fee?: number | null
          maximum_acceptable_minimum_spend?: number | null
          metadata?: Json
          minimum_required_net_annual_value?: number | null
          minimum_required_reward_rate?: number | null
          preference_data_completeness?: number | null
          preference_data_confidence?: number | null
          preference_strategy?: string
          preferred_airline_programs?: string[] | null
          preferred_bank_id?: string | null
          preferred_card_ids?: string[] | null
          preferred_digital_wallets?: string[] | null
          preferred_hotel_programs?: string[] | null
          preferred_languages?: string[] | null
          preferred_lounge_programs?: string[] | null
          preferred_payment_network?:
            | Database["public"]["Enums"]["payment_network"]
            | null
          preferred_reward_type?: string | null
          prefers_airline_miles?: boolean | null
          prefers_automatic_redemption?: boolean | null
          prefers_cashback?: boolean | null
          prefers_dining_benefits?: boolean | null
          prefers_fee_waiver?: boolean | null
          prefers_installment_plans?: boolean | null
          prefers_lounge_access?: boolean | null
          prefers_no_foreign_transaction_fee?: boolean | null
          prefers_simple_rewards?: boolean | null
          prefers_transferable_points?: boolean | null
          prefers_travel_insurance?: boolean | null
          prefers_welcome_bonus?: boolean | null
          profile_name: string
          profile_slug?: string | null
          updated_at?: string
          wants_salary_transfer_products?: boolean | null
          wants_shariah_compliant_products?: boolean | null
          willing_to_pay_annual_fee?: boolean | null
        }
        Update: {
          accepts_spending_conditions?: boolean | null
          accepts_temporary_offers?: boolean | null
          created_at?: string
          data_source?: string
          desired_annual_airport_transfers?: number | null
          desired_annual_concierge_requests?: number | null
          desired_annual_golf_rounds?: number | null
          desired_annual_lounge_visits?: number | null
          desired_supplementary_card_count?: number | null
          excluded_bank_ids?: string[] | null
          excluded_card_ids?: string[] | null
          financial_profile_id?: string
          id?: string
          is_active?: boolean
          is_primary?: boolean
          last_verified_at?: string | null
          maximum_acceptable_annual_fee?: number | null
          maximum_acceptable_foreign_transaction_fee?: number | null
          maximum_acceptable_minimum_spend?: number | null
          metadata?: Json
          minimum_required_net_annual_value?: number | null
          minimum_required_reward_rate?: number | null
          preference_data_completeness?: number | null
          preference_data_confidence?: number | null
          preference_strategy?: string
          preferred_airline_programs?: string[] | null
          preferred_bank_id?: string | null
          preferred_card_ids?: string[] | null
          preferred_digital_wallets?: string[] | null
          preferred_hotel_programs?: string[] | null
          preferred_languages?: string[] | null
          preferred_lounge_programs?: string[] | null
          preferred_payment_network?:
            | Database["public"]["Enums"]["payment_network"]
            | null
          preferred_reward_type?: string | null
          prefers_airline_miles?: boolean | null
          prefers_automatic_redemption?: boolean | null
          prefers_cashback?: boolean | null
          prefers_dining_benefits?: boolean | null
          prefers_fee_waiver?: boolean | null
          prefers_installment_plans?: boolean | null
          prefers_lounge_access?: boolean | null
          prefers_no_foreign_transaction_fee?: boolean | null
          prefers_simple_rewards?: boolean | null
          prefers_transferable_points?: boolean | null
          prefers_travel_insurance?: boolean | null
          prefers_welcome_bonus?: boolean | null
          profile_name?: string
          profile_slug?: string | null
          updated_at?: string
          wants_salary_transfer_products?: boolean | null
          wants_shariah_compliant_products?: boolean | null
          willing_to_pay_annual_fee?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "customer_preference_profiles_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "customer_preference_profiles_preferred_bank_id_fkey"
            columns: ["preferred_bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
        ]
      }
      customer_preferences: {
        Row: {
          created_at: string
          exclusion_if_unmet: boolean
          hard_requirement: boolean
          id: string
          importance: Database["public"]["Enums"]["customer_preference_importance"]
          is_active: boolean
          maximum_value: number | null
          metadata: Json
          minimum_value: number | null
          notes_ar: string | null
          notes_en: string | null
          preference_category: string
          preference_code: string
          preference_profile_id: string
          preferred_value_text: string | null
          preferred_values: Json | null
          target_value: number | null
          updated_at: string
          weight: number
        }
        Insert: {
          created_at?: string
          exclusion_if_unmet?: boolean
          hard_requirement?: boolean
          id?: string
          importance?: Database["public"]["Enums"]["customer_preference_importance"]
          is_active?: boolean
          maximum_value?: number | null
          metadata?: Json
          minimum_value?: number | null
          notes_ar?: string | null
          notes_en?: string | null
          preference_category: string
          preference_code: string
          preference_profile_id: string
          preferred_value_text?: string | null
          preferred_values?: Json | null
          target_value?: number | null
          updated_at?: string
          weight?: number
        }
        Update: {
          created_at?: string
          exclusion_if_unmet?: boolean
          hard_requirement?: boolean
          id?: string
          importance?: Database["public"]["Enums"]["customer_preference_importance"]
          is_active?: boolean
          maximum_value?: number | null
          metadata?: Json
          minimum_value?: number | null
          notes_ar?: string | null
          notes_en?: string | null
          preference_category?: string
          preference_code?: string
          preference_profile_id?: string
          preferred_value_text?: string | null
          preferred_values?: Json | null
          target_value?: number | null
          updated_at?: string
          weight?: number
        }
        Relationships: [
          {
            foreignKeyName: "customer_preferences_preference_profile_id_fkey"
            columns: ["preference_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_preference_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      customer_spending_categories: {
        Row: {
          category_code: string
          category_name_ar: string | null
          category_name_en: string | null
          confidence_score: number | null
          created_at: string
          data_source: string
          domestic_amount: number | null
          foreign_currency_amount: number | null
          id: string
          in_store_amount: number | null
          international_amount: number | null
          is_active: boolean
          merchant_category_codes: string[] | null
          metadata: Json
          notes_ar: string | null
          notes_en: string | null
          online_amount: number | null
          recurring_amount: number | null
          spending_amount: number
          spending_profile_id: string
          transaction_count: number | null
          updated_at: string
        }
        Insert: {
          category_code: string
          category_name_ar?: string | null
          category_name_en?: string | null
          confidence_score?: number | null
          created_at?: string
          data_source?: string
          domestic_amount?: number | null
          foreign_currency_amount?: number | null
          id?: string
          in_store_amount?: number | null
          international_amount?: number | null
          is_active?: boolean
          merchant_category_codes?: string[] | null
          metadata?: Json
          notes_ar?: string | null
          notes_en?: string | null
          online_amount?: number | null
          recurring_amount?: number | null
          spending_amount: number
          spending_profile_id: string
          transaction_count?: number | null
          updated_at?: string
        }
        Update: {
          category_code?: string
          category_name_ar?: string | null
          category_name_en?: string | null
          confidence_score?: number | null
          created_at?: string
          data_source?: string
          domestic_amount?: number | null
          foreign_currency_amount?: number | null
          id?: string
          in_store_amount?: number | null
          international_amount?: number | null
          is_active?: boolean
          merchant_category_codes?: string[] | null
          metadata?: Json
          notes_ar?: string | null
          notes_en?: string | null
          online_amount?: number | null
          recurring_amount?: number | null
          spending_amount?: number
          spending_profile_id?: string
          transaction_count?: number | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "customer_spending_categories_spending_profile_id_fkey"
            columns: ["spending_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_spending_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      customer_spending_profiles: {
        Row: {
          average_monthly_balance_carried: number | null
          average_transaction_amount: number | null
          cash_advance_amount: number | null
          contactless_spend: number | null
          created_at: string
          currency_id: string
          data_source: string
          digital_wallet_spend: number | null
          domestic_spend: number | null
          estimated_international_transaction_count: number | null
          estimated_monthly_payment: number | null
          estimated_transaction_count: number | null
          expected_annual_spend_growth_rate: number | null
          financial_profile_id: string
          foreign_currency_spend: number | null
          id: string
          in_store_spend: number | null
          installment_purchase_spend: number | null
          international_spend: number | null
          is_active: boolean
          is_primary: boolean
          last_verified_at: string | null
          metadata: Json
          online_spend: number | null
          pays_statement_balance_in_full: boolean | null
          period_end: string | null
          period_start: string | null
          preferred_digital_wallet: string | null
          primary_spending_channel: string | null
          profile_name: string
          profile_slug: string | null
          recurring_spend: number | null
          spending_data_completeness: number | null
          spending_data_confidence: number | null
          spending_period: string
          total_card_spend: number | null
          updated_at: string
          uses_cash_advance: boolean | null
          uses_digital_wallet: boolean | null
          uses_installment_plans: boolean | null
        }
        Insert: {
          average_monthly_balance_carried?: number | null
          average_transaction_amount?: number | null
          cash_advance_amount?: number | null
          contactless_spend?: number | null
          created_at?: string
          currency_id: string
          data_source?: string
          digital_wallet_spend?: number | null
          domestic_spend?: number | null
          estimated_international_transaction_count?: number | null
          estimated_monthly_payment?: number | null
          estimated_transaction_count?: number | null
          expected_annual_spend_growth_rate?: number | null
          financial_profile_id: string
          foreign_currency_spend?: number | null
          id?: string
          in_store_spend?: number | null
          installment_purchase_spend?: number | null
          international_spend?: number | null
          is_active?: boolean
          is_primary?: boolean
          last_verified_at?: string | null
          metadata?: Json
          online_spend?: number | null
          pays_statement_balance_in_full?: boolean | null
          period_end?: string | null
          period_start?: string | null
          preferred_digital_wallet?: string | null
          primary_spending_channel?: string | null
          profile_name: string
          profile_slug?: string | null
          recurring_spend?: number | null
          spending_data_completeness?: number | null
          spending_data_confidence?: number | null
          spending_period?: string
          total_card_spend?: number | null
          updated_at?: string
          uses_cash_advance?: boolean | null
          uses_digital_wallet?: boolean | null
          uses_installment_plans?: boolean | null
        }
        Update: {
          average_monthly_balance_carried?: number | null
          average_transaction_amount?: number | null
          cash_advance_amount?: number | null
          contactless_spend?: number | null
          created_at?: string
          currency_id?: string
          data_source?: string
          digital_wallet_spend?: number | null
          domestic_spend?: number | null
          estimated_international_transaction_count?: number | null
          estimated_monthly_payment?: number | null
          estimated_transaction_count?: number | null
          expected_annual_spend_growth_rate?: number | null
          financial_profile_id?: string
          foreign_currency_spend?: number | null
          id?: string
          in_store_spend?: number | null
          installment_purchase_spend?: number | null
          international_spend?: number | null
          is_active?: boolean
          is_primary?: boolean
          last_verified_at?: string | null
          metadata?: Json
          online_spend?: number | null
          pays_statement_balance_in_full?: boolean | null
          period_end?: string | null
          period_start?: string | null
          preferred_digital_wallet?: string | null
          primary_spending_channel?: string | null
          profile_name?: string
          profile_slug?: string | null
          recurring_spend?: number | null
          spending_data_completeness?: number | null
          spending_data_confidence?: number | null
          spending_period?: string
          total_card_spend?: number | null
          updated_at?: string
          uses_cash_advance?: boolean | null
          uses_digital_wallet?: boolean | null
          uses_installment_plans?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "customer_spending_profiles_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "customer_spending_profiles_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      data_access_logs: {
        Row: {
          access_context: Json
          access_duration_milliseconds: number | null
          access_outcome: string
          access_purpose: string
          access_reference: string
          access_type: string
          accessed_at: string
          actor_reference: string | null
          actor_type: string
          approval_reference: string | null
          consent_reference: string | null
          correlation_id: string | null
          created_at: string
          data_categories: Json
          data_classification: string
          denial_reason_code: string | null
          denial_reason_text: string | null
          device_reference: string | null
          entity_id: string | null
          entity_reference: string | null
          entity_type: string
          fields_accessed: Json
          id: string
          impersonated_user_id: string | null
          legal_basis: string | null
          metadata: Json
          query_fingerprint: string | null
          record_count: number
          request_reference: string | null
          security_context: Json
          session_reference: string | null
          source_component: string | null
          source_ip_hash: string | null
          source_service: string | null
          user_agent_hash: string | null
          user_id: string | null
        }
        Insert: {
          access_context?: Json
          access_duration_milliseconds?: number | null
          access_outcome?: string
          access_purpose: string
          access_reference: string
          access_type: string
          accessed_at?: string
          actor_reference?: string | null
          actor_type?: string
          approval_reference?: string | null
          consent_reference?: string | null
          correlation_id?: string | null
          created_at?: string
          data_categories?: Json
          data_classification?: string
          denial_reason_code?: string | null
          denial_reason_text?: string | null
          device_reference?: string | null
          entity_id?: string | null
          entity_reference?: string | null
          entity_type: string
          fields_accessed?: Json
          id?: string
          impersonated_user_id?: string | null
          legal_basis?: string | null
          metadata?: Json
          query_fingerprint?: string | null
          record_count?: number
          request_reference?: string | null
          security_context?: Json
          session_reference?: string | null
          source_component?: string | null
          source_ip_hash?: string | null
          source_service?: string | null
          user_agent_hash?: string | null
          user_id?: string | null
        }
        Update: {
          access_context?: Json
          access_duration_milliseconds?: number | null
          access_outcome?: string
          access_purpose?: string
          access_reference?: string
          access_type?: string
          accessed_at?: string
          actor_reference?: string | null
          actor_type?: string
          approval_reference?: string | null
          consent_reference?: string | null
          correlation_id?: string | null
          created_at?: string
          data_categories?: Json
          data_classification?: string
          denial_reason_code?: string | null
          denial_reason_text?: string | null
          device_reference?: string | null
          entity_id?: string | null
          entity_reference?: string | null
          entity_type?: string
          fields_accessed?: Json
          id?: string
          impersonated_user_id?: string | null
          legal_basis?: string | null
          metadata?: Json
          query_fingerprint?: string | null
          record_count?: number
          request_reference?: string | null
          security_context?: Json
          session_reference?: string | null
          source_component?: string | null
          source_ip_hash?: string | null
          source_service?: string | null
          user_agent_hash?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      data_classification_rules: {
        Row: {
          access_conditions: Json
          access_logging_required: boolean
          classification_level: string
          classification_reference: string
          column_name: string | null
          created_at: string
          cross_border_transfer_restricted: boolean
          customer_consent_required: boolean
          data_category: string
          effective_from: string
          effective_until: string | null
          encryption_configuration: Json
          encryption_required: boolean
          entity_type: string | null
          export_restricted: boolean
          id: string
          masking_configuration: Json
          masking_required: boolean
          maximum_retention_days: number | null
          metadata: Json
          minimum_retention_days: number | null
          privileged_access_required: boolean
          regulatory_scope: string | null
          rule_status: string
          schema_name: string
          sensitivity_type: string | null
          table_name: string
          tokenization_required: boolean
          updated_at: string
        }
        Insert: {
          access_conditions?: Json
          access_logging_required?: boolean
          classification_level: string
          classification_reference: string
          column_name?: string | null
          created_at?: string
          cross_border_transfer_restricted?: boolean
          customer_consent_required?: boolean
          data_category: string
          effective_from?: string
          effective_until?: string | null
          encryption_configuration?: Json
          encryption_required?: boolean
          entity_type?: string | null
          export_restricted?: boolean
          id?: string
          masking_configuration?: Json
          masking_required?: boolean
          maximum_retention_days?: number | null
          metadata?: Json
          minimum_retention_days?: number | null
          privileged_access_required?: boolean
          regulatory_scope?: string | null
          rule_status?: string
          schema_name?: string
          sensitivity_type?: string | null
          table_name: string
          tokenization_required?: boolean
          updated_at?: string
        }
        Update: {
          access_conditions?: Json
          access_logging_required?: boolean
          classification_level?: string
          classification_reference?: string
          column_name?: string | null
          created_at?: string
          cross_border_transfer_restricted?: boolean
          customer_consent_required?: boolean
          data_category?: string
          effective_from?: string
          effective_until?: string | null
          encryption_configuration?: Json
          encryption_required?: boolean
          entity_type?: string | null
          export_restricted?: boolean
          id?: string
          masking_configuration?: Json
          masking_required?: boolean
          maximum_retention_days?: number | null
          metadata?: Json
          minimum_retention_days?: number | null
          privileged_access_required?: boolean
          regulatory_scope?: string | null
          rule_status?: string
          schema_name?: string
          sensitivity_type?: string | null
          table_name?: string
          tokenization_required?: boolean
          updated_at?: string
        }
        Relationships: []
      }
      data_export_requests: {
        Row: {
          approval_request_id: string | null
          approved_at: string | null
          cancelled_at: string | null
          completed_at: string | null
          consent_reference: string | null
          created_at: string
          data_classification: string
          data_scope: string
          delivery_details: Json
          download_count: number
          downloaded_at: string | null
          encryption_key_reference: string | null
          encryption_required: boolean
          entity_types: Json
          expires_at: string | null
          export_format: string
          export_purpose: string
          export_reference: string
          export_status: string
          export_summary: Json
          export_type: string
          failed_at: string | null
          failure_code: string | null
          failure_message: string | null
          file_hash: string | null
          file_name: string | null
          file_size_bytes: number | null
          filters: Json
          id: string
          legal_basis: string | null
          maximum_download_count: number
          metadata: Json
          password_protected: boolean
          processing_started_at: string | null
          record_count: number | null
          redaction_required: boolean
          redaction_summary: Json
          requested_at: string
          requested_by_user_id: string | null
          requested_fields: Json
          storage_bucket: string | null
          storage_path: string | null
          storage_provider: string | null
          subject_user_id: string | null
          submitted_at: string | null
          updated_at: string
          watermark_required: boolean
        }
        Insert: {
          approval_request_id?: string | null
          approved_at?: string | null
          cancelled_at?: string | null
          completed_at?: string | null
          consent_reference?: string | null
          created_at?: string
          data_classification?: string
          data_scope: string
          delivery_details?: Json
          download_count?: number
          downloaded_at?: string | null
          encryption_key_reference?: string | null
          encryption_required?: boolean
          entity_types?: Json
          expires_at?: string | null
          export_format?: string
          export_purpose: string
          export_reference: string
          export_status?: string
          export_summary?: Json
          export_type: string
          failed_at?: string | null
          failure_code?: string | null
          failure_message?: string | null
          file_hash?: string | null
          file_name?: string | null
          file_size_bytes?: number | null
          filters?: Json
          id?: string
          legal_basis?: string | null
          maximum_download_count?: number
          metadata?: Json
          password_protected?: boolean
          processing_started_at?: string | null
          record_count?: number | null
          redaction_required?: boolean
          redaction_summary?: Json
          requested_at?: string
          requested_by_user_id?: string | null
          requested_fields?: Json
          storage_bucket?: string | null
          storage_path?: string | null
          storage_provider?: string | null
          subject_user_id?: string | null
          submitted_at?: string | null
          updated_at?: string
          watermark_required?: boolean
        }
        Update: {
          approval_request_id?: string | null
          approved_at?: string | null
          cancelled_at?: string | null
          completed_at?: string | null
          consent_reference?: string | null
          created_at?: string
          data_classification?: string
          data_scope?: string
          delivery_details?: Json
          download_count?: number
          downloaded_at?: string | null
          encryption_key_reference?: string | null
          encryption_required?: boolean
          entity_types?: Json
          expires_at?: string | null
          export_format?: string
          export_purpose?: string
          export_reference?: string
          export_status?: string
          export_summary?: Json
          export_type?: string
          failed_at?: string | null
          failure_code?: string | null
          failure_message?: string | null
          file_hash?: string | null
          file_name?: string | null
          file_size_bytes?: number | null
          filters?: Json
          id?: string
          legal_basis?: string | null
          maximum_download_count?: number
          metadata?: Json
          password_protected?: boolean
          processing_started_at?: string | null
          record_count?: number | null
          redaction_required?: boolean
          redaction_summary?: Json
          requested_at?: string
          requested_by_user_id?: string | null
          requested_fields?: Json
          storage_bucket?: string | null
          storage_path?: string | null
          storage_provider?: string | null
          subject_user_id?: string | null
          submitted_at?: string | null
          updated_at?: string
          watermark_required?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "data_export_requests_approval_request_id_fkey"
            columns: ["approval_request_id"]
            isOneToOne: false
            referencedRelation: "approval_requests"
            referencedColumns: ["id"]
          },
        ]
      }
      data_retention_executions: {
        Row: {
          affected_records: Json
          approval_request_id: string | null
          completed_at: string | null
          created_at: string
          entity_id: string | null
          entity_reference: string | null
          entity_type: string
          error_code: string | null
          error_message: string | null
          errors: Json
          executed_by_user_id: string | null
          execution_reference: string
          execution_status: string
          execution_summary: Json
          execution_type: string
          failed_at: string | null
          id: string
          legal_hold_records: number
          metadata: Json
          records_anonymized: number
          records_archived: number
          records_deleted: number
          records_evaluated: number
          records_failed: number
          records_skipped: number
          retention_policy_id: string
          scheduled_at: string | null
          started_at: string | null
          updated_at: string
        }
        Insert: {
          affected_records?: Json
          approval_request_id?: string | null
          completed_at?: string | null
          created_at?: string
          entity_id?: string | null
          entity_reference?: string | null
          entity_type: string
          error_code?: string | null
          error_message?: string | null
          errors?: Json
          executed_by_user_id?: string | null
          execution_reference: string
          execution_status?: string
          execution_summary?: Json
          execution_type?: string
          failed_at?: string | null
          id?: string
          legal_hold_records?: number
          metadata?: Json
          records_anonymized?: number
          records_archived?: number
          records_deleted?: number
          records_evaluated?: number
          records_failed?: number
          records_skipped?: number
          retention_policy_id: string
          scheduled_at?: string | null
          started_at?: string | null
          updated_at?: string
        }
        Update: {
          affected_records?: Json
          approval_request_id?: string | null
          completed_at?: string | null
          created_at?: string
          entity_id?: string | null
          entity_reference?: string | null
          entity_type?: string
          error_code?: string | null
          error_message?: string | null
          errors?: Json
          executed_by_user_id?: string | null
          execution_reference?: string
          execution_status?: string
          execution_summary?: Json
          execution_type?: string
          failed_at?: string | null
          id?: string
          legal_hold_records?: number
          metadata?: Json
          records_anonymized?: number
          records_archived?: number
          records_deleted?: number
          records_evaluated?: number
          records_failed?: number
          records_skipped?: number
          retention_policy_id?: string
          scheduled_at?: string | null
          started_at?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "data_retention_executions_approval_request_id_fkey"
            columns: ["approval_request_id"]
            isOneToOne: false
            referencedRelation: "approval_requests"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "data_retention_executions_retention_policy_id_fkey"
            columns: ["retention_policy_id"]
            isOneToOne: false
            referencedRelation: "data_retention_policies"
            referencedColumns: ["id"]
          },
        ]
      }
      data_retention_policies: {
        Row: {
          anonymize_after_days: number | null
          approval_required: boolean
          approved_at: string | null
          approved_by: string | null
          archive_after_days: number | null
          archive_configuration: Json
          archive_storage_class: string | null
          automated_execution: boolean
          created_at: string
          delete_after_days: number | null
          deletion_configuration: Json
          disposition_method: string
          effective_from: string
          effective_until: string | null
          entity_type: string
          exclusion_conditions: Json
          id: string
          last_reviewed_at: string | null
          legal_basis: string | null
          legal_hold_override: boolean
          metadata: Json
          next_review_due_at: string | null
          policy_conditions: Json
          policy_name: string
          policy_status: string
          regulatory_reference: string | null
          retention_period_days: number
          retention_policy_reference: string
          retention_trigger: string
          review_interval_days: number | null
          schema_name: string | null
          table_name: string | null
          updated_at: string
        }
        Insert: {
          anonymize_after_days?: number | null
          approval_required?: boolean
          approved_at?: string | null
          approved_by?: string | null
          archive_after_days?: number | null
          archive_configuration?: Json
          archive_storage_class?: string | null
          automated_execution?: boolean
          created_at?: string
          delete_after_days?: number | null
          deletion_configuration?: Json
          disposition_method?: string
          effective_from?: string
          effective_until?: string | null
          entity_type: string
          exclusion_conditions?: Json
          id?: string
          last_reviewed_at?: string | null
          legal_basis?: string | null
          legal_hold_override?: boolean
          metadata?: Json
          next_review_due_at?: string | null
          policy_conditions?: Json
          policy_name: string
          policy_status?: string
          regulatory_reference?: string | null
          retention_period_days: number
          retention_policy_reference: string
          retention_trigger: string
          review_interval_days?: number | null
          schema_name?: string | null
          table_name?: string | null
          updated_at?: string
        }
        Update: {
          anonymize_after_days?: number | null
          approval_required?: boolean
          approved_at?: string | null
          approved_by?: string | null
          archive_after_days?: number | null
          archive_configuration?: Json
          archive_storage_class?: string | null
          automated_execution?: boolean
          created_at?: string
          delete_after_days?: number | null
          deletion_configuration?: Json
          disposition_method?: string
          effective_from?: string
          effective_until?: string | null
          entity_type?: string
          exclusion_conditions?: Json
          id?: string
          last_reviewed_at?: string | null
          legal_basis?: string | null
          legal_hold_override?: boolean
          metadata?: Json
          next_review_due_at?: string | null
          policy_conditions?: Json
          policy_name?: string
          policy_status?: string
          regulatory_reference?: string | null
          retention_period_days?: number
          retention_policy_reference?: string
          retention_trigger?: string
          review_interval_days?: number | null
          schema_name?: string | null
          table_name?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      eligibility_assessments: {
        Row: {
          age_requirement_satisfied: boolean | null
          assessed_at: string
          assessment_method: string
          assessment_status: Database["public"]["Enums"]["eligibility_assessment_status"]
          assessment_version: string
          banking_relationship_requirement_satisfied: boolean | null
          calculated_age: number | null
          card_id: string
          confidence_level: Database["public"]["Enums"]["recommendation_confidence_level"]
          confidence_score: number | null
          created_at: string
          customer_segment_requirement_satisfied: boolean | null
          eligibility_score: number | null
          employment_requirement_satisfied: boolean | null
          expires_at: string | null
          financial_profile_id: string
          hard_requirements_failed: number
          hard_requirements_passed: number
          hard_requirements_total: number
          id: string
          income_currency_id: string | null
          income_requirement_satisfied: boolean | null
          input_snapshot: Json
          is_current: boolean
          manual_review_reason_ar: string | null
          manual_review_reason_en: string | null
          manual_review_required: boolean
          maximum_allowed_age: number | null
          metadata: Json
          minimum_required_age: number | null
          minimum_required_income: number | null
          monthly_income_used: number | null
          nationality_requirement_satisfied: boolean | null
          primary_exclusion_reason:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          requirements_conditionally_passed: number
          requirements_failed: number
          requirements_not_applicable: number
          requirements_passed: number
          requirements_total: number
          requirements_unknown: number
          residency_requirement_satisfied: boolean | null
          salary_transfer_satisfied: boolean | null
          source_snapshot: Json
          updated_at: string
        }
        Insert: {
          age_requirement_satisfied?: boolean | null
          assessed_at?: string
          assessment_method?: string
          assessment_status?: Database["public"]["Enums"]["eligibility_assessment_status"]
          assessment_version?: string
          banking_relationship_requirement_satisfied?: boolean | null
          calculated_age?: number | null
          card_id: string
          confidence_level?: Database["public"]["Enums"]["recommendation_confidence_level"]
          confidence_score?: number | null
          created_at?: string
          customer_segment_requirement_satisfied?: boolean | null
          eligibility_score?: number | null
          employment_requirement_satisfied?: boolean | null
          expires_at?: string | null
          financial_profile_id: string
          hard_requirements_failed?: number
          hard_requirements_passed?: number
          hard_requirements_total?: number
          id?: string
          income_currency_id?: string | null
          income_requirement_satisfied?: boolean | null
          input_snapshot?: Json
          is_current?: boolean
          manual_review_reason_ar?: string | null
          manual_review_reason_en?: string | null
          manual_review_required?: boolean
          maximum_allowed_age?: number | null
          metadata?: Json
          minimum_required_age?: number | null
          minimum_required_income?: number | null
          monthly_income_used?: number | null
          nationality_requirement_satisfied?: boolean | null
          primary_exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          requirements_conditionally_passed?: number
          requirements_failed?: number
          requirements_not_applicable?: number
          requirements_passed?: number
          requirements_total?: number
          requirements_unknown?: number
          residency_requirement_satisfied?: boolean | null
          salary_transfer_satisfied?: boolean | null
          source_snapshot?: Json
          updated_at?: string
        }
        Update: {
          age_requirement_satisfied?: boolean | null
          assessed_at?: string
          assessment_method?: string
          assessment_status?: Database["public"]["Enums"]["eligibility_assessment_status"]
          assessment_version?: string
          banking_relationship_requirement_satisfied?: boolean | null
          calculated_age?: number | null
          card_id?: string
          confidence_level?: Database["public"]["Enums"]["recommendation_confidence_level"]
          confidence_score?: number | null
          created_at?: string
          customer_segment_requirement_satisfied?: boolean | null
          eligibility_score?: number | null
          employment_requirement_satisfied?: boolean | null
          expires_at?: string | null
          financial_profile_id?: string
          hard_requirements_failed?: number
          hard_requirements_passed?: number
          hard_requirements_total?: number
          id?: string
          income_currency_id?: string | null
          income_requirement_satisfied?: boolean | null
          input_snapshot?: Json
          is_current?: boolean
          manual_review_reason_ar?: string | null
          manual_review_reason_en?: string | null
          manual_review_required?: boolean
          maximum_allowed_age?: number | null
          metadata?: Json
          minimum_required_age?: number | null
          minimum_required_income?: number | null
          monthly_income_used?: number | null
          nationality_requirement_satisfied?: boolean | null
          primary_exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          requirements_conditionally_passed?: number
          requirements_failed?: number
          requirements_not_applicable?: number
          requirements_passed?: number
          requirements_total?: number
          requirements_unknown?: number
          residency_requirement_satisfied?: boolean | null
          salary_transfer_satisfied?: boolean | null
          source_snapshot?: Json
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "eligibility_assessments_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eligibility_assessments_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eligibility_assessments_income_currency_id_fkey"
            columns: ["income_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      eligibility_requirement_assessments: {
        Row: {
          confidence_score: number | null
          created_at: string
          currency_id: string | null
          customer_value_numeric: number | null
          customer_value_text: string | null
          customer_values: Json | null
          eligibility_assessment_id: string
          eligibility_requirement_id: string | null
          evaluated_at: string
          evaluation_details: Json
          evaluation_method: string
          exclusion_reason:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          explanation_ar: string | null
          explanation_en: string | null
          id: string
          is_exclusion_trigger: boolean
          is_hard_requirement: boolean
          matched: boolean | null
          metadata: Json
          missing_information_ar: string | null
          missing_information_en: string | null
          required_maximum_numeric: number | null
          required_minimum_numeric: number | null
          required_value_text: string | null
          required_values: Json | null
          requirement_code: string
          requirement_result: Database["public"]["Enums"]["eligibility_requirement_result"]
          requirement_type: string
          result_score: number | null
          rule_version: string
          updated_at: string
        }
        Insert: {
          confidence_score?: number | null
          created_at?: string
          currency_id?: string | null
          customer_value_numeric?: number | null
          customer_value_text?: string | null
          customer_values?: Json | null
          eligibility_assessment_id: string
          eligibility_requirement_id?: string | null
          evaluated_at?: string
          evaluation_details?: Json
          evaluation_method?: string
          exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          explanation_ar?: string | null
          explanation_en?: string | null
          id?: string
          is_exclusion_trigger?: boolean
          is_hard_requirement?: boolean
          matched?: boolean | null
          metadata?: Json
          missing_information_ar?: string | null
          missing_information_en?: string | null
          required_maximum_numeric?: number | null
          required_minimum_numeric?: number | null
          required_value_text?: string | null
          required_values?: Json | null
          requirement_code: string
          requirement_result?: Database["public"]["Enums"]["eligibility_requirement_result"]
          requirement_type: string
          result_score?: number | null
          rule_version?: string
          updated_at?: string
        }
        Update: {
          confidence_score?: number | null
          created_at?: string
          currency_id?: string | null
          customer_value_numeric?: number | null
          customer_value_text?: string | null
          customer_values?: Json | null
          eligibility_assessment_id?: string
          eligibility_requirement_id?: string | null
          evaluated_at?: string
          evaluation_details?: Json
          evaluation_method?: string
          exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          explanation_ar?: string | null
          explanation_en?: string | null
          id?: string
          is_exclusion_trigger?: boolean
          is_hard_requirement?: boolean
          matched?: boolean | null
          metadata?: Json
          missing_information_ar?: string | null
          missing_information_en?: string | null
          required_maximum_numeric?: number | null
          required_minimum_numeric?: number | null
          required_value_text?: string | null
          required_values?: Json | null
          requirement_code?: string
          requirement_result?: Database["public"]["Enums"]["eligibility_requirement_result"]
          requirement_type?: string
          result_score?: number | null
          rule_version?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "eligibility_requirement_assessm_eligibility_requirement_id_fkey"
            columns: ["eligibility_requirement_id"]
            isOneToOne: false
            referencedRelation: "card_eligibility_requirements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eligibility_requirement_assessme_eligibility_assessment_id_fkey"
            columns: ["eligibility_assessment_id"]
            isOneToOne: false
            referencedRelation: "eligibility_assessments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eligibility_requirement_assessments_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      feature_flags: {
        Row: {
          activates_at: string | null
          administrative_reason: string
          created_at: string
          created_by_user_id: string | null
          default_enabled: boolean
          description: string | null
          display_name: string
          expires_at: string | null
          flag_key: string
          id: string
          lifecycle_status: string
          metadata: Json
          rollout_percentage: number | null
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          activates_at?: string | null
          administrative_reason: string
          created_at?: string
          created_by_user_id?: string | null
          default_enabled?: boolean
          description?: string | null
          display_name: string
          expires_at?: string | null
          flag_key: string
          id?: string
          lifecycle_status?: string
          metadata?: Json
          rollout_percentage?: number | null
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          activates_at?: string | null
          administrative_reason?: string
          created_at?: string
          created_by_user_id?: string | null
          default_enabled?: boolean
          description?: string | null
          display_name?: string
          expires_at?: string | null
          flag_key?: string
          id?: string
          lifecycle_status?: string
          metadata?: Json
          rollout_percentage?: number | null
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: []
      }
      governance_control_assessments: {
        Row: {
          approved_at: string | null
          approver_user_id: string | null
          assessment_period_end: string | null
          assessment_period_start: string | null
          assessment_reference: string
          assessment_result: string | null
          assessment_status: string
          assessment_type: string
          assessor_notes: string | null
          assessor_user_id: string | null
          completed_at: string | null
          conclusion: string | null
          confidence_score: number | null
          control_id: string
          created_at: string
          effectiveness_score: number | null
          evidence_summary: Json
          exceptions: Json
          exceptions_found: number
          id: string
          metadata: Json
          remediation_completed_at: string | null
          remediation_due_at: string | null
          remediation_plan: Json
          remediation_required: boolean
          reviewed_at: string | null
          reviewer_notes: string | null
          reviewer_user_id: string | null
          sample_size: number | null
          scheduled_at: string | null
          severity: string | null
          started_at: string | null
          test_procedures: Json
          test_results: Json
          updated_at: string
        }
        Insert: {
          approved_at?: string | null
          approver_user_id?: string | null
          assessment_period_end?: string | null
          assessment_period_start?: string | null
          assessment_reference: string
          assessment_result?: string | null
          assessment_status?: string
          assessment_type: string
          assessor_notes?: string | null
          assessor_user_id?: string | null
          completed_at?: string | null
          conclusion?: string | null
          confidence_score?: number | null
          control_id: string
          created_at?: string
          effectiveness_score?: number | null
          evidence_summary?: Json
          exceptions?: Json
          exceptions_found?: number
          id?: string
          metadata?: Json
          remediation_completed_at?: string | null
          remediation_due_at?: string | null
          remediation_plan?: Json
          remediation_required?: boolean
          reviewed_at?: string | null
          reviewer_notes?: string | null
          reviewer_user_id?: string | null
          sample_size?: number | null
          scheduled_at?: string | null
          severity?: string | null
          started_at?: string | null
          test_procedures?: Json
          test_results?: Json
          updated_at?: string
        }
        Update: {
          approved_at?: string | null
          approver_user_id?: string | null
          assessment_period_end?: string | null
          assessment_period_start?: string | null
          assessment_reference?: string
          assessment_result?: string | null
          assessment_status?: string
          assessment_type?: string
          assessor_notes?: string | null
          assessor_user_id?: string | null
          completed_at?: string | null
          conclusion?: string | null
          confidence_score?: number | null
          control_id?: string
          created_at?: string
          effectiveness_score?: number | null
          evidence_summary?: Json
          exceptions?: Json
          exceptions_found?: number
          id?: string
          metadata?: Json
          remediation_completed_at?: string | null
          remediation_due_at?: string | null
          remediation_plan?: Json
          remediation_required?: boolean
          reviewed_at?: string | null
          reviewer_notes?: string | null
          reviewer_user_id?: string | null
          sample_size?: number | null
          scheduled_at?: string | null
          severity?: string | null
          started_at?: string | null
          test_procedures?: Json
          test_results?: Json
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "governance_control_assessments_control_id_fkey"
            columns: ["control_id"]
            isOneToOne: false
            referencedRelation: "governance_controls"
            referencedColumns: ["id"]
          },
        ]
      }
      governance_controls: {
        Row: {
          approval_owner_user_id: string | null
          approved_at: string | null
          approved_by: string | null
          automation_level: string
          control_category: string
          control_description: string | null
          control_domain: string
          control_frequency: string
          control_name: string
          control_owner_user_id: string | null
          control_reference: string
          control_status: string
          control_type: string
          created_at: string
          effective_from: string | null
          effective_until: string | null
          evidence_owner_user_id: string | null
          evidence_requirements: Json
          evidence_retention_days: number | null
          id: string
          implementation_guidance: Json
          last_reviewed_at: string | null
          metadata: Json
          next_review_due_at: string | null
          policy_references: Json
          regulatory_references: Json
          requires_approval: boolean
          requires_evidence: boolean
          requires_periodic_testing: boolean
          retired_at: string | null
          retirement_reason: string | null
          risk_level: string
          suspended_at: string | null
          suspension_reason: string | null
          testing_configuration: Json
          testing_interval_days: number | null
          updated_at: string
        }
        Insert: {
          approval_owner_user_id?: string | null
          approved_at?: string | null
          approved_by?: string | null
          automation_level?: string
          control_category: string
          control_description?: string | null
          control_domain: string
          control_frequency?: string
          control_name: string
          control_owner_user_id?: string | null
          control_reference: string
          control_status?: string
          control_type: string
          created_at?: string
          effective_from?: string | null
          effective_until?: string | null
          evidence_owner_user_id?: string | null
          evidence_requirements?: Json
          evidence_retention_days?: number | null
          id?: string
          implementation_guidance?: Json
          last_reviewed_at?: string | null
          metadata?: Json
          next_review_due_at?: string | null
          policy_references?: Json
          regulatory_references?: Json
          requires_approval?: boolean
          requires_evidence?: boolean
          requires_periodic_testing?: boolean
          retired_at?: string | null
          retirement_reason?: string | null
          risk_level?: string
          suspended_at?: string | null
          suspension_reason?: string | null
          testing_configuration?: Json
          testing_interval_days?: number | null
          updated_at?: string
        }
        Update: {
          approval_owner_user_id?: string | null
          approved_at?: string | null
          approved_by?: string | null
          automation_level?: string
          control_category?: string
          control_description?: string | null
          control_domain?: string
          control_frequency?: string
          control_name?: string
          control_owner_user_id?: string | null
          control_reference?: string
          control_status?: string
          control_type?: string
          created_at?: string
          effective_from?: string | null
          effective_until?: string | null
          evidence_owner_user_id?: string | null
          evidence_requirements?: Json
          evidence_retention_days?: number | null
          id?: string
          implementation_guidance?: Json
          last_reviewed_at?: string | null
          metadata?: Json
          next_review_due_at?: string | null
          policy_references?: Json
          regulatory_references?: Json
          requires_approval?: boolean
          requires_evidence?: boolean
          requires_periodic_testing?: boolean
          retired_at?: string | null
          retirement_reason?: string | null
          risk_level?: string
          suspended_at?: string | null
          suspension_reason?: string | null
          testing_configuration?: Json
          testing_interval_days?: number | null
          updated_at?: string
        }
        Relationships: []
      }
      legal_hold_items: {
        Row: {
          created_at: string
          entity_id: string | null
          entity_reference: string | null
          entity_type: string
          hold_item_reference: string
          id: string
          integrity_hash: string | null
          item_status: string
          legal_hold_id: string
          metadata: Json
          preservation_details: Json
          preservation_method: string
          preserved_at: string
          released_at: string | null
          source_snapshot: Json
          storage_reference: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          created_at?: string
          entity_id?: string | null
          entity_reference?: string | null
          entity_type: string
          hold_item_reference: string
          id?: string
          integrity_hash?: string | null
          item_status?: string
          legal_hold_id: string
          metadata?: Json
          preservation_details?: Json
          preservation_method?: string
          preserved_at?: string
          released_at?: string | null
          source_snapshot?: Json
          storage_reference?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          created_at?: string
          entity_id?: string | null
          entity_reference?: string | null
          entity_type?: string
          hold_item_reference?: string
          id?: string
          integrity_hash?: string | null
          item_status?: string
          legal_hold_id?: string
          metadata?: Json
          preservation_details?: Json
          preservation_method?: string
          preserved_at?: string
          released_at?: string | null
          source_snapshot?: Json
          storage_reference?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "legal_hold_items_legal_hold_id_fkey"
            columns: ["legal_hold_id"]
            isOneToOne: false
            referencedRelation: "legal_holds"
            referencedColumns: ["id"]
          },
        ]
      }
      legal_holds: {
        Row: {
          approved_at: string | null
          approved_by_user_id: string | null
          case_reference: string | null
          collection_instructions: Json
          created_at: string
          custodian_user_id: string | null
          data_scope: Json
          effective_from: string
          effective_until: string | null
          entity_references: Json
          entity_types: Json
          hold_name: string
          hold_status: string
          hold_type: string
          id: string
          issuing_entity: string | null
          legal_authority: string | null
          legal_hold_reference: string
          matter_reference: string | null
          metadata: Json
          notification_details: Json
          reason: string
          release_reason: string | null
          released_at: string | null
          released_by_user_id: string | null
          requested_by_user_id: string | null
          scope_description: string
          updated_at: string
          user_references: Json
        }
        Insert: {
          approved_at?: string | null
          approved_by_user_id?: string | null
          case_reference?: string | null
          collection_instructions?: Json
          created_at?: string
          custodian_user_id?: string | null
          data_scope?: Json
          effective_from?: string
          effective_until?: string | null
          entity_references?: Json
          entity_types?: Json
          hold_name: string
          hold_status?: string
          hold_type: string
          id?: string
          issuing_entity?: string | null
          legal_authority?: string | null
          legal_hold_reference: string
          matter_reference?: string | null
          metadata?: Json
          notification_details?: Json
          reason: string
          release_reason?: string | null
          released_at?: string | null
          released_by_user_id?: string | null
          requested_by_user_id?: string | null
          scope_description: string
          updated_at?: string
          user_references?: Json
        }
        Update: {
          approved_at?: string | null
          approved_by_user_id?: string | null
          case_reference?: string | null
          collection_instructions?: Json
          created_at?: string
          custodian_user_id?: string | null
          data_scope?: Json
          effective_from?: string
          effective_until?: string | null
          entity_references?: Json
          entity_types?: Json
          hold_name?: string
          hold_status?: string
          hold_type?: string
          id?: string
          issuing_entity?: string | null
          legal_authority?: string | null
          legal_hold_reference?: string
          matter_reference?: string | null
          metadata?: Json
          notification_details?: Json
          reason?: string
          release_reason?: string | null
          released_at?: string | null
          released_by_user_id?: string | null
          requested_by_user_id?: string | null
          scope_description?: string
          updated_at?: string
          user_references?: Json
        }
        Relationships: []
      }
      loyalty_programs: {
        Row: {
          created_at: string
          id: string
          is_active: boolean
          logo_url: string | null
          name_ar: string
          name_en: string
          slug: string
          type: Database["public"]["Enums"]["loyalty_program_type"]
          updated_at: string
          website_url: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          is_active?: boolean
          logo_url?: string | null
          name_ar: string
          name_en: string
          slug: string
          type: Database["public"]["Enums"]["loyalty_program_type"]
          updated_at?: string
          website_url?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          is_active?: boolean
          logo_url?: string | null
          name_ar?: string
          name_en?: string
          slug?: string
          type?: Database["public"]["Enums"]["loyalty_program_type"]
          updated_at?: string
          website_url?: string | null
        }
        Relationships: []
      }
      merchant_aliases: {
        Row: {
          alias: string
          alias_language: string
          alias_type: string
          created_at: string
          created_by_user_id: string | null
          id: string
          is_active: boolean
          merchant_id: string
          normalized_alias: string | null
          notes: string | null
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          alias: string
          alias_language: string
          alias_type?: string
          created_at?: string
          created_by_user_id?: string | null
          id?: string
          is_active?: boolean
          merchant_id: string
          normalized_alias?: string | null
          notes?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          alias?: string
          alias_language?: string
          alias_type?: string
          created_at?: string
          created_by_user_id?: string | null
          id?: string
          is_active?: boolean
          merchant_id?: string
          normalized_alias?: string | null
          notes?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "merchant_aliases_merchant_id_fkey"
            columns: ["merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
        ]
      }
      merchant_categories: {
        Row: {
          code: string
          created_at: string
          description_ar: string | null
          description_en: string | null
          id: string
          is_active: boolean
          name_ar: string
          name_en: string
          slug: string
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          name_ar: string
          name_en: string
          slug: string
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          name_ar?: string
          name_en?: string
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      merchant_category_assignments: {
        Row: {
          created_at: string
          created_by_user_id: string | null
          id: string
          is_primary: boolean
          merchant_category_id: string
          merchant_id: string
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          created_at?: string
          created_by_user_id?: string | null
          id?: string
          is_primary?: boolean
          merchant_category_id: string
          merchant_id: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          created_at?: string
          created_by_user_id?: string | null
          id?: string
          is_primary?: boolean
          merchant_category_id?: string
          merchant_id?: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "merchant_category_assignments_merchant_category_id_fkey"
            columns: ["merchant_category_id"]
            isOneToOne: false
            referencedRelation: "merchant_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "merchant_category_assignments_merchant_id_fkey"
            columns: ["merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
        ]
      }
      merchant_domains: {
        Row: {
          created_at: string
          created_by_user_id: string | null
          domain: string
          domain_type: string
          id: string
          is_active: boolean
          is_primary: boolean
          merchant_id: string
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          created_at?: string
          created_by_user_id?: string | null
          domain: string
          domain_type?: string
          id?: string
          is_active?: boolean
          is_primary?: boolean
          merchant_id: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          created_at?: string
          created_by_user_id?: string | null
          domain?: string
          domain_type?: string
          id?: string
          is_active?: boolean
          is_primary?: boolean
          merchant_id?: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "merchant_domains_merchant_id_fkey"
            columns: ["merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
        ]
      }
      merchant_market_presence: {
        Row: {
          country_id: string
          created_at: string
          created_by_user_id: string | null
          id: string
          is_active: boolean
          merchant_id: string
          presence_type: string
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          country_id: string
          created_at?: string
          created_by_user_id?: string | null
          id?: string
          is_active?: boolean
          merchant_id: string
          presence_type?: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          country_id?: string
          created_at?: string
          created_by_user_id?: string | null
          id?: string
          is_active?: boolean
          merchant_id?: string
          presence_type?: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "merchant_market_presence_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "merchant_market_presence_merchant_id_fkey"
            columns: ["merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
        ]
      }
      merchant_relationships: {
        Row: {
          child_merchant_id: string
          created_at: string
          created_by_user_id: string | null
          id: string
          is_active: boolean
          notes: string | null
          parent_merchant_id: string
          relationship_type: string
          updated_at: string
          updated_by_user_id: string | null
        }
        Insert: {
          child_merchant_id: string
          created_at?: string
          created_by_user_id?: string | null
          id?: string
          is_active?: boolean
          notes?: string | null
          parent_merchant_id: string
          relationship_type: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Update: {
          child_merchant_id?: string
          created_at?: string
          created_by_user_id?: string | null
          id?: string
          is_active?: boolean
          notes?: string | null
          parent_merchant_id?: string
          relationship_type?: string
          updated_at?: string
          updated_by_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "merchant_relationships_child_merchant_id_fkey"
            columns: ["child_merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "merchant_relationships_parent_merchant_id_fkey"
            columns: ["parent_merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
        ]
      }
      merchants: {
        Row: {
          archived_at: string | null
          archived_by_user_id: string | null
          channel_type: string
          created_at: string
          created_by_user_id: string | null
          description_ar: string | null
          description_en: string | null
          display_name_ar: string
          display_name_en: string
          headquarters_country_id: string | null
          id: string
          legal_name_ar: string | null
          legal_name_en: string | null
          lifecycle_status: string
          merchant_classification: string
          metadata: Json
          rejected_at: string | null
          rejected_by_user_id: string | null
          rejection_reason: string | null
          slug: string
          superseded_at: string | null
          superseded_by_merchant_id: string | null
          updated_at: string
          updated_by_user_id: string | null
          verification_status: string
          verified_at: string | null
          verified_by_user_id: string | null
        }
        Insert: {
          archived_at?: string | null
          archived_by_user_id?: string | null
          channel_type?: string
          created_at?: string
          created_by_user_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          display_name_ar: string
          display_name_en: string
          headquarters_country_id?: string | null
          id?: string
          legal_name_ar?: string | null
          legal_name_en?: string | null
          lifecycle_status?: string
          merchant_classification?: string
          metadata?: Json
          rejected_at?: string | null
          rejected_by_user_id?: string | null
          rejection_reason?: string | null
          slug: string
          superseded_at?: string | null
          superseded_by_merchant_id?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
          verification_status?: string
          verified_at?: string | null
          verified_by_user_id?: string | null
        }
        Update: {
          archived_at?: string | null
          archived_by_user_id?: string | null
          channel_type?: string
          created_at?: string
          created_by_user_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          display_name_ar?: string
          display_name_en?: string
          headquarters_country_id?: string | null
          id?: string
          legal_name_ar?: string | null
          legal_name_en?: string | null
          lifecycle_status?: string
          merchant_classification?: string
          metadata?: Json
          rejected_at?: string | null
          rejected_by_user_id?: string | null
          rejection_reason?: string | null
          slug?: string
          superseded_at?: string | null
          superseded_by_merchant_id?: string | null
          updated_at?: string
          updated_by_user_id?: string | null
          verification_status?: string
          verified_at?: string | null
          verified_by_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "merchants_headquarters_country_id_fkey"
            columns: ["headquarters_country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "merchants_superseded_by_merchant_id_fkey"
            columns: ["superseded_by_merchant_id"]
            isOneToOne: false
            referencedRelation: "merchants"
            referencedColumns: ["id"]
          },
        ]
      }
      notification_deliveries: {
        Row: {
          accepted_at: string | null
          attempt_number: number
          bounced_at: string | null
          channel: string
          clicked_at: string | null
          complained_at: string | null
          cost_amount: number | null
          cost_currency_code: string | null
          created_at: string
          delivered_at: string | null
          delivery_metadata: Json
          delivery_priority: string
          delivery_reference: string
          delivery_status: string
          failed_at: string | null
          failure_category: string | null
          failure_code: string | null
          failure_message: string | null
          id: string
          latency_milliseconds: number | null
          maximum_attempts: number
          next_retry_at: string | null
          notification_id: string
          opened_at: string | null
          provider_code: string | null
          provider_message_reference: string | null
          provider_request: Json
          provider_response: Json
          provider_status_code: string | null
          queued_at: string
          recipient_address: string | null
          rejected_at: string | null
          scheduled_for: string
          sending_started_at: string | null
          sent_at: string | null
          sequence_number: number
          tracking_data: Json
          unsubscribed_at: string | null
          updated_at: string
        }
        Insert: {
          accepted_at?: string | null
          attempt_number?: number
          bounced_at?: string | null
          channel: string
          clicked_at?: string | null
          complained_at?: string | null
          cost_amount?: number | null
          cost_currency_code?: string | null
          created_at?: string
          delivered_at?: string | null
          delivery_metadata?: Json
          delivery_priority?: string
          delivery_reference: string
          delivery_status?: string
          failed_at?: string | null
          failure_category?: string | null
          failure_code?: string | null
          failure_message?: string | null
          id?: string
          latency_milliseconds?: number | null
          maximum_attempts?: number
          next_retry_at?: string | null
          notification_id: string
          opened_at?: string | null
          provider_code?: string | null
          provider_message_reference?: string | null
          provider_request?: Json
          provider_response?: Json
          provider_status_code?: string | null
          queued_at?: string
          recipient_address?: string | null
          rejected_at?: string | null
          scheduled_for?: string
          sending_started_at?: string | null
          sent_at?: string | null
          sequence_number?: number
          tracking_data?: Json
          unsubscribed_at?: string | null
          updated_at?: string
        }
        Update: {
          accepted_at?: string | null
          attempt_number?: number
          bounced_at?: string | null
          channel?: string
          clicked_at?: string | null
          complained_at?: string | null
          cost_amount?: number | null
          cost_currency_code?: string | null
          created_at?: string
          delivered_at?: string | null
          delivery_metadata?: Json
          delivery_priority?: string
          delivery_reference?: string
          delivery_status?: string
          failed_at?: string | null
          failure_category?: string | null
          failure_code?: string | null
          failure_message?: string | null
          id?: string
          latency_milliseconds?: number | null
          maximum_attempts?: number
          next_retry_at?: string | null
          notification_id?: string
          opened_at?: string | null
          provider_code?: string | null
          provider_message_reference?: string | null
          provider_request?: Json
          provider_response?: Json
          provider_status_code?: string | null
          queued_at?: string
          recipient_address?: string | null
          rejected_at?: string | null
          scheduled_for?: string
          sending_started_at?: string | null
          sent_at?: string | null
          sequence_number?: number
          tracking_data?: Json
          unsubscribed_at?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "notification_deliveries_notification_id_fkey"
            columns: ["notification_id"]
            isOneToOne: false
            referencedRelation: "notifications"
            referencedColumns: ["id"]
          },
        ]
      }
      notification_subscriptions: {
        Row: {
          bank_id: string | null
          baseline_numeric_value: number | null
          card_id: string | null
          channel_overrides: Json
          collection_id: string | null
          comparison_id: string | null
          cooldown_minutes: number
          created_at: string
          delivery_mode: string
          event_category: string | null
          expires_at: string | null
          filter_configuration: Json
          id: string
          is_active: boolean
          is_paused: boolean
          last_notified_at: string | null
          last_triggered_at: string | null
          maximum_alerts_per_day: number | null
          maximum_alerts_per_week: number | null
          metadata: Json
          minimum_priority: string
          notification_count: number
          notification_type: string | null
          paused_until: string | null
          preferred_channel: string | null
          saved_card_id: string | null
          starts_at: string
          subscription_reference: string
          subscription_type: string
          target_entity_id: string | null
          target_entity_type: string
          threshold_configuration: Json
          threshold_numeric_value: number | null
          threshold_operator: string | null
          threshold_percentage: number | null
          threshold_text_value: string | null
          trigger_count: number
          updated_at: string
          user_id: string
        }
        Insert: {
          bank_id?: string | null
          baseline_numeric_value?: number | null
          card_id?: string | null
          channel_overrides?: Json
          collection_id?: string | null
          comparison_id?: string | null
          cooldown_minutes?: number
          created_at?: string
          delivery_mode?: string
          event_category?: string | null
          expires_at?: string | null
          filter_configuration?: Json
          id?: string
          is_active?: boolean
          is_paused?: boolean
          last_notified_at?: string | null
          last_triggered_at?: string | null
          maximum_alerts_per_day?: number | null
          maximum_alerts_per_week?: number | null
          metadata?: Json
          minimum_priority?: string
          notification_count?: number
          notification_type?: string | null
          paused_until?: string | null
          preferred_channel?: string | null
          saved_card_id?: string | null
          starts_at?: string
          subscription_reference: string
          subscription_type: string
          target_entity_id?: string | null
          target_entity_type: string
          threshold_configuration?: Json
          threshold_numeric_value?: number | null
          threshold_operator?: string | null
          threshold_percentage?: number | null
          threshold_text_value?: string | null
          trigger_count?: number
          updated_at?: string
          user_id: string
        }
        Update: {
          bank_id?: string | null
          baseline_numeric_value?: number | null
          card_id?: string | null
          channel_overrides?: Json
          collection_id?: string | null
          comparison_id?: string | null
          cooldown_minutes?: number
          created_at?: string
          delivery_mode?: string
          event_category?: string | null
          expires_at?: string | null
          filter_configuration?: Json
          id?: string
          is_active?: boolean
          is_paused?: boolean
          last_notified_at?: string | null
          last_triggered_at?: string | null
          maximum_alerts_per_day?: number | null
          maximum_alerts_per_week?: number | null
          metadata?: Json
          minimum_priority?: string
          notification_count?: number
          notification_type?: string | null
          paused_until?: string | null
          preferred_channel?: string | null
          saved_card_id?: string | null
          starts_at?: string
          subscription_reference?: string
          subscription_type?: string
          target_entity_id?: string | null
          target_entity_type?: string
          threshold_configuration?: Json
          threshold_numeric_value?: number | null
          threshold_operator?: string | null
          threshold_percentage?: number | null
          threshold_text_value?: string | null
          trigger_count?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "notification_subscriptions_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notification_subscriptions_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notification_subscriptions_collection_id_fkey"
            columns: ["collection_id"]
            isOneToOne: false
            referencedRelation: "user_card_collections"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notification_subscriptions_comparison_id_fkey"
            columns: ["comparison_id"]
            isOneToOne: false
            referencedRelation: "card_comparisons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notification_subscriptions_saved_card_id_fkey"
            columns: ["saved_card_id"]
            isOneToOne: false
            referencedRelation: "user_saved_cards"
            referencedColumns: ["id"]
          },
        ]
      }
      notification_templates: {
        Row: {
          action_label_template: string | null
          action_url_template: string | null
          approved_at: string | null
          approved_by: string | null
          body_template: string
          channel: string
          channel_configuration: Json
          created_at: string
          created_by: string | null
          icon_code: string | null
          id: string
          image_url_template: string | null
          is_active: boolean
          is_default: boolean
          is_marketing: boolean
          is_system_template: boolean
          is_transactional: boolean
          language_code: string
          metadata: Json
          notification_type: string
          optional_variables: Json
          priority_level: string
          required_variables: Json
          requires_user_consent: boolean
          sample_payload: Json
          short_body_template: string | null
          subject_template: string | null
          supports_batching: boolean
          supports_digest: boolean
          supports_personalization: boolean
          template_code: string
          template_name: string
          template_status: string
          template_version: number
          title_template: string
          updated_at: string
          valid_from: string | null
          valid_until: string | null
        }
        Insert: {
          action_label_template?: string | null
          action_url_template?: string | null
          approved_at?: string | null
          approved_by?: string | null
          body_template: string
          channel: string
          channel_configuration?: Json
          created_at?: string
          created_by?: string | null
          icon_code?: string | null
          id?: string
          image_url_template?: string | null
          is_active?: boolean
          is_default?: boolean
          is_marketing?: boolean
          is_system_template?: boolean
          is_transactional?: boolean
          language_code?: string
          metadata?: Json
          notification_type: string
          optional_variables?: Json
          priority_level?: string
          required_variables?: Json
          requires_user_consent?: boolean
          sample_payload?: Json
          short_body_template?: string | null
          subject_template?: string | null
          supports_batching?: boolean
          supports_digest?: boolean
          supports_personalization?: boolean
          template_code: string
          template_name: string
          template_status?: string
          template_version?: number
          title_template: string
          updated_at?: string
          valid_from?: string | null
          valid_until?: string | null
        }
        Update: {
          action_label_template?: string | null
          action_url_template?: string | null
          approved_at?: string | null
          approved_by?: string | null
          body_template?: string
          channel?: string
          channel_configuration?: Json
          created_at?: string
          created_by?: string | null
          icon_code?: string | null
          id?: string
          image_url_template?: string | null
          is_active?: boolean
          is_default?: boolean
          is_marketing?: boolean
          is_system_template?: boolean
          is_transactional?: boolean
          language_code?: string
          metadata?: Json
          notification_type?: string
          optional_variables?: Json
          priority_level?: string
          required_variables?: Json
          requires_user_consent?: boolean
          sample_payload?: Json
          short_body_template?: string | null
          subject_template?: string | null
          supports_batching?: boolean
          supports_digest?: boolean
          supports_personalization?: boolean
          template_code?: string
          template_name?: string
          template_status?: string
          template_version?: number
          title_template?: string
          updated_at?: string
          valid_from?: string | null
          valid_until?: string | null
        }
        Relationships: []
      }
      notifications: {
        Row: {
          acknowledged_at: string | null
          action_label: string | null
          action_url: string | null
          alert_event_id: string | null
          archived_at: string | null
          bank_id: string | null
          batch_reference: string | null
          body: string
          cancelled_at: string | null
          card_id: string | null
          channel_plan: Json
          comparison_id: string | null
          correlation_id: string | null
          created_at: string
          deduplication_key: string | null
          delivery_summary: Json
          digest_reference: string | null
          dismissed_at: string | null
          expires_at: string | null
          failed_at: string | null
          failure_code: string | null
          failure_message: string | null
          first_clicked_at: string | null
          first_delivered_at: string | null
          first_opened_at: string | null
          icon_code: string | null
          id: string
          image_url: string | null
          is_archived: boolean
          is_clicked: boolean
          is_dismissed: boolean
          is_marketing: boolean
          is_opened: boolean
          is_read: boolean
          is_silent: boolean
          is_transactional: boolean
          language_code: string
          maximum_retry_count: number
          metadata: Json
          next_retry_at: string | null
          notification_category: string
          notification_reference: string
          notification_status: string
          notification_type: string
          payload: Json
          personalization_context: Json
          priority_level: string
          processing_started_at: string | null
          queued_at: string
          read_at: string | null
          recommendation_run_id: string | null
          rendered_content: Json
          requires_acknowledgement: boolean
          retry_count: number
          saved_card_id: string | null
          scheduled_for: string
          sent_at: string | null
          short_body: string | null
          subscription_id: string | null
          target_entity_id: string | null
          target_entity_type: string | null
          template_id: string | null
          title: string
          updated_at: string
          user_id: string
        }
        Insert: {
          acknowledged_at?: string | null
          action_label?: string | null
          action_url?: string | null
          alert_event_id?: string | null
          archived_at?: string | null
          bank_id?: string | null
          batch_reference?: string | null
          body: string
          cancelled_at?: string | null
          card_id?: string | null
          channel_plan?: Json
          comparison_id?: string | null
          correlation_id?: string | null
          created_at?: string
          deduplication_key?: string | null
          delivery_summary?: Json
          digest_reference?: string | null
          dismissed_at?: string | null
          expires_at?: string | null
          failed_at?: string | null
          failure_code?: string | null
          failure_message?: string | null
          first_clicked_at?: string | null
          first_delivered_at?: string | null
          first_opened_at?: string | null
          icon_code?: string | null
          id?: string
          image_url?: string | null
          is_archived?: boolean
          is_clicked?: boolean
          is_dismissed?: boolean
          is_marketing?: boolean
          is_opened?: boolean
          is_read?: boolean
          is_silent?: boolean
          is_transactional?: boolean
          language_code?: string
          maximum_retry_count?: number
          metadata?: Json
          next_retry_at?: string | null
          notification_category: string
          notification_reference: string
          notification_status?: string
          notification_type: string
          payload?: Json
          personalization_context?: Json
          priority_level?: string
          processing_started_at?: string | null
          queued_at?: string
          read_at?: string | null
          recommendation_run_id?: string | null
          rendered_content?: Json
          requires_acknowledgement?: boolean
          retry_count?: number
          saved_card_id?: string | null
          scheduled_for?: string
          sent_at?: string | null
          short_body?: string | null
          subscription_id?: string | null
          target_entity_id?: string | null
          target_entity_type?: string | null
          template_id?: string | null
          title: string
          updated_at?: string
          user_id: string
        }
        Update: {
          acknowledged_at?: string | null
          action_label?: string | null
          action_url?: string | null
          alert_event_id?: string | null
          archived_at?: string | null
          bank_id?: string | null
          batch_reference?: string | null
          body?: string
          cancelled_at?: string | null
          card_id?: string | null
          channel_plan?: Json
          comparison_id?: string | null
          correlation_id?: string | null
          created_at?: string
          deduplication_key?: string | null
          delivery_summary?: Json
          digest_reference?: string | null
          dismissed_at?: string | null
          expires_at?: string | null
          failed_at?: string | null
          failure_code?: string | null
          failure_message?: string | null
          first_clicked_at?: string | null
          first_delivered_at?: string | null
          first_opened_at?: string | null
          icon_code?: string | null
          id?: string
          image_url?: string | null
          is_archived?: boolean
          is_clicked?: boolean
          is_dismissed?: boolean
          is_marketing?: boolean
          is_opened?: boolean
          is_read?: boolean
          is_silent?: boolean
          is_transactional?: boolean
          language_code?: string
          maximum_retry_count?: number
          metadata?: Json
          next_retry_at?: string | null
          notification_category?: string
          notification_reference?: string
          notification_status?: string
          notification_type?: string
          payload?: Json
          personalization_context?: Json
          priority_level?: string
          processing_started_at?: string | null
          queued_at?: string
          read_at?: string | null
          recommendation_run_id?: string | null
          rendered_content?: Json
          requires_acknowledgement?: boolean
          retry_count?: number
          saved_card_id?: string | null
          scheduled_for?: string
          sent_at?: string | null
          short_body?: string | null
          subscription_id?: string | null
          target_entity_id?: string | null
          target_entity_type?: string | null
          template_id?: string | null
          title?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "notifications_alert_event_id_fkey"
            columns: ["alert_event_id"]
            isOneToOne: false
            referencedRelation: "alert_events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_comparison_id_fkey"
            columns: ["comparison_id"]
            isOneToOne: false
            referencedRelation: "card_comparisons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_saved_card_id_fkey"
            columns: ["saved_card_id"]
            isOneToOne: false
            referencedRelation: "user_saved_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_subscription_id_fkey"
            columns: ["subscription_id"]
            isOneToOne: false
            referencedRelation: "notification_subscriptions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_template_id_fkey"
            columns: ["template_id"]
            isOneToOne: false
            referencedRelation: "notification_templates"
            referencedColumns: ["id"]
          },
        ]
      }
      platform_permissions: {
        Row: {
          action_code: string
          created_at: string
          description: string | null
          id: string
          is_active: boolean
          is_system_managed: boolean
          permission_code: string
          permission_name: string
          resource_code: string
          updated_at: string
        }
        Insert: {
          action_code: string
          created_at?: string
          description?: string | null
          id?: string
          is_active?: boolean
          is_system_managed?: boolean
          permission_code: string
          permission_name: string
          resource_code: string
          updated_at?: string
        }
        Update: {
          action_code?: string
          created_at?: string
          description?: string | null
          id?: string
          is_active?: boolean
          is_system_managed?: boolean
          permission_code?: string
          permission_name?: string
          resource_code?: string
          updated_at?: string
        }
        Relationships: []
      }
      platform_role_permissions: {
        Row: {
          created_at: string
          grant_reference: string | null
          granted_at: string
          granted_by_user_id: string | null
          id: string
          permission_id: string
          revocation_reason: string | null
          revoked_at: string | null
          revoked_by_user_id: string | null
          role_id: string
          updated_at: string
          valid_from: string
          valid_until: string | null
        }
        Insert: {
          created_at?: string
          grant_reference?: string | null
          granted_at?: string
          granted_by_user_id?: string | null
          id?: string
          permission_id: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          role_id: string
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
        }
        Update: {
          created_at?: string
          grant_reference?: string | null
          granted_at?: string
          granted_by_user_id?: string | null
          id?: string
          permission_id?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          role_id?: string
          updated_at?: string
          valid_from?: string
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "platform_role_permissions_permission_id_fkey"
            columns: ["permission_id"]
            isOneToOne: false
            referencedRelation: "platform_permissions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "platform_role_permissions_role_id_fkey"
            columns: ["role_id"]
            isOneToOne: false
            referencedRelation: "platform_roles"
            referencedColumns: ["id"]
          },
        ]
      }
      platform_roles: {
        Row: {
          created_at: string
          description: string | null
          id: string
          is_active: boolean
          is_system_managed: boolean
          role_code: string
          role_name: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          is_active?: boolean
          is_system_managed?: boolean
          role_code: string
          role_name: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          is_active?: boolean
          is_system_managed?: boolean
          role_code?: string
          role_name?: string
          updated_at?: string
        }
        Relationships: []
      }
      recommendation_explanations: {
        Row: {
          action_code: string | null
          action_label_ar: string | null
          action_label_en: string | null
          action_url: string | null
          actual_boolean_value: boolean | null
          actual_numeric_value: number | null
          actual_text_value: string | null
          badge_code: string | null
          calculation_details: Json
          callout_code: string | null
          card_id: string
          confidence_score: number | null
          created_at: string
          currency_id: string | null
          display_group: string | null
          display_priority: number
          evidence: Json
          expected_boolean_value: boolean | null
          expected_numeric_value: number | null
          expected_text_value: string | null
          explanation_category: string
          explanation_code: string
          explanation_sentiment: string
          explanation_severity: string
          explanation_text_ar: string | null
          explanation_text_en: string
          explanation_title_ar: string | null
          explanation_title_en: string | null
          explanation_type: Database["public"]["Enums"]["explanation_type"]
          factor_code: string | null
          financial_value_contribution: number | null
          generation_method: string
          generation_version: string
          icon_code: string | null
          id: string
          importance_score: number | null
          is_actionable: boolean
          is_admin_visible: boolean
          is_advisor_visible: boolean
          is_customer_visible: boolean
          is_negative: boolean
          is_positive: boolean
          is_primary: boolean
          is_warning: boolean
          maximum_numeric_value: number | null
          metadata: Json
          minimum_numeric_value: number | null
          preference_code: string | null
          presentation_configuration: Json
          recommendation_result_id: string
          recommendation_run_card_id: string
          recommendation_run_id: string
          score_contribution: number | null
          short_text_ar: string | null
          short_text_en: string | null
          source_entity: string | null
          source_field: string | null
          source_record_id: string | null
          template_code: string | null
          template_variables: Json
          updated_at: string
          value_component_code: string | null
          weighted_score_contribution: number | null
        }
        Insert: {
          action_code?: string | null
          action_label_ar?: string | null
          action_label_en?: string | null
          action_url?: string | null
          actual_boolean_value?: boolean | null
          actual_numeric_value?: number | null
          actual_text_value?: string | null
          badge_code?: string | null
          calculation_details?: Json
          callout_code?: string | null
          card_id: string
          confidence_score?: number | null
          created_at?: string
          currency_id?: string | null
          display_group?: string | null
          display_priority?: number
          evidence?: Json
          expected_boolean_value?: boolean | null
          expected_numeric_value?: number | null
          expected_text_value?: string | null
          explanation_category: string
          explanation_code: string
          explanation_sentiment?: string
          explanation_severity?: string
          explanation_text_ar?: string | null
          explanation_text_en: string
          explanation_title_ar?: string | null
          explanation_title_en?: string | null
          explanation_type: Database["public"]["Enums"]["explanation_type"]
          factor_code?: string | null
          financial_value_contribution?: number | null
          generation_method?: string
          generation_version?: string
          icon_code?: string | null
          id?: string
          importance_score?: number | null
          is_actionable?: boolean
          is_admin_visible?: boolean
          is_advisor_visible?: boolean
          is_customer_visible?: boolean
          is_negative?: boolean
          is_positive?: boolean
          is_primary?: boolean
          is_warning?: boolean
          maximum_numeric_value?: number | null
          metadata?: Json
          minimum_numeric_value?: number | null
          preference_code?: string | null
          presentation_configuration?: Json
          recommendation_result_id: string
          recommendation_run_card_id: string
          recommendation_run_id: string
          score_contribution?: number | null
          short_text_ar?: string | null
          short_text_en?: string | null
          source_entity?: string | null
          source_field?: string | null
          source_record_id?: string | null
          template_code?: string | null
          template_variables?: Json
          updated_at?: string
          value_component_code?: string | null
          weighted_score_contribution?: number | null
        }
        Update: {
          action_code?: string | null
          action_label_ar?: string | null
          action_label_en?: string | null
          action_url?: string | null
          actual_boolean_value?: boolean | null
          actual_numeric_value?: number | null
          actual_text_value?: string | null
          badge_code?: string | null
          calculation_details?: Json
          callout_code?: string | null
          card_id?: string
          confidence_score?: number | null
          created_at?: string
          currency_id?: string | null
          display_group?: string | null
          display_priority?: number
          evidence?: Json
          expected_boolean_value?: boolean | null
          expected_numeric_value?: number | null
          expected_text_value?: string | null
          explanation_category?: string
          explanation_code?: string
          explanation_sentiment?: string
          explanation_severity?: string
          explanation_text_ar?: string | null
          explanation_text_en?: string
          explanation_title_ar?: string | null
          explanation_title_en?: string | null
          explanation_type?: Database["public"]["Enums"]["explanation_type"]
          factor_code?: string | null
          financial_value_contribution?: number | null
          generation_method?: string
          generation_version?: string
          icon_code?: string | null
          id?: string
          importance_score?: number | null
          is_actionable?: boolean
          is_admin_visible?: boolean
          is_advisor_visible?: boolean
          is_customer_visible?: boolean
          is_negative?: boolean
          is_positive?: boolean
          is_primary?: boolean
          is_warning?: boolean
          maximum_numeric_value?: number | null
          metadata?: Json
          minimum_numeric_value?: number | null
          preference_code?: string | null
          presentation_configuration?: Json
          recommendation_result_id?: string
          recommendation_run_card_id?: string
          recommendation_run_id?: string
          score_contribution?: number | null
          short_text_ar?: string | null
          short_text_en?: string | null
          source_entity?: string | null
          source_field?: string | null
          source_record_id?: string | null
          template_code?: string | null
          template_variables?: Json
          updated_at?: string
          value_component_code?: string | null
          weighted_score_contribution?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_explanations_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_explanations_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_explanations_recommendation_result_id_fkey"
            columns: ["recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_explanations_recommendation_run_card_id_fkey"
            columns: ["recommendation_run_card_id"]
            isOneToOne: false
            referencedRelation: "recommendation_run_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_explanations_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_factor_scores: {
        Row: {
          adjusted_score: number | null
          applied_conditions: Json
          bonus_score: number
          calculation_details: Json
          calculation_formula: string | null
          card_id: string
          category_weight: number
          completeness_multiplier: number
          confidence_multiplier: number
          confidence_score: number | null
          created_at: string
          data_completeness_score: number | null
          default_boolean_value: boolean | null
          default_numeric_value: number | null
          default_text_value: string | null
          default_value_applied: boolean
          errors: Json
          evaluated_at: string
          evaluation_method: string
          evaluation_sequence: number | null
          evaluation_status: string
          evaluation_version: string
          evidence: Json
          exclusion_if_failed: boolean
          exclusion_reason:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          exclusion_triggered: boolean
          execution_duration_ms: number | null
          factor_applied: boolean
          factor_category: string
          factor_code: string
          factor_direction: string
          factor_failed: boolean
          factor_name_ar: string | null
          factor_name_en: string
          factor_skipped: boolean
          factor_value_type: string
          factor_weight: number
          final_score_contribution: number | null
          hard_requirement: boolean
          hard_requirement_satisfied: boolean | null
          id: string
          is_visible_to_admin: boolean
          is_visible_to_advisor: boolean
          is_visible_to_customer: boolean
          maximum_input_value: number | null
          maximum_output_score: number | null
          metadata: Json
          minimum_input_value: number | null
          minimum_output_score: number | null
          missing_value: boolean
          missing_value_strategy: string | null
          neutral_output_score: number | null
          normalization_method: string | null
          normalized_boolean_value: boolean | null
          normalized_numeric_value: number | null
          normalized_score: number | null
          normalized_text_value: string | null
          penalty_multiplier: number
          penalty_score: number
          preference_multiplier: number
          raw_boolean_value: boolean | null
          raw_json_value: Json | null
          raw_numeric_value: number | null
          raw_score: number | null
          raw_text_value: string | null
          recommendation_model_factor_id: string
          recommendation_model_id: string
          recommendation_result_id: string | null
          recommendation_run_card_id: string
          recommendation_run_id: string
          scoring_band: Json
          segment_weight_multiplier: number
          source_entity: string
          source_field: string | null
          source_record_id: string | null
          target_input_value: number | null
          threshold_operator: string | null
          threshold_satisfied: boolean | null
          threshold_value: number | null
          updated_at: string
          warnings: Json
          weighted_score: number | null
        }
        Insert: {
          adjusted_score?: number | null
          applied_conditions?: Json
          bonus_score?: number
          calculation_details?: Json
          calculation_formula?: string | null
          card_id: string
          category_weight?: number
          completeness_multiplier?: number
          confidence_multiplier?: number
          confidence_score?: number | null
          created_at?: string
          data_completeness_score?: number | null
          default_boolean_value?: boolean | null
          default_numeric_value?: number | null
          default_text_value?: string | null
          default_value_applied?: boolean
          errors?: Json
          evaluated_at?: string
          evaluation_method?: string
          evaluation_sequence?: number | null
          evaluation_status?: string
          evaluation_version?: string
          evidence?: Json
          exclusion_if_failed?: boolean
          exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          exclusion_triggered?: boolean
          execution_duration_ms?: number | null
          factor_applied?: boolean
          factor_category: string
          factor_code: string
          factor_direction: string
          factor_failed?: boolean
          factor_name_ar?: string | null
          factor_name_en: string
          factor_skipped?: boolean
          factor_value_type: string
          factor_weight?: number
          final_score_contribution?: number | null
          hard_requirement?: boolean
          hard_requirement_satisfied?: boolean | null
          id?: string
          is_visible_to_admin?: boolean
          is_visible_to_advisor?: boolean
          is_visible_to_customer?: boolean
          maximum_input_value?: number | null
          maximum_output_score?: number | null
          metadata?: Json
          minimum_input_value?: number | null
          minimum_output_score?: number | null
          missing_value?: boolean
          missing_value_strategy?: string | null
          neutral_output_score?: number | null
          normalization_method?: string | null
          normalized_boolean_value?: boolean | null
          normalized_numeric_value?: number | null
          normalized_score?: number | null
          normalized_text_value?: string | null
          penalty_multiplier?: number
          penalty_score?: number
          preference_multiplier?: number
          raw_boolean_value?: boolean | null
          raw_json_value?: Json | null
          raw_numeric_value?: number | null
          raw_score?: number | null
          raw_text_value?: string | null
          recommendation_model_factor_id: string
          recommendation_model_id: string
          recommendation_result_id?: string | null
          recommendation_run_card_id: string
          recommendation_run_id: string
          scoring_band?: Json
          segment_weight_multiplier?: number
          source_entity: string
          source_field?: string | null
          source_record_id?: string | null
          target_input_value?: number | null
          threshold_operator?: string | null
          threshold_satisfied?: boolean | null
          threshold_value?: number | null
          updated_at?: string
          warnings?: Json
          weighted_score?: number | null
        }
        Update: {
          adjusted_score?: number | null
          applied_conditions?: Json
          bonus_score?: number
          calculation_details?: Json
          calculation_formula?: string | null
          card_id?: string
          category_weight?: number
          completeness_multiplier?: number
          confidence_multiplier?: number
          confidence_score?: number | null
          created_at?: string
          data_completeness_score?: number | null
          default_boolean_value?: boolean | null
          default_numeric_value?: number | null
          default_text_value?: string | null
          default_value_applied?: boolean
          errors?: Json
          evaluated_at?: string
          evaluation_method?: string
          evaluation_sequence?: number | null
          evaluation_status?: string
          evaluation_version?: string
          evidence?: Json
          exclusion_if_failed?: boolean
          exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          exclusion_triggered?: boolean
          execution_duration_ms?: number | null
          factor_applied?: boolean
          factor_category?: string
          factor_code?: string
          factor_direction?: string
          factor_failed?: boolean
          factor_name_ar?: string | null
          factor_name_en?: string
          factor_skipped?: boolean
          factor_value_type?: string
          factor_weight?: number
          final_score_contribution?: number | null
          hard_requirement?: boolean
          hard_requirement_satisfied?: boolean | null
          id?: string
          is_visible_to_admin?: boolean
          is_visible_to_advisor?: boolean
          is_visible_to_customer?: boolean
          maximum_input_value?: number | null
          maximum_output_score?: number | null
          metadata?: Json
          minimum_input_value?: number | null
          minimum_output_score?: number | null
          missing_value?: boolean
          missing_value_strategy?: string | null
          neutral_output_score?: number | null
          normalization_method?: string | null
          normalized_boolean_value?: boolean | null
          normalized_numeric_value?: number | null
          normalized_score?: number | null
          normalized_text_value?: string | null
          penalty_multiplier?: number
          penalty_score?: number
          preference_multiplier?: number
          raw_boolean_value?: boolean | null
          raw_json_value?: Json | null
          raw_numeric_value?: number | null
          raw_score?: number | null
          raw_text_value?: string | null
          recommendation_model_factor_id?: string
          recommendation_model_id?: string
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string
          recommendation_run_id?: string
          scoring_band?: Json
          segment_weight_multiplier?: number
          source_entity?: string
          source_field?: string | null
          source_record_id?: string | null
          target_input_value?: number | null
          threshold_operator?: string | null
          threshold_satisfied?: boolean | null
          threshold_value?: number | null
          updated_at?: string
          warnings?: Json
          weighted_score?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_factor_scores_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_factor_scores_recommendation_model_factor_i_fkey"
            columns: ["recommendation_model_factor_id"]
            isOneToOne: false
            referencedRelation: "recommendation_model_factors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_factor_scores_recommendation_model_id_fkey"
            columns: ["recommendation_model_id"]
            isOneToOne: false
            referencedRelation: "recommendation_models"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_factor_scores_recommendation_result_id_fkey"
            columns: ["recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_factor_scores_recommendation_run_card_id_fkey"
            columns: ["recommendation_run_card_id"]
            isOneToOne: false
            referencedRelation: "recommendation_run_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_factor_scores_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_feedback: {
        Row: {
          accuracy_rating: number | null
          card_id: string | null
          contact_permission: boolean
          created_at: string
          ease_of_use_rating: number | null
          eligibility_assessment_was_accurate: boolean | null
          eligibility_rating: number | null
          expected_recommendation: string | null
          explanation_rating: number | null
          feedback_comment: string | null
          feedback_context: Json
          feedback_reference: string
          feedback_source: string
          feedback_status: string
          feedback_title: string | null
          feedback_type: string
          financial_profile_id: string | null
          follow_up_due_at: string | null
          follow_up_owner_id: string | null
          follow_up_required: boolean
          follow_up_status: string | null
          followed_up_at: string | null
          id: string
          improvement_suggestion: string | null
          metadata: Json
          missing_feature_codes: string[] | null
          model_training_eligible: boolean
          negative_reason_codes: string[] | null
          overall_rating: number | null
          positive_reason_codes: string[] | null
          primary_reason_code: string | null
          quality_review_data: Json
          quality_review_required: boolean
          quality_review_status: string | null
          quality_reviewed_at: string | null
          quality_reviewed_by: string | null
          recommendation_accepted: boolean | null
          recommendation_helpful: boolean | null
          recommendation_interaction_id: string | null
          recommendation_result_id: string | null
          recommendation_run_card_id: string | null
          recommendation_run_id: string
          recommendation_was_expected: boolean | null
          rejection_reason: string | null
          relevance_rating: number | null
          reported_issue_description: string | null
          reported_issue_severity: string | null
          reported_issue_type: string | null
          resolution_code: string | null
          resolution_notes: string | null
          resolved_at: string | null
          result_was_understandable: boolean | null
          secondary_reason_codes: string[] | null
          selected_alternative_reference: string | null
          selected_alternative_type: string | null
          selected_card_id: string | null
          selected_recommendation_result_id: string | null
          structured_feedback: Json
          submitted_at: string
          updated_at: string
          user_id: string | null
          value_estimate_rating: number | null
          value_estimate_was_realistic: boolean | null
          withdrawn_at: string | null
        }
        Insert: {
          accuracy_rating?: number | null
          card_id?: string | null
          contact_permission?: boolean
          created_at?: string
          ease_of_use_rating?: number | null
          eligibility_assessment_was_accurate?: boolean | null
          eligibility_rating?: number | null
          expected_recommendation?: string | null
          explanation_rating?: number | null
          feedback_comment?: string | null
          feedback_context?: Json
          feedback_reference: string
          feedback_source?: string
          feedback_status?: string
          feedback_title?: string | null
          feedback_type: string
          financial_profile_id?: string | null
          follow_up_due_at?: string | null
          follow_up_owner_id?: string | null
          follow_up_required?: boolean
          follow_up_status?: string | null
          followed_up_at?: string | null
          id?: string
          improvement_suggestion?: string | null
          metadata?: Json
          missing_feature_codes?: string[] | null
          model_training_eligible?: boolean
          negative_reason_codes?: string[] | null
          overall_rating?: number | null
          positive_reason_codes?: string[] | null
          primary_reason_code?: string | null
          quality_review_data?: Json
          quality_review_required?: boolean
          quality_review_status?: string | null
          quality_reviewed_at?: string | null
          quality_reviewed_by?: string | null
          recommendation_accepted?: boolean | null
          recommendation_helpful?: boolean | null
          recommendation_interaction_id?: string | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_run_id: string
          recommendation_was_expected?: boolean | null
          rejection_reason?: string | null
          relevance_rating?: number | null
          reported_issue_description?: string | null
          reported_issue_severity?: string | null
          reported_issue_type?: string | null
          resolution_code?: string | null
          resolution_notes?: string | null
          resolved_at?: string | null
          result_was_understandable?: boolean | null
          secondary_reason_codes?: string[] | null
          selected_alternative_reference?: string | null
          selected_alternative_type?: string | null
          selected_card_id?: string | null
          selected_recommendation_result_id?: string | null
          structured_feedback?: Json
          submitted_at?: string
          updated_at?: string
          user_id?: string | null
          value_estimate_rating?: number | null
          value_estimate_was_realistic?: boolean | null
          withdrawn_at?: string | null
        }
        Update: {
          accuracy_rating?: number | null
          card_id?: string | null
          contact_permission?: boolean
          created_at?: string
          ease_of_use_rating?: number | null
          eligibility_assessment_was_accurate?: boolean | null
          eligibility_rating?: number | null
          expected_recommendation?: string | null
          explanation_rating?: number | null
          feedback_comment?: string | null
          feedback_context?: Json
          feedback_reference?: string
          feedback_source?: string
          feedback_status?: string
          feedback_title?: string | null
          feedback_type?: string
          financial_profile_id?: string | null
          follow_up_due_at?: string | null
          follow_up_owner_id?: string | null
          follow_up_required?: boolean
          follow_up_status?: string | null
          followed_up_at?: string | null
          id?: string
          improvement_suggestion?: string | null
          metadata?: Json
          missing_feature_codes?: string[] | null
          model_training_eligible?: boolean
          negative_reason_codes?: string[] | null
          overall_rating?: number | null
          positive_reason_codes?: string[] | null
          primary_reason_code?: string | null
          quality_review_data?: Json
          quality_review_required?: boolean
          quality_review_status?: string | null
          quality_reviewed_at?: string | null
          quality_reviewed_by?: string | null
          recommendation_accepted?: boolean | null
          recommendation_helpful?: boolean | null
          recommendation_interaction_id?: string | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_run_id?: string
          recommendation_was_expected?: boolean | null
          rejection_reason?: string | null
          relevance_rating?: number | null
          reported_issue_description?: string | null
          reported_issue_severity?: string | null
          reported_issue_type?: string | null
          resolution_code?: string | null
          resolution_notes?: string | null
          resolved_at?: string | null
          result_was_understandable?: boolean | null
          secondary_reason_codes?: string[] | null
          selected_alternative_reference?: string | null
          selected_alternative_type?: string | null
          selected_card_id?: string | null
          selected_recommendation_result_id?: string | null
          structured_feedback?: Json
          submitted_at?: string
          updated_at?: string
          user_id?: string | null
          value_estimate_rating?: number | null
          value_estimate_was_realistic?: boolean | null
          withdrawn_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_feedback_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_feedback_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_feedback_recommendation_interaction_id_fkey"
            columns: ["recommendation_interaction_id"]
            isOneToOne: false
            referencedRelation: "recommendation_interactions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_feedback_recommendation_result_id_fkey"
            columns: ["recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_feedback_recommendation_run_card_id_fkey"
            columns: ["recommendation_run_card_id"]
            isOneToOne: false
            referencedRelation: "recommendation_run_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_feedback_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_feedback_selected_card_id_fkey"
            columns: ["selected_card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_feedback_selected_recommendation_result_id_fkey"
            columns: ["selected_recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_interactions: {
        Row: {
          application_version: string | null
          attribution_campaign: string | null
          attribution_content: string | null
          attribution_data: Json
          attribution_medium: string | null
          attribution_source: string | null
          attribution_term: string | null
          browser_family: string | null
          call_to_action_code: string | null
          card_id: string | null
          city_code: string | null
          comparison_card_ids: string[] | null
          component_code: string | null
          correlation_id: string | null
          country_code: string | null
          created_at: string
          destination_reference: string | null
          destination_type: string | null
          destination_url: string | null
          device_data: Json
          device_type: string | null
          duration_ms: number | null
          event_properties: Json
          expected_net_value_at_interaction: number | null
          experiment_code: string | null
          experiment_variant: string | null
          financial_profile_id: string | null
          id: string
          idempotency_key: string | null
          interaction_channel: string | null
          interaction_context: string | null
          interaction_reference: string
          interaction_source: string
          interaction_type: string
          interaction_value: number | null
          interaction_value_currency_id: string | null
          ip_address_hash: string | null
          is_authenticated: boolean
          is_conversion_event: boolean
          is_customer_initiated: boolean
          is_unique_interaction: boolean
          journey_reference: string | null
          locale_code: string | null
          metadata: Json
          occurred_at: string
          operating_system: string | null
          page_code: string | null
          placement_code: string | null
          processed_at: string | null
          processing_metadata: Json
          received_at: string
          recommendation_rank_at_interaction: number | null
          recommendation_result_id: string | null
          recommendation_run_card_id: string | null
          recommendation_run_id: string
          recommendation_score_at_interaction: number | null
          referrer_hash: string | null
          region_code: string | null
          sequence_number: number | null
          session_reference: string | null
          updated_at: string
          user_agent_hash: string | null
          user_id: string | null
          value_currency_id: string | null
        }
        Insert: {
          application_version?: string | null
          attribution_campaign?: string | null
          attribution_content?: string | null
          attribution_data?: Json
          attribution_medium?: string | null
          attribution_source?: string | null
          attribution_term?: string | null
          browser_family?: string | null
          call_to_action_code?: string | null
          card_id?: string | null
          city_code?: string | null
          comparison_card_ids?: string[] | null
          component_code?: string | null
          correlation_id?: string | null
          country_code?: string | null
          created_at?: string
          destination_reference?: string | null
          destination_type?: string | null
          destination_url?: string | null
          device_data?: Json
          device_type?: string | null
          duration_ms?: number | null
          event_properties?: Json
          expected_net_value_at_interaction?: number | null
          experiment_code?: string | null
          experiment_variant?: string | null
          financial_profile_id?: string | null
          id?: string
          idempotency_key?: string | null
          interaction_channel?: string | null
          interaction_context?: string | null
          interaction_reference: string
          interaction_source?: string
          interaction_type: string
          interaction_value?: number | null
          interaction_value_currency_id?: string | null
          ip_address_hash?: string | null
          is_authenticated?: boolean
          is_conversion_event?: boolean
          is_customer_initiated?: boolean
          is_unique_interaction?: boolean
          journey_reference?: string | null
          locale_code?: string | null
          metadata?: Json
          occurred_at?: string
          operating_system?: string | null
          page_code?: string | null
          placement_code?: string | null
          processed_at?: string | null
          processing_metadata?: Json
          received_at?: string
          recommendation_rank_at_interaction?: number | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_run_id: string
          recommendation_score_at_interaction?: number | null
          referrer_hash?: string | null
          region_code?: string | null
          sequence_number?: number | null
          session_reference?: string | null
          updated_at?: string
          user_agent_hash?: string | null
          user_id?: string | null
          value_currency_id?: string | null
        }
        Update: {
          application_version?: string | null
          attribution_campaign?: string | null
          attribution_content?: string | null
          attribution_data?: Json
          attribution_medium?: string | null
          attribution_source?: string | null
          attribution_term?: string | null
          browser_family?: string | null
          call_to_action_code?: string | null
          card_id?: string | null
          city_code?: string | null
          comparison_card_ids?: string[] | null
          component_code?: string | null
          correlation_id?: string | null
          country_code?: string | null
          created_at?: string
          destination_reference?: string | null
          destination_type?: string | null
          destination_url?: string | null
          device_data?: Json
          device_type?: string | null
          duration_ms?: number | null
          event_properties?: Json
          expected_net_value_at_interaction?: number | null
          experiment_code?: string | null
          experiment_variant?: string | null
          financial_profile_id?: string | null
          id?: string
          idempotency_key?: string | null
          interaction_channel?: string | null
          interaction_context?: string | null
          interaction_reference?: string
          interaction_source?: string
          interaction_type?: string
          interaction_value?: number | null
          interaction_value_currency_id?: string | null
          ip_address_hash?: string | null
          is_authenticated?: boolean
          is_conversion_event?: boolean
          is_customer_initiated?: boolean
          is_unique_interaction?: boolean
          journey_reference?: string | null
          locale_code?: string | null
          metadata?: Json
          occurred_at?: string
          operating_system?: string | null
          page_code?: string | null
          placement_code?: string | null
          processed_at?: string | null
          processing_metadata?: Json
          received_at?: string
          recommendation_rank_at_interaction?: number | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_run_id?: string
          recommendation_score_at_interaction?: number | null
          referrer_hash?: string | null
          region_code?: string | null
          sequence_number?: number | null
          session_reference?: string | null
          updated_at?: string
          user_agent_hash?: string | null
          user_id?: string | null
          value_currency_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_interactions_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_interactions_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_interactions_interaction_value_currency_id_fkey"
            columns: ["interaction_value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_interactions_recommendation_result_id_fkey"
            columns: ["recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_interactions_recommendation_run_card_id_fkey"
            columns: ["recommendation_run_card_id"]
            isOneToOne: false
            referencedRelation: "recommendation_run_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_interactions_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_interactions_value_currency_id_fkey"
            columns: ["value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_model_factors: {
        Row: {
          apply_only_when: Json
          completeness_sensitive: boolean
          confidence_sensitive: boolean
          created_at: string
          description_ar: string | null
          description_en: string | null
          exclusion_if_failed: boolean
          explanation_template_ar: string | null
          explanation_template_en: string | null
          factor_category: string
          factor_code: string
          factor_direction: string
          factor_name_ar: string | null
          factor_name_en: string
          factor_value_type: string
          failure_explanation_ar: string | null
          failure_explanation_en: string | null
          hard_requirement: boolean
          id: string
          is_active: boolean
          maximum_input_value: number | null
          maximum_output_score: number
          metadata: Json
          minimum_input_value: number | null
          minimum_output_score: number
          missing_value_score: number | null
          missing_value_strategy: string
          neutral_output_score: number | null
          normalization_method: string
          preference_sensitive: boolean
          priority: number
          recommendation_model_id: string
          scoring_bands: Json
          scoring_parameters: Json
          source_entity: string
          source_expression: string | null
          source_field: string | null
          target_input_value: number | null
          threshold_operator: string | null
          threshold_score: number | null
          threshold_value: number | null
          updated_at: string
          weight: number
        }
        Insert: {
          apply_only_when?: Json
          completeness_sensitive?: boolean
          confidence_sensitive?: boolean
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          exclusion_if_failed?: boolean
          explanation_template_ar?: string | null
          explanation_template_en?: string | null
          factor_category: string
          factor_code: string
          factor_direction?: string
          factor_name_ar?: string | null
          factor_name_en: string
          factor_value_type?: string
          failure_explanation_ar?: string | null
          failure_explanation_en?: string | null
          hard_requirement?: boolean
          id?: string
          is_active?: boolean
          maximum_input_value?: number | null
          maximum_output_score?: number
          metadata?: Json
          minimum_input_value?: number | null
          minimum_output_score?: number
          missing_value_score?: number | null
          missing_value_strategy?: string
          neutral_output_score?: number | null
          normalization_method?: string
          preference_sensitive?: boolean
          priority?: number
          recommendation_model_id: string
          scoring_bands?: Json
          scoring_parameters?: Json
          source_entity: string
          source_expression?: string | null
          source_field?: string | null
          target_input_value?: number | null
          threshold_operator?: string | null
          threshold_score?: number | null
          threshold_value?: number | null
          updated_at?: string
          weight?: number
        }
        Update: {
          apply_only_when?: Json
          completeness_sensitive?: boolean
          confidence_sensitive?: boolean
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          exclusion_if_failed?: boolean
          explanation_template_ar?: string | null
          explanation_template_en?: string | null
          factor_category?: string
          factor_code?: string
          factor_direction?: string
          factor_name_ar?: string | null
          factor_name_en?: string
          factor_value_type?: string
          failure_explanation_ar?: string | null
          failure_explanation_en?: string | null
          hard_requirement?: boolean
          id?: string
          is_active?: boolean
          maximum_input_value?: number | null
          maximum_output_score?: number
          metadata?: Json
          minimum_input_value?: number | null
          minimum_output_score?: number
          missing_value_score?: number | null
          missing_value_strategy?: string
          neutral_output_score?: number | null
          normalization_method?: string
          preference_sensitive?: boolean
          priority?: number
          recommendation_model_id?: string
          scoring_bands?: Json
          scoring_parameters?: Json
          source_entity?: string
          source_expression?: string | null
          source_field?: string | null
          target_input_value?: number | null
          threshold_operator?: string | null
          threshold_score?: number | null
          threshold_value?: number | null
          updated_at?: string
          weight?: number
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_model_factors_recommendation_model_id_fkey"
            columns: ["recommendation_model_id"]
            isOneToOne: false
            referencedRelation: "recommendation_models"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_model_segments: {
        Row: {
          configuration_overrides: Json
          created_at: string
          customer_segment: string | null
          description_ar: string | null
          description_en: string | null
          employment_sectors: string[] | null
          employment_statuses: string[] | null
          id: string
          income_currency_id: string | null
          is_active: boolean
          maximum_annual_spend: number | null
          maximum_monthly_income: number | null
          metadata: Json
          minimum_annual_spend: number | null
          minimum_monthly_income: number | null
          nationality_country_codes: string[] | null
          preference_strategy: string | null
          priority: number
          recommendation_model_id: string
          required_conditions: Json
          residence_country_codes: string[] | null
          segment_code: string
          segment_name_ar: string | null
          segment_name_en: string
          spend_currency_id: string | null
          updated_at: string
          weight_overrides: Json
        }
        Insert: {
          configuration_overrides?: Json
          created_at?: string
          customer_segment?: string | null
          description_ar?: string | null
          description_en?: string | null
          employment_sectors?: string[] | null
          employment_statuses?: string[] | null
          id?: string
          income_currency_id?: string | null
          is_active?: boolean
          maximum_annual_spend?: number | null
          maximum_monthly_income?: number | null
          metadata?: Json
          minimum_annual_spend?: number | null
          minimum_monthly_income?: number | null
          nationality_country_codes?: string[] | null
          preference_strategy?: string | null
          priority?: number
          recommendation_model_id: string
          required_conditions?: Json
          residence_country_codes?: string[] | null
          segment_code: string
          segment_name_ar?: string | null
          segment_name_en: string
          spend_currency_id?: string | null
          updated_at?: string
          weight_overrides?: Json
        }
        Update: {
          configuration_overrides?: Json
          created_at?: string
          customer_segment?: string | null
          description_ar?: string | null
          description_en?: string | null
          employment_sectors?: string[] | null
          employment_statuses?: string[] | null
          id?: string
          income_currency_id?: string | null
          is_active?: boolean
          maximum_annual_spend?: number | null
          maximum_monthly_income?: number | null
          metadata?: Json
          minimum_annual_spend?: number | null
          minimum_monthly_income?: number | null
          nationality_country_codes?: string[] | null
          preference_strategy?: string | null
          priority?: number
          recommendation_model_id?: string
          required_conditions?: Json
          residence_country_codes?: string[] | null
          segment_code?: string
          segment_name_ar?: string | null
          segment_name_en?: string
          spend_currency_id?: string | null
          updated_at?: string
          weight_overrides?: Json
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_model_segments_income_currency_id_fkey"
            columns: ["income_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_model_segments_recommendation_model_id_fkey"
            columns: ["recommendation_model_id"]
            isOneToOne: false
            referencedRelation: "recommendation_models"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_model_segments_spend_currency_id_fkey"
            columns: ["spend_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_models: {
        Row: {
          allow_conditionally_eligible_results: boolean
          allow_manual_review_results: boolean
          apply_benefit_utilization_adjustment: boolean
          apply_confidence_adjustment: boolean
          apply_data_completeness_adjustment: boolean
          apply_reward_utilization_adjustment: boolean
          approved_at: string | null
          approved_by: string | null
          bank_relationship_weight: number
          confidence_rules: Json
          confidence_weight: number
          configuration: Json
          created_at: string
          created_by: string | null
          description_ar: string | null
          description_en: string | null
          effective_from: string | null
          effective_to: string | null
          eligibility_rules: Json
          eligibility_weight: number
          enforce_hard_eligibility: boolean
          exclude_expired_products: boolean
          exclude_inactive_products: boolean
          exclude_ineligible_cards: boolean
          exclude_preference_conflicts: boolean
          exclude_unknown_eligibility: boolean
          exclusion_rules: Json
          explanation_rules: Json
          fees_weight: number
          financial_value_weight: number
          id: string
          is_active: boolean
          is_default: boolean
          lifestyle_weight: number
          maximum_results: number
          metadata: Json
          methodology_notes_ar: string | null
          methodology_notes_en: string | null
          minimum_confidence_score: number | null
          minimum_recommendation_score: number | null
          missing_value_strategy: string
          model_code: string
          model_name_ar: string | null
          model_name_en: string
          model_status: string
          model_type: Database["public"]["Enums"]["recommendation_model_type"]
          model_version: string
          negative_value_strategy: string
          preference_weight: number
          published_at: string | null
          rank_by: string
          require_preference_profile: boolean
          require_spending_profile: boolean
          require_value_simulation: boolean
          retired_at: string | null
          rewards_weight: number
          score_normalization_method: string
          scoring_formula: Json
          scoring_scale_max: number
          scoring_scale_min: number
          simplicity_weight: number
          tie_breaker_strategy: string
          travel_weight: number
          updated_at: string
        }
        Insert: {
          allow_conditionally_eligible_results?: boolean
          allow_manual_review_results?: boolean
          apply_benefit_utilization_adjustment?: boolean
          apply_confidence_adjustment?: boolean
          apply_data_completeness_adjustment?: boolean
          apply_reward_utilization_adjustment?: boolean
          approved_at?: string | null
          approved_by?: string | null
          bank_relationship_weight?: number
          confidence_rules?: Json
          confidence_weight?: number
          configuration?: Json
          created_at?: string
          created_by?: string | null
          description_ar?: string | null
          description_en?: string | null
          effective_from?: string | null
          effective_to?: string | null
          eligibility_rules?: Json
          eligibility_weight?: number
          enforce_hard_eligibility?: boolean
          exclude_expired_products?: boolean
          exclude_inactive_products?: boolean
          exclude_ineligible_cards?: boolean
          exclude_preference_conflicts?: boolean
          exclude_unknown_eligibility?: boolean
          exclusion_rules?: Json
          explanation_rules?: Json
          fees_weight?: number
          financial_value_weight?: number
          id?: string
          is_active?: boolean
          is_default?: boolean
          lifestyle_weight?: number
          maximum_results?: number
          metadata?: Json
          methodology_notes_ar?: string | null
          methodology_notes_en?: string | null
          minimum_confidence_score?: number | null
          minimum_recommendation_score?: number | null
          missing_value_strategy?: string
          model_code: string
          model_name_ar?: string | null
          model_name_en: string
          model_status?: string
          model_type: Database["public"]["Enums"]["recommendation_model_type"]
          model_version?: string
          negative_value_strategy?: string
          preference_weight?: number
          published_at?: string | null
          rank_by?: string
          require_preference_profile?: boolean
          require_spending_profile?: boolean
          require_value_simulation?: boolean
          retired_at?: string | null
          rewards_weight?: number
          score_normalization_method?: string
          scoring_formula?: Json
          scoring_scale_max?: number
          scoring_scale_min?: number
          simplicity_weight?: number
          tie_breaker_strategy?: string
          travel_weight?: number
          updated_at?: string
        }
        Update: {
          allow_conditionally_eligible_results?: boolean
          allow_manual_review_results?: boolean
          apply_benefit_utilization_adjustment?: boolean
          apply_confidence_adjustment?: boolean
          apply_data_completeness_adjustment?: boolean
          apply_reward_utilization_adjustment?: boolean
          approved_at?: string | null
          approved_by?: string | null
          bank_relationship_weight?: number
          confidence_rules?: Json
          confidence_weight?: number
          configuration?: Json
          created_at?: string
          created_by?: string | null
          description_ar?: string | null
          description_en?: string | null
          effective_from?: string | null
          effective_to?: string | null
          eligibility_rules?: Json
          eligibility_weight?: number
          enforce_hard_eligibility?: boolean
          exclude_expired_products?: boolean
          exclude_inactive_products?: boolean
          exclude_ineligible_cards?: boolean
          exclude_preference_conflicts?: boolean
          exclude_unknown_eligibility?: boolean
          exclusion_rules?: Json
          explanation_rules?: Json
          fees_weight?: number
          financial_value_weight?: number
          id?: string
          is_active?: boolean
          is_default?: boolean
          lifestyle_weight?: number
          maximum_results?: number
          metadata?: Json
          methodology_notes_ar?: string | null
          methodology_notes_en?: string | null
          minimum_confidence_score?: number | null
          minimum_recommendation_score?: number | null
          missing_value_strategy?: string
          model_code?: string
          model_name_ar?: string | null
          model_name_en?: string
          model_status?: string
          model_type?: Database["public"]["Enums"]["recommendation_model_type"]
          model_version?: string
          negative_value_strategy?: string
          preference_weight?: number
          published_at?: string | null
          rank_by?: string
          require_preference_profile?: boolean
          require_spending_profile?: boolean
          require_value_simulation?: boolean
          retired_at?: string | null
          rewards_weight?: number
          score_normalization_method?: string
          scoring_formula?: Json
          scoring_scale_max?: number
          scoring_scale_min?: number
          simplicity_weight?: number
          tie_breaker_strategy?: string
          travel_weight?: number
          updated_at?: string
        }
        Relationships: []
      }
      recommendation_outcomes: {
        Row: {
          actual_first_year_benefit_value: number | null
          actual_first_year_cost: number | null
          actual_first_year_net_value: number | null
          actual_first_year_reward_value: number | null
          actual_value_currency_id: string | null
          application_decision: string | null
          application_details: Json
          application_received_at: string | null
          application_rejection_reason_code: string | null
          application_rejection_reason_text: string | null
          application_started_at: string | null
          application_status: string | null
          application_submitted_at: string | null
          approval_prediction_correct: boolean | null
          approval_type: string | null
          approved_annual_fee: number | null
          approved_annual_fee_currency_id: string | null
          approved_at: string | null
          approved_credit_limit: number | null
          approved_credit_limit_currency_id: string | null
          attribution_confidence_score: number | null
          attribution_details: Json
          attribution_model: string
          attribution_reference: string | null
          attribution_status: string
          attribution_window_days: number | null
          bank_application_reference: string | null
          bank_id: string | null
          card_activated_at: string | null
          card_delivered_at: string | null
          card_id: string | null
          card_issued_at: string | null
          commission_amount: number | null
          commission_confirmed_at: string | null
          commission_currency_id: string | null
          commission_eligible_at: string | null
          commission_invoiced_at: string | null
          commission_paid_at: string | null
          commission_rate: number | null
          commission_reversal_reason: string | null
          commission_reversed_at: string | null
          commission_status: string
          commission_type: string | null
          correlation_id: string | null
          created_at: string
          decision_at: string | null
          documents_completed_at: string | null
          documents_requested_at: string | null
          eligibility_prediction_correct: boolean | null
          expected_first_year_net_value: number | null
          expected_value_currency_id: string | null
          expected_value_prediction_validated: boolean | null
          expired_at: string | null
          external_application_reference: string | null
          finalized_at: string | null
          financial_outcome_details: Json
          financial_profile_id: string | null
          first_transaction_at: string | null
          id: string
          idempotency_key: string | null
          is_attributed_to_platform: boolean
          is_attributed_to_recommendation: boolean
          is_final: boolean
          is_test: boolean
          is_top_recommendation_selected: boolean | null
          issued_card_id: string | null
          issued_card_variant: string | null
          manual_review_reason: string | null
          manual_review_required: boolean
          manual_review_status: string | null
          metadata: Json
          net_value_variance: number | null
          net_value_variance_percentage: number | null
          outcome_channel: string | null
          outcome_occurred_at: string
          outcome_processed_at: string | null
          outcome_received_at: string
          outcome_reference: string
          outcome_source: string
          outcome_status: string
          outcome_type: string
          partner_name: string | null
          partner_reference: string | null
          partner_settlement_reference: string | null
          partner_type: string | null
          processing_errors: Json
          recommendation_accuracy_score: number | null
          recommendation_feedback_id: string | null
          recommendation_interaction_id: string | null
          recommendation_match_status: string | null
          recommendation_result_id: string | null
          recommendation_run_card_id: string | null
          recommendation_run_id: string
          recommendation_success: boolean | null
          reconciled_at: string | null
          reconciled_by: string | null
          reconciliation_batch_reference: string | null
          reconciliation_currency_id: string | null
          reconciliation_details: Json
          reconciliation_difference_amount: number | null
          reconciliation_status: string
          rejected_at: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          selected_expected_net_value: number | null
          selected_recommendation_rank: number | null
          selected_recommendation_score: number | null
          selected_value_currency_id: string | null
          source_payload: Json
          updated_at: string
          user_id: string | null
          validation_details: Json
          withdrawn_at: string | null
        }
        Insert: {
          actual_first_year_benefit_value?: number | null
          actual_first_year_cost?: number | null
          actual_first_year_net_value?: number | null
          actual_first_year_reward_value?: number | null
          actual_value_currency_id?: string | null
          application_decision?: string | null
          application_details?: Json
          application_received_at?: string | null
          application_rejection_reason_code?: string | null
          application_rejection_reason_text?: string | null
          application_started_at?: string | null
          application_status?: string | null
          application_submitted_at?: string | null
          approval_prediction_correct?: boolean | null
          approval_type?: string | null
          approved_annual_fee?: number | null
          approved_annual_fee_currency_id?: string | null
          approved_at?: string | null
          approved_credit_limit?: number | null
          approved_credit_limit_currency_id?: string | null
          attribution_confidence_score?: number | null
          attribution_details?: Json
          attribution_model?: string
          attribution_reference?: string | null
          attribution_status?: string
          attribution_window_days?: number | null
          bank_application_reference?: string | null
          bank_id?: string | null
          card_activated_at?: string | null
          card_delivered_at?: string | null
          card_id?: string | null
          card_issued_at?: string | null
          commission_amount?: number | null
          commission_confirmed_at?: string | null
          commission_currency_id?: string | null
          commission_eligible_at?: string | null
          commission_invoiced_at?: string | null
          commission_paid_at?: string | null
          commission_rate?: number | null
          commission_reversal_reason?: string | null
          commission_reversed_at?: string | null
          commission_status?: string
          commission_type?: string | null
          correlation_id?: string | null
          created_at?: string
          decision_at?: string | null
          documents_completed_at?: string | null
          documents_requested_at?: string | null
          eligibility_prediction_correct?: boolean | null
          expected_first_year_net_value?: number | null
          expected_value_currency_id?: string | null
          expected_value_prediction_validated?: boolean | null
          expired_at?: string | null
          external_application_reference?: string | null
          finalized_at?: string | null
          financial_outcome_details?: Json
          financial_profile_id?: string | null
          first_transaction_at?: string | null
          id?: string
          idempotency_key?: string | null
          is_attributed_to_platform?: boolean
          is_attributed_to_recommendation?: boolean
          is_final?: boolean
          is_test?: boolean
          is_top_recommendation_selected?: boolean | null
          issued_card_id?: string | null
          issued_card_variant?: string | null
          manual_review_reason?: string | null
          manual_review_required?: boolean
          manual_review_status?: string | null
          metadata?: Json
          net_value_variance?: number | null
          net_value_variance_percentage?: number | null
          outcome_channel?: string | null
          outcome_occurred_at?: string
          outcome_processed_at?: string | null
          outcome_received_at?: string
          outcome_reference: string
          outcome_source?: string
          outcome_status?: string
          outcome_type: string
          partner_name?: string | null
          partner_reference?: string | null
          partner_settlement_reference?: string | null
          partner_type?: string | null
          processing_errors?: Json
          recommendation_accuracy_score?: number | null
          recommendation_feedback_id?: string | null
          recommendation_interaction_id?: string | null
          recommendation_match_status?: string | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_run_id: string
          recommendation_success?: boolean | null
          reconciled_at?: string | null
          reconciled_by?: string | null
          reconciliation_batch_reference?: string | null
          reconciliation_currency_id?: string | null
          reconciliation_details?: Json
          reconciliation_difference_amount?: number | null
          reconciliation_status?: string
          rejected_at?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          selected_expected_net_value?: number | null
          selected_recommendation_rank?: number | null
          selected_recommendation_score?: number | null
          selected_value_currency_id?: string | null
          source_payload?: Json
          updated_at?: string
          user_id?: string | null
          validation_details?: Json
          withdrawn_at?: string | null
        }
        Update: {
          actual_first_year_benefit_value?: number | null
          actual_first_year_cost?: number | null
          actual_first_year_net_value?: number | null
          actual_first_year_reward_value?: number | null
          actual_value_currency_id?: string | null
          application_decision?: string | null
          application_details?: Json
          application_received_at?: string | null
          application_rejection_reason_code?: string | null
          application_rejection_reason_text?: string | null
          application_started_at?: string | null
          application_status?: string | null
          application_submitted_at?: string | null
          approval_prediction_correct?: boolean | null
          approval_type?: string | null
          approved_annual_fee?: number | null
          approved_annual_fee_currency_id?: string | null
          approved_at?: string | null
          approved_credit_limit?: number | null
          approved_credit_limit_currency_id?: string | null
          attribution_confidence_score?: number | null
          attribution_details?: Json
          attribution_model?: string
          attribution_reference?: string | null
          attribution_status?: string
          attribution_window_days?: number | null
          bank_application_reference?: string | null
          bank_id?: string | null
          card_activated_at?: string | null
          card_delivered_at?: string | null
          card_id?: string | null
          card_issued_at?: string | null
          commission_amount?: number | null
          commission_confirmed_at?: string | null
          commission_currency_id?: string | null
          commission_eligible_at?: string | null
          commission_invoiced_at?: string | null
          commission_paid_at?: string | null
          commission_rate?: number | null
          commission_reversal_reason?: string | null
          commission_reversed_at?: string | null
          commission_status?: string
          commission_type?: string | null
          correlation_id?: string | null
          created_at?: string
          decision_at?: string | null
          documents_completed_at?: string | null
          documents_requested_at?: string | null
          eligibility_prediction_correct?: boolean | null
          expected_first_year_net_value?: number | null
          expected_value_currency_id?: string | null
          expected_value_prediction_validated?: boolean | null
          expired_at?: string | null
          external_application_reference?: string | null
          finalized_at?: string | null
          financial_outcome_details?: Json
          financial_profile_id?: string | null
          first_transaction_at?: string | null
          id?: string
          idempotency_key?: string | null
          is_attributed_to_platform?: boolean
          is_attributed_to_recommendation?: boolean
          is_final?: boolean
          is_test?: boolean
          is_top_recommendation_selected?: boolean | null
          issued_card_id?: string | null
          issued_card_variant?: string | null
          manual_review_reason?: string | null
          manual_review_required?: boolean
          manual_review_status?: string | null
          metadata?: Json
          net_value_variance?: number | null
          net_value_variance_percentage?: number | null
          outcome_channel?: string | null
          outcome_occurred_at?: string
          outcome_processed_at?: string | null
          outcome_received_at?: string
          outcome_reference?: string
          outcome_source?: string
          outcome_status?: string
          outcome_type?: string
          partner_name?: string | null
          partner_reference?: string | null
          partner_settlement_reference?: string | null
          partner_type?: string | null
          processing_errors?: Json
          recommendation_accuracy_score?: number | null
          recommendation_feedback_id?: string | null
          recommendation_interaction_id?: string | null
          recommendation_match_status?: string | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_run_id?: string
          recommendation_success?: boolean | null
          reconciled_at?: string | null
          reconciled_by?: string | null
          reconciliation_batch_reference?: string | null
          reconciliation_currency_id?: string | null
          reconciliation_details?: Json
          reconciliation_difference_amount?: number | null
          reconciliation_status?: string
          rejected_at?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          selected_expected_net_value?: number | null
          selected_recommendation_rank?: number | null
          selected_recommendation_score?: number | null
          selected_value_currency_id?: string | null
          source_payload?: Json
          updated_at?: string
          user_id?: string | null
          validation_details?: Json
          withdrawn_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_outcomes_actual_value_currency_id_fkey"
            columns: ["actual_value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_approved_annual_fee_currency_id_fkey"
            columns: ["approved_annual_fee_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_approved_credit_limit_currency_id_fkey"
            columns: ["approved_credit_limit_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_commission_currency_id_fkey"
            columns: ["commission_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_expected_value_currency_id_fkey"
            columns: ["expected_value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_issued_card_id_fkey"
            columns: ["issued_card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_recommendation_feedback_id_fkey"
            columns: ["recommendation_feedback_id"]
            isOneToOne: false
            referencedRelation: "recommendation_feedback"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_recommendation_interaction_id_fkey"
            columns: ["recommendation_interaction_id"]
            isOneToOne: false
            referencedRelation: "recommendation_interactions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_recommendation_result_id_fkey"
            columns: ["recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_recommendation_run_card_id_fkey"
            columns: ["recommendation_run_card_id"]
            isOneToOne: false
            referencedRelation: "recommendation_run_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_reconciliation_currency_id_fkey"
            columns: ["reconciliation_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_outcomes_selected_value_currency_id_fkey"
            columns: ["selected_value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_results: {
        Row: {
          badge_codes: string[] | null
          bank_relationship_score: number | null
          break_even_spend: number | null
          call_to_action_code: string | null
          call_to_action_label_ar: string | null
          call_to_action_label_en: string | null
          call_to_action_url: string | null
          card_id: string
          confidence_adjusted_score: number | null
          confidence_level:
            | Database["public"]["Enums"]["recommendation_confidence_level"]
            | null
          confidence_score: number | null
          created_at: string
          data_quality_score: number | null
          disclaimer_ar: string | null
          disclaimer_en: string | null
          display_priority: number
          display_variant: string
          eligibility_assessment_id: string | null
          eligibility_score: number | null
          eligibility_status:
            | Database["public"]["Enums"]["eligibility_assessment_status"]
            | null
          eligibility_summary_ar: string | null
          eligibility_summary_en: string | null
          exclusion_reason:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          expected_annual_fee: number | null
          expected_net_value: number | null
          expected_reward_value: number | null
          expected_total_benefit: number | null
          expected_total_cost: number | null
          expires_at: string | null
          fees_score: number | null
          final_score: number | null
          financial_value_score: number | null
          generated_at: string
          hard_preference_conflict_count: number
          hard_requirements_satisfied: boolean | null
          id: string
          is_current: boolean
          is_customer_actionable: boolean
          is_featured: boolean
          is_top_recommendation: boolean
          is_visible: boolean
          key_benefits: Json
          key_costs: Json
          key_tradeoffs: Json
          lifestyle_score: number | null
          manual_review_required: boolean
          matched_preference_count: number
          metadata: Json
          normalized_score: number | null
          preference_conflicts: Json
          preference_matches: Json
          preference_score: number | null
          preference_summary_ar: string | null
          preference_summary_en: string | null
          presentation_configuration: Json
          primary_reason_ar: string | null
          primary_reason_code: string | null
          primary_reason_en: string | null
          published_at: string | null
          raw_score: number | null
          recommendation_rank: number | null
          recommendation_run_card_id: string
          recommendation_run_id: string
          recommendation_status: Database["public"]["Enums"]["recommendation_result_status"]
          result_snapshot: Json
          result_summary_ar: string | null
          result_summary_en: string | null
          result_title_ar: string | null
          result_title_en: string | null
          rewards_score: number | null
          scoring_breakdown: Json
          secondary_reason_codes: string[] | null
          simplicity_score: number | null
          travel_score: number | null
          unmet_preference_count: number
          updated_at: string
          value_currency_id: string | null
          value_simulation_id: string | null
          value_summary_ar: string | null
          value_summary_en: string | null
          warning_codes: string[] | null
          warnings: Json
        }
        Insert: {
          badge_codes?: string[] | null
          bank_relationship_score?: number | null
          break_even_spend?: number | null
          call_to_action_code?: string | null
          call_to_action_label_ar?: string | null
          call_to_action_label_en?: string | null
          call_to_action_url?: string | null
          card_id: string
          confidence_adjusted_score?: number | null
          confidence_level?:
            | Database["public"]["Enums"]["recommendation_confidence_level"]
            | null
          confidence_score?: number | null
          created_at?: string
          data_quality_score?: number | null
          disclaimer_ar?: string | null
          disclaimer_en?: string | null
          display_priority?: number
          display_variant?: string
          eligibility_assessment_id?: string | null
          eligibility_score?: number | null
          eligibility_status?:
            | Database["public"]["Enums"]["eligibility_assessment_status"]
            | null
          eligibility_summary_ar?: string | null
          eligibility_summary_en?: string | null
          exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          expected_annual_fee?: number | null
          expected_net_value?: number | null
          expected_reward_value?: number | null
          expected_total_benefit?: number | null
          expected_total_cost?: number | null
          expires_at?: string | null
          fees_score?: number | null
          final_score?: number | null
          financial_value_score?: number | null
          generated_at?: string
          hard_preference_conflict_count?: number
          hard_requirements_satisfied?: boolean | null
          id?: string
          is_current?: boolean
          is_customer_actionable?: boolean
          is_featured?: boolean
          is_top_recommendation?: boolean
          is_visible?: boolean
          key_benefits?: Json
          key_costs?: Json
          key_tradeoffs?: Json
          lifestyle_score?: number | null
          manual_review_required?: boolean
          matched_preference_count?: number
          metadata?: Json
          normalized_score?: number | null
          preference_conflicts?: Json
          preference_matches?: Json
          preference_score?: number | null
          preference_summary_ar?: string | null
          preference_summary_en?: string | null
          presentation_configuration?: Json
          primary_reason_ar?: string | null
          primary_reason_code?: string | null
          primary_reason_en?: string | null
          published_at?: string | null
          raw_score?: number | null
          recommendation_rank?: number | null
          recommendation_run_card_id: string
          recommendation_run_id: string
          recommendation_status: Database["public"]["Enums"]["recommendation_result_status"]
          result_snapshot?: Json
          result_summary_ar?: string | null
          result_summary_en?: string | null
          result_title_ar?: string | null
          result_title_en?: string | null
          rewards_score?: number | null
          scoring_breakdown?: Json
          secondary_reason_codes?: string[] | null
          simplicity_score?: number | null
          travel_score?: number | null
          unmet_preference_count?: number
          updated_at?: string
          value_currency_id?: string | null
          value_simulation_id?: string | null
          value_summary_ar?: string | null
          value_summary_en?: string | null
          warning_codes?: string[] | null
          warnings?: Json
        }
        Update: {
          badge_codes?: string[] | null
          bank_relationship_score?: number | null
          break_even_spend?: number | null
          call_to_action_code?: string | null
          call_to_action_label_ar?: string | null
          call_to_action_label_en?: string | null
          call_to_action_url?: string | null
          card_id?: string
          confidence_adjusted_score?: number | null
          confidence_level?:
            | Database["public"]["Enums"]["recommendation_confidence_level"]
            | null
          confidence_score?: number | null
          created_at?: string
          data_quality_score?: number | null
          disclaimer_ar?: string | null
          disclaimer_en?: string | null
          display_priority?: number
          display_variant?: string
          eligibility_assessment_id?: string | null
          eligibility_score?: number | null
          eligibility_status?:
            | Database["public"]["Enums"]["eligibility_assessment_status"]
            | null
          eligibility_summary_ar?: string | null
          eligibility_summary_en?: string | null
          exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          expected_annual_fee?: number | null
          expected_net_value?: number | null
          expected_reward_value?: number | null
          expected_total_benefit?: number | null
          expected_total_cost?: number | null
          expires_at?: string | null
          fees_score?: number | null
          final_score?: number | null
          financial_value_score?: number | null
          generated_at?: string
          hard_preference_conflict_count?: number
          hard_requirements_satisfied?: boolean | null
          id?: string
          is_current?: boolean
          is_customer_actionable?: boolean
          is_featured?: boolean
          is_top_recommendation?: boolean
          is_visible?: boolean
          key_benefits?: Json
          key_costs?: Json
          key_tradeoffs?: Json
          lifestyle_score?: number | null
          manual_review_required?: boolean
          matched_preference_count?: number
          metadata?: Json
          normalized_score?: number | null
          preference_conflicts?: Json
          preference_matches?: Json
          preference_score?: number | null
          preference_summary_ar?: string | null
          preference_summary_en?: string | null
          presentation_configuration?: Json
          primary_reason_ar?: string | null
          primary_reason_code?: string | null
          primary_reason_en?: string | null
          published_at?: string | null
          raw_score?: number | null
          recommendation_rank?: number | null
          recommendation_run_card_id?: string
          recommendation_run_id?: string
          recommendation_status?: Database["public"]["Enums"]["recommendation_result_status"]
          result_snapshot?: Json
          result_summary_ar?: string | null
          result_summary_en?: string | null
          result_title_ar?: string | null
          result_title_en?: string | null
          rewards_score?: number | null
          scoring_breakdown?: Json
          secondary_reason_codes?: string[] | null
          simplicity_score?: number | null
          travel_score?: number | null
          unmet_preference_count?: number
          updated_at?: string
          value_currency_id?: string | null
          value_simulation_id?: string | null
          value_summary_ar?: string | null
          value_summary_en?: string | null
          warning_codes?: string[] | null
          warnings?: Json
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_results_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_results_eligibility_assessment_id_fkey"
            columns: ["eligibility_assessment_id"]
            isOneToOne: false
            referencedRelation: "eligibility_assessments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_results_recommendation_run_card_id_fkey"
            columns: ["recommendation_run_card_id"]
            isOneToOne: true
            referencedRelation: "recommendation_run_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_results_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_results_value_currency_id_fkey"
            columns: ["value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_results_value_simulation_id_fkey"
            columns: ["value_simulation_id"]
            isOneToOne: false
            referencedRelation: "card_value_simulations"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_run_cards: {
        Row: {
          card_id: string
          confidence_score: number | null
          created_at: string
          eligibility_assessment_id: string | null
          exclusion_reason:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          final_score: number | null
          id: string
          is_visible: boolean
          metadata: Json
          recommendation_rank: number | null
          recommendation_run_id: string
          recommendation_status: Database["public"]["Enums"]["recommendation_result_status"]
          updated_at: string
          value_simulation_id: string | null
        }
        Insert: {
          card_id: string
          confidence_score?: number | null
          created_at?: string
          eligibility_assessment_id?: string | null
          exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          final_score?: number | null
          id?: string
          is_visible?: boolean
          metadata?: Json
          recommendation_rank?: number | null
          recommendation_run_id: string
          recommendation_status?: Database["public"]["Enums"]["recommendation_result_status"]
          updated_at?: string
          value_simulation_id?: string | null
        }
        Update: {
          card_id?: string
          confidence_score?: number | null
          created_at?: string
          eligibility_assessment_id?: string | null
          exclusion_reason?:
            | Database["public"]["Enums"]["recommendation_exclusion_reason"]
            | null
          final_score?: number | null
          id?: string
          is_visible?: boolean
          metadata?: Json
          recommendation_rank?: number | null
          recommendation_run_id?: string
          recommendation_status?: Database["public"]["Enums"]["recommendation_result_status"]
          updated_at?: string
          value_simulation_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_run_cards_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_run_cards_eligibility_assessment_id_fkey"
            columns: ["eligibility_assessment_id"]
            isOneToOne: false
            referencedRelation: "eligibility_assessments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_run_cards_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_run_cards_value_simulation_id_fkey"
            columns: ["value_simulation_id"]
            isOneToOne: false
            referencedRelation: "card_value_simulations"
            referencedColumns: ["id"]
          },
        ]
      }
      recommendation_runs: {
        Row: {
          cards_evaluated: number
          cards_excluded: number
          cards_failed: number
          cards_recommended: number
          completed_at: string | null
          configuration_snapshot: Json
          created_at: string
          engine_version: string
          execution_log: Json
          execution_time_ms: number | null
          financial_profile_id: string
          id: string
          input_snapshot: Json
          metadata: Json
          overall_confidence: number | null
          preference_profile_id: string | null
          recommendation_model_id: string
          run_name: string | null
          run_status: Database["public"]["Enums"]["recommendation_run_status"]
          spending_profile_id: string | null
          started_at: string
          top_recommendation_card_id: string | null
          top_recommendation_score: number | null
          updated_at: string
          warnings: Json
        }
        Insert: {
          cards_evaluated?: number
          cards_excluded?: number
          cards_failed?: number
          cards_recommended?: number
          completed_at?: string | null
          configuration_snapshot?: Json
          created_at?: string
          engine_version?: string
          execution_log?: Json
          execution_time_ms?: number | null
          financial_profile_id: string
          id?: string
          input_snapshot?: Json
          metadata?: Json
          overall_confidence?: number | null
          preference_profile_id?: string | null
          recommendation_model_id: string
          run_name?: string | null
          run_status?: Database["public"]["Enums"]["recommendation_run_status"]
          spending_profile_id?: string | null
          started_at?: string
          top_recommendation_card_id?: string | null
          top_recommendation_score?: number | null
          updated_at?: string
          warnings?: Json
        }
        Update: {
          cards_evaluated?: number
          cards_excluded?: number
          cards_failed?: number
          cards_recommended?: number
          completed_at?: string | null
          configuration_snapshot?: Json
          created_at?: string
          engine_version?: string
          execution_log?: Json
          execution_time_ms?: number | null
          financial_profile_id?: string
          id?: string
          input_snapshot?: Json
          metadata?: Json
          overall_confidence?: number | null
          preference_profile_id?: string | null
          recommendation_model_id?: string
          run_name?: string | null
          run_status?: Database["public"]["Enums"]["recommendation_run_status"]
          spending_profile_id?: string | null
          started_at?: string
          top_recommendation_card_id?: string | null
          top_recommendation_score?: number | null
          updated_at?: string
          warnings?: Json
        }
        Relationships: [
          {
            foreignKeyName: "recommendation_runs_financial_profile_id_fkey"
            columns: ["financial_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_financial_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_runs_preference_profile_id_fkey"
            columns: ["preference_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_preference_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_runs_recommendation_model_id_fkey"
            columns: ["recommendation_model_id"]
            isOneToOne: false
            referencedRelation: "recommendation_models"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_runs_spending_profile_id_fkey"
            columns: ["spending_profile_id"]
            isOneToOne: false
            referencedRelation: "customer_spending_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "recommendation_runs_top_recommendation_card_id_fkey"
            columns: ["top_recommendation_card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
        ]
      }
      referral_attributions: {
        Row: {
          application_id: string | null
          attributed_at: string | null
          attribution_confidence: number | null
          attribution_details: Json
          attribution_model: string
          attribution_reference: string
          attribution_status: string
          attribution_type: string
          attribution_weight: number
          bank_click_reference: string | null
          bank_confirmation_payload: Json
          bank_confirmed_at: string | null
          bank_id: string
          campaign_code: string | null
          campaign_reference: string | null
          card_id: string | null
          click_reference: string | null
          content_code: string | null
          converted_at: string | null
          created_at: string
          creative_reference: string | null
          device_reference: string | null
          expires_at: string | null
          external_attribution_reference: string | null
          id: string
          ip_address_hash: string | null
          is_bank_confirmed: boolean
          is_final: boolean
          is_primary: boolean
          journey_reference: string | null
          landing_page_url: string | null
          medium_code: string | null
          metadata: Json
          occurred_at: string
          partner_click_reference: string | null
          partner_product_id: string | null
          partnership_id: string
          placement_reference: string | null
          referral_link_id: string | null
          referrer_url: string | null
          rejected_at: string | null
          rejection_reason_code: string | null
          rejection_reason_text: string | null
          session_reference: string | null
          source_code: string | null
          term_code: string | null
          touchpoint_details: Json
          touchpoint_type: string
          updated_at: string
          user_agent_hash: string | null
          user_id: string | null
          visitor_reference: string | null
        }
        Insert: {
          application_id?: string | null
          attributed_at?: string | null
          attribution_confidence?: number | null
          attribution_details?: Json
          attribution_model?: string
          attribution_reference: string
          attribution_status?: string
          attribution_type?: string
          attribution_weight?: number
          bank_click_reference?: string | null
          bank_confirmation_payload?: Json
          bank_confirmed_at?: string | null
          bank_id: string
          campaign_code?: string | null
          campaign_reference?: string | null
          card_id?: string | null
          click_reference?: string | null
          content_code?: string | null
          converted_at?: string | null
          created_at?: string
          creative_reference?: string | null
          device_reference?: string | null
          expires_at?: string | null
          external_attribution_reference?: string | null
          id?: string
          ip_address_hash?: string | null
          is_bank_confirmed?: boolean
          is_final?: boolean
          is_primary?: boolean
          journey_reference?: string | null
          landing_page_url?: string | null
          medium_code?: string | null
          metadata?: Json
          occurred_at?: string
          partner_click_reference?: string | null
          partner_product_id?: string | null
          partnership_id: string
          placement_reference?: string | null
          referral_link_id?: string | null
          referrer_url?: string | null
          rejected_at?: string | null
          rejection_reason_code?: string | null
          rejection_reason_text?: string | null
          session_reference?: string | null
          source_code?: string | null
          term_code?: string | null
          touchpoint_details?: Json
          touchpoint_type?: string
          updated_at?: string
          user_agent_hash?: string | null
          user_id?: string | null
          visitor_reference?: string | null
        }
        Update: {
          application_id?: string | null
          attributed_at?: string | null
          attribution_confidence?: number | null
          attribution_details?: Json
          attribution_model?: string
          attribution_reference?: string
          attribution_status?: string
          attribution_type?: string
          attribution_weight?: number
          bank_click_reference?: string | null
          bank_confirmation_payload?: Json
          bank_confirmed_at?: string | null
          bank_id?: string
          campaign_code?: string | null
          campaign_reference?: string | null
          card_id?: string | null
          click_reference?: string | null
          content_code?: string | null
          converted_at?: string | null
          created_at?: string
          creative_reference?: string | null
          device_reference?: string | null
          expires_at?: string | null
          external_attribution_reference?: string | null
          id?: string
          ip_address_hash?: string | null
          is_bank_confirmed?: boolean
          is_final?: boolean
          is_primary?: boolean
          journey_reference?: string | null
          landing_page_url?: string | null
          medium_code?: string | null
          metadata?: Json
          occurred_at?: string
          partner_click_reference?: string | null
          partner_product_id?: string | null
          partnership_id?: string
          placement_reference?: string | null
          referral_link_id?: string | null
          referrer_url?: string | null
          rejected_at?: string | null
          rejection_reason_code?: string | null
          rejection_reason_text?: string | null
          session_reference?: string | null
          source_code?: string | null
          term_code?: string | null
          touchpoint_details?: Json
          touchpoint_type?: string
          updated_at?: string
          user_agent_hash?: string | null
          user_id?: string | null
          visitor_reference?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "referral_attributions_application_id_fkey"
            columns: ["application_id"]
            isOneToOne: false
            referencedRelation: "bank_applications"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_attributions_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_attributions_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_attributions_partner_product_id_fkey"
            columns: ["partner_product_id"]
            isOneToOne: false
            referencedRelation: "bank_partner_products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_attributions_partnership_id_fkey"
            columns: ["partnership_id"]
            isOneToOne: false
            referencedRelation: "bank_partnerships"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_attributions_referral_link_id_fkey"
            columns: ["referral_link_id"]
            isOneToOne: false
            referencedRelation: "referral_links"
            referencedColumns: ["id"]
          },
        ]
      }
      referral_links: {
        Row: {
          application_count: number
          approved_application_count: number
          attribution_model: string
          attribution_window_days: number | null
          bank_id: string
          campaign_code: string | null
          campaign_reference: string | null
          card_id: string | null
          channel: string
          click_count: number
          content_code: string | null
          conversion_count: number
          cookie_window_days: number | null
          created_at: string
          creative_reference: string | null
          deep_link_url: string | null
          destination_url: string
          expires_at: string | null
          id: string
          is_test_link: boolean
          last_clicked_at: string | null
          last_converted_at: string | null
          link_name: string
          link_status: string
          link_type: string
          maximum_clicks: number | null
          maximum_conversions: number | null
          medium_code: string | null
          metadata: Json
          partner_product_id: string | null
          partnership_id: string
          placement_reference: string | null
          referral_code: string
          referral_link_reference: string
          routing_configuration: Json
          short_url: string | null
          source_code: string | null
          starts_at: string
          term_code: string | null
          tracking_parameters: Json
          unique_click_count: number
          updated_at: string
        }
        Insert: {
          application_count?: number
          approved_application_count?: number
          attribution_model?: string
          attribution_window_days?: number | null
          bank_id: string
          campaign_code?: string | null
          campaign_reference?: string | null
          card_id?: string | null
          channel?: string
          click_count?: number
          content_code?: string | null
          conversion_count?: number
          cookie_window_days?: number | null
          created_at?: string
          creative_reference?: string | null
          deep_link_url?: string | null
          destination_url: string
          expires_at?: string | null
          id?: string
          is_test_link?: boolean
          last_clicked_at?: string | null
          last_converted_at?: string | null
          link_name: string
          link_status?: string
          link_type?: string
          maximum_clicks?: number | null
          maximum_conversions?: number | null
          medium_code?: string | null
          metadata?: Json
          partner_product_id?: string | null
          partnership_id: string
          placement_reference?: string | null
          referral_code: string
          referral_link_reference: string
          routing_configuration?: Json
          short_url?: string | null
          source_code?: string | null
          starts_at?: string
          term_code?: string | null
          tracking_parameters?: Json
          unique_click_count?: number
          updated_at?: string
        }
        Update: {
          application_count?: number
          approved_application_count?: number
          attribution_model?: string
          attribution_window_days?: number | null
          bank_id?: string
          campaign_code?: string | null
          campaign_reference?: string | null
          card_id?: string | null
          channel?: string
          click_count?: number
          content_code?: string | null
          conversion_count?: number
          cookie_window_days?: number | null
          created_at?: string
          creative_reference?: string | null
          deep_link_url?: string | null
          destination_url?: string
          expires_at?: string | null
          id?: string
          is_test_link?: boolean
          last_clicked_at?: string | null
          last_converted_at?: string | null
          link_name?: string
          link_status?: string
          link_type?: string
          maximum_clicks?: number | null
          maximum_conversions?: number | null
          medium_code?: string | null
          metadata?: Json
          partner_product_id?: string | null
          partnership_id?: string
          placement_reference?: string | null
          referral_code?: string
          referral_link_reference?: string
          routing_configuration?: Json
          short_url?: string | null
          source_code?: string | null
          starts_at?: string
          term_code?: string | null
          tracking_parameters?: Json
          unique_click_count?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "referral_links_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "banks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_links_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_links_partner_product_id_fkey"
            columns: ["partner_product_id"]
            isOneToOne: false
            referencedRelation: "bank_partner_products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_links_partnership_id_fkey"
            columns: ["partnership_id"]
            isOneToOne: false
            referencedRelation: "bank_partnerships"
            referencedColumns: ["id"]
          },
        ]
      }
      reward_categories: {
        Row: {
          created_at: string
          description_ar: string | null
          description_en: string | null
          icon_name: string | null
          id: string
          is_active: boolean
          name_ar: string
          name_en: string
          slug: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          icon_name?: string | null
          id?: string
          is_active?: boolean
          name_ar: string
          name_en: string
          slug: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description_ar?: string | null
          description_en?: string | null
          icon_name?: string | null
          id?: string
          is_active?: boolean
          name_ar?: string
          name_en?: string
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      reward_exclusions: {
        Row: {
          category_slug: string | null
          country_code: string | null
          created_at: string
          exclusion_type: string
          id: string
          is_active: boolean
          merchant_category_id: string | null
          merchant_name_pattern: string | null
          reason_ar: string | null
          reason_en: string | null
          reward_rule_id: string
          transaction_type_slug: string | null
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          category_slug?: string | null
          country_code?: string | null
          created_at?: string
          exclusion_type: string
          id?: string
          is_active?: boolean
          merchant_category_id?: string | null
          merchant_name_pattern?: string | null
          reason_ar?: string | null
          reason_en?: string | null
          reward_rule_id: string
          transaction_type_slug?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          category_slug?: string | null
          country_code?: string | null
          created_at?: string
          exclusion_type?: string
          id?: string
          is_active?: boolean
          merchant_category_id?: string | null
          merchant_name_pattern?: string | null
          reason_ar?: string | null
          reason_en?: string | null
          reward_rule_id?: string
          transaction_type_slug?: string | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "reward_exclusions_merchant_category_id_fkey"
            columns: ["merchant_category_id"]
            isOneToOne: false
            referencedRelation: "merchant_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_exclusions_reward_rule_id_fkey"
            columns: ["reward_rule_id"]
            isOneToOne: false
            referencedRelation: "reward_rules"
            referencedColumns: ["id"]
          },
        ]
      }
      reward_redemption_rates: {
        Row: {
          created_at: string
          currency_id: string | null
          description_ar: string | null
          description_en: string | null
          id: string
          is_active: boolean
          loyalty_program_id: string
          maximum_points: number | null
          minimum_points: number | null
          monetary_value: number | null
          name_ar: string
          name_en: string
          partner_program_id: string | null
          points_required: number
          priority: number
          processing_fee_amount: number | null
          processing_fee_percentage: number | null
          redemption_increment: number | null
          redemption_type: string
          slug: string
          transfer_ratio_from: number | null
          transfer_ratio_to: number | null
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          loyalty_program_id: string
          maximum_points?: number | null
          minimum_points?: number | null
          monetary_value?: number | null
          name_ar: string
          name_en: string
          partner_program_id?: string | null
          points_required: number
          priority?: number
          processing_fee_amount?: number | null
          processing_fee_percentage?: number | null
          redemption_increment?: number | null
          redemption_type: string
          slug: string
          transfer_ratio_from?: number | null
          transfer_ratio_to?: number | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          created_at?: string
          currency_id?: string | null
          description_ar?: string | null
          description_en?: string | null
          id?: string
          is_active?: boolean
          loyalty_program_id?: string
          maximum_points?: number | null
          minimum_points?: number | null
          monetary_value?: number | null
          name_ar?: string
          name_en?: string
          partner_program_id?: string | null
          points_required?: number
          priority?: number
          processing_fee_amount?: number | null
          processing_fee_percentage?: number | null
          redemption_increment?: number | null
          redemption_type?: string
          slug?: string
          transfer_ratio_from?: number | null
          transfer_ratio_to?: number | null
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "reward_redemption_rates_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_redemption_rates_loyalty_program_id_fkey"
            columns: ["loyalty_program_id"]
            isOneToOne: false
            referencedRelation: "loyalty_programs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_redemption_rates_partner_program_id_fkey"
            columns: ["partner_program_id"]
            isOneToOne: false
            referencedRelation: "loyalty_programs"
            referencedColumns: ["id"]
          },
        ]
      }
      reward_rules: {
        Row: {
          calculation_method: Database["public"]["Enums"]["reward_calculation_method"]
          cap_amount: number | null
          cap_period: Database["public"]["Enums"]["reward_cap_period"]
          card_id: string
          created_at: string
          id: string
          is_active: boolean
          minimum_spend: number | null
          minimum_spend_period:
            | Database["public"]["Enums"]["minimum_spend_period"]
            | null
          priority: number
          reward_category_id: string | null
          reward_currency_id: string | null
          reward_type: Database["public"]["Enums"]["reward_type"]
          reward_value: number
          rounding_method: Database["public"]["Enums"]["reward_rounding_method"]
          updated_at: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          calculation_method: Database["public"]["Enums"]["reward_calculation_method"]
          cap_amount?: number | null
          cap_period?: Database["public"]["Enums"]["reward_cap_period"]
          card_id: string
          created_at?: string
          id?: string
          is_active?: boolean
          minimum_spend?: number | null
          minimum_spend_period?:
            | Database["public"]["Enums"]["minimum_spend_period"]
            | null
          priority?: number
          reward_category_id?: string | null
          reward_currency_id?: string | null
          reward_type: Database["public"]["Enums"]["reward_type"]
          reward_value: number
          rounding_method?: Database["public"]["Enums"]["reward_rounding_method"]
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          calculation_method?: Database["public"]["Enums"]["reward_calculation_method"]
          cap_amount?: number | null
          cap_period?: Database["public"]["Enums"]["reward_cap_period"]
          card_id?: string
          created_at?: string
          id?: string
          is_active?: boolean
          minimum_spend?: number | null
          minimum_spend_period?:
            | Database["public"]["Enums"]["minimum_spend_period"]
            | null
          priority?: number
          reward_category_id?: string | null
          reward_currency_id?: string | null
          reward_type?: Database["public"]["Enums"]["reward_type"]
          reward_value?: number
          rounding_method?: Database["public"]["Enums"]["reward_rounding_method"]
          updated_at?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "reward_rules_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_rules_reward_category_id_fkey"
            columns: ["reward_category_id"]
            isOneToOne: false
            referencedRelation: "reward_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_rules_reward_currency_id_fkey"
            columns: ["reward_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      reward_targets: {
        Row: {
          category_slug: string | null
          created_at: string
          id: string
          merchant_category_id: string | null
          reward_rule_id: string
          target_type: Database["public"]["Enums"]["reward_target_type"]
          updated_at: string
        }
        Insert: {
          category_slug?: string | null
          created_at?: string
          id?: string
          merchant_category_id?: string | null
          reward_rule_id: string
          target_type: Database["public"]["Enums"]["reward_target_type"]
          updated_at?: string
        }
        Update: {
          category_slug?: string | null
          created_at?: string
          id?: string
          merchant_category_id?: string | null
          reward_rule_id?: string
          target_type?: Database["public"]["Enums"]["reward_target_type"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "reward_targets_merchant_category_id_fkey"
            columns: ["merchant_category_id"]
            isOneToOne: false
            referencedRelation: "merchant_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reward_targets_reward_rule_id_fkey"
            columns: ["reward_rule_id"]
            isOneToOne: false
            referencedRelation: "reward_rules"
            referencedColumns: ["id"]
          },
        ]
      }
      user_card_collections: {
        Row: {
          archived_at: string | null
          card_count: number
          collection_code: string
          collection_name: string
          collection_name_ar: string | null
          collection_type: string
          created_at: string
          deleted_at: string | null
          description: string | null
          description_ar: string | null
          display_order: number
          icon_code: string | null
          id: string
          is_archived: boolean
          is_default: boolean
          is_deleted: boolean
          is_private: boolean
          is_system_collection: boolean
          last_card_added_at: string | null
          metadata: Json
          sharing_enabled: boolean
          sharing_expires_at: string | null
          sharing_token: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          archived_at?: string | null
          card_count?: number
          collection_code: string
          collection_name: string
          collection_name_ar?: string | null
          collection_type?: string
          created_at?: string
          deleted_at?: string | null
          description?: string | null
          description_ar?: string | null
          display_order?: number
          icon_code?: string | null
          id?: string
          is_archived?: boolean
          is_default?: boolean
          is_deleted?: boolean
          is_private?: boolean
          is_system_collection?: boolean
          last_card_added_at?: string | null
          metadata?: Json
          sharing_enabled?: boolean
          sharing_expires_at?: string | null
          sharing_token?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          archived_at?: string | null
          card_count?: number
          collection_code?: string
          collection_name?: string
          collection_name_ar?: string | null
          collection_type?: string
          created_at?: string
          deleted_at?: string | null
          description?: string | null
          description_ar?: string | null
          display_order?: number
          icon_code?: string | null
          id?: string
          is_archived?: boolean
          is_default?: boolean
          is_deleted?: boolean
          is_private?: boolean
          is_system_collection?: boolean
          last_card_added_at?: string | null
          metadata?: Json
          sharing_enabled?: boolean
          sharing_expires_at?: string | null
          sharing_token?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      user_notification_preferences: {
        Row: {
          application_alerts_enabled: boolean
          benefit_changes_enabled: boolean
          card_updates_enabled: boolean
          channel_preferences: Json
          comparison_alerts_enabled: boolean
          consent_details: Json
          consent_status: string
          created_at: string
          digest_configuration: Json
          digest_day_of_week: number | null
          digest_enabled: boolean
          digest_frequency: string
          digest_hour_local: number
          eligibility_alerts_enabled: boolean
          email_enabled: boolean
          fee_changes_enabled: boolean
          id: string
          in_app_enabled: boolean
          last_preferences_reviewed_at: string | null
          marketing_consent_at: string | null
          marketing_consent_withdrawn_at: string | null
          marketing_enabled: boolean
          maximum_marketing_notifications_per_week: number | null
          maximum_notifications_per_day: number | null
          metadata: Json
          minimum_priority: string
          notification_type_preferences: Json
          notifications_enabled: boolean
          offer_expiry_reminders_enabled: boolean
          offers_enabled: boolean
          preference_reference: string
          preferred_language_code: string
          product_announcements_enabled: boolean
          push_enabled: boolean
          quiet_hours_allow_urgent: boolean
          quiet_hours_enabled: boolean
          quiet_hours_end: string | null
          quiet_hours_start: string | null
          recommendation_alerts_enabled: boolean
          reward_changes_enabled: boolean
          saved_card_alerts_enabled: boolean
          security_alerts_enabled: boolean
          sms_enabled: boolean
          timezone_name: string
          transactional_enabled: boolean
          updated_at: string
          user_id: string
          whatsapp_enabled: boolean
        }
        Insert: {
          application_alerts_enabled?: boolean
          benefit_changes_enabled?: boolean
          card_updates_enabled?: boolean
          channel_preferences?: Json
          comparison_alerts_enabled?: boolean
          consent_details?: Json
          consent_status?: string
          created_at?: string
          digest_configuration?: Json
          digest_day_of_week?: number | null
          digest_enabled?: boolean
          digest_frequency?: string
          digest_hour_local?: number
          eligibility_alerts_enabled?: boolean
          email_enabled?: boolean
          fee_changes_enabled?: boolean
          id?: string
          in_app_enabled?: boolean
          last_preferences_reviewed_at?: string | null
          marketing_consent_at?: string | null
          marketing_consent_withdrawn_at?: string | null
          marketing_enabled?: boolean
          maximum_marketing_notifications_per_week?: number | null
          maximum_notifications_per_day?: number | null
          metadata?: Json
          minimum_priority?: string
          notification_type_preferences?: Json
          notifications_enabled?: boolean
          offer_expiry_reminders_enabled?: boolean
          offers_enabled?: boolean
          preference_reference: string
          preferred_language_code?: string
          product_announcements_enabled?: boolean
          push_enabled?: boolean
          quiet_hours_allow_urgent?: boolean
          quiet_hours_enabled?: boolean
          quiet_hours_end?: string | null
          quiet_hours_start?: string | null
          recommendation_alerts_enabled?: boolean
          reward_changes_enabled?: boolean
          saved_card_alerts_enabled?: boolean
          security_alerts_enabled?: boolean
          sms_enabled?: boolean
          timezone_name?: string
          transactional_enabled?: boolean
          updated_at?: string
          user_id: string
          whatsapp_enabled?: boolean
        }
        Update: {
          application_alerts_enabled?: boolean
          benefit_changes_enabled?: boolean
          card_updates_enabled?: boolean
          channel_preferences?: Json
          comparison_alerts_enabled?: boolean
          consent_details?: Json
          consent_status?: string
          created_at?: string
          digest_configuration?: Json
          digest_day_of_week?: number | null
          digest_enabled?: boolean
          digest_frequency?: string
          digest_hour_local?: number
          eligibility_alerts_enabled?: boolean
          email_enabled?: boolean
          fee_changes_enabled?: boolean
          id?: string
          in_app_enabled?: boolean
          last_preferences_reviewed_at?: string | null
          marketing_consent_at?: string | null
          marketing_consent_withdrawn_at?: string | null
          marketing_enabled?: boolean
          maximum_marketing_notifications_per_week?: number | null
          maximum_notifications_per_day?: number | null
          metadata?: Json
          minimum_priority?: string
          notification_type_preferences?: Json
          notifications_enabled?: boolean
          offer_expiry_reminders_enabled?: boolean
          offers_enabled?: boolean
          preference_reference?: string
          preferred_language_code?: string
          product_announcements_enabled?: boolean
          push_enabled?: boolean
          quiet_hours_allow_urgent?: boolean
          quiet_hours_enabled?: boolean
          quiet_hours_end?: string | null
          quiet_hours_start?: string | null
          recommendation_alerts_enabled?: boolean
          reward_changes_enabled?: boolean
          saved_card_alerts_enabled?: boolean
          security_alerts_enabled?: boolean
          sms_enabled?: boolean
          timezone_name?: string
          transactional_enabled?: boolean
          updated_at?: string
          user_id?: string
          whatsapp_enabled?: boolean
        }
        Relationships: []
      }
      user_platform_role_assignments: {
        Row: {
          assigned_at: string
          assigned_by_user_id: string | null
          assignment_reason: string | null
          assignment_reference: string | null
          created_at: string
          id: string
          revocation_reason: string | null
          revoked_at: string | null
          revoked_by_user_id: string | null
          role_id: string
          scope_reference: string | null
          scope_type: string
          updated_at: string
          user_id: string
          valid_from: string
          valid_until: string | null
        }
        Insert: {
          assigned_at?: string
          assigned_by_user_id?: string | null
          assignment_reason?: string | null
          assignment_reference?: string | null
          created_at?: string
          id?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          role_id: string
          scope_reference?: string | null
          scope_type?: string
          updated_at?: string
          user_id: string
          valid_from?: string
          valid_until?: string | null
        }
        Update: {
          assigned_at?: string
          assigned_by_user_id?: string | null
          assignment_reason?: string | null
          assignment_reference?: string | null
          created_at?: string
          id?: string
          revocation_reason?: string | null
          revoked_at?: string | null
          revoked_by_user_id?: string | null
          role_id?: string
          scope_reference?: string | null
          scope_type?: string
          updated_at?: string
          user_id?: string
          valid_from?: string
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_platform_role_assignments_role_id_fkey"
            columns: ["role_id"]
            isOneToOne: false
            referencedRelation: "platform_roles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_profiles: {
        Row: {
          account_status: string
          activated_at: string
          created_at: string
          deactivated_at: string | null
          display_name: string | null
          id: string
          onboarding_status: string
          preferred_language_code: string
          profile_completed_at: string | null
          suspended_at: string | null
          suspension_reason: string | null
          timezone_name: string
          updated_at: string
          user_id: string
        }
        Insert: {
          account_status?: string
          activated_at?: string
          created_at?: string
          deactivated_at?: string | null
          display_name?: string | null
          id?: string
          onboarding_status?: string
          preferred_language_code?: string
          profile_completed_at?: string | null
          suspended_at?: string | null
          suspension_reason?: string | null
          timezone_name?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          account_status?: string
          activated_at?: string
          created_at?: string
          deactivated_at?: string | null
          display_name?: string | null
          id?: string
          onboarding_status?: string
          preferred_language_code?: string
          profile_completed_at?: string | null
          suspended_at?: string | null
          suspension_reason?: string | null
          timezone_name?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      user_saved_cards: {
        Row: {
          annual_fee_at_save: number | null
          annual_fee_currency_id: string | null
          application_intent: string | null
          archived_at: string | null
          card_id: string
          card_snapshot: Json
          collection_id: string
          created_at: string
          expected_annual_value: number | null
          expected_annual_value_currency_id: string | null
          id: string
          interest_status: string
          is_application_candidate: boolean
          is_archived: boolean
          is_pinned: boolean
          is_removed: boolean
          last_compared_at: string | null
          last_updated_from_card_at: string | null
          last_viewed_at: string | null
          metadata: Json
          notification_preferences: Json
          offer_expires_at: string | null
          offer_reference: string | null
          personal_note: string | null
          position: number
          priority_level: string
          promotional_offer_at_save: boolean | null
          rank_at_save: number | null
          recommendation_result_id: string | null
          recommendation_run_card_id: string | null
          recommendation_run_id: string | null
          reminder_at: string | null
          reminder_enabled: boolean
          removed_at: string | null
          saved_at: string
          saved_context: Json
          saved_reason_code: string | null
          saved_reason_text: string | null
          saved_reference: string
          saved_source: string
          score_at_save: number | null
          source_interaction_id: string | null
          target_application_date: string | null
          target_credit_limit: number | null
          target_credit_limit_currency_id: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          annual_fee_at_save?: number | null
          annual_fee_currency_id?: string | null
          application_intent?: string | null
          archived_at?: string | null
          card_id: string
          card_snapshot?: Json
          collection_id: string
          created_at?: string
          expected_annual_value?: number | null
          expected_annual_value_currency_id?: string | null
          id?: string
          interest_status?: string
          is_application_candidate?: boolean
          is_archived?: boolean
          is_pinned?: boolean
          is_removed?: boolean
          last_compared_at?: string | null
          last_updated_from_card_at?: string | null
          last_viewed_at?: string | null
          metadata?: Json
          notification_preferences?: Json
          offer_expires_at?: string | null
          offer_reference?: string | null
          personal_note?: string | null
          position?: number
          priority_level?: string
          promotional_offer_at_save?: boolean | null
          rank_at_save?: number | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_run_id?: string | null
          reminder_at?: string | null
          reminder_enabled?: boolean
          removed_at?: string | null
          saved_at?: string
          saved_context?: Json
          saved_reason_code?: string | null
          saved_reason_text?: string | null
          saved_reference: string
          saved_source?: string
          score_at_save?: number | null
          source_interaction_id?: string | null
          target_application_date?: string | null
          target_credit_limit?: number | null
          target_credit_limit_currency_id?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          annual_fee_at_save?: number | null
          annual_fee_currency_id?: string | null
          application_intent?: string | null
          archived_at?: string | null
          card_id?: string
          card_snapshot?: Json
          collection_id?: string
          created_at?: string
          expected_annual_value?: number | null
          expected_annual_value_currency_id?: string | null
          id?: string
          interest_status?: string
          is_application_candidate?: boolean
          is_archived?: boolean
          is_pinned?: boolean
          is_removed?: boolean
          last_compared_at?: string | null
          last_updated_from_card_at?: string | null
          last_viewed_at?: string | null
          metadata?: Json
          notification_preferences?: Json
          offer_expires_at?: string | null
          offer_reference?: string | null
          personal_note?: string | null
          position?: number
          priority_level?: string
          promotional_offer_at_save?: boolean | null
          rank_at_save?: number | null
          recommendation_result_id?: string | null
          recommendation_run_card_id?: string | null
          recommendation_run_id?: string | null
          reminder_at?: string | null
          reminder_enabled?: boolean
          removed_at?: string | null
          saved_at?: string
          saved_context?: Json
          saved_reason_code?: string | null
          saved_reason_text?: string | null
          saved_reference?: string
          saved_source?: string
          score_at_save?: number | null
          source_interaction_id?: string | null
          target_application_date?: string | null
          target_credit_limit?: number | null
          target_credit_limit_currency_id?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_saved_cards_annual_fee_currency_id_fkey"
            columns: ["annual_fee_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_saved_cards_card_id_fkey"
            columns: ["card_id"]
            isOneToOne: false
            referencedRelation: "cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_saved_cards_collection_id_fkey"
            columns: ["collection_id"]
            isOneToOne: false
            referencedRelation: "user_card_collections"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_saved_cards_expected_annual_value_currency_id_fkey"
            columns: ["expected_annual_value_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_saved_cards_recommendation_result_id_fkey"
            columns: ["recommendation_result_id"]
            isOneToOne: false
            referencedRelation: "recommendation_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_saved_cards_recommendation_run_card_id_fkey"
            columns: ["recommendation_run_card_id"]
            isOneToOne: false
            referencedRelation: "recommendation_run_cards"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_saved_cards_recommendation_run_id_fkey"
            columns: ["recommendation_run_id"]
            isOneToOne: false
            referencedRelation: "recommendation_runs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_saved_cards_source_interaction_id_fkey"
            columns: ["source_interaction_id"]
            isOneToOne: false
            referencedRelation: "recommendation_interactions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_saved_cards_target_credit_limit_currency_id_fkey"
            columns: ["target_credit_limit_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      acknowledge_background_job_cancellation: {
        Args: { requested_execution_id: string; requested_lease_token: string }
        Returns: boolean
      }
      api_client_has_scope: {
        Args: { requested_client_id: string; requested_scope_code: string }
        Returns: boolean
      }
      catalog_target_bank_id: {
        Args: { requested_target_id: string; requested_target_type: string }
        Returns: string
      }
      catalog_user_has_active_scope: {
        Args: { requested_bank_id: string; requested_user_id: string }
        Returns: boolean
      }
      catalog_user_has_target_access: {
        Args: {
          requested_target_id: string
          requested_target_type: string
          requested_user_id: string
        }
        Returns: boolean
      }
      complete_background_job_execution: {
        Args: {
          requested_execution_id: string
          requested_lease_token: string
          requested_result: Json
        }
        Returns: boolean
      }
      decide_catalog_publication: {
        Args: {
          comments: string
          decision: string
          requested_request_id: string
        }
        Returns: string
      }
      enqueue_background_job: {
        Args: {
          requested_available_at?: string
          requested_commission_settlement_id?: string
          requested_data_retention_execution_id?: string
          requested_idempotency_key?: string
          requested_job_code: string
          requested_payload?: Json
          requested_priority?: number
        }
        Returns: string
      }
      fail_background_job_execution: {
        Args: {
          requested_execution_id: string
          requested_failure_code: string
          requested_failure_details?: Json
          requested_failure_message: string
          requested_lease_token: string
          requested_retryable?: boolean
        }
        Returns: string
      }
      get_api_client_rate_limit: {
        Args: { requested_client_id: string }
        Returns: {
          burst_limit: number
          policy_id: string
          request_limit: number
          window_seconds: number
        }[]
      }
      get_published_card_detail: {
        Args: { requested_slug: string }
        Returns: Json
      }
      has_active_catalog_scope: {
        Args: { requested_bank_id: string }
        Returns: boolean
      }
      has_active_platform_permission: {
        Args: { requested_permission_code: string }
        Returns: boolean
      }
      has_active_platform_role: {
        Args: { requested_role_code: string }
        Returns: boolean
      }
      has_catalog_publication_version_access: {
        Args: { requested_version_id: string }
        Returns: boolean
      }
      has_catalog_target_access: {
        Args: { requested_target_id: string; requested_target_type: string }
        Returns: boolean
      }
      heartbeat_background_job_execution: {
        Args: { requested_execution_id: string; requested_lease_token: string }
        Returns: boolean
      }
      is_api_key_active: {
        Args: { requested_secret_hash: string }
        Returns: boolean
      }
      is_feature_enabled: {
        Args: { requested_flag_key: string; rollout_subject?: string }
        Returns: boolean
      }
      lease_background_jobs: {
        Args: { requested_limit?: number; requested_worker_id: string }
        Returns: {
          attempt_count: number
          available_at: string
          cancellation_reason: string | null
          cancellation_requested_at: string | null
          cancellation_requested_by_user_id: string | null
          cancelled_at: string | null
          commission_settlement_id: string | null
          completed_at: string | null
          created_at: string
          data_retention_execution_id: string | null
          execution_reference: string
          execution_status: string
          failed_at: string | null
          failure_code: string | null
          failure_details: Json | null
          failure_message: string | null
          heartbeat_at: string | null
          id: string
          idempotency_key: string | null
          job_definition_id: string
          lease_expires_at: string | null
          lease_token: string | null
          leased_at: string | null
          payload: Json
          priority: number
          queued_at: string
          result: Json | null
          retryable: boolean | null
          schedule_id: string | null
          scheduled_for: string | null
          started_at: string | null
          updated_at: string
          worker_id: string | null
        }[]
        SetofOptions: {
          from: "*"
          to: "background_job_executions"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      materialize_due_background_jobs: {
        Args: { requested_limit?: number }
        Returns: string[]
      }
      publish_catalog_version: {
        Args: { requested_version_id: string }
        Returns: string
      }
      reap_expired_background_job_leases: {
        Args: { requested_limit?: number }
        Returns: number
      }
      request_background_job_cancellation: {
        Args: { requested_execution_id: string; requested_reason: string }
        Returns: boolean
      }
      rollback_catalog_version: {
        Args: {
          current_version_id: string
          reason: string
          replacement_version_id: string
        }
        Returns: string
      }
      search_published_cards: {
        Args: {
          requested_bank_slug?: string
          requested_locale?: string
          requested_max_annual_fee?: number
          requested_maximum_salary?: number
          requested_min_reward_value?: number
          requested_network_slug?: string
          requested_page?: number
          requested_page_size?: number
          requested_persona?: string
          requested_reward_category_slug?: string
          requested_reward_type?: string
          requested_search?: string
          requested_sort?: string
        }
        Returns: Json
      }
      start_background_job_execution: {
        Args: { requested_execution_id: string; requested_lease_token: string }
        Returns: boolean
      }
      submit_catalog_publication: {
        Args: {
          effective_end?: string
          effective_start?: string
          final_approver_id: string
          publish_at?: string
          requested_version_id: string
          reviewer_id: string
          unpublish_at?: string
        }
        Returns: string
      }
      unpublish_catalog_version: {
        Args: { archive: boolean; reason: string; requested_version_id: string }
        Returns: string
      }
    }
    Enums: {
      billing_period: "MONTHLY" | "QUARTERLY" | "YEARLY" | "ONE_TIME"
      card_availability_status: "AVAILABLE" | "COMING_SOON" | "DISCONTINUED"
      customer_preference_importance:
        | "not_important"
        | "low"
        | "medium"
        | "high"
        | "essential"
      eligibility_assessment_status:
        | "eligible"
        | "likely_eligible"
        | "conditionally_eligible"
        | "not_eligible"
        | "insufficient_information"
        | "manual_review_required"
      eligibility_requirement_result:
        | "passed"
        | "failed"
        | "conditionally_passed"
        | "unknown"
        | "not_applicable"
      explanation_type:
        | "eligibility"
        | "financial_value"
        | "rewards"
        | "travel"
        | "lounge"
        | "dining"
        | "shopping"
        | "insurance"
        | "fees"
        | "risk"
        | "condition"
        | "warning"
        | "advantage"
        | "disadvantage"
        | "alternative"
        | "general"
      fee_type:
        | "ANNUAL"
        | "ISSUANCE"
        | "REPLACEMENT"
        | "LATE_PAYMENT"
        | "FOREIGN_TRANSACTION"
        | "CASH_ADVANCE"
        | "OTHER"
      fee_waiver_type:
        | "NONE"
        | "FIRST_YEAR"
        | "SPEND_THRESHOLD"
        | "SALARY_TRANSFER"
        | "LIFETIME"
      loyalty_program_type:
        | "AIRLINE"
        | "HOTEL"
        | "BANK_POINTS"
        | "CASHBACK"
        | "RETAIL"
        | "OTHER"
      minimum_spend_period: "TRANSACTION" | "DAY" | "MONTH" | "YEAR"
      payment_network: "VISA" | "MASTERCARD" | "AMERICAN_EXPRESS" | "MADA"
      recommendation_confidence_level:
        | "very_low"
        | "low"
        | "medium"
        | "high"
        | "very_high"
      recommendation_exclusion_reason:
        | "eligibility_failed"
        | "income_requirement_not_met"
        | "salary_transfer_required"
        | "customer_segment_required"
        | "employment_requirement_not_met"
        | "nationality_requirement_not_met"
        | "residency_requirement_not_met"
        | "age_requirement_not_met"
        | "annual_fee_too_high"
        | "spending_requirement_not_met"
        | "insufficient_customer_data"
        | "card_inactive"
        | "card_unavailable"
        | "user_excluded"
        | "model_excluded"
        | "other"
      recommendation_model_type:
        | "rule_based"
        | "weighted"
        | "financial_value"
        | "hybrid"
        | "machine_learning"
        | "editorial"
      recommendation_result_status:
        | "recommended"
        | "conditionally_recommended"
        | "alternative"
        | "not_recommended"
        | "excluded"
      recommendation_run_status:
        | "pending"
        | "processing"
        | "completed"
        | "partially_completed"
        | "failed"
        | "cancelled"
        | "expired"
      reward_calculation_method: "FIXED" | "PERCENTAGE" | "TIERED"
      reward_cap_period: "NONE" | "MONTH" | "QUARTER" | "YEAR" | "LIFETIME"
      reward_exclusion_type: "MCC" | "CATEGORY"
      reward_rounding_method: "NONE" | "UP" | "DOWN" | "NEAREST"
      reward_target_type: "MCC" | "CATEGORY"
      reward_type: "CASHBACK" | "POINTS" | "MILES" | "DISCOUNT" | "VOUCHER"
      target_user_type:
        | "GENERAL"
        | "STUDENT"
        | "SALARY"
        | "PRIVATE_BANKING"
        | "BUSINESS"
      threshold_period: "MONTH" | "QUARTER" | "YEAR"
      value_component_direction: "benefit" | "cost" | "neutral"
      value_simulation_component_type:
        | "base_rewards"
        | "bonus_rewards"
        | "welcome_bonus"
        | "cashback"
        | "miles"
        | "points"
        | "lounge_access"
        | "travel_benefit"
        | "dining_benefit"
        | "insurance_benefit"
        | "network_benefit"
        | "merchant_offer"
        | "installment_benefit"
        | "annual_fee"
        | "supplementary_card_fee"
        | "foreign_transaction_fee"
        | "cash_advance_fee"
        | "reward_redemption_cost"
        | "opportunity_cost"
        | "other_benefit"
        | "other_cost"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      billing_period: ["MONTHLY", "QUARTERLY", "YEARLY", "ONE_TIME"],
      card_availability_status: ["AVAILABLE", "COMING_SOON", "DISCONTINUED"],
      customer_preference_importance: [
        "not_important",
        "low",
        "medium",
        "high",
        "essential",
      ],
      eligibility_assessment_status: [
        "eligible",
        "likely_eligible",
        "conditionally_eligible",
        "not_eligible",
        "insufficient_information",
        "manual_review_required",
      ],
      eligibility_requirement_result: [
        "passed",
        "failed",
        "conditionally_passed",
        "unknown",
        "not_applicable",
      ],
      explanation_type: [
        "eligibility",
        "financial_value",
        "rewards",
        "travel",
        "lounge",
        "dining",
        "shopping",
        "insurance",
        "fees",
        "risk",
        "condition",
        "warning",
        "advantage",
        "disadvantage",
        "alternative",
        "general",
      ],
      fee_type: [
        "ANNUAL",
        "ISSUANCE",
        "REPLACEMENT",
        "LATE_PAYMENT",
        "FOREIGN_TRANSACTION",
        "CASH_ADVANCE",
        "OTHER",
      ],
      fee_waiver_type: [
        "NONE",
        "FIRST_YEAR",
        "SPEND_THRESHOLD",
        "SALARY_TRANSFER",
        "LIFETIME",
      ],
      loyalty_program_type: [
        "AIRLINE",
        "HOTEL",
        "BANK_POINTS",
        "CASHBACK",
        "RETAIL",
        "OTHER",
      ],
      minimum_spend_period: ["TRANSACTION", "DAY", "MONTH", "YEAR"],
      payment_network: ["VISA", "MASTERCARD", "AMERICAN_EXPRESS", "MADA"],
      recommendation_confidence_level: [
        "very_low",
        "low",
        "medium",
        "high",
        "very_high",
      ],
      recommendation_exclusion_reason: [
        "eligibility_failed",
        "income_requirement_not_met",
        "salary_transfer_required",
        "customer_segment_required",
        "employment_requirement_not_met",
        "nationality_requirement_not_met",
        "residency_requirement_not_met",
        "age_requirement_not_met",
        "annual_fee_too_high",
        "spending_requirement_not_met",
        "insufficient_customer_data",
        "card_inactive",
        "card_unavailable",
        "user_excluded",
        "model_excluded",
        "other",
      ],
      recommendation_model_type: [
        "rule_based",
        "weighted",
        "financial_value",
        "hybrid",
        "machine_learning",
        "editorial",
      ],
      recommendation_result_status: [
        "recommended",
        "conditionally_recommended",
        "alternative",
        "not_recommended",
        "excluded",
      ],
      recommendation_run_status: [
        "pending",
        "processing",
        "completed",
        "partially_completed",
        "failed",
        "cancelled",
        "expired",
      ],
      reward_calculation_method: ["FIXED", "PERCENTAGE", "TIERED"],
      reward_cap_period: ["NONE", "MONTH", "QUARTER", "YEAR", "LIFETIME"],
      reward_exclusion_type: ["MCC", "CATEGORY"],
      reward_rounding_method: ["NONE", "UP", "DOWN", "NEAREST"],
      reward_target_type: ["MCC", "CATEGORY"],
      reward_type: ["CASHBACK", "POINTS", "MILES", "DISCOUNT", "VOUCHER"],
      target_user_type: [
        "GENERAL",
        "STUDENT",
        "SALARY",
        "PRIVATE_BANKING",
        "BUSINESS",
      ],
      threshold_period: ["MONTH", "QUARTER", "YEAR"],
      value_component_direction: ["benefit", "cost", "neutral"],
      value_simulation_component_type: [
        "base_rewards",
        "bonus_rewards",
        "welcome_bonus",
        "cashback",
        "miles",
        "points",
        "lounge_access",
        "travel_benefit",
        "dining_benefit",
        "insurance_benefit",
        "network_benefit",
        "merchant_offer",
        "installment_benefit",
        "annual_fee",
        "supplementary_card_fee",
        "foreign_transaction_fee",
        "cash_advance_fee",
        "reward_redemption_cost",
        "opportunity_cost",
        "other_benefit",
        "other_cost",
      ],
    },
  },
} as const

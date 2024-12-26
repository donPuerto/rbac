-- =====================================================================================
-- RBAC System Cleanup
-- =====================================================================================
-- Description: Drops all components of the RBAC system in the correct dependency order
-- Version: 1.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Force drop problematic types
DO $$
BEGIN
    DROP TYPE IF EXISTS public.communication_language_type CASCADE;
EXCEPTION
    WHEN OTHERS THEN 
        RAISE NOTICE 'Error force dropping communication_language_type: %', SQLERRM;
END $$;

-- Drop Extensions (if they were created specifically for this system)
-- =====================================================================================
DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
DROP EXTENSION IF EXISTS pgcrypto CASCADE;
DROP EXTENSION IF EXISTS pg_trgm CASCADE;
DROP EXTENSION IF EXISTS unaccent CASCADE;
DROP EXTENSION IF EXISTS fuzzystrmatch CASCADE;

-- Drop Event Triggers
-- =====================================================================================
DROP EVENT TRIGGER IF EXISTS prevent_drop_trigger CASCADE;
DROP EVENT TRIGGER IF EXISTS audit_ddl_trigger CASCADE;
DROP EVENT TRIGGER IF EXISTS track_schema_changes CASCADE;

-- Drop Triggers
-- =====================================================================================
DO $$
DECLARE
    trigger_record RECORD;
BEGIN
    FOR trigger_record IN 
        SELECT DISTINCT trigger_name, event_object_table
        FROM information_schema.triggers
        WHERE trigger_schema = 'public'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.%I CASCADE;',
            trigger_record.trigger_name,
            trigger_record.event_object_table);
    END LOOP;
END $$;

-- Drop Specific Triggers
DO $$
BEGIN
    -- User Management Triggers
    DROP TRIGGER IF EXISTS user_audit_trigger ON public.profiles CASCADE;
    DROP TRIGGER IF EXISTS user_timestamp_trigger ON public.profiles CASCADE;
    DROP TRIGGER IF EXISTS user_search_trigger ON public.profiles CASCADE;
    DROP TRIGGER IF EXISTS user_notification_trigger ON public.profiles CASCADE;

    -- RBAC Triggers
    DROP TRIGGER IF EXISTS role_audit_trigger ON public.roles CASCADE;
    DROP TRIGGER IF EXISTS permission_audit_trigger ON public.permissions CASCADE;
    DROP TRIGGER IF EXISTS role_permission_audit_trigger ON public.role_permissions CASCADE;
    DROP TRIGGER IF EXISTS role_delegation_audit_trigger ON public.role_delegations CASCADE;

    -- CRM Triggers
    DROP TRIGGER IF EXISTS lead_audit_trigger ON public.crm_leads CASCADE;
    DROP TRIGGER IF EXISTS opportunity_audit_trigger ON public.crm_opportunities CASCADE;
    DROP TRIGGER IF EXISTS contact_audit_trigger ON public.crm_contacts CASCADE;
    DROP TRIGGER IF EXISTS quote_audit_trigger ON public.crm_quotes CASCADE;
    DROP TRIGGER IF EXISTS pipeline_audit_trigger ON public.crm_pipelines CASCADE;
    DROP TRIGGER IF EXISTS communication_audit_trigger ON public.crm_communications CASCADE;

    -- Task Triggers
    DROP TRIGGER IF EXISTS task_audit_trigger ON public.tasks CASCADE;
    DROP TRIGGER IF EXISTS task_notification_trigger ON public.tasks CASCADE;
    DROP TRIGGER IF EXISTS task_assignment_trigger ON public.task_assignments CASCADE;
    DROP TRIGGER IF EXISTS task_status_trigger ON public.tasks CASCADE;

    -- Document Triggers
    DROP TRIGGER IF EXISTS document_audit_trigger ON public.documents CASCADE;
    DROP TRIGGER IF EXISTS document_version_trigger ON public.documents CASCADE;
    DROP TRIGGER IF EXISTS document_workflow_trigger ON public.document_workflows CASCADE;
    DROP TRIGGER IF EXISTS document_notification_trigger ON public.documents CASCADE;

    -- Inventory Triggers
    DROP TRIGGER IF EXISTS inventory_audit_trigger ON public.inventory_items CASCADE;
    DROP TRIGGER IF EXISTS stock_level_trigger ON public.inventory_transactions CASCADE;
    DROP TRIGGER IF EXISTS quality_check_trigger ON public.quality_inspections CASCADE;
    DROP TRIGGER IF EXISTS reorder_alert_trigger ON public.inventory_items CASCADE;

    -- Financial Triggers
    DROP TRIGGER IF EXISTS journal_audit_trigger ON public.journal_entries CASCADE;
    DROP TRIGGER IF EXISTS payment_audit_trigger ON public.payment_transactions CASCADE;
    DROP TRIGGER IF EXISTS budget_check_trigger ON public.journal_entries CASCADE;
    DROP TRIGGER IF EXISTS balance_update_trigger ON public.journal_entries CASCADE;

    -- System Triggers
    DROP TRIGGER IF EXISTS audit_log_trigger ON public.audit_logs CASCADE;
    DROP TRIGGER IF EXISTS error_log_trigger ON public.error_logs CASCADE;
    DROP TRIGGER IF EXISTS activity_log_trigger ON public.user_activities CASCADE;
    DROP TRIGGER IF EXISTS metric_update_trigger ON public.system_metrics CASCADE;

    -- Search Triggers
    DROP TRIGGER IF EXISTS profile_search_update ON public.profiles CASCADE;
    DROP TRIGGER IF EXISTS lead_search_update ON public.crm_leads CASCADE;
    DROP TRIGGER IF EXISTS contact_search_update ON public.crm_contacts CASCADE;
    DROP TRIGGER IF EXISTS document_search_update ON public.documents CASCADE;
    DROP TRIGGER IF EXISTS task_search_update ON public.tasks CASCADE;

    -- Timestamp Triggers
    DROP TRIGGER IF EXISTS update_timestamp ON public.profiles CASCADE;
    DROP TRIGGER IF EXISTS update_timestamp ON public.roles CASCADE;
    DROP TRIGGER IF EXISTS update_timestamp ON public.permissions CASCADE;
    DROP TRIGGER IF EXISTS update_timestamp ON public.documents CASCADE;
    DROP TRIGGER IF EXISTS update_timestamp ON public.tasks CASCADE;

EXCEPTION
    WHEN OTHERS THEN null; -- Ignore errors if triggers don't exist
END $$;

-- Revoke All Grants and Permissions
-- =====================================================================================
DO $$ 
BEGIN
    -- Revoke all privileges from roles
    REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authenticated;
    REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM authenticated;
    REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM authenticated;
    REVOKE ALL ON SCHEMA public FROM authenticated;

    REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
    REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM anon;
    REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon;
    REVOKE ALL ON SCHEMA public FROM anon;

    REVOKE ALL ON ALL TABLES IN SCHEMA public FROM service_role;
    REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM service_role;
    REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM service_role;
    REVOKE ALL ON SCHEMA public FROM service_role;
EXCEPTION
    WHEN OTHERS THEN null; -- Ignore errors if roles don't exist
END $$;

-- Disable RLS on all tables
-- =====================================================================================
DO $$ 
DECLARE
    table_record record;
BEGIN
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('ALTER TABLE IF EXISTS public.%I DISABLE ROW LEVEL SECURITY;', table_record.table_name);
    END LOOP;
END $$;

-- Drop RLS Policies
-- =====================================================================================
DO $$ 
DECLARE
    policy_record record;
BEGIN
    FOR policy_record IN 
        SELECT schemaname, tablename, policyname
        FROM pg_policies 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', 
            policy_record.policyname, 
            policy_record.tablename);
    END LOOP;
END $$;

-- Drop Constraints
-- =====================================================================================
DO $$
DECLARE
    _sql text;
BEGIN
    -- Drop all foreign key constraints first
    FOR _sql IN (
        SELECT format('ALTER TABLE %I.%I DROP CONSTRAINT %I;',
                     tc.table_schema,
                     tc.table_name,
                     tc.constraint_name)
        FROM information_schema.table_constraints tc
        WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public'
        ORDER BY tc.constraint_name DESC
    ) LOOP
        EXECUTE _sql;
    END LOOP;

    -- Drop all primary key and unique constraints
    FOR _sql IN (
        SELECT format('ALTER TABLE %I.%I DROP CONSTRAINT %I;',
                     tc.table_schema,
                     tc.table_name,
                     tc.constraint_name)
        FROM information_schema.table_constraints tc
        WHERE tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE')
        AND tc.table_schema = 'public'
        ORDER BY tc.constraint_name DESC
    ) LOOP
        EXECUTE _sql;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN 
        RAISE NOTICE 'Error dropping constraints: %', SQLERRM;
END $$;

-- Drop Indexes
-- =====================================================================================
DO $$
DECLARE
    idx_record record;
BEGIN
    FOR idx_record IN 
        SELECT schemaname, tablename, indexname 
        FROM pg_indexes 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP INDEX IF EXISTS public.%I CASCADE;', idx_record.indexname);
    END LOOP;
END $$;

-- Drop Views
-- =====================================================================================
DO $$
BEGIN
    -- User Management Views
    DROP VIEW IF EXISTS public.user_role_permissions CASCADE;
    DROP VIEW IF EXISTS public.active_users CASCADE;
    DROP VIEW IF EXISTS public.user_activity_summary CASCADE;
    DROP VIEW IF EXISTS public.user_security_status CASCADE;

    -- CRM Views
    DROP VIEW IF EXISTS public.lead_pipeline_summary CASCADE;
    DROP VIEW IF EXISTS public.opportunity_pipeline CASCADE;
    DROP VIEW IF EXISTS public.customer_360_view CASCADE;
    DROP VIEW IF EXISTS public.sales_dashboard CASCADE;
    DROP VIEW IF EXISTS public.campaign_performance CASCADE;
    DROP VIEW IF EXISTS public.communication_history CASCADE;

    -- Task Management Views
    DROP VIEW IF EXISTS public.task_dashboard CASCADE;
    DROP VIEW IF EXISTS public.sprint_summary CASCADE;
    DROP VIEW IF EXISTS public.board_status CASCADE;
    DROP VIEW IF EXISTS public.task_assignments_view CASCADE;
    DROP VIEW IF EXISTS public.time_tracking_summary CASCADE;

    -- Document Management Views
    DROP VIEW IF EXISTS public.document_status_summary CASCADE;
    DROP VIEW IF EXISTS public.pending_approvals CASCADE;
    DROP VIEW IF EXISTS public.document_access_log CASCADE;
    DROP VIEW IF EXISTS public.document_version_history CASCADE;

    -- Inventory Management Views
    DROP VIEW IF EXISTS public.inventory_status CASCADE;
    DROP VIEW IF EXISTS public.low_stock_alerts CASCADE;
    DROP VIEW IF EXISTS public.purchase_order_status CASCADE;
    DROP VIEW IF EXISTS public.quality_inspection_summary CASCADE;
    DROP VIEW IF EXISTS public.inventory_valuation CASCADE;

    -- Financial Management Views
    DROP VIEW IF EXISTS public.account_balances CASCADE;
    DROP VIEW IF EXISTS public.payment_summary CASCADE;
    DROP VIEW IF EXISTS public.budget_vs_actual CASCADE;
    DROP VIEW IF EXISTS public.financial_statements CASCADE;
    DROP VIEW IF EXISTS public.cash_flow_projection CASCADE;

    -- Audit and System Views
    DROP VIEW IF EXISTS public.audit_log_summary CASCADE;
    DROP VIEW IF EXISTS public.system_health_dashboard CASCADE;
    DROP VIEW IF EXISTS public.error_log_summary CASCADE;
    DROP VIEW IF EXISTS public.user_activity_dashboard CASCADE;

EXCEPTION
    WHEN OTHERS THEN null; -- Ignore errors if views don't exist
END $$;

-- Drop Functions and Procedures
-- =====================================================================================
DO $$
BEGIN
    -- Drop Core System Functions
    DROP FUNCTION IF EXISTS public.initialize_system() CASCADE;
    DROP FUNCTION IF EXISTS public.upgrade_system_version() CASCADE;
    DROP FUNCTION IF EXISTS public.validate_system_health() CASCADE;
    DROP FUNCTION IF EXISTS public.cleanup_system() CASCADE;
    DROP FUNCTION IF EXISTS public.backup_system() CASCADE;
    DROP FUNCTION IF EXISTS public.restore_system() CASCADE;

    -- Drop User Management Functions
    DROP FUNCTION IF EXISTS public.create_user(text, text, text) CASCADE;
    DROP FUNCTION IF EXISTS public.update_user(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.delete_user(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.get_user_profile(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.update_user_profile(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_user_preferences(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_user_security(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.verify_user_email(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.reset_user_password(uuid, text, text) CASCADE;
    DROP FUNCTION IF EXISTS public.handle_user_signup() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_user_login() CASCADE;
    DROP FUNCTION IF EXISTS public.authenticate_user(text, text) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_password_reset_token(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_password_strength(text) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_mfa_token(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.verify_mfa_token(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.update_last_login(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.check_password_expiry(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.handle_failed_login_attempt(text) CASCADE;
    DROP FUNCTION IF EXISTS public.handle_user_logout(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.handle_session_timeout(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_user_session(uuid) CASCADE;

    -- Drop RBAC Functions
    DROP FUNCTION IF EXISTS public.assign_role(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.remove_role(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.get_user_roles(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.get_role_permissions(text) CASCADE;
    DROP FUNCTION IF EXISTS public.check_permission(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.delegate_role(uuid, uuid, text, timestamp) CASCADE;
    DROP FUNCTION IF EXISTS public.revoke_delegation(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.get_effective_permissions(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.check_role_hierarchy(text, text) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_permission_assignment(text, text) CASCADE;
    DROP FUNCTION IF EXISTS public.audit_permission_changes() CASCADE;
    DROP FUNCTION IF EXISTS public.check_circular_delegation() CASCADE;
    DROP FUNCTION IF EXISTS public.sync_role_permissions() CASCADE;
    DROP FUNCTION IF EXISTS public.validate_role_changes() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_permission_inheritance() CASCADE;

    -- Drop Audit and System Functions
    DROP FUNCTION IF EXISTS public.log_activity(uuid, text, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.log_audit(text, text, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.log_error(text, text, text) CASCADE;
    DROP FUNCTION IF EXISTS public.get_system_metrics() CASCADE;
    DROP FUNCTION IF EXISTS public.cleanup_old_logs(interval) CASCADE;
    DROP FUNCTION IF EXISTS public.backup_system_data() CASCADE;
    DROP FUNCTION IF EXISTS public.cleanup_expired_sessions() CASCADE;
    DROP FUNCTION IF EXISTS public.rotate_encryption_keys() CASCADE;
    DROP FUNCTION IF EXISTS public.analyze_system_performance() CASCADE;
    DROP FUNCTION IF EXISTS public.backup_critical_data() CASCADE;
    DROP FUNCTION IF EXISTS public.monitor_database_size() CASCADE;
    DROP FUNCTION IF EXISTS public.analyze_security_events() CASCADE;
    DROP FUNCTION IF EXISTS public.monitor_system_health() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_system_alerts() CASCADE;

    -- Drop CRM Functions
    DROP FUNCTION IF EXISTS public.create_lead(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_lead(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.convert_lead_to_opportunity(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.create_contact(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_contact(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.create_opportunity(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_opportunity(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.create_quote(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_quote(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.manage_pipeline(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.track_communication(uuid, uuid, text, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.manage_campaign(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_lead_score(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.update_pipeline_stage(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_quote_pdf(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_deal_probability(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.track_customer_interaction(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.analyze_communication_sentiment(text) CASCADE;
    DROP FUNCTION IF EXISTS public.handle_lead_assignment() CASCADE;
    DROP FUNCTION IF EXISTS public.process_automation_rules() CASCADE;
    DROP FUNCTION IF EXISTS public.sync_crm_data() CASCADE;

    -- Drop Task Management Functions
    DROP FUNCTION IF EXISTS public.create_task(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_task(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.assign_task(uuid, uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.complete_task(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.create_board(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_board(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.manage_sprint(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.track_time(uuid, interval) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_sprint_metrics(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.update_task_dependencies() CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_burndown_data(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.estimate_completion_date(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.analyze_team_performance(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.sync_project_status() CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_velocity() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_task_notifications() CASCADE;

    -- Drop Document Management Functions
    DROP FUNCTION IF EXISTS public.create_document(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_document(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.share_document(uuid, uuid[], text) CASCADE;
    DROP FUNCTION IF EXISTS public.approve_document(uuid, uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.manage_document_workflow(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.version_document(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_document_preview(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.check_document_access(uuid, uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.track_document_views(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.archive_old_versions() CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_storage_usage() CASCADE;
    DROP FUNCTION IF EXISTS public.process_document_ocr() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_document_expiry() CASCADE;
    DROP FUNCTION IF EXISTS public.sync_document_metadata() CASCADE;

    -- Drop Inventory Management Functions
    DROP FUNCTION IF EXISTS public.create_inventory_item(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_inventory_item(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.track_inventory_transaction(uuid, text, numeric) CASCADE;
    DROP FUNCTION IF EXISTS public.adjust_stock(uuid, numeric, text) CASCADE;
    DROP FUNCTION IF EXISTS public.create_purchase_order(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.update_purchase_order(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.manage_quality_inspection(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_reorder_point(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.forecast_inventory_needs(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.track_lot_numbers(uuid, text) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_inventory_turnover() CASCADE;
    DROP FUNCTION IF EXISTS public.validate_stock_movement(uuid, numeric) CASCADE;
    DROP FUNCTION IF EXISTS public.process_stock_alerts() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_inventory_valuation() CASCADE;
    DROP FUNCTION IF EXISTS public.sync_warehouse_data() CASCADE;

    -- Drop Financial Management Functions
    DROP FUNCTION IF EXISTS public.create_journal_entry(jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.post_journal_entry(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.process_payment(uuid, numeric, text) CASCADE;
    DROP FUNCTION IF EXISTS public.manage_budget(uuid, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_tax(numeric, text) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_financial_report(text, date, date) CASCADE;
    DROP FUNCTION IF EXISTS public.manage_currency_conversion(text, text, numeric) CASCADE;
    DROP FUNCTION IF EXISTS public.reconcile_accounts() CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_financial_ratios(date) CASCADE;
    DROP FUNCTION IF EXISTS public.process_recurring_transactions() CASCADE;
    DROP FUNCTION IF EXISTS public.generate_tax_report(date, date) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_journal_entry(uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.process_period_end() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_bank_reconciliation() CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_depreciation() CASCADE;

    -- Drop Utility Functions
    DROP FUNCTION IF EXISTS public.format_currency(numeric, text) CASCADE;
    DROP FUNCTION IF EXISTS public.format_date(timestamp, text) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_email(text) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_phone(text) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_unique_code(text) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_distance(point, point) CASCADE;
    DROP FUNCTION IF EXISTS public.encrypt_sensitive_data(text) CASCADE;
    DROP FUNCTION IF EXISTS public.decrypt_sensitive_data(text) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_audit_trail(text, uuid) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_json_schema(jsonb, jsonb) CASCADE;
    DROP FUNCTION IF EXISTS public.sanitize_html_input(text) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_unique_slug(text) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_business_days(date, date) CASCADE;
    DROP FUNCTION IF EXISTS public.format_phone_number(text, text) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_tax_number(text, text) CASCADE;
    DROP FUNCTION IF EXISTS public.calculate_age(date) CASCADE;
    DROP FUNCTION IF EXISTS public.generate_random_string(integer) CASCADE;
    DROP FUNCTION IF EXISTS public.validate_url(text) CASCADE;
    DROP FUNCTION IF EXISTS public.format_file_size(bigint) CASCADE;

    -- Drop Trigger Functions
    DROP FUNCTION IF EXISTS public.audit_trigger_func() CASCADE;
    DROP FUNCTION IF EXISTS public.update_timestamp_func() CASCADE;
    DROP FUNCTION IF EXISTS public.check_permission_func() CASCADE;
    DROP FUNCTION IF EXISTS public.notify_users_func() CASCADE;
    DROP FUNCTION IF EXISTS public.update_search_vector_func() CASCADE;
    DROP FUNCTION IF EXISTS public.maintain_history_func() CASCADE;
    DROP FUNCTION IF EXISTS public.validate_data_func() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_soft_delete_func() CASCADE;
    DROP FUNCTION IF EXISTS public.sync_related_data_func() CASCADE;
    DROP FUNCTION IF EXISTS public.process_workflow_func() CASCADE;

    -- Drop existing update_timestamp function
    DROP FUNCTION IF EXISTS public.update_timestamp() CASCADE;
END $$;

-- Create update_timestamp function for triggers
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop Tables
-- =====================================================================================
DO $$
BEGIN
    -- Drop Additional CRM Tables
    DROP TABLE IF EXISTS public.crm_automations CASCADE;
    DROP TABLE IF EXISTS public.crm_documents CASCADE;
    DROP TABLE IF EXISTS public.crm_jobs CASCADE;
    DROP TABLE IF EXISTS public.crm_notes CASCADE;
    DROP TABLE IF EXISTS public.crm_products CASCADE;
    DROP TABLE IF EXISTS public.crm_relationships CASCADE;
    
    -- Drop Additional User Tables
    DROP TABLE IF EXISTS public.user_onboarding CASCADE;
    DROP TABLE IF EXISTS public.user_phone_numbers CASCADE;
    DROP TABLE IF EXISTS public.user_security_settings CASCADE;

    -- Drop CRM Tables (drop dependent tables first)
    DROP TABLE IF EXISTS public.crm_campaign_members CASCADE;
    DROP TABLE IF EXISTS public.crm_event_attendees CASCADE;
    DROP TABLE IF EXISTS public.crm_activities CASCADE;
    DROP TABLE IF EXISTS public.crm_tags CASCADE;
    DROP TABLE IF EXISTS public.crm_quote_items CASCADE;
    DROP TABLE IF EXISTS public.crm_quotes CASCADE;
    DROP TABLE IF EXISTS public.crm_deals CASCADE;
    DROP TABLE IF EXISTS public.crm_contracts CASCADE;
    DROP TABLE IF EXISTS public.crm_opportunities CASCADE;
    DROP TABLE IF EXISTS public.crm_leads CASCADE;
    DROP TABLE IF EXISTS public.crm_contacts CASCADE;
    DROP TABLE IF EXISTS public.crm_companies CASCADE;
    DROP TABLE IF EXISTS public.crm_pipelines CASCADE;
    DROP TABLE IF EXISTS public.crm_pipeline_stages CASCADE;
    DROP TABLE IF EXISTS public.crm_automation_rules CASCADE;
    DROP TABLE IF EXISTS public.crm_automation_actions CASCADE;
    DROP TABLE IF EXISTS public.crm_campaigns CASCADE;
    DROP TABLE IF EXISTS public.crm_events CASCADE;
    DROP TABLE IF EXISTS public.crm_communications CASCADE;
    DROP TABLE IF EXISTS public.crm_attachments CASCADE;

    -- Drop Task Management Tables
    DROP TABLE IF EXISTS public.task_checklist_items CASCADE;
    DROP TABLE IF EXISTS public.task_checklists CASCADE;
    DROP TABLE IF EXISTS public.task_comments CASCADE;
    DROP TABLE IF EXISTS public.task_attachments CASCADE;
    DROP TABLE IF EXISTS public.task_time_entries CASCADE;
    DROP TABLE IF EXISTS public.task_dependencies CASCADE;
    DROP TABLE IF EXISTS public.task_assignments CASCADE;
    DROP TABLE IF EXISTS public.task_labels CASCADE;
    DROP TABLE IF EXISTS public.task_templates CASCADE;
    DROP TABLE IF EXISTS public.tasks CASCADE;
    DROP TABLE IF EXISTS public.boards CASCADE;
    DROP TABLE IF EXISTS public.board_lists CASCADE;
    DROP TABLE IF EXISTS public.sprints CASCADE;
    DROP TABLE IF EXISTS public.epics CASCADE;
    DROP TABLE IF EXISTS public.project_members CASCADE;
    DROP TABLE IF EXISTS public.projects CASCADE;

    -- Drop Document Management Tables
    DROP TABLE IF EXISTS public.document_versions CASCADE;
    DROP TABLE IF EXISTS public.document_shares CASCADE;
    DROP TABLE IF EXISTS public.document_comments CASCADE;
    DROP TABLE IF EXISTS public.document_approvals CASCADE;
    DROP TABLE IF EXISTS public.document_workflows CASCADE;
    DROP TABLE IF EXISTS public.document_tags CASCADE;
    DROP TABLE IF EXISTS public.document_categories CASCADE;
    DROP TABLE IF EXISTS public.document_templates CASCADE;
    DROP TABLE IF EXISTS public.documents CASCADE;

    -- Drop Communication Tables
    DROP TABLE IF EXISTS public.communication_attachments CASCADE;
    DROP TABLE IF EXISTS public.communication_templates CASCADE;
    DROP TABLE IF EXISTS public.communication_logs CASCADE;
    DROP TABLE IF EXISTS public.notification_preferences CASCADE;
    DROP TABLE IF EXISTS public.notification_templates CASCADE;
    DROP TABLE IF EXISTS public.notifications CASCADE;
    DROP TABLE IF EXISTS public.message_threads CASCADE;
    DROP TABLE IF EXISTS public.messages CASCADE;

    -- Drop Financial Tables
    DROP TABLE IF EXISTS public.payment_transactions CASCADE;
    DROP TABLE IF EXISTS public.payment_methods CASCADE;
    DROP TABLE IF EXISTS public.journal_entry_lines CASCADE;
    DROP TABLE IF EXISTS public.journal_entries CASCADE;
    DROP TABLE IF EXISTS public.chart_of_accounts CASCADE;
    DROP TABLE IF EXISTS public.tax_records CASCADE;
    DROP TABLE IF EXISTS public.currency_rates CASCADE;
    DROP TABLE IF EXISTS public.financial_periods CASCADE;
    DROP TABLE IF EXISTS public.budgets CASCADE;
    DROP TABLE IF EXISTS public.budget_items CASCADE;
    DROP TABLE IF EXISTS public.invoices CASCADE;
    DROP TABLE IF EXISTS public.invoice_items CASCADE;
    DROP TABLE IF EXISTS public.expense_claims CASCADE;
    DROP TABLE IF EXISTS public.expense_items CASCADE;
    
    -- Drop Inventory Tables
    DROP TABLE IF EXISTS public.purchase_order_items CASCADE;
    DROP TABLE IF EXISTS public.purchase_orders CASCADE;
    DROP TABLE IF EXISTS public.inventory_transactions CASCADE;
    DROP TABLE IF EXISTS public.inventory_items CASCADE;
    DROP TABLE IF EXISTS public.inventory_locations CASCADE;
    DROP TABLE IF EXISTS public.quality_inspections CASCADE;
    DROP TABLE IF EXISTS public.stock_adjustments CASCADE;
    DROP TABLE IF EXISTS public.product_categories CASCADE;
    DROP TABLE IF EXISTS public.product_variants CASCADE;
    DROP TABLE IF EXISTS public.product_prices CASCADE;
    DROP TABLE IF EXISTS public.supplier_products CASCADE;
    DROP TABLE IF EXISTS public.suppliers CASCADE;
    DROP TABLE IF EXISTS public.warehouses CASCADE;
    DROP TABLE IF EXISTS public.warehouse_locations CASCADE;

    -- Drop System Management Tables
    DROP TABLE IF EXISTS public.system_jobs CASCADE;
    DROP TABLE IF EXISTS public.system_job_logs CASCADE;
    DROP TABLE IF EXISTS public.system_metrics CASCADE;
    DROP TABLE IF EXISTS public.system_backups CASCADE;
    DROP TABLE IF EXISTS public.system_settings CASCADE;
    DROP TABLE IF EXISTS public.system_integrations CASCADE;
    DROP TABLE IF EXISTS public.api_logs CASCADE;
    DROP TABLE IF EXISTS public.error_logs CASCADE;
    DROP TABLE IF EXISTS public.audit_logs CASCADE;
    DROP TABLE IF EXISTS public.activity_logs CASCADE;

    -- Drop User Management Tables (dependent tables first)
    DROP TABLE IF EXISTS public.user_sessions CASCADE;
    DROP TABLE IF EXISTS public.user_devices CASCADE;
    DROP TABLE IF EXISTS public.user_tokens CASCADE;
    DROP TABLE IF EXISTS public.user_mfa_settings CASCADE;
    DROP TABLE IF EXISTS public.user_backup_codes CASCADE;
    DROP TABLE IF EXISTS public.user_api_keys CASCADE;
    DROP TABLE IF EXISTS public.user_preferences CASCADE;
    DROP TABLE IF EXISTS public.user_notifications CASCADE;
    DROP TABLE IF EXISTS public.user_activities CASCADE;
    DROP TABLE IF EXISTS public.user_security_questions CASCADE;
    DROP TABLE IF EXISTS public.user_addresses CASCADE;
    DROP TABLE IF EXISTS public.user_contacts CASCADE;
    DROP TABLE IF EXISTS public.profiles CASCADE;

    -- Drop RBAC Tables (drop in correct dependency order)
    DROP TABLE IF EXISTS public.role_delegations CASCADE;
    DROP TABLE IF EXISTS public.role_permissions CASCADE;
    DROP TABLE IF EXISTS public.user_roles CASCADE;
    DROP TABLE IF EXISTS public.role_hierarchies CASCADE;
    DROP TABLE IF EXISTS public.permission_groups CASCADE;
    DROP TABLE IF EXISTS public.permissions CASCADE;
    DROP TABLE IF EXISTS public.roles CASCADE;

    -- Drop Core Tables (if any remain)
    DROP TABLE IF EXISTS public.countries CASCADE;
    DROP TABLE IF EXISTS public.regions CASCADE;
    DROP TABLE IF EXISTS public.cities CASCADE;
    DROP TABLE IF EXISTS public.languages CASCADE;
    DROP TABLE IF EXISTS public.currencies CASCADE;
    DROP TABLE IF EXISTS public.timezones CASCADE;

EXCEPTION
    WHEN OTHERS THEN null; -- Ignore errors if tables don't exist
END $$;

-- Drop Enum Types
-- =====================================================================================
DO $$ 
BEGIN
    -- Drop Additional System Enums
    DROP TYPE IF EXISTS public.campaign_status_type CASCADE;
    DROP TYPE IF EXISTS public.campaign_type CASCADE;
    DROP TYPE IF EXISTS public.crm_entity_type CASCADE;
    DROP TYPE IF EXISTS public.delegation_status CASCADE;
    DROP TYPE IF EXISTS public.error_severity_type CASCADE;
    DROP TYPE IF EXISTS public.job_priority CASCADE;
    DROP TYPE IF EXISTS public.job_status CASCADE;
    DROP TYPE IF EXISTS public.product_category CASCADE;
    DROP TYPE IF EXISTS public.purchase_order_status CASCADE;
    DROP TYPE IF EXISTS public.task_status_type CASCADE;
    DROP TYPE IF EXISTS public.communication_channel CASCADE;
    DROP TYPE IF EXISTS public.inventory_valuation_method CASCADE;
    DROP TYPE IF EXISTS public.unit_of_measure_type CASCADE;

    -- Drop Core System Enums
    DROP TYPE IF EXISTS public.entity_type CASCADE;
    DROP TYPE IF EXISTS public.security_level CASCADE;
    DROP TYPE IF EXISTS public.notification_frequency CASCADE;
    DROP TYPE IF EXISTS public.subscription_status CASCADE;

    -- Drop Core User Enums
    DROP TYPE IF EXISTS public.gender_type CASCADE;
    DROP TYPE IF EXISTS public.status_type CASCADE;
    DROP TYPE IF EXISTS public.role_type CASCADE;
    DROP TYPE IF EXISTS public.verification_type CASCADE;
    DROP TYPE IF EXISTS public.privacy_level CASCADE;
    DROP TYPE IF EXISTS public.onboarding_status CASCADE;

    -- Drop UI and Preferences Enums
    DROP TYPE IF EXISTS public.theme_type CASCADE;
    DROP TYPE IF EXISTS public.display_density_type CASCADE;
    DROP TYPE IF EXISTS public.date_format_type CASCADE;
    DROP TYPE IF EXISTS public.time_format_type CASCADE;
    DROP TYPE IF EXISTS public.communication_language_type CASCADE;

    -- Drop Contact Enums
    DROP TYPE IF EXISTS public.email_type CASCADE;
    DROP TYPE IF EXISTS public.phone_type CASCADE;
    DROP TYPE IF EXISTS public.address_type CASCADE;

    -- Drop RBAC Enums
    DROP TYPE IF EXISTS public.role_status_type CASCADE;
    DROP TYPE IF EXISTS public.permission_category_type CASCADE;
    DROP TYPE IF EXISTS public.permission_status_type CASCADE;
    DROP TYPE IF EXISTS public.delegation_status_type CASCADE;
    DROP TYPE IF EXISTS public.role_hierarchy_type CASCADE;

    -- Drop Security Enums
    DROP TYPE IF EXISTS public.two_factor_method_type CASCADE;
    DROP TYPE IF EXISTS public.mfa_type CASCADE;
    DROP TYPE IF EXISTS public.security_question_type CASCADE;
    DROP TYPE IF EXISTS public.api_key_type CASCADE;

    -- Drop System Audit Enums
    DROP TYPE IF EXISTS public.audit_action_type CASCADE;
    DROP TYPE IF EXISTS public.audit_category_type CASCADE;
    DROP TYPE IF EXISTS public.audit_status_type CASCADE;
    DROP TYPE IF EXISTS public.data_sensitivity_type CASCADE;
    DROP TYPE IF EXISTS public.compliance_status_type CASCADE;
    DROP TYPE IF EXISTS public.system_metric_type CASCADE;

    -- Drop CRM Enums
    DROP TYPE IF EXISTS public.customer_type CASCADE;
    DROP TYPE IF EXISTS public.customer_segment_type CASCADE;
    DROP TYPE IF EXISTS public.customer_status CASCADE;
    DROP TYPE IF EXISTS public.lead_status CASCADE;
    DROP TYPE IF EXISTS public.lead_source CASCADE;
    DROP TYPE IF EXISTS public.opportunity_status CASCADE;
    DROP TYPE IF EXISTS public.quote_status CASCADE;
    DROP TYPE IF EXISTS public.communication_channel_type CASCADE;
    DROP TYPE IF EXISTS public.communication_language_type CASCADE;
    DROP TYPE IF EXISTS public.communication_direction CASCADE;
    DROP TYPE IF EXISTS public.communication_status CASCADE;
    DROP TYPE IF EXISTS public.pipeline_stage_type CASCADE;
    DROP TYPE IF EXISTS public.deal_status CASCADE;
    DROP TYPE IF EXISTS public.contract_status CASCADE;

    -- Drop Task Management Enums
    DROP TYPE IF EXISTS public.task_type CASCADE;
    DROP TYPE IF EXISTS public.task_status CASCADE;
    DROP TYPE IF EXISTS public.task_priority CASCADE;
    DROP TYPE IF EXISTS public.task_assignment_role CASCADE;
    DROP TYPE IF EXISTS public.task_dependency_type CASCADE;
    DROP TYPE IF EXISTS public.board_type CASCADE;
    DROP TYPE IF EXISTS public.list_type CASCADE;
    DROP TYPE IF EXISTS public.task_label_type CASCADE;
    DROP TYPE IF EXISTS public.task_template_type CASCADE;
    DROP TYPE IF EXISTS public.time_tracking_type CASCADE;
    DROP TYPE IF EXISTS public.label_color_type CASCADE;
    DROP TYPE IF EXISTS public.label_group_type CASCADE;
    DROP TYPE IF EXISTS public.sprint_status CASCADE;
    DROP TYPE IF EXISTS public.epic_status CASCADE;

    -- Drop Document Management Enums
    DROP TYPE IF EXISTS public.document_type CASCADE;
    DROP TYPE IF EXISTS public.document_status CASCADE;
    DROP TYPE IF EXISTS public.access_level CASCADE;
    DROP TYPE IF EXISTS public.workflow_status CASCADE;
    DROP TYPE IF EXISTS public.approval_status CASCADE;
    DROP TYPE IF EXISTS public.document_category_type CASCADE;
    DROP TYPE IF EXISTS public.document_tag_type CASCADE;

    -- Drop Inventory Management Enums
    DROP TYPE IF EXISTS public.inventory_location_type CASCADE;
    DROP TYPE IF EXISTS public.inventory_transaction_type CASCADE;
    DROP TYPE IF EXISTS public.stock_adjustment_type CASCADE;
    DROP TYPE IF EXISTS public.quality_status_type CASCADE;
    DROP TYPE IF EXISTS public.storage_condition_type CASCADE;
    DROP TYPE IF EXISTS public.unit_of_measure CASCADE;
    DROP TYPE IF EXISTS public.product_status CASCADE;
    DROP TYPE IF EXISTS public.product_type CASCADE;
    DROP TYPE IF EXISTS public.product_category_type CASCADE;
    DROP TYPE IF EXISTS public.supplier_status CASCADE;

    -- Drop Financial Management Enums
    DROP TYPE IF EXISTS public.transaction_type CASCADE;
    DROP TYPE IF EXISTS public.payment_status CASCADE;
    DROP TYPE IF EXISTS public.payment_method CASCADE;
    DROP TYPE IF EXISTS public.account_type CASCADE;
    DROP TYPE IF EXISTS public.currency_type CASCADE;
    DROP TYPE IF EXISTS public.tax_type CASCADE;
    DROP TYPE IF EXISTS public.journal_entry_type CASCADE;
    DROP TYPE IF EXISTS public.budget_status CASCADE;
    DROP TYPE IF EXISTS public.financial_period_status CASCADE;

EXCEPTION
    WHEN OTHERS THEN 
        RAISE NOTICE 'Error dropping enum types: %', SQLERRM;
        -- Continue with other drops even if one fails
END $$;

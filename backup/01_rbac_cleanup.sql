-- =====================================================================================
-- RBAC System Cleanup
-- =====================================================================================
-- Description: Drops all components of the RBAC system in the correct dependency order
-- Version: 1.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Table of Contents
-- =====================================================================================
-- 1. Enum Types (02_enum.sql)
--    - Core User Enums
--      * gender_type, status_type, role_type
--      * address_type, phone_type, mfa_type
--    - CRM Enums
--      * customer_segment_type, crm_entity_type
--      * lead_status, opportunity_status, quote_status
--      * job_status, job_priority, pipeline_stage
--      * communication_channel, product_category
--      * document_category, campaign_type
--      * campaign_status_type
--    - Task Management Enums
--      * task_type, task_status, task_priority
--    - Inventory Enums
--      * inventory_transaction_type, inventory_location_type
--      * purchase_order_status
--    - Accounting Enums
--      * payment_status, payment_method, account_type
--      * tax_type, journal_entry_type

-- 2. Core Tables (03_tables.sql)
--    - User Management
--      * profiles
--      * user_security_settings
--      * user_preferences
--      * user_onboarding
--      * user_addresses
--      * user_phone_numbers
--    - RBAC Core
--      * roles
--      * permissions
--      * user_roles
--      * role_permissions
--      * role_delegations
--    - System Tables
--      * error_logs
--      * audit_logs
--      * user_activities
--    - CRM Core
--      * crm_leads
--      * crm_contacts
--      * crm_opportunities
--      * crm_quotes
--      * crm_jobs
--    - CRM Support
--      * crm_products
--      * crm_pipelines
--      * crm_communications
--      * crm_documents
--      * crm_relationships
--      * crm_notes
--      * crm_automations
--    - Task Management
--      * tasks
--    - Inventory Management
--      * inventory_locations
--      * inventory_items
--      * inventory_transactions
--      * purchase_orders
--      * purchase_order_items
--    - Accounting
--      * chart_of_accounts
--      * journal_entries
--      * journal_entry_lines
--      * payment_transactions

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

-- Drop Functions
-- =====================================================================================
DO $$
DECLARE
    func_record record;
BEGIN
    FOR func_record IN 
        SELECT ns.nspname as schema_name,
               p.proname as function_name,
               pg_get_function_identity_arguments(p.oid) as argument_list
        FROM pg_proc p
        JOIN pg_namespace ns ON p.pronamespace = ns.oid
        WHERE ns.nspname = 'public'
    LOOP
        EXECUTE format('DROP FUNCTION IF EXISTS public.%I(%s) CASCADE;',
            func_record.function_name,
            func_record.argument_list);
    END LOOP;
END $$;

-- Drop Tables
-- =====================================================================================
DO $$ 
BEGIN
    -- Drop tables in reverse dependency order
    
    -- Drop Accounting Tables
    DROP TABLE IF EXISTS public.payment_transactions CASCADE;
    DROP TABLE IF EXISTS public.journal_entry_lines CASCADE;
    DROP TABLE IF EXISTS public.journal_entries CASCADE;
    DROP TABLE IF EXISTS public.chart_of_accounts CASCADE;
    
    -- Drop Inventory Tables
    DROP TABLE IF EXISTS public.purchase_order_items CASCADE;
    DROP TABLE IF EXISTS public.purchase_orders CASCADE;
    DROP TABLE IF EXISTS public.inventory_transactions CASCADE;
    DROP TABLE IF EXISTS public.inventory_items CASCADE;
    DROP TABLE IF EXISTS public.inventory_locations CASCADE;
    
    -- Drop Task Tables
    DROP TABLE IF EXISTS public.tasks CASCADE;
    
    -- Drop CRM Support Tables
    DROP TABLE IF EXISTS public.crm_automations CASCADE;
    DROP TABLE IF EXISTS public.crm_notes CASCADE;
    DROP TABLE IF EXISTS public.crm_relationships CASCADE;
    DROP TABLE IF EXISTS public.crm_documents CASCADE;
    DROP TABLE IF EXISTS public.crm_communications CASCADE;
    DROP TABLE IF EXISTS public.crm_pipelines CASCADE;
    DROP TABLE IF EXISTS public.crm_products CASCADE;
    
    -- Drop CRM Core Tables
    DROP TABLE IF EXISTS public.crm_jobs CASCADE;
    DROP TABLE IF EXISTS public.crm_quotes CASCADE;
    DROP TABLE IF EXISTS public.crm_opportunities CASCADE;
    DROP TABLE IF EXISTS public.crm_contacts CASCADE;
    DROP TABLE IF EXISTS public.crm_leads CASCADE;
    
    -- Drop System Tables
    DROP TABLE IF EXISTS public.user_activities CASCADE;
    DROP TABLE IF EXISTS public.audit_logs CASCADE;
    DROP TABLE IF EXISTS public.error_logs CASCADE;
    
    -- Drop RBAC Tables
    DROP TABLE IF EXISTS public.role_delegations CASCADE;
    DROP TABLE IF EXISTS public.role_permissions CASCADE;
    DROP TABLE IF EXISTS public.user_roles CASCADE;
    DROP TABLE IF EXISTS public.permissions CASCADE;
    DROP TABLE IF EXISTS public.roles CASCADE;
    
    -- Drop User Management Tables
    DROP TABLE IF EXISTS public.user_phone_numbers CASCADE;
    DROP TABLE IF EXISTS public.user_addresses CASCADE;
    DROP TABLE IF EXISTS public.user_onboarding CASCADE;
    DROP TABLE IF EXISTS public.user_preferences CASCADE;
    DROP TABLE IF EXISTS public.user_security_settings CASCADE;
    DROP TABLE IF EXISTS public.profiles CASCADE;
END $$;

-- Drop Enum Types
-- =====================================================================================
DO $$ 
BEGIN
    -- Drop Core User Enums
    DROP TYPE IF EXISTS public.gender_type CASCADE;
    DROP TYPE IF EXISTS public.status_type CASCADE;
    DROP TYPE IF EXISTS public.role_type CASCADE;
    DROP TYPE IF EXISTS public.address_type CASCADE;
    DROP TYPE IF EXISTS public.phone_type CASCADE;
    
    -- Drop System Enums
    DROP TYPE IF EXISTS public.error_severity_type CASCADE;
    DROP TYPE IF EXISTS public.delegation_status CASCADE;
    
    -- Drop CRM Enums
    DROP TYPE IF EXISTS public.customer_type CASCADE;
    DROP TYPE IF EXISTS public.customer_segment_type CASCADE;
    DROP TYPE IF EXISTS public.lead_status CASCADE;
    DROP TYPE IF EXISTS public.opportunity_status CASCADE;
    DROP TYPE IF EXISTS public.quote_status CASCADE;
    DROP TYPE IF EXISTS public.job_status CASCADE;
    DROP TYPE IF EXISTS public.job_priority CASCADE;
    DROP TYPE IF EXISTS public.task_type CASCADE;
    DROP TYPE IF EXISTS public.task_status CASCADE;
    DROP TYPE IF EXISTS public.task_priority CASCADE;
    DROP TYPE IF EXISTS public.campaign_type CASCADE;
    DROP TYPE IF EXISTS public.campaign_status_type CASCADE;
    DROP TYPE IF EXISTS public.crm_entity_type CASCADE;
    DROP TYPE IF EXISTS public.communication_channel CASCADE;
    DROP TYPE IF EXISTS public.product_category CASCADE;
    
    -- Drop Inventory Enums
    DROP TYPE IF EXISTS public.inventory_transaction_type CASCADE;
    DROP TYPE IF EXISTS public.inventory_location_type CASCADE;
    DROP TYPE IF EXISTS public.purchase_order_status CASCADE;
    
    -- Drop Payment Enums
    DROP TYPE IF EXISTS public.payment_status CASCADE;
    DROP TYPE IF EXISTS public.payment_method CASCADE;
    DROP TYPE IF EXISTS public.account_type CASCADE;
EXCEPTION
    WHEN OTHERS THEN null; -- Ignore errors if types don't exist
END $$;

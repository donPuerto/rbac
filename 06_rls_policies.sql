-- =====================================================================================
-- RBAC System Row Level Security Policies
-- =====================================================================================
-- Description: Row Level Security (RLS) policies for the RBAC system
-- Version: 1.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Drop all existing RLS policies
-- =====================================================================================
DO $$ 
BEGIN
    -- Core User Tables
    DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
    DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
    DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
    DROP POLICY IF EXISTS "Admins can manage all profiles" ON public.profiles;
    DROP POLICY IF EXISTS "Users can manage their own security settings" ON public.user_security_settings;
    DROP POLICY IF EXISTS "Users can manage their own preferences" ON public.user_preferences;
    DROP POLICY IF EXISTS "Users can view their own onboarding" ON public.user_onboarding;
    DROP POLICY IF EXISTS "Users can manage their own addresses" ON public.user_addresses;

    -- RBAC Tables
    DROP POLICY IF EXISTS "Anyone can view active roles" ON public.roles;
    DROP POLICY IF EXISTS "Only super admins can manage roles" ON public.roles;
    DROP POLICY IF EXISTS "Anyone can view permissions" ON public.permissions;
    DROP POLICY IF EXISTS "Only super admins can manage permissions" ON public.permissions;
    DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
    DROP POLICY IF EXISTS "Only admins can manage user roles" ON public.user_roles;
    DROP POLICY IF EXISTS "Anyone can view role permissions" ON public.role_permissions;
    DROP POLICY IF EXISTS "Only super admins can manage role permissions" ON public.role_permissions;
    DROP POLICY IF EXISTS "Users can view their delegations" ON public.role_delegations;
    DROP POLICY IF EXISTS "Only admins can manage delegations" ON public.role_delegations;

    -- System Tables
    DROP POLICY IF EXISTS "Only system can insert error logs" ON public.error_logs;
    DROP POLICY IF EXISTS "Only admins can view error logs" ON public.error_logs;
    DROP POLICY IF EXISTS "Only system can insert audit logs" ON public.audit_logs;
    DROP POLICY IF EXISTS "Only audit admins can view audit logs" ON public.audit_logs;
    DROP POLICY IF EXISTS "Users can view their own activities" ON public.user_activities;
    DROP POLICY IF EXISTS "Admins can view all activities" ON public.user_activities;

    -- CRM Core Tables
    DROP POLICY IF EXISTS "Users can view assigned leads" ON public.crm_leads;
    DROP POLICY IF EXISTS "Sales managers can view all leads" ON public.crm_leads;
    DROP POLICY IF EXISTS "Users can view assigned contacts" ON public.crm_contacts;
    DROP POLICY IF EXISTS "Sales team can view all contacts" ON public.crm_contacts;
    DROP POLICY IF EXISTS "Users can view assigned opportunities" ON public.crm_opportunities;
    DROP POLICY IF EXISTS "Sales managers can view all opportunities" ON public.crm_opportunities;
    DROP POLICY IF EXISTS "Users can view assigned quotes" ON public.crm_quotes;
    DROP POLICY IF EXISTS "Sales team can view all quotes" ON public.crm_quotes;
    DROP POLICY IF EXISTS "Users can view assigned jobs" ON public.crm_jobs;
    DROP POLICY IF EXISTS "Project managers can view all jobs" ON public.crm_jobs;

    -- CRM Support Tables
    DROP POLICY IF EXISTS "Anyone can view active products" ON public.crm_products;
    DROP POLICY IF EXISTS "Product managers can manage products" ON public.crm_products;
    DROP POLICY IF EXISTS "Anyone can view pipelines" ON public.crm_pipelines;
    DROP POLICY IF EXISTS "Sales managers can manage pipelines" ON public.crm_pipelines;
    DROP POLICY IF EXISTS "Users can view related communications" ON public.crm_communications;
    DROP POLICY IF EXISTS "Users can view accessible documents" ON public.crm_documents;
    DROP POLICY IF EXISTS "Users can view related relationships" ON public.crm_relationships;
    DROP POLICY IF EXISTS "Users can view accessible notes" ON public.crm_notes;
    DROP POLICY IF EXISTS "Admins can manage automations" ON public.crm_automations;

    -- Task Management
    DROP POLICY IF EXISTS "Users can view assigned tasks" ON public.tasks;
    DROP POLICY IF EXISTS "Project managers can view all tasks" ON public.tasks;
    DROP POLICY IF EXISTS "Users can manage task assignments" ON public.task_assignments;
    DROP POLICY IF EXISTS "Users can manage task comments" ON public.task_comments;
    DROP POLICY IF EXISTS "Users can manage task attachments" ON public.task_attachments;

    -- Inventory Management
    DROP POLICY IF EXISTS "Users can view inventory locations" ON public.inventory_locations;
    DROP POLICY IF EXISTS "Inventory managers can manage locations" ON public.inventory_locations;
    DROP POLICY IF EXISTS "Users can view inventory items" ON public.inventory_items;
    DROP POLICY IF EXISTS "Inventory managers can manage items" ON public.inventory_items;
    DROP POLICY IF EXISTS "Users can view inventory transactions" ON public.inventory_transactions;
    DROP POLICY IF EXISTS "Inventory managers can manage transactions" ON public.inventory_transactions;
    DROP POLICY IF EXISTS "Users can view purchase orders" ON public.purchase_orders;
    DROP POLICY IF EXISTS "Purchase managers can manage orders" ON public.purchase_orders;
    DROP POLICY IF EXISTS "Users can view order items" ON public.purchase_order_items;
    DROP POLICY IF EXISTS "Purchase managers can manage order items" ON public.purchase_order_items;

    -- Accounting Integration
    DROP POLICY IF EXISTS "Accountants can view chart of accounts" ON public.chart_of_accounts;
    DROP POLICY IF EXISTS "Senior accountants can manage accounts" ON public.chart_of_accounts;
    DROP POLICY IF EXISTS "Accountants can view journal entries" ON public.journal_entries;
    DROP POLICY IF EXISTS "Senior accountants can manage entries" ON public.journal_entries;
    DROP POLICY IF EXISTS "Accountants can view entry lines" ON public.journal_entry_lines;
    DROP POLICY IF EXISTS "Senior accountants can manage entry lines" ON public.journal_entry_lines;
    DROP POLICY IF EXISTS "Users can view their payment transactions" ON public.payment_transactions;
    DROP POLICY IF EXISTS "Finance team can manage payments" ON public.payment_transactions;
END $$;

-- Enable Row Level Security
-- =====================================================================================
DO $$ 
BEGIN
    -- Core User Tables
    ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_security_settings ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_onboarding ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_addresses ENABLE ROW LEVEL SECURITY;

    -- RBAC Tables
    ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.role_delegations ENABLE ROW LEVEL SECURITY;

    -- System Tables
    ALTER TABLE public.error_logs ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;

    -- CRM Core Tables
    ALTER TABLE public.crm_leads ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_contacts ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_opportunities ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_quotes ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_jobs ENABLE ROW LEVEL SECURITY;

    -- CRM Support Tables
    ALTER TABLE public.crm_products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_pipelines ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_communications ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_documents ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_relationships ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_notes ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.crm_automations ENABLE ROW LEVEL SECURITY;

    -- Task Management
    ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.task_assignments ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.task_comments ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.task_attachments ENABLE ROW LEVEL SECURITY;

    -- Inventory Management
    ALTER TABLE public.inventory_locations ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.inventory_transactions ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.purchase_orders ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.purchase_order_items ENABLE ROW LEVEL SECURITY;

    -- Accounting Integration
    ALTER TABLE public.chart_of_accounts ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.journal_entry_lines ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
END $$;

-- Core User Tables Policies
-- =====================================================================================
CREATE POLICY "Users can view their own profile"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = id
        OR has_permission(auth.uid(), 'user', 'read')
    );
COMMENT ON POLICY "Users can view their own profile" ON public.profiles IS 'Users can view their own profile or profiles they have permission to read';

CREATE POLICY "Admins can view all profiles"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (
        has_permission(auth.uid(), 'user', 'read_all')
    );
COMMENT ON POLICY "Admins can view all profiles" ON public.profiles IS 'Admins can view all profiles';

CREATE POLICY "Users can update their own profile"
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (
        auth.uid() = id
        OR has_permission(auth.uid(), 'user', 'update')
    )
    WITH CHECK (
        auth.uid() = id
        OR has_permission(auth.uid(), 'user', 'update')
    );
COMMENT ON POLICY "Users can update their own profile" ON public.profiles IS 'Users can update their own profile or profiles they have permission to update';

CREATE POLICY "Admins can manage all profiles"
    ON public.profiles
    FOR ALL
    TO authenticated
    USING (
        has_permission(auth.uid(), 'user', 'manage')
    )
    WITH CHECK (
        has_permission(auth.uid(), 'user', 'manage')
    );
COMMENT ON POLICY "Admins can manage all profiles" ON public.profiles IS 'Admins can manage all profiles';

-- RBAC Tables Policies
-- =====================================================================================
CREATE POLICY "Anyone can view active roles"
    ON public.roles
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL
        AND is_active = true
    );
COMMENT ON POLICY "Anyone can view active roles" ON public.roles IS 'Anyone can view active roles';

CREATE POLICY "Only super admins can manage roles"
    ON public.roles
    FOR ALL
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    )
    WITH CHECK (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    );
COMMENT ON POLICY "Only super admins can manage roles" ON public.roles IS 'Only super admins can manage roles';

-- System Tables Policies
-- =====================================================================================
CREATE POLICY "Only system can insert error logs"
    ON public.error_logs
    FOR INSERT
    TO authenticated
    USING (
        auth.uid() = 'system'
    );
COMMENT ON POLICY "Only system can insert error logs" ON public.error_logs IS 'Only system can insert error logs';

CREATE POLICY "Only admins can view error logs"
    ON public.error_logs
    FOR SELECT
    TO authenticated
    USING (
        has_permission(auth.uid(), 'error_log', 'read')
    );
COMMENT ON POLICY "Only admins can view error logs" ON public.error_logs IS 'Only admins can view error logs';

-- CRM Core Tables Policies
-- =====================================================================================
CREATE POLICY "Users can view assigned leads"
    ON public.crm_leads
    FOR SELECT
    TO authenticated
    USING (
        assigned_to = auth.uid()
        OR has_permission(auth.uid(), 'lead', 'read')
    );
COMMENT ON POLICY "Users can view assigned leads" ON public.crm_leads IS 'Users can view assigned leads or leads they have permission to read';

CREATE POLICY "Sales managers can view all leads"
    ON public.crm_leads
    FOR SELECT
    TO authenticated
    USING (
        has_permission(auth.uid(), 'lead', 'read_all')
    );
COMMENT ON POLICY "Sales managers can view all leads" ON public.crm_leads IS 'Sales managers can view all leads';

-- CRM Support Tables Policies
-- =====================================================================================
CREATE POLICY "Anyone can view active products"
    ON public.crm_products
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL
        AND is_active = true
    );
COMMENT ON POLICY "Anyone can view active products" ON public.crm_products IS 'Anyone can view active products';

CREATE POLICY "Product managers can manage products"
    ON public.crm_products
    FOR ALL
    TO authenticated
    USING (
        has_permission(auth.uid(), 'product', 'manage')
    )
    WITH CHECK (
        has_permission(auth.uid(), 'product', 'manage')
    );
COMMENT ON POLICY "Product managers can manage products" ON public.crm_products IS 'Product managers can manage products';

-- Task Management Policies
-- =====================================================================================
CREATE POLICY "Users can view assigned tasks"
    ON public.tasks
    FOR SELECT
    TO authenticated
    USING (
        assigned_to = auth.uid()
        OR has_permission(auth.uid(), 'task', 'read')
    );
COMMENT ON POLICY "Users can view assigned tasks" ON public.tasks IS 'Users can view assigned tasks or tasks they have permission to read';

CREATE POLICY "Project managers can view all tasks"
    ON public.tasks
    FOR SELECT
    TO authenticated
    USING (
        has_permission(auth.uid(), 'task', 'read_all')
    );
COMMENT ON POLICY "Project managers can view all tasks" ON public.tasks IS 'Project managers can view all tasks';

-- Inventory Management Policies
-- =====================================================================================
CREATE POLICY "Users can view inventory locations"
    ON public.inventory_locations
    FOR SELECT
    TO authenticated
    USING (
        has_permission(auth.uid(), 'inventory_location', 'read')
    );
COMMENT ON POLICY "Users can view inventory locations" ON public.inventory_locations IS 'Users can view inventory locations they have permission to read';

CREATE POLICY "Inventory managers can manage locations"
    ON public.inventory_locations
    FOR ALL
    TO authenticated
    USING (
        has_permission(auth.uid(), 'inventory_location', 'manage')
    )
    WITH CHECK (
        has_permission(auth.uid(), 'inventory_location', 'manage')
    );
COMMENT ON POLICY "Inventory managers can manage locations" ON public.inventory_locations IS 'Inventory managers can manage locations';

-- Accounting Integration Policies
-- =====================================================================================
CREATE POLICY "Accountants can view chart of accounts"
    ON public.chart_of_accounts
    FOR SELECT
    TO authenticated
    USING (
        has_permission(auth.uid(), 'chart_of_accounts', 'read')
    );
COMMENT ON POLICY "Accountants can view chart of accounts" ON public.chart_of_accounts IS 'Accountants can view chart of accounts they have permission to read';

CREATE POLICY "Senior accountants can manage accounts"
    ON public.chart_of_accounts
    FOR ALL
    TO authenticated
    USING (
        has_permission(auth.uid(), 'chart_of_accounts', 'manage')
    )
    WITH CHECK (
        has_permission(auth.uid(), 'chart_of_accounts', 'manage')
    );
COMMENT ON POLICY "Senior accountants can manage accounts" ON public.chart_of_accounts IS 'Senior accountants can manage accounts';
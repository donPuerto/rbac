-- =====================================================================================
-- RBAC System Tables
-- =====================================================================================
-- Description: Core table definitions for the Role-Based Access Control (RBAC) system
-- Version: 1.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Table of Contents
-- =====================================================================================
-- 1. Core User Tables
--    - profiles                (Core user information)
--    - user_security_settings  (Security and authentication)
--    - user_preferences        (User settings and preferences)
--    - user_onboarding        (Onboarding progress tracking)
--    - user_addresses         (User address management)
--    - user_phone_numbers     (User phone numbers)

-- 2. RBAC Tables
--    - roles                  (Role definitions)
--    - permissions           (Permission definitions)
--    - user_roles            (User-role assignments)
--    - role_permissions      (Role-permission mappings)
--    - role_delegations      (Role delegation tracking)

-- 3. System Tables
--    - error_logs            (Error tracking)
--    - audit_logs            (System audit trail)
--    - user_activities       (User activity tracking)

-- 4. CRM Core Tables
--    - crm_leads            (Lead management)
--    - crm_contacts         (Contact management)
--    - crm_opportunities    (Sales opportunities)
--    - crm_quotes           (Quote management)
--    - crm_jobs             (Job/Project tracking)

-- 5. CRM Support Tables
--    - crm_products         (Product catalog)
--    - crm_pipelines        (Sales pipeline config)
--    - crm_communications   (Communication records)
--    - crm_documents        (Document management)
--    - crm_relationships    (Entity relationships)
--    - crm_notes            (Universal notes)
--    - crm_automations      (Automation rules)

-- 6. Task Management
--    - tasks                (Universal task system)

-- 7. Inventory Management
--    - inventory_locations  (Storage locations)
--    - inventory_items      (Stock items)
--    - inventory_transactions (Stock movements)
--    - purchase_orders      (Purchase management)
--    - purchase_order_items (PO line items)

-- 8. Accounting Integration
--    - chart_of_accounts    (Account structure)
--    - journal_entries      (Accounting entries)
--    - journal_entry_lines  (Entry details)
--    - payment_transactions (Payment records)

-- Drop statements for clean setup
-- =====================================================================================

-- Drop Core User Tables
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.user_security_settings CASCADE;
DROP TABLE IF EXISTS public.user_preferences CASCADE;
DROP TABLE IF EXISTS public.user_onboarding CASCADE;
DROP TABLE IF EXISTS public.user_addresses CASCADE;
DROP TABLE IF EXISTS public.user_phone_numbers CASCADE;

-- Drop RBAC Tables
DROP TABLE IF EXISTS public.role_delegations CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;
DROP TABLE IF EXISTS public.user_roles CASCADE;
DROP TABLE IF EXISTS public.permissions CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;

-- Drop System Tables
DROP TABLE IF EXISTS public.error_logs CASCADE;
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.user_activities CASCADE;

-- Drop CRM Core Tables
DROP TABLE IF EXISTS public.crm_leads CASCADE;
DROP TABLE IF EXISTS public.crm_contacts CASCADE;
DROP TABLE IF EXISTS public.crm_opportunities CASCADE;
DROP TABLE IF EXISTS public.crm_quotes CASCADE;
DROP TABLE IF EXISTS public.crm_jobs CASCADE;

-- Drop CRM Support Tables
DROP TABLE IF EXISTS public.crm_products CASCADE;
DROP TABLE IF EXISTS public.crm_pipelines CASCADE;
DROP TABLE IF EXISTS public.crm_communications CASCADE;
DROP TABLE IF EXISTS public.crm_documents CASCADE;
DROP TABLE IF EXISTS public.crm_relationships CASCADE;
DROP TABLE IF EXISTS public.crm_notes CASCADE;
DROP TABLE IF EXISTS public.crm_automations CASCADE;

-- Drop Task Management Tables
DROP TABLE IF EXISTS public.tasks CASCADE;

-- Drop Inventory Management Tables
DROP TABLE IF EXISTS public.inventory_locations CASCADE;
DROP TABLE IF EXISTS public.inventory_items CASCADE;
DROP TABLE IF EXISTS public.inventory_transactions CASCADE;
DROP TABLE IF EXISTS public.purchase_orders CASCADE;
DROP TABLE IF EXISTS public.purchase_order_items CASCADE;

-- Drop Accounting Tables
DROP TABLE IF EXISTS public.chart_of_accounts CASCADE;
DROP TABLE IF EXISTS public.journal_entries CASCADE;
DROP TABLE IF EXISTS public.journal_entry_lines CASCADE;
DROP TABLE IF EXISTS public.payment_transactions CASCADE;

-- =====================================================================================
-- Core Tables
-- =====================================================================================

-- Profiles table: Stores core user information and profile data
-- =====================================================================================
-- Drop existing indexes
DROP INDEX IF EXISTS public.idx_profiles_email;
DROP INDEX IF EXISTS public.idx_profiles_username;
DROP INDEX IF EXISTS public.idx_profiles_status;
DROP INDEX IF EXISTS public.idx_profiles_company;
DROP INDEX IF EXISTS public.idx_profiles_department;
DROP INDEX IF EXISTS public.idx_profiles_created_at;

CREATE TABLE public.profiles (
    -- Primary identification (matches auth.users)
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    username TEXT UNIQUE CHECK (
        -- Must start with @
        username LIKE '@%' AND
        -- Must be between 3 and 30 characters (including @)
        length(username) BETWEEN 3 AND 30 AND
        -- Can only contain lowercase letters, numbers, and underscores after @
        username ~ '^@[a-z0-9_]+$'
    ),

    -- Personal information
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    display_name TEXT,                    -- Public display name
    date_of_birth DATE,                   -- For age verification
    gender enums.gender_type,
    avatar_url TEXT,                      -- Profile picture URL
    bio TEXT,
    
     -- Professional information
    company TEXT,                         -- Company name
    job_title TEXT,                       -- Job position
    department TEXT,                      -- Department within company
    industry TEXT,                        -- Industry sector
    website TEXT,                         -- Professional website
    customer_segment enums.customer_segment_type,

    -- Account status
    status enums.status_type NOT NULL DEFAULT 'active',
    is_active BOOLEAN DEFAULT true,       -- Account status flag

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,               -- Soft delete timestamp
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL    -- Optimistic locking
);
COMMENT ON TABLE public.profiles IS 'Core user information and profile data';

-- Indexes for profiles
CREATE INDEX idx_profiles_email ON public.profiles(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_username ON public.profiles(username) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_status ON public.profiles(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_company ON public.profiles(company) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_department ON public.profiles(department) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_created_at ON public.profiles(created_at) WHERE deleted_at IS NULL;

-- Grants for profiles
GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO service_role;

-- User Security Settings table: Manages all security-related aspects of user accounts
-- =====================================================================================
-- Drop existing indexes
DROP INDEX IF EXISTS public.idx_user_security_settings_user_id;
DROP INDEX IF EXISTS public.idx_user_security_settings_email_verified;
DROP INDEX IF EXISTS public.idx_user_security_settings_last_login;
DROP INDEX IF EXISTS public.idx_user_security_settings_failed_attempts;
DROP INDEX IF EXISTS public.idx_user_security_settings_locked_until;

CREATE TABLE public.user_security_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Security settings
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_method TEXT DEFAULT 'app',
    recovery_email TEXT,
    recovery_phone TEXT,
    last_password_change TIMESTAMPTZ,
    password_expires_at TIMESTAMPTZ,
    
    -- Session tracking
    last_login_at TIMESTAMPTZ,
    last_active_at TIMESTAMPTZ,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMPTZ,
    
    -- Verification status
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    identity_verified BOOLEAN DEFAULT false,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL
);

-- Indexes for user_security_settings
CREATE INDEX idx_user_security_settings_user_id ON public.user_security_settings(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_email_verified ON public.user_security_settings(email_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_last_login ON public.user_security_settings(last_login_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_failed_attempts ON public.user_security_settings(failed_login_attempts) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_locked_until ON public.user_security_settings(locked_until) WHERE deleted_at IS NULL;

-- Grants for user_security_settings
GRANT SELECT ON public.user_security_settings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_security_settings TO service_role;

-- User Preferences table: Stores user-specific settings and preferences
-- =====================================================================================
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Language and locale
    preferred_language TEXT DEFAULT 'en',
    timezone TEXT DEFAULT 'UTC',
    date_format TEXT DEFAULT 'YYYY-MM-DD',
    time_format TEXT DEFAULT '24h',

    -- Notification preferences
    email_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    push_notifications BOOLEAN DEFAULT true,
    in_app_notifications BOOLEAN DEFAULT true,
    
    -- Email preferences
    weekly_digest BOOLEAN DEFAULT true,
    marketing_emails BOOLEAN DEFAULT true,
    
    -- UI preferences
    theme TEXT DEFAULT 'system',          -- system, light, dark
    sidebar_collapsed BOOLEAN DEFAULT false,
    display_density TEXT DEFAULT 'comfortable',
    
     -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    UNIQUE(user_id, deleted_at)
);

-- Indexes for user_preferences
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_theme ON public.user_preferences(theme) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_language ON public.user_preferences(preferred_language) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_timezone ON public.user_preferences(timezone) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_notifications ON public.user_preferences(email_notifications, push_notifications, sms_notifications) WHERE deleted_at IS NULL;

-- Grants for user_preferences
GRANT SELECT ON public.user_preferences TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_preferences TO service_role;

-- User Onboarding table: Tracks the user's journey through the onboarding process
-- =====================================================================================
CREATE TABLE public.user_onboarding (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Onboarding progress
    onboarding_completed BOOLEAN DEFAULT false,
    onboarding_step INTEGER DEFAULT 1,
    onboarding_started_at TIMESTAMPTZ,
    onboarding_completed_at TIMESTAMPTZ,
    
    -- Consent tracking
    terms_accepted BOOLEAN DEFAULT false,
    terms_accepted_at TIMESTAMPTZ,
    terms_version TEXT,
    privacy_accepted BOOLEAN DEFAULT false,
    privacy_accepted_at TIMESTAMPTZ,
    privacy_version TEXT,
    marketing_consent BOOLEAN DEFAULT false,
    marketing_consent_at TIMESTAMPTZ,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    UNIQUE(user_id, deleted_at)
);

-- Indexes for user_onboarding
CREATE INDEX idx_user_onboarding_user_id ON public.user_onboarding(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_completed ON public.user_onboarding(onboarding_completed) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_step ON public.user_onboarding(onboarding_step) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_terms ON public.user_onboarding(terms_accepted, privacy_accepted) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_marketing ON public.user_onboarding(marketing_consent) WHERE deleted_at IS NULL;

-- Grants for user_onboarding
GRANT SELECT ON public.user_onboarding TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_onboarding TO service_role;


-- =====================================================================================
-- RBAC Tables
-- =====================================================================================

-- Roles table: Defines the available roles in the system
-- =====================================================================================
CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    type enums.role_type NOT NULL DEFAULT 'custom',
    is_system BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    permissions TEXT[] DEFAULT ARRAY[]::TEXT[],
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    UNIQUE(name, deleted_at)
);

-- Comments
COMMENT ON TABLE public.roles IS 'Defines the available roles in the system';

-- Indexes
CREATE INDEX idx_roles_name ON public.roles(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_roles_type ON public.roles(type) WHERE deleted_at IS NULL;
CREATE INDEX idx_roles_is_active ON public.roles(is_active) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.roles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.roles TO service_role;

-- Permissions table: Available system permissions
-- =====================================================================================
CREATE TABLE public.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    is_system BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    UNIQUE(name, deleted_at)
);

-- Comments
COMMENT ON TABLE public.permissions IS 'Defines available system permissions';

-- Indexes
CREATE INDEX idx_permissions_name ON public.permissions(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_permissions_category ON public.permissions(category) WHERE deleted_at IS NULL;
CREATE INDEX idx_permissions_is_active ON public.permissions(is_active) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.permissions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.permissions TO service_role;

-- User Roles table: Maps users to roles
-- =====================================================================================
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES public.roles(id),
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    UNIQUE(user_id, role_id, deleted_at)
);

-- Comments
COMMENT ON TABLE public.user_roles IS 'Maps users to their assigned roles';

-- Indexes
CREATE INDEX idx_user_roles_user ON public.user_roles(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_roles_role ON public.user_roles(role_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_roles_is_active ON public.user_roles(is_active) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.user_roles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_roles TO service_role;

-- Role Permissions table: Maps roles to permissions
-- =====================================================================================
CREATE TABLE public.role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL REFERENCES public.roles(id),
    permission_id UUID NOT NULL REFERENCES public.permissions(id),
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    UNIQUE(role_id, permission_id, deleted_at)
);

-- Comments
COMMENT ON TABLE public.role_permissions IS 'Maps roles to their assigned permissions';

-- Indexes
CREATE INDEX idx_role_permissions_role ON public.role_permissions(role_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_permissions_permission ON public.role_permissions(permission_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_permissions_is_active ON public.role_permissions(is_active) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.role_permissions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.role_permissions TO service_role;

-- Role Delegations table: Tracks role management delegations
CREATE TABLE public.role_delegations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delegator_id UUID NOT NULL REFERENCES public.profiles(id),
    delegate_id UUID NOT NULL REFERENCES public.profiles(id),
    role_id UUID NOT NULL REFERENCES public.roles(id),
    can_grant BOOLEAN DEFAULT false,
    can_revoke BOOLEAN DEFAULT false,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id),
    CHECK (delegator_id != delegate_id),
    UNIQUE(delegator_id, delegate_id, role_id, deleted_at)
);

-- Indexes
CREATE INDEX idx_role_delegations_delegator ON public.role_delegations(delegator_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_delegate ON public.role_delegations(delegate_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_role ON public.role_delegations(role_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_expires ON public.role_delegations(expires_at) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.role_delegations TO authenticated;
GRANT ALL ON public.role_delegations TO service_role;

COMMENT ON TABLE public.role_delegations IS 'Role management delegation tracking';

-- =====================================================================================
-- System Tables
-- =====================================================================================

-- Error Logs table: System-wide error tracking
CREATE TABLE public.error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    error_message TEXT NOT NULL,
    error_details TEXT,
    error_code TEXT,
    error_stack TEXT,
    severity enums.severity_type NOT NULL DEFAULT 'ERROR' 
        CHECK (severity IN ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL')),
    function_name TEXT,
    schema_name TEXT,
    table_name TEXT,
    context_data JSONB,
    request_data JSONB,
    user_id UUID REFERENCES public.profiles(id),
    ip_address TEXT,
    user_agent TEXT,
    occurred_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    is_resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES public.profiles(id),
    resolution_notes TEXT
);

-- Indexes
CREATE INDEX idx_error_logs_severity ON public.error_logs(severity);
CREATE INDEX idx_error_logs_occurred_at ON public.error_logs(occurred_at);
CREATE INDEX idx_error_logs_created_at ON public.error_logs(created_at);
CREATE INDEX idx_error_logs_user_id ON public.error_logs(user_id);
CREATE INDEX idx_error_logs_function ON public.error_logs(function_name);
CREATE INDEX idx_error_logs_is_resolved ON public.error_logs(is_resolved);
CREATE INDEX idx_error_logs_table_name ON public.error_logs(table_name);

-- Grants
GRANT SELECT ON public.error_logs TO authenticated;
GRANT ALL ON public.error_logs TO service_role;

COMMENT ON TABLE public.error_logs IS 'System-wide error tracking and debugging';

-- Audit Logs table: System change tracking
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_fields TEXT[],
    performed_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    ip_address TEXT,
    user_agent TEXT
);

-- Indexes
CREATE INDEX idx_audit_logs_table_name ON public.audit_logs(table_name);
CREATE INDEX idx_audit_logs_record_id ON public.audit_logs(record_id);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX idx_audit_logs_performed_by ON public.audit_logs(performed_by);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs(created_at);

-- Grants
GRANT SELECT ON public.audit_logs TO authenticated;
GRANT ALL ON public.audit_logs TO service_role;

COMMENT ON TABLE public.audit_logs IS 'Comprehensive system audit trail';

-- User Activities table: User interaction tracking
CREATE TABLE public.user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    activity_category TEXT NOT NULL,
    activity_source TEXT NOT NULL,
    description TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    ip_address TEXT,
    user_agent TEXT,
    device_info JSONB,
    location_info JSONB,
    session_id UUID,
    page_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_user_activities_user_id ON public.user_activities(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_activities_type ON public.user_activities(activity_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_activities_created_at ON public.user_activities(created_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_activities_category ON public.user_activities(activity_category) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.user_activities TO authenticated;
GRANT ALL ON public.user_activities TO service_role;

COMMENT ON TABLE public.user_activities IS 'User activity and behavior tracking';

-- =====================================================================================
-- CRM Tables
-- =====================================================================================

-- CRM Automations: Manages automated marketing campaigns and customer engagement workflows
-- =====================================================================================
CREATE TABLE public.crm_automations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Campaign Information
    name TEXT NOT NULL,
    description TEXT,
    campaign_type enums.campaign_type NOT NULL,
    
    -- Targeting
    target_segment TEXT[] NOT NULL,
    target_criteria JSONB,
    excluded_segments TEXT[],
    
    -- Schedule
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    frequency TEXT CHECK (frequency IN ('once', 'daily', 'weekly', 'monthly', 'custom')),
    custom_schedule JSONB,
    
    -- Content and Delivery
    content_template TEXT,
    content_variables JSONB,
    delivery_channel TEXT[] NOT NULL,
    
    -- Performance Metrics
    total_recipients INTEGER DEFAULT 0,
    successful_deliveries INTEGER DEFAULT 0,
    engagement_rate DECIMAL(5,2) DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0,
    revenue_generated DECIMAL(12,2) DEFAULT 0,
    
    -- Status and Control
    status enums.campaign_status_type NOT NULL DEFAULT 'draft',
    is_active BOOLEAN DEFAULT true,
    priority INTEGER CHECK (priority BETWEEN 1 AND 5),
    
    -- A/B Testing
    ab_test_enabled BOOLEAN DEFAULT false,
    ab_test_variables JSONB,
    
    -- Audit
    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    
    -- Metadata
    tags TEXT[],
    metadata JSONB
);

-- Indexes for CRM Automations
CREATE INDEX idx_crm_automations_status ON public.crm_automations(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_automations_type ON public.crm_automations(campaign_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_automations_dates ON public.crm_automations(start_date, end_date) WHERE status = 'active' AND deleted_at IS NULL;
CREATE INDEX idx_crm_automations_active ON public.crm_automations(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_automations_priority ON public.crm_automations(priority) WHERE status = 'active' AND deleted_at IS NULL;

-- Grants for crm_automations
GRANT SELECT ON public.crm_automations TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.crm_automations TO service_role;

-- Tasks table: Universal task management for CRM entities
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    task_type enums.task_type NOT NULL,
    priority enums.task_priority DEFAULT 'medium' NOT NULL,
    status enums.task_status_type DEFAULT 'pending' NOT NULL,
    
    -- Entity Reference (polymorphic association)
    entity_type enums.crm_entity_type NOT NULL,
    entity_id UUID NOT NULL,
    
    -- Scheduling
    due_date TIMESTAMPTZ,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    duration INTEGER, -- in minutes
    is_all_day BOOLEAN DEFAULT false,
    
    -- Assignment
    assigned_to UUID REFERENCES public.profiles(id),
    team_members UUID[] DEFAULT ARRAY[]::UUID[],
    
    -- Recurrence
    recurrence_rule TEXT, -- iCal RRULE format
    recurrence_exception_dates TIMESTAMPTZ[],
    parent_task_id UUID REFERENCES public.tasks(id),
    
    -- Progress
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    completion_notes TEXT,
    completed_at TIMESTAMPTZ,
    completed_by UUID REFERENCES public.profiles(id),
    
    -- Reminders
    reminder_before INTERVAL,
    reminder_sent_at TIMESTAMPTZ,
    
    -- Additional Data
    location JSONB,
    attachments JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id),
    
    -- Constraints
    CONSTRAINT valid_progress CHECK (progress >= 0 AND progress <= 100),
    CONSTRAINT valid_dates CHECK (
        (end_date IS NULL) OR 
        (start_date IS NULL) OR 
        (end_date > start_date)
    ),
    CONSTRAINT valid_completion CHECK (
        (completed_at IS NULL AND completed_by IS NULL) OR
        (completed_at IS NOT NULL AND completed_by IS NOT NULL)
    )
);

-- Indexes for tasks
CREATE INDEX idx_tasks_entity ON public.tasks (entity_type, entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_status ON public.tasks (status) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_type ON public.tasks (task_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_priority ON public.tasks (priority) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_assigned_to ON public.tasks (assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_due_date ON public.tasks (due_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_start_date ON public.tasks (start_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_parent_task ON public.tasks (parent_task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_tags ON public.tasks USING gin (tags) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.tasks TO authenticated;
GRANT ALL ON public.tasks TO service_role;

-- =====================================================================================
-- CRM Tables
-- =====================================================================================

-- Leads table: Potential customers or business opportunities
CREATE TABLE public.crm_leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    source TEXT,
    status enums.lead_status DEFAULT 'new' NOT NULL,
    notes TEXT,
    assigned_to UUID REFERENCES public.profiles(id),
    contact_id UUID REFERENCES public.crm_contacts(id), -- Set when converted to contact
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Contacts table: Qualified leads and existing customers
CREATE TABLE public.crm_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address JSONB DEFAULT '{}',
    customer_type enums.customer_type NOT NULL DEFAULT 'prospect',
    customer_segment enums.customer_segment_type,
    source TEXT,
    notes TEXT,
    assigned_to UUID REFERENCES public.profiles(id),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Opportunities table: Potential deals or sales
CREATE TABLE public.crm_opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES public.crm_contacts(id),
    name TEXT NOT NULL,
    description TEXT,
    status enums.opportunity_status DEFAULT 'new' NOT NULL,
    value DECIMAL(15,2),
    currency TEXT DEFAULT 'USD',
    probability INTEGER CHECK (probability >= 0 AND probability <= 100),
    expected_close_date DATE,
    actual_close_date DATE,
    assigned_to UUID REFERENCES public.profiles(id),
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Quotes table: Price quotes for opportunities
CREATE TABLE public.crm_quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID REFERENCES public.crm_opportunities(id),
    contact_id UUID NOT NULL REFERENCES public.crm_contacts(id),
    quote_number TEXT NOT NULL UNIQUE,
    status enums.quote_status DEFAULT 'draft' NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    valid_until DATE,
    notes TEXT,
    terms_and_conditions TEXT,
    line_items JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Jobs table: Scheduled work or services
CREATE TABLE public.crm_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_number TEXT NOT NULL UNIQUE,
    contact_id UUID NOT NULL REFERENCES public.crm_contacts(id),
    opportunity_id UUID REFERENCES public.crm_opportunities(id),
    quote_id UUID REFERENCES public.crm_quotes(id),
    title TEXT NOT NULL,
    description TEXT,
    status enums.job_status DEFAULT 'scheduled' NOT NULL,
    priority enums.job_priority DEFAULT 'medium' NOT NULL,
    scheduled_start TIMESTAMPTZ NOT NULL,
    scheduled_end TIMESTAMPTZ NOT NULL,
    actual_start TIMESTAMPTZ,
    actual_end TIMESTAMPTZ,
    location JSONB,
    assigned_to UUID REFERENCES public.profiles(id),
    team_members UUID[] DEFAULT ARRAY[]::UUID[],
    equipment_needed TEXT[],
    estimated_cost DECIMAL(15,2),
    actual_cost DECIMAL(15,2),
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id),
    CONSTRAINT valid_schedule CHECK (scheduled_end > scheduled_start),
    CONSTRAINT valid_actual_time CHECK (
        (actual_end IS NULL) OR 
        (actual_start IS NOT NULL AND actual_end > actual_start)
    )
);

-- Indexes
CREATE INDEX idx_leads_status ON public.crm_leads(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_assigned_to ON public.crm_leads(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_email ON public.crm_leads(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_leads_contact_id ON public.crm_leads(contact_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_contacts_email ON public.crm_contacts(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_contacts_customer_type ON public.crm_contacts(customer_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_contacts_assigned_to ON public.crm_contacts(assigned_to) WHERE deleted_at IS NULL;

CREATE INDEX idx_opportunities_contact_id ON public.crm_opportunities(contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_opportunities_status ON public.crm_opportunities(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_opportunities_assigned_to ON public.crm_opportunities(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_opportunities_expected_close ON public.crm_opportunities(expected_close_date) WHERE deleted_at IS NULL;

CREATE INDEX idx_quotes_opportunity_id ON public.crm_quotes(opportunity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_quotes_contact_id ON public.crm_quotes(contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_quotes_status ON public.crm_quotes(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_quotes_valid_until ON public.crm_quotes(valid_until) WHERE deleted_at IS NULL;

CREATE INDEX idx_jobs_contact_id ON public.crm_jobs(contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_jobs_opportunity_id ON public.crm_jobs(opportunity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_jobs_quote_id ON public.crm_jobs(quote_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_jobs_status ON public.crm_jobs(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_jobs_scheduled_start ON public.crm_jobs(scheduled_start) WHERE deleted_at IS NULL;
CREATE INDEX idx_jobs_assigned_to ON public.crm_jobs(assigned_to) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.crm_leads TO authenticated;
GRANT SELECT ON public.crm_contacts TO authenticated;
GRANT SELECT ON public.crm_opportunities TO authenticated;
GRANT SELECT ON public.crm_quotes TO authenticated;
GRANT SELECT ON public.crm_jobs TO authenticated;

GRANT ALL ON public.crm_leads TO service_role;
GRANT ALL ON public.crm_contacts TO service_role;
GRANT ALL ON public.crm_opportunities TO service_role;
GRANT ALL ON public.crm_quotes TO service_role;
GRANT ALL ON public.crm_jobs TO service_role;

-- =====================================================================================
-- Supporting Tables
-- =====================================================================================

-- Contact Information Tables
-- =====================================================================================

-- Phone Numbers: Stores multiple phone numbers per user
CREATE TABLE public.user_phone_numbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    -- Phone Information
    phone_number TEXT NOT NULL,
    phone_type enums.phone_type NOT NULL,
    country_code TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verification_code TEXT,
    verified_at TIMESTAMPTZ,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    label TEXT,
    notes TEXT,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT valid_phone CHECK (phone_number ~ '^\+?[0-9\s-\(\)]+$'),
    CONSTRAINT one_primary_phone UNIQUE (user_id, is_primary) WHERE is_primary = true AND deleted_at IS NULL
);

COMMENT ON TABLE public.user_phone_numbers IS 'Stores multiple phone numbers for each user';

-- Addresses: Stores multiple addresses per user
CREATE TABLE public.user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    -- Address Information
    address_type enums.address_type NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    
    -- Address Components
    street_address TEXT NOT NULL,
    street_address2 TEXT,
    city TEXT NOT NULL,
    state TEXT,
    postal_code TEXT,
    country TEXT NOT NULL,
    
    -- Geolocation
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- Metadata
    label TEXT,
    notes TEXT,
    
    -- Verification
    verified_at TIMESTAMPTZ,
    verification_method TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT one_primary_address UNIQUE (user_id, is_primary) WHERE is_primary = true AND deleted_at IS NULL
);

COMMENT ON TABLE public.user_addresses IS 'Stores multiple addresses for each user';

-- Grants
GRANT SELECT ON public.user_phone_numbers TO authenticated;
GRANT SELECT ON public.user_addresses TO authenticated;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO service_role;

CREATE TYPE enums.gender_type AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE enums.customer_segment_type AS ENUM ('individual', 'business', 'organization');
CREATE TYPE enums.phone_type AS ENUM ('mobile', 'work', 'home', 'fax', 'other');
CREATE TYPE enums.address_type AS ENUM ('home', 'work', 'billing', 'shipping', 'other');
CREATE TYPE enums.task_type AS ENUM ('follow_up', 'call', 'meeting', 'email', 'proposal', 'contract', 'demo', 'support', 'role_expiration', 'system_maintenance');
CREATE TYPE enums.task_status_type AS ENUM ('pending', 'in_progress', 'completed', 'cancelled', 'blocked', 'deferred');
CREATE TYPE enums.campaign_type AS ENUM ('email_campaign', 'sms_campaign', 'social_media', 'webinar', 'event', 'newsletter', 'drip_campaign', 'lead_nurturing', 'customer_onboarding', 'retention_campaign');
CREATE TYPE enums.campaign_status_type AS ENUM ('draft', 'scheduled', 'active', 'paused', 'completed', 'cancelled');
CREATE TYPE enums.status_type AS ENUM ('active', 'inactive', 'suspended', 'pending');

-- Products/Services table: Catalog of offerings
CREATE TABLE public.crm_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE,
    category enums.product_category NOT NULL,
    description TEXT,
    price DECIMAL(15,2),
    currency TEXT DEFAULT 'USD',
    unit TEXT,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Sales Pipelines table: Define different sales processes
CREATE TABLE public.crm_pipelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    stages JSONB NOT NULL, -- Array of stage configurations
    is_default BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Communications table: Track all communications
CREATE TABLE public.crm_communications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type enums.crm_entity_type NOT NULL,
    entity_id UUID NOT NULL,
    channel enums.communication_channel NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('inbound', 'outbound')),
    subject TEXT,
    content TEXT,
    status TEXT NOT NULL CHECK (status IN ('draft', 'sent', 'delivered', 'failed')),
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Documents table: Store and manage CRM-related documents
CREATE TABLE public.crm_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type enums.crm_entity_type NOT NULL,
    entity_id UUID NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    version INTEGER DEFAULT 1,
    status TEXT NOT NULL CHECK (status IN ('draft', 'final', 'archived')),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Relationships table: Track relationships between CRM entities
CREATE TABLE public.crm_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_entity_type enums.crm_entity_type NOT NULL,
    from_entity_id UUID NOT NULL,
    to_entity_type enums.crm_entity_type NOT NULL,
    to_entity_id UUID NOT NULL,
    relationship_type TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id),
    CONSTRAINT unique_relationship UNIQUE (from_entity_type, from_entity_id, to_entity_type, to_entity_id, relationship_type)
);

-- Notes table: Universal notes for any CRM entity
CREATE TABLE public.crm_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type enums.crm_entity_type NOT NULL,
    entity_id UUID NOT NULL,
    title TEXT,
    content TEXT NOT NULL,
    is_private BOOLEAN DEFAULT false,
    pinned BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Indexes for new tables
CREATE INDEX idx_products_category ON public.crm_products(category) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_active ON public.crm_products(is_active) WHERE deleted_at IS NULL;

CREATE INDEX idx_pipelines_default ON public.crm_pipelines(is_default) WHERE deleted_at IS NULL;

CREATE INDEX idx_communications_entity ON public.crm_communications(entity_type, entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_communications_channel ON public.crm_communications(channel) WHERE deleted_at IS NULL;
CREATE INDEX idx_communications_scheduled ON public.crm_communications(scheduled_at) WHERE deleted_at IS NULL;

CREATE INDEX idx_documents_entity ON public.crm_documents(entity_type, entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_documents_category ON public.crm_documents(category) WHERE deleted_at IS NULL;

CREATE INDEX idx_relationships_from ON public.crm_relationships(from_entity_type, from_entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_relationships_to ON public.crm_relationships(to_entity_type, to_entity_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_notes_entity ON public.crm_notes(entity_type, entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_pinned ON public.crm_notes(pinned) WHERE deleted_at IS NULL AND pinned = true;

-- Grants
GRANT SELECT ON public.crm_products TO authenticated;
GRANT SELECT ON public.crm_pipelines TO authenticated;
GRANT SELECT ON public.crm_communications TO authenticated;
GRANT SELECT ON public.crm_documents TO authenticated;
GRANT SELECT ON public.crm_relationships TO authenticated;
GRANT SELECT ON public.crm_notes TO authenticated;

GRANT ALL ON public.crm_products TO service_role;
GRANT ALL ON public.crm_pipelines TO service_role;
GRANT ALL ON public.crm_communications TO service_role;
GRANT ALL ON public.crm_documents TO service_role;
GRANT ALL ON public.crm_relationships TO service_role;
GRANT ALL ON public.crm_notes TO service_role;

-- =====================================================================================
-- Inventory Tables
-- =====================================================================================

-- Inventory Locations table: Physical locations for inventory
CREATE TABLE public.inventory_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE,
    type enums.inventory_location_type NOT NULL,
    address JSONB,
    contact_info JSONB,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Inventory Items table: Track inventory levels
CREATE TABLE public.inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.crm_products(id),
    location_id UUID REFERENCES public.inventory_locations(id),
    quantity DECIMAL(15,2) NOT NULL DEFAULT 0,
    unit_cost DECIMAL(15,2),
    reorder_point DECIMAL(15,2),
    reorder_quantity DECIMAL(15,2),
    last_counted_at TIMESTAMPTZ,
    last_counted_by UUID REFERENCES public.profiles(id),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id),
    CONSTRAINT unique_product_location UNIQUE (product_id, location_id)
);

-- Inventory Transactions table: Track all inventory movements
CREATE TABLE public.inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_type enums.inventory_transaction_type NOT NULL,
    product_id UUID REFERENCES public.crm_products(id),
    from_location_id UUID REFERENCES public.inventory_locations(id),
    to_location_id UUID REFERENCES public.inventory_locations(id),
    quantity DECIMAL(15,2) NOT NULL,
    unit_cost DECIMAL(15,2),
    total_cost DECIMAL(15,2),
    reference_type TEXT, -- 'purchase_order', 'sales_order', etc.
    reference_id UUID,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Purchase Orders table
CREATE TABLE public.purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_number TEXT UNIQUE NOT NULL,
    supplier_id UUID NOT NULL,
    status enums.purchase_order_status DEFAULT 'draft' NOT NULL,
    order_date DATE NOT NULL,
    expected_date DATE,
    delivery_date DATE,
    subtotal DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    notes TEXT,
    terms_conditions TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Purchase Order Items table
CREATE TABLE public.purchase_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_order_id UUID NOT NULL REFERENCES public.purchase_orders(id),
    product_id UUID NOT NULL REFERENCES public.crm_products(id),
    quantity DECIMAL(15,2) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    received_quantity DECIMAL(15,2) DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- =====================================================================================
-- Accounting Integration Tables
-- =====================================================================================

-- Chart of Accounts table
CREATE TABLE public.chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    account_type enums.account_type NOT NULL,
    parent_account_id UUID REFERENCES public.chart_of_accounts(id),
    is_active BOOLEAN DEFAULT true,
    external_id TEXT, -- For third-party integration
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Journal Entries table
CREATE TABLE public.journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_number TEXT UNIQUE NOT NULL,
    entry_date DATE NOT NULL,
    description TEXT,
    reference_type TEXT, -- 'invoice', 'payment', 'purchase_order', etc.
    reference_id UUID,
    is_posted BOOLEAN DEFAULT false,
    posted_at TIMESTAMPTZ,
    posted_by UUID REFERENCES public.profiles(id),
    external_id TEXT, -- For third-party integration
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Journal Entry Lines table
CREATE TABLE public.journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES public.journal_entries(id),
    account_id UUID NOT NULL REFERENCES public.chart_of_accounts(id),
    description TEXT,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    external_id TEXT, -- For third-party integration
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id),
    CONSTRAINT valid_amount CHECK (
        (debit_amount = 0 AND credit_amount > 0) OR
        (debit_amount > 0 AND credit_amount = 0)
    )
);

-- Payment Transactions table
CREATE TABLE public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_number TEXT UNIQUE NOT NULL,
    payment_date DATE NOT NULL,
    payment_method enums.payment_method NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    status enums.payment_status DEFAULT 'pending' NOT NULL,
    reference_type TEXT, -- 'invoice', 'purchase_order', etc.
    reference_id UUID,
    payment_details JSONB, -- Store payment gateway details
    external_id TEXT, -- For third-party integration
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.profiles(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.profiles(id)
);

-- Indexes
CREATE INDEX idx_inventory_items_product ON public.inventory_items(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_location ON public.inventory_items(location_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_reorder ON public.inventory_items(product_id) WHERE quantity <= reorder_point AND deleted_at IS NULL;

CREATE INDEX idx_inventory_transactions_product ON public.inventory_transactions(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_type ON public.inventory_transactions(transaction_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_reference ON public.inventory_transactions(reference_type, reference_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_purchase_orders_status ON public.purchase_orders(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_purchase_orders_supplier ON public.purchase_orders(supplier_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_purchase_orders_dates ON public.purchase_orders(order_date, expected_date) WHERE deleted_at IS NULL;

CREATE INDEX idx_chart_of_accounts_type ON public.chart_of_accounts(account_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_chart_of_accounts_active ON public.chart_of_accounts(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_chart_of_accounts_parent ON public.chart_of_accounts(parent_account_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_journal_entries_date ON public.journal_entries(entry_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_journal_entries_posted ON public.journal_entries(is_posted) WHERE deleted_at IS NULL;
CREATE INDEX idx_journal_entries_reference ON public.journal_entries(reference_type, reference_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_payment_transactions_date ON public.payment_transactions(payment_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_payment_transactions_reference ON public.payment_transactions(reference_type, reference_id) WHERE deleted_at IS NULL;

-- Grants
GRANT SELECT ON public.inventory_locations TO authenticated;
GRANT SELECT ON public.inventory_items TO authenticated;
GRANT SELECT ON public.inventory_transactions TO authenticated;
GRANT SELECT ON public.purchase_orders TO authenticated;
GRANT SELECT ON public.purchase_order_items TO authenticated;
GRANT SELECT ON public.chart_of_accounts TO authenticated;
GRANT SELECT ON public.journal_entries TO authenticated;
GRANT SELECT ON public.journal_entry_lines TO authenticated;
GRANT SELECT ON public.payment_transactions TO authenticated;

GRANT ALL ON public.inventory_locations TO service_role;
GRANT ALL ON public.inventory_items TO service_role;
GRANT ALL ON public.inventory_transactions TO service_role;
GRANT ALL ON public.purchase_orders TO service_role;
GRANT ALL ON public.purchase_order_items TO service_role;
GRANT ALL ON public.chart_of_accounts TO service_role;
GRANT ALL ON public.journal_entries TO service_role;
GRANT ALL ON public.journal_entry_lines TO service_role;
GRANT ALL ON public.payment_transactions TO service_role;

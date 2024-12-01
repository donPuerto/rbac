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
-- 1. Core Tables
--    - users                 (Core user information and profile data)
--    - roles                 (System role definitions)
--    - permissions          (Available system permissions)
--    - user_roles           (User-role assignments)
--    - role_permissions     (Role-permission mappings)
--    - role_delegations     (Role management delegations)
--
-- 2. System Management Tables
--    - error_logs           (System-wide error tracking and debugging)
--    - audit_logs           (System change tracking)
--    - user_activities      (User behavior tracking)
--    - scheduled_tasks      (Task scheduling for role expiration)
--
-- 3. Supporting Tables
--    - user_phone_numbers   (User contact information)
--    - user_addresses       (User physical addresses)
-- =====================================================================================

-- Drop statements for clean setup
-- =====================================================================================
-- Drop indexes first
DROP INDEX IF EXISTS public.idx_users_email CASCADE;
DROP INDEX IF EXISTS public.idx_users_status CASCADE;
DROP INDEX IF EXISTS public.idx_users_created_at CASCADE;
DROP INDEX IF EXISTS public.idx_users_updated_at CASCADE;
DROP INDEX IF EXISTS public.idx_users_deleted_at CASCADE;

DROP INDEX IF EXISTS public.idx_roles_name CASCADE;
DROP INDEX IF EXISTS public.idx_roles_type CASCADE;
DROP INDEX IF EXISTS public.idx_roles_is_active CASCADE;

DROP INDEX IF EXISTS public.idx_permissions_name CASCADE;
DROP INDEX IF EXISTS public.idx_permissions_resource_action CASCADE;
DROP INDEX IF EXISTS public.idx_permissions_is_active CASCADE;

DROP INDEX IF EXISTS public.idx_user_roles_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_user_roles_role_id CASCADE;
DROP INDEX IF EXISTS public.idx_user_roles_assigned_at CASCADE;
DROP INDEX IF EXISTS public.idx_user_roles_is_active CASCADE;

DROP INDEX IF EXISTS public.idx_role_permissions_role_id CASCADE;
DROP INDEX IF EXISTS public.idx_role_permissions_permission_id CASCADE;
DROP INDEX IF EXISTS public.idx_role_permissions_granted_at CASCADE;

DROP INDEX IF EXISTS public.idx_role_delegations_delegator CASCADE;
DROP INDEX IF EXISTS public.idx_role_delegations_delegate CASCADE;
DROP INDEX IF EXISTS public.idx_role_delegations_role CASCADE;
DROP INDEX IF EXISTS public.idx_role_delegations_expires CASCADE;

DROP INDEX IF EXISTS public.idx_error_logs_severity CASCADE;
DROP INDEX IF EXISTS public.idx_error_logs_created_at CASCADE;
DROP INDEX IF EXISTS public.idx_error_logs_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_error_logs_function CASCADE;

DROP INDEX IF EXISTS public.idx_audit_logs_table_name CASCADE;
DROP INDEX IF EXISTS public.idx_audit_logs_record_id CASCADE;
DROP INDEX IF EXISTS public.idx_audit_logs_action CASCADE;
DROP INDEX IF EXISTS public.idx_audit_logs_performed_by CASCADE;
DROP INDEX IF EXISTS public.idx_audit_logs_created_at CASCADE;

DROP INDEX IF EXISTS public.idx_user_activities_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_user_activities_type CASCADE;
DROP INDEX IF EXISTS public.idx_user_activities_created_at CASCADE;

DROP INDEX IF EXISTS public.idx_scheduled_tasks_type CASCADE;
DROP INDEX IF EXISTS public.idx_scheduled_tasks_status CASCADE;
DROP INDEX IF EXISTS public.idx_scheduled_tasks_execute_at CASCADE;

DROP INDEX IF EXISTS public.idx_phone_numbers_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_phone_numbers_type CASCADE;
DROP INDEX IF EXISTS public.idx_phone_numbers_is_primary CASCADE;

DROP INDEX IF EXISTS public.idx_addresses_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_addresses_type CASCADE;
DROP INDEX IF EXISTS public.idx_addresses_is_primary CASCADE;

-- Drop tables
DROP TABLE IF EXISTS public.user_activities CASCADE;
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.user_addresses CASCADE;
DROP TABLE IF EXISTS public.user_phone_numbers CASCADE;
DROP TABLE IF EXISTS public.scheduled_tasks CASCADE;
DROP TABLE IF EXISTS public.role_delegations CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;
DROP TABLE IF EXISTS public.user_roles CASCADE;
DROP TABLE IF EXISTS public.permissions CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.error_logs CASCADE;

-- =====================================================================================
-- Core Tables
-- =====================================================================================

-- Users table: Stores core user information and profile data
-- =====================================================================================
CREATE TABLE public.users (
    -- Primary identification (matches auth.users)
    id UUID PRIMARY KEY,                  -- ID from auth.users
    email TEXT NOT NULL UNIQUE,

    -- Personal information
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    display_name TEXT,                    -- Public display name
    date_of_birth DATE,                   -- For age verification
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    avatar_url TEXT,                      -- Profile picture URL
    bio TEXT,                             -- User biography/description

    -- Account settings
    status TEXT NOT NULL DEFAULT 'active' 
        CHECK (status IN ('active', 'inactive', 'suspended', 'pending')),
    preferred_language TEXT DEFAULT 'en',  -- UI language preference
    timezone TEXT DEFAULT 'UTC',          -- User's timezone
    notification_preferences JSONB DEFAULT '{"email": true, "sms": false}'::jsonb,
    is_active BOOLEAN DEFAULT true,       -- Account status flag
  
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,               -- Soft delete timestamp
    deleted_by UUID DEFAULT NULL,
    version INTEGER DEFAULT 1 NOT NULL    -- Optimistic locking
);
COMMENT ON TABLE public.users IS 'Core user information and profile data';

-- Create indexes for users table
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_status ON public.users(status);
CREATE INDEX idx_users_created_at ON public.users(created_at);
CREATE INDEX idx_users_updated_at ON public.users(updated_at);
CREATE INDEX idx_users_deleted_at ON public.users(deleted_at) WHERE deleted_at IS NOT NULL;

-- Grant permissions for users table
GRANT SELECT ON public.users TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO service_role;

-- Roles table: Defines system roles with role_type hierarchy
-- =====================================================================================
CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,            -- Role identifier
    description TEXT,                     -- Human-readable description
    type role_type NOT NULL,              -- Hierarchical role type
    is_system_role BOOLEAN DEFAULT false, -- System vs custom role
    is_active BOOLEAN DEFAULT true,       -- Role status

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    UNIQUE(name, deleted_at)              -- Allows name reuse after soft delete
);
COMMENT ON TABLE public.roles IS 'System role definitions with hierarchy levels';

-- Create indexes for roles table
CREATE INDEX idx_roles_name ON public.roles(name);
CREATE INDEX idx_roles_type ON public.roles(type);
CREATE INDEX idx_roles_is_active ON public.roles(is_active);

-- Grant permissions for roles table
GRANT SELECT ON public.roles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.roles TO service_role;

-- Permissions table: Defines available system permissions
-- =====================================================================================
CREATE TABLE public.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,            -- Permission identifier
    description TEXT,                     -- Human-readable description
    resource TEXT NOT NULL,               -- Resource being protected
    action TEXT NOT NULL,                 -- Allowed action on resource
    is_system_permission BOOLEAN DEFAULT false,  -- System vs custom permission
    is_active BOOLEAN DEFAULT true,       -- Permission status

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL
);
COMMENT ON TABLE public.permissions IS 'Available system permissions and access controls';

-- Create indexes for permissions table
CREATE INDEX idx_permissions_name ON public.permissions(name);
CREATE INDEX idx_permissions_resource_action ON public.permissions(resource, action);
CREATE INDEX idx_permissions_is_active ON public.permissions(is_active);

-- Grant permissions for permissions table
GRANT SELECT ON public.permissions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.permissions TO service_role;

-- User Roles: Maps users to their assigned roles
-- =====================================================================================
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,

    -- Assignment tracking
    assigned_by UUID REFERENCES auth.users(id),
    assigned_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    is_active BOOLEAN DEFAULT true,       -- Role assignment status

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),

    -- Constraints
    UNIQUE(user_id, role_id, deleted_at)  -- Prevent duplicate assignments
);
COMMENT ON TABLE public.user_roles IS 'User to role assignments with temporal constraints';

-- Create indexes for user_roles table
CREATE INDEX idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON public.user_roles(role_id);
CREATE INDEX idx_user_roles_assigned_at ON public.user_roles(assigned_at);
CREATE INDEX idx_user_roles_is_active ON public.user_roles(is_active);

-- Grant permissions for user_roles table
GRANT SELECT ON public.user_roles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_roles TO service_role;

-- Role Permissions: Maps roles to their assigned permissions
-- =====================================================================================
CREATE TABLE public.role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,

    -- Grant details
    granted_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    granted_by UUID REFERENCES auth.users(id),
    is_active BOOLEAN DEFAULT true,

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),

    -- Constraints
    UNIQUE(role_id, permission_id, deleted_at)  -- Prevent duplicate grants
);
COMMENT ON TABLE public.role_permissions IS 'Role to permission mappings with temporal constraints';

-- Create indexes for role_permissions table
CREATE INDEX idx_role_permissions_role_id ON public.role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON public.role_permissions(permission_id);
CREATE INDEX idx_role_permissions_granted_at ON public.role_permissions(granted_at);

-- Grant permissions for role_permissions table
GRANT SELECT ON public.role_permissions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.role_permissions TO service_role;

-- Role Delegations: Tracks role management delegations
-- =====================================================================================
CREATE TABLE public.role_delegations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delegator_id UUID NOT NULL REFERENCES auth.users(id),
    delegate_id UUID NOT NULL REFERENCES auth.users(id),
    role_id UUID NOT NULL REFERENCES public.roles(id),
    
    -- Delegation details
    can_grant BOOLEAN DEFAULT false,      -- Can grant role to others
    can_revoke BOOLEAN DEFAULT false,     -- Can revoke role from others
    expires_at TIMESTAMPTZ,               -- When delegation expires
    is_active BOOLEAN DEFAULT true,

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),

    -- Constraints
    CHECK (delegator_id != delegate_id),  -- Cannot delegate to self
    UNIQUE(delegator_id, delegate_id, role_id, deleted_at)
);
COMMENT ON TABLE public.role_delegations IS 'Tracks role management delegation capabilities';

-- Create indexes for role_delegations table
CREATE INDEX idx_role_delegations_delegator ON public.role_delegations(delegator_id);
CREATE INDEX idx_role_delegations_delegate ON public.role_delegations(delegate_id);
CREATE INDEX idx_role_delegations_role ON public.role_delegations(role_id);
CREATE INDEX idx_role_delegations_expires ON public.role_delegations(expires_at);

-- Grant permissions for role_delegations table
GRANT SELECT ON public.role_delegations TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.role_delegations TO service_role;

-- =====================================================================================
-- System Management Tables
-- =====================================================================================

-- Error Logs: System-wide error tracking and debugging
-- =====================================================================================
CREATE TABLE public.error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Error details
    error_message TEXT NOT NULL,          -- Main error message
    error_details TEXT,                   -- Detailed error information (e.g., SQLERRM)
    error_code TEXT,                      -- PostgreSQL error code (SQLSTATE)
    error_stack TEXT,                     -- Stack trace if available
    severity TEXT NOT NULL DEFAULT 'ERROR' 
        CHECK (severity IN ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL')),
    
    -- Context information
    function_name TEXT,                   -- Name of the function where error occurred
    schema_name TEXT,                     -- Schema where the error occurred
    table_name TEXT,                      -- Table involved (if applicable)
    
    -- Additional context
    context_data JSONB,                   -- JSON containing relevant error context
    request_data JSONB,                   -- Request-specific data when error occurred
    
    -- User information
    user_id UUID REFERENCES auth.users(id), -- User who triggered the error
    ip_address TEXT,                      -- IP address if available
    user_agent TEXT,                      -- User agent if available
    
    -- Timestamps
    occurred_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    -- Status tracking
    is_resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES auth.users(id),
    resolution_notes TEXT
);
COMMENT ON TABLE public.error_logs IS 'System-wide error logging table for tracking and debugging issues';

-- Create indexes for error_logs table
CREATE INDEX idx_error_logs_severity ON public.error_logs(severity);
CREATE INDEX idx_error_logs_occurred_at ON public.error_logs(occurred_at);
CREATE INDEX idx_error_logs_created_at ON public.error_logs(created_at);
CREATE INDEX idx_error_logs_user_id ON public.error_logs(user_id);
CREATE INDEX idx_error_logs_function ON public.error_logs(function_name);
CREATE INDEX idx_error_logs_is_resolved ON public.error_logs(is_resolved);
CREATE INDEX idx_error_logs_table_name ON public.error_logs(table_name);

-- Grant permissions for error_logs table
GRANT SELECT ON public.error_logs TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.error_logs TO service_role;

-- Audit Logs: System change tracking
-- =====================================================================================
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,             -- Table being audited
    record_id UUID NOT NULL,              -- Primary key of audited record
    action TEXT NOT NULL,                 -- INSERT, UPDATE, DELETE
    old_data JSONB,                       -- Previous state
    new_data JSONB,                       -- New state
    changed_fields TEXT[],                -- Array of changed field names
    performed_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    ip_address TEXT,                      -- IP address of user
    user_agent TEXT                       -- Browser/client info
);
COMMENT ON TABLE public.audit_logs IS 'Comprehensive system audit trail';

-- Create indexes for audit_logs table
CREATE INDEX idx_audit_logs_table_name ON public.audit_logs(table_name);
CREATE INDEX idx_audit_logs_record_id ON public.audit_logs(record_id);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX idx_audit_logs_performed_by ON public.audit_logs(performed_by);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs(created_at);

-- Grant permissions for audit_logs table
GRANT SELECT ON public.audit_logs TO authenticated;
GRANT SELECT, INSERT ON public.audit_logs TO service_role;

-- User Activities: User behavior tracking
-- =====================================================================================
CREATE TABLE public.user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    activity_type TEXT NOT NULL,          -- Login, logout, etc.
    description TEXT,                     -- Activity details
    metadata JSONB,                       -- Additional activity data
    ip_address TEXT,                      -- User's IP address
    user_agent TEXT,                      -- User's browser/client
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.user_activities IS 'User action and behavior tracking';

-- Create indexes for user_activities table
CREATE INDEX idx_user_activities_user_id ON public.user_activities(user_id);
CREATE INDEX idx_user_activities_type ON public.user_activities(activity_type);
CREATE INDEX idx_user_activities_created_at ON public.user_activities(created_at);

-- Grant permissions for user_activities table
GRANT SELECT ON public.user_activities TO authenticated;
GRANT SELECT, INSERT ON public.user_activities TO service_role;

-- Scheduled Tasks: System scheduled tasks including role expirations
-- =====================================================================================
CREATE TABLE public.scheduled_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_type TEXT NOT NULL,              -- Type of scheduled task
    execute_at TIMESTAMPTZ NOT NULL,      -- When to execute
    data JSONB NOT NULL,                  -- Task-specific data
    status TEXT DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    
    -- Execution tracking
    started_at TIMESTAMPTZ,               -- When task started
    completed_at TIMESTAMPTZ,             -- When task finished
    error_message TEXT,                   -- If task failed
    retry_count INTEGER DEFAULT 0,        -- Number of retries
    next_retry_at TIMESTAMPTZ,           -- When to retry if failed
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id)
);
COMMENT ON TABLE public.scheduled_tasks IS 'Manages scheduled system tasks';

-- Create indexes for scheduled_tasks table
CREATE INDEX idx_scheduled_tasks_type ON public.scheduled_tasks(task_type);
CREATE INDEX idx_scheduled_tasks_status ON public.scheduled_tasks(status);
CREATE INDEX idx_scheduled_tasks_execute_at ON public.scheduled_tasks(execute_at);

-- Grant permissions for scheduled_tasks table
GRANT SELECT ON public.scheduled_tasks TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.scheduled_tasks TO service_role;

-- =====================================================================================
-- Supporting Tables
-- =====================================================================================

-- User Phone Numbers: User contact information
-- =====================================================================================
CREATE TABLE public.user_phone_numbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    phone_number TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'mobile'
        CHECK (type IN ('mobile', 'home', 'work', 'other')),
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    UNIQUE(user_id, phone_number, deleted_at)
);
COMMENT ON TABLE public.user_phone_numbers IS 'User phone number management';

-- Create indexes for user_phone_numbers table
CREATE INDEX idx_phone_numbers_user_id ON public.user_phone_numbers(user_id);
CREATE INDEX idx_phone_numbers_type ON public.user_phone_numbers(type);
CREATE INDEX idx_phone_numbers_is_primary ON public.user_phone_numbers(is_primary);

-- Grant permissions for user_phone_numbers table
GRANT SELECT ON public.user_phone_numbers TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_phone_numbers TO service_role;

-- User Addresses: User physical addresses
-- =====================================================================================
CREATE TABLE public.user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL DEFAULT 'home'
        CHECK (type IN ('home', 'work', 'billing', 'shipping', 'other')),
    is_primary BOOLEAN DEFAULT false,
    
    -- Address fields
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    city TEXT NOT NULL,
    state TEXT,
    postal_code TEXT,
    country TEXT NOT NULL,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    UNIQUE(user_id, type, is_primary, deleted_at)
);
COMMENT ON TABLE public.user_addresses IS 'User address management';

-- Create indexes for user_addresses table
CREATE INDEX idx_addresses_user_id ON public.user_addresses(user_id);
CREATE INDEX idx_addresses_type ON public.user_addresses(type);
CREATE INDEX idx_addresses_is_primary ON public.user_addresses(is_primary);

-- Grant permissions for user_addresses table
GRANT SELECT ON public.user_addresses TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_addresses TO service_role;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO service_role;

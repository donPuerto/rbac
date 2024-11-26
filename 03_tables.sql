-- =====================================================================================
-- RBAC System Tables
-- =====================================================================================
-- Description: This file contains the table definitions for the RBAC system.
-- Tables are created in order of dependencies, with core tables first, followed by
-- junction tables and supporting tables. Each table includes audit fields for tracking
-- changes and maintaining data integrity.
-- =====================================================================================

-- =====================================================================================
-- Core Tables
-- =====================================================================================

-- Users table: Stores core user information and profile data
-- =====================================================================================
CREATE TABLE public.users (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- Permissions table: Defines available system permissions
-- =====================================================================================
CREATE TABLE public.permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,            -- Permission identifier
    description TEXT,                     -- Human-readable description
    resource TEXT NOT NULL,               -- Resource being protected
    action TEXT NOT NULL,                 -- Allowed action on resource
    is_system_permission BOOLEAN DEFAULT false,  -- System vs custom permission
    is_active BOOLEAN DEFAULT true,       -- Permission status

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),
    version INTEGER DEFAULT 1 NOT NULL
);

-- Roles table: Defines system roles with role_type hierarchy
-- =====================================================================================
CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,            -- Role identifier
    description TEXT,                     -- Human-readable description
    role_type role_type NOT NULL,         -- Hierarchical role type
    is_system_role BOOLEAN DEFAULT false, -- System vs custom role
    is_active BOOLEAN DEFAULT true,       -- Role status

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(name, deleted_at)              -- Allows name reuse after soft delete
);

-- =====================================================================================
-- Junction Tables
-- =====================================================================================

-- User Roles: Maps users to their assigned roles
-- =====================================================================================
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,

    -- Assignment tracking
    assigned_by UUID REFERENCES public.users(id),
    assigned_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    is_active BOOLEAN DEFAULT true,       -- Role assignment status

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),

    -- Constraints
    UNIQUE(user_id, role_id, deleted_at)  -- Prevent duplicate assignments
);

-- Role Permissions: Maps roles to their granted permissions
-- =====================================================================================
CREATE TABLE public.role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,

    -- Grant tracking
    granted_by UUID REFERENCES public.users(id),
    granted_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    is_active BOOLEAN DEFAULT true,       -- Permission grant status

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),

    -- Constraints
    UNIQUE(role_id, permission_id, deleted_at)  -- Prevent duplicate grants
);

-- =====================================================================================
-- Supporting Tables
-- =====================================================================================

-- User Phone Numbers: Stores multiple phone numbers per user
-- =====================================================================================
CREATE TABLE public.user_phone_numbers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    phone_number TEXT NOT NULL,
    phone_type TEXT NOT NULL CHECK (phone_type IN ('mobile', 'home', 'work', 'other')),
    is_primary BOOLEAN DEFAULT false,     -- Primary contact number flag
    is_verified BOOLEAN DEFAULT false,    -- Phone verification status
    verification_code TEXT,               -- For phone verification process
    verification_expires_at TIMESTAMPTZ,  -- Verification code expiry
    country_code TEXT NOT NULL,           -- International dialing code

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    UNIQUE (user_id, phone_number, deleted_at)  -- Prevent duplicate numbers
);

-- User Addresses: Stores multiple addresses per user
-- =====================================================================================
CREATE TABLE public.user_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address_type TEXT NOT NULL CHECK (address_type IN ('home', 'work', 'billing', 'shipping', 'other')),
    is_primary BOOLEAN DEFAULT false,     -- Primary address flag
    is_verified BOOLEAN DEFAULT false,    -- Address verification status
    street_address TEXT NOT NULL,
    apartment_unit TEXT,
    city TEXT NOT NULL,
    state_province TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    country TEXT NOT NULL,

    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    UNIQUE (user_id, address_type, street_address, apartment_unit, deleted_at)
);

-- =====================================================================================
-- Audit and Activity Tables
-- =====================================================================================

-- System Audit Logs: Tracks system-level changes
-- =====================================================================================
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name TEXT NOT NULL,             -- Modified table
    record_id UUID NOT NULL,              -- Modified record ID
    action TEXT NOT NULL,                 -- Type of change
    old_data JSONB,                       -- Previous state
    new_data JSONB,                       -- New state
    performed_by UUID REFERENCES public.users(id),
    performed_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- User Activity Logs: Tracks user actions and behaviors
-- =====================================================================================
CREATE TABLE public.user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id),
    activity_type TEXT NOT NULL,          -- Type of activity
    description TEXT,                     -- Human-readable description
    details JSONB,                        -- Additional activity data
    ip_address TEXT,                      -- User's IP address
    user_agent TEXT,                      -- User's browser/client
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Add helpful comments to tables
COMMENT ON TABLE public.users IS 'Core user information and profile data';
COMMENT ON TABLE public.permissions IS 'Available system permissions for access control';
COMMENT ON TABLE public.roles IS 'System roles with hierarchical types';
COMMENT ON TABLE public.user_roles IS 'Maps users to their assigned roles';
COMMENT ON TABLE public.role_permissions IS 'Maps roles to their granted permissions';
COMMENT ON TABLE public.user_phone_numbers IS 'User contact phone numbers with verification';
COMMENT ON TABLE public.user_addresses IS 'User physical addresses';
COMMENT ON TABLE public.audit_logs IS 'System-level change tracking';
COMMENT ON TABLE public.user_activities IS 'User action and behavior tracking';

-- Add necessary table for role delegations if not exists
CREATE TABLE IF NOT EXISTS public.role_delegations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delegator_id UUID NOT NULL REFERENCES public.users(id),
    delegate_id UUID NOT NULL REFERENCES public.users(id),
    role_types role_type[] NOT NULL,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES public.users(id),
    
    -- Constraints
    UNIQUE(delegator_id, delegate_id, deleted_at)
);

-- Add necessary table for scheduled tasks if not exists
CREATE TABLE IF NOT EXISTS public.scheduled_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_type TEXT NOT NULL,
    execute_at TIMESTAMPTZ NOT NULL,
    parameters JSONB NOT NULL,
    is_processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMPTZ,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES public.users(id)
);

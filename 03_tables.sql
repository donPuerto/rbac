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
--    - profiles                  : Core user profile information and preferences
--      * Basic user information (name, handle, avatar)
--      * Profile customization and settings
--      * Social features (followers, following)
--      * Profile verification and status
--
--    - user_security_settings    : Security and authentication configuration
--      * Two-factor authentication settings
--      * Security questions and recovery
--      * Login attempt tracking
--      * Session management
--
--    - user_preferences         : User-specific settings and preferences
--      * UI/UX preferences
--      * Notification settings
--      * Privacy settings
--      * Regional preferences
--
--    - user_onboarding         : Onboarding process tracking
--      * Onboarding step progress
--      * Terms and privacy acceptance
--      * Feature introduction tracking
--      * Welcome flow completion
--
-- 2. Entity Contact Tables
--    - entity_emails           : Email address management
--      * Multiple email support
--      * Primary email designation
--      * Email verification status
--      * Email type categorization
--
--    - entity_phones          : Phone number management
--      * Multiple phone numbers
--      * Primary phone designation
--      * Phone verification status
--      * Phone type categorization
--
--    - entity_addresses       : Address management
--      * Multiple addresses support
--      * Address type categorization
--      * Geocoding support
--      * Address verification
--
-- 3. RBAC (Role-Based Access Control)
--    - roles                  : Role definitions
--      * System and custom roles
--      * Role hierarchies
--      * Permission assignments
--      * Role status tracking
--
--    - permissions            : Permission definitions
--      * Granular access controls
--      * Permission categories
--      * System vs custom permissions
--      * Permission status tracking
--
--    - user_roles            : User-role assignments
--      * Role mapping to users
--      * Role assignment status
--      * Assignment metadata
--      * Temporal tracking
--
--    - role_permissions      : Role-permission mappings
--      * Permission assignments to roles
--      * Permission inheritance
--      * Assignment status tracking
--      * Assignment metadata
--
--    - role_delegations      : Temporary role assignments
--      * Time-bound delegations
--      * Delegation chain tracking
--      * Revocation management
--      * Delegation status tracking
--
-- 4. System Audit Tables
--    - audit_logs            : System-wide audit trailing
--      * Action tracking
--      * Change history
--      * User activity logs
--      * System event records
--
-- 5. CRM Core Tables
--    - crm_leads             : Lead management
--      * Lead details and history
--      * Relationship tracking
--      * Lead preferences
--      * Communication logs
--
--    - crm_contacts           : Customer and contact management
--      * Contact details and history
--      * Relationship tracking
--      * Contact preferences
--      * Communication logs
--
--    - crm_referrals        : Referral program management
--      * Referral source tracking
--      * Reward management
--      * Referral status
--      * Performance metrics
--
--    - crm_opportunities     : Sales opportunity tracking
--      * Pipeline stage tracking
--      * Deal value estimation
--      * Win/loss probability
--      * Opportunity history
--
--    - crm_quotes            : Quote management
--      * Quote generation
--      * Version control
--      * Approval workflow
--      * Quote templates
--
--    - crm_jobs             : Job and project tracking
--      * Project milestones
--      * Resource allocation
--      * Timeline management
--      * Deliverable tracking
--
--    - crm_products         : Product catalog
--      * Product details
--      * Pricing tiers
--      * Product categories
--      * Inventory linkage
--
--    - crm_pipelines        : Sales pipeline configuration
--      * Stage definitions
--      * Pipeline metrics
--      * Workflow automation
--      * Stage requirements
--
--    - crm_communications   : Communication history
--      * Email tracking
--      * Call logs
--      * Meeting notes
--      * Communication preferences
--
--    - crm_documents        : Document management
--      * File storage
--      * Version control
--      * Access permissions
--      * Document categories
--
--    - crm_relationships    : Relationship mapping
--      * Contact connections
--      * Organization hierarchy
--      * Relationship types
--      * Influence mapping
--
--    - crm_notes            : Note management
--      * Activity notes
--      * Follow-up reminders
--      * Note categorization
--      * Mention tracking
--
-- 6. Task Management Tables
--    - task_boards           : Project and task board management
--      * Board organization
--      * Access permissions
--      * Board templates
--      * Workflow settings
--
--    - task_lists           : Task list and column management
--      * List ordering
--      * List categories
--      * Status tracking
--      * List templates
--
--    - tasks                : Core task management
--      * Task details
--      * Priority levels
--      * Due dates
--      * Status workflow
--
--    - task_assignments     : Task assignment tracking
--      * User assignments
--      * Role assignments
--      * Assignment history
--      * Workload tracking
--
--    - task_dependencies    : Task dependency management
--      * Dependency types
--      * Blocking relationships
--      * Critical path tracking
--      * Dependency validation
--
--    - task_comments        : Task communication
--      * Comment threading
--      * Mention support
--      * Attachment links
--      * Edit history
--
--    - task_attachments     : Task file management
--      * File storage
--      * Version control
--      * Preview generation
--      * File organization
--
--    - task_labels          : Task categorization
--      * Label hierarchies
--      * Color coding
--      * Label grouping
--      * Usage tracking
--
--    - task_templates       : Reusable task templates
--      * Template categories
--      * Default assignments
--      * Checklist templates
--      * Automation rules
--
--    - task_time_entries    : Time tracking
--      * Time logging
--      * Duration tracking
--      * Billing integration
--      * Report generation
--
-- 7. Inventory Tables
--    - inventory_locations    : Storage and warehouse management
--      * Location details and hierarchy
--      * Storage capacity tracking
--      * Environmental conditions
--      * Access control settings
--
--    - inventory_items       : Item catalog and stock management
--      * SKU management
--      * Stock levels
--      * Reorder points
--      * Item categorization
--
--    - inventory_transactions : Stock movement tracking
--      * Inbound/outbound tracking
--      * Transfer management
--      * Batch/lot tracking
--      * Transaction history
--
--    - purchase_orders       : Purchase order management
--      * Vendor management
--      * Order tracking
--      * Approval workflow
--      * Delivery scheduling
--
--    - purchase_order_items  : Purchase order line items
--      * Item specifications
--      * Pricing details
--      * Quantity management
--      * Delivery status
--
-- 8. Accounting Integration Tables
--    - chart_of_accounts     : Account structure management
--      * Account hierarchy
--      * Account categories
--      * Balance tracking
--      * Fiscal year settings
--
--    - journal_entries       : Financial transaction records
--      * Entry categorization
--      * Multi-currency support
--      * Audit trail
--      * Reconciliation status
--
--    - journal_entry_lines   : Detailed transaction lines
--      * Debit/credit entries
--      * Cost center tracking
--      * Project allocation
--      * Tax handling
--
--    - payment_transactions  : Payment processing records
--      * Payment methods
--      * Transaction status
--      * Payment reconciliation
--      * Fee tracking
--
-- Note: Each table includes:
-- * Soft delete support (deleted_at, deleted_by)
-- * Version control (version field)
-- * Audit fields (created_at, updated_at, created_by, updated_by)
-- * Appropriate indexes and constraints
-- * Row-level security policies where applicable
-- * Proper grants and permissions
-- =====================================================================================

-- Core User Tables
-- =====================================================================================

-- Update Profiles Table
-- =====================================================================================
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    
    -- Basic Information
    handle TEXT UNIQUE CHECK (handle ~* '^[a-zA-Z0-9_]{3,50}$'),
    username TEXT CHECK (username ~* '^[a-zA-Z0-9\s]{2,50}$'),
    full_name TEXT,
    display_name TEXT,
    avatar_url TEXT,
    banner_url TEXT,
    
    -- Profile Details
    bio TEXT,
    tagline TEXT,
    website TEXT,
    birth_date DATE,
    gender public.gender_type,
    pronouns TEXT,
    
    -- Social Media
    social_links JSONB DEFAULT '{}'::jsonb,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    
    -- Profile Status
    is_verified BOOLEAN DEFAULT false,
    verification_level INTEGER DEFAULT 0,
    reputation_score INTEGER DEFAULT 0,
    trust_score INTEGER DEFAULT 0,
    
    -- Profile Customization
    theme_preference public.theme_type,
    language_preference TEXT DEFAULT 'en',
    timezone TEXT,
    
    -- Tags and Categories
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    interests TEXT[] DEFAULT ARRAY[]::TEXT[],
    skills TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    last_active_at TIMESTAMPTZ,
    profile_views INTEGER DEFAULT 0,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL,

    CONSTRAINT valid_handle CHECK (handle IS NOT NULL AND length(handle) >= 3),
    CONSTRAINT valid_counts CHECK (
        followers_count >= 0 AND 
        following_count >= 0 AND 
        profile_views >= 0
    )
);

-- Create indexes for profiles
CREATE UNIQUE INDEX idx_profiles_user_id ON public.profiles(user_id) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_profiles_handle ON public.profiles(handle) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_username ON public.profiles(username) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_verification ON public.profiles(is_verified, verification_level) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_last_active ON public.profiles(last_active_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_tags ON public.profiles USING gin(tags) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_interests ON public.profiles USING gin(interests) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_skills ON public.profiles USING gin(skills) WHERE deleted_at IS NULL;

-- Add RLS policies for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Grants for profiles
GRANT SELECT ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;

-- Add trigger for profiles
CREATE TRIGGER set_timestamp_profiles
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

-- User Preferences Table
-- =====================================================================================
-- Description: Stores user-specific settings and preferences
-- Dependencies: profiles
-- Notes: Manages user customization, notification, and display settings

-- Drop existing indexes
DROP INDEX IF EXISTS idx_user_preferences_user_id;
DROP INDEX IF EXISTS idx_user_preferences_theme;
DROP INDEX IF EXISTS idx_user_preferences_language;
DROP INDEX IF EXISTS idx_user_preferences_timezone;
DROP INDEX IF EXISTS idx_user_preferences_notifications;

-- Drop existing grants
REVOKE ALL ON public.user_preferences FROM authenticated;
REVOKE ALL ON public.user_preferences FROM service_role;

-- Create table
CREATE TABLE public.user_preferences (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Language and locale
    preferred_language TEXT DEFAULT 'en',
    timezone TEXT DEFAULT 'UTC',
    date_format date_format_type DEFAULT 'YYYY-MM-DD',
    time_format time_format_type DEFAULT '24h',
    number_format TEXT DEFAULT '#,##0.00',
    currency TEXT DEFAULT 'USD',
    
    -- Notification preferences
    email_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    push_notifications BOOLEAN DEFAULT true,
    in_app_notifications BOOLEAN DEFAULT true,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    notification_frequency TEXT DEFAULT 'instant',  -- instant, hourly, daily, weekly
    
    -- Email preferences
    weekly_digest BOOLEAN DEFAULT true,
    marketing_emails BOOLEAN DEFAULT true,
    security_alerts BOOLEAN DEFAULT true,
    product_updates BOOLEAN DEFAULT true,
    
    -- UI preferences
    theme public.theme_type DEFAULT 'system',
    sidebar_collapsed BOOLEAN DEFAULT false,
    display_density display_density_type DEFAULT 'comfortable',
    default_dashboard TEXT DEFAULT 'home',
    items_per_page INTEGER DEFAULT 25,
    enable_animations BOOLEAN DEFAULT true,
    high_contrast BOOLEAN DEFAULT false,
    font_size TEXT DEFAULT 'medium',         -- small, medium, large
    
    -- Privacy preferences
    profile_visibility TEXT DEFAULT 'public', -- public, private, contacts
    online_status_visible BOOLEAN DEFAULT true,
    activity_status_visible BOOLEAN DEFAULT true,
    share_data_for_improvement BOOLEAN DEFAULT true,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    CONSTRAINT unique_user_preferences UNIQUE(user_id, deleted_at),
    CONSTRAINT valid_items_per_page CHECK (items_per_page BETWEEN 10 AND 100),
    CONSTRAINT valid_quiet_hours CHECK (
        (quiet_hours_start IS NULL AND quiet_hours_end IS NULL) OR
        (quiet_hours_start IS NOT NULL AND quiet_hours_end IS NOT NULL)
    ),
    CONSTRAINT valid_notification_frequency CHECK (
        notification_frequency IN ('instant', 'hourly', 'daily', 'weekly')
    ),
    CONSTRAINT valid_font_size CHECK (
        font_size IN ('small', 'medium', 'large')
    ),
    CONSTRAINT valid_profile_visibility CHECK (
        profile_visibility IN ('public', 'private', 'contacts')
    )
);

-- Create indexes
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_theme ON public.user_preferences(theme) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_language ON public.user_preferences(preferred_language) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_timezone ON public.user_preferences(timezone) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_notifications ON public.user_preferences(email_notifications, push_notifications, sms_notifications) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_preferences_visibility ON public.user_preferences(profile_visibility) WHERE deleted_at IS NULL;

-- Create grants
GRANT SELECT ON public.user_preferences TO authenticated;
GRANT ALL ON public.user_preferences TO service_role;

-- Add table comments
COMMENT ON TABLE public.user_preferences IS 'Stores user-specific settings and preferences';
COMMENT ON COLUMN public.user_preferences.user_id IS 'References the profiles table';
COMMENT ON COLUMN public.user_preferences.preferred_language IS 'User preferred language code';
COMMENT ON COLUMN public.user_preferences.timezone IS 'User timezone for date/time display';
COMMENT ON COLUMN public.user_preferences.theme IS 'UI theme preference';
COMMENT ON COLUMN public.user_preferences.display_density IS 'UI density preference';
COMMENT ON COLUMN public.user_preferences.quiet_hours_start IS 'Start time for notification quiet hours';
COMMENT ON COLUMN public.user_preferences.quiet_hours_end IS 'End time for notification quiet hours';
COMMENT ON COLUMN public.user_preferences.notification_frequency IS 'How often to send grouped notifications';
COMMENT ON COLUMN public.user_preferences.profile_visibility IS 'Who can view the user profile';
COMMENT ON COLUMN public.user_preferences.version IS 'Version number for optimistic locking';

-- User Security Settings Table
-- =====================================================================================
-- Description: Manages security-related settings for user accounts
-- Dependencies: profiles (user_id)
-- Notes: Handles MFA, account locking, and security preferences

-- Drop existing indexes
DROP INDEX IF EXISTS idx_user_security_settings_user_id;
DROP INDEX IF EXISTS idx_user_security_settings_email_verified;
DROP INDEX IF EXISTS idx_user_security_settings_last_login;
DROP INDEX IF EXISTS idx_user_security_settings_failed_attempts;
DROP INDEX IF EXISTS idx_user_security_settings_locked_until;

-- Drop existing grants
REVOKE ALL ON public.user_security_settings FROM authenticated;
REVOKE ALL ON public.user_security_settings FROM service_role;

-- Create table
CREATE TABLE public.user_security_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    
    -- Security settings
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_method TEXT CHECK (two_factor_method IN ('app', 'sms', 'email')),
    recovery_email TEXT CHECK (recovery_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    recovery_phone TEXT CHECK (recovery_phone ~* '^\+[1-9]\d{1,14}$'),
    last_password_change TIMESTAMPTZ DEFAULT now(),
    password_expires_at TIMESTAMPTZ,
    password_history JSONB DEFAULT '[]'::jsonb,
    
    -- Session and security tracking
    last_login_at TIMESTAMPTZ,
    last_active_at TIMESTAMPTZ,
    failed_login_attempts INTEGER DEFAULT 0 CHECK (failed_login_attempts >= 0),
    locked_until TIMESTAMPTZ,
    last_security_audit TIMESTAMPTZ,
    security_questions JSONB,
    
    -- Device and location tracking
    trusted_devices JSONB DEFAULT '[]'::jsonb,
    known_ips JSONB DEFAULT '[]'::jsonb,
    last_ip_address INET,
    last_user_agent TEXT,
    
    -- Verification status
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    identity_verified BOOLEAN DEFAULT false,
    verification_documents JSONB DEFAULT '[]'::jsonb,
    
    -- Security preferences
    login_notification_enabled BOOLEAN DEFAULT true,
    suspicious_activity_notification BOOLEAN DEFAULT true,
    max_sessions INTEGER DEFAULT 5 CHECK (max_sessions BETWEEN 1 AND 10),
    session_timeout_minutes INTEGER DEFAULT 60 CHECK (session_timeout_minutes > 0),
    require_2fa_for_sensitive_ops BOOLEAN DEFAULT false,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL,
    
    -- Additional constraints
    CONSTRAINT valid_password_expiry CHECK (password_expires_at > last_password_change),
    CONSTRAINT valid_lock_period CHECK (locked_until > now() OR locked_until IS NULL),
    CONSTRAINT valid_2fa_config CHECK (
        (two_factor_enabled = false) OR 
        (two_factor_enabled = true AND two_factor_method IS NOT NULL)
    )
);

-- Indexes for user_security_settings
CREATE UNIQUE INDEX idx_user_security_settings_user_id ON public.user_security_settings(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_email_verified ON public.user_security_settings(email_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_last_login ON public.user_security_settings(last_login_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_failed_attempts ON public.user_security_settings(failed_login_attempts) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_locked_until ON public.user_security_settings(locked_until) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_last_active ON public.user_security_settings(last_active_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_security_settings_verification ON public.user_security_settings(email_verified, phone_verified, identity_verified) WHERE deleted_at IS NULL;

-- Grants for user_security_settings
GRANT SELECT ON public.user_security_settings TO authenticated;
GRANT ALL ON public.user_security_settings TO service_role;

-- Trigger for updating timestamp
CREATE TRIGGER set_timestamp
    BEFORE UPDATE ON public.user_security_settings
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

-- User Onboarding table: Tracks the user's journey through the onboarding process
-- =====================================================================================
CREATE TABLE public.user_onboarding (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    
    -- Onboarding progress tracking
    onboarding_completed BOOLEAN DEFAULT false,
    onboarding_step INTEGER DEFAULT 1 CHECK (onboarding_step BETWEEN 1 AND 10),
    current_step_started_at TIMESTAMPTZ,
    onboarding_started_at TIMESTAMPTZ,
    onboarding_completed_at TIMESTAMPTZ,
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage BETWEEN 0 AND 100),
    
    -- Step completion status
    profile_completed BOOLEAN DEFAULT false,
    preferences_set BOOLEAN DEFAULT false,
    security_configured BOOLEAN DEFAULT false,
    email_verified BOOLEAN DEFAULT false,
    interests_selected BOOLEAN DEFAULT false,
    avatar_uploaded BOOLEAN DEFAULT false,
    
    -- Consent and legal tracking
    terms_accepted BOOLEAN DEFAULT false,
    terms_accepted_at TIMESTAMPTZ,
    terms_version TEXT NOT NULL DEFAULT '1.0',
    terms_accepted_ip INET,
    privacy_accepted BOOLEAN DEFAULT false,
    privacy_accepted_at TIMESTAMPTZ,
    privacy_version TEXT NOT NULL DEFAULT '1.0',
    privacy_accepted_ip INET,
    
    -- Marketing and communications
    marketing_consent BOOLEAN DEFAULT false,
    marketing_consent_at TIMESTAMPTZ,
    marketing_preferences JSONB DEFAULT '{"email": false, "sms": false, "push": false}'::jsonb,
    communication_language TEXT DEFAULT 'en',
    
    -- Additional tracking
    device_info JSONB,
    referral_source TEXT,
    utm_parameters JSONB,
    onboarding_platform TEXT CHECK (onboarding_platform IN ('web', 'ios', 'android', 'desktop')),
    last_active_step INTEGER,
    step_history JSONB DEFAULT '[]'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    CONSTRAINT unique_user_onboarding UNIQUE(user_id, deleted_at),
    CONSTRAINT valid_completion_time CHECK (
        (onboarding_completed = false) OR 
        (onboarding_completed = true AND onboarding_completed_at IS NOT NULL AND onboarding_completed_at > onboarding_started_at)
    ),
    CONSTRAINT valid_terms_acceptance CHECK (
        (terms_accepted = false) OR 
        (terms_accepted = true AND terms_accepted_at IS NOT NULL)
    ),
    CONSTRAINT valid_privacy_acceptance CHECK (
        (privacy_accepted = false) OR 
        (privacy_accepted = true AND privacy_accepted_at IS NOT NULL)
    )
);

-- Indexes for user_onboarding
CREATE UNIQUE INDEX idx_user_onboarding_user_id ON public.user_onboarding(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_completion ON public.user_onboarding(onboarding_completed, completion_percentage) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_step ON public.user_onboarding(onboarding_step, last_active_step) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_consent ON public.user_onboarding(terms_accepted, privacy_accepted, marketing_consent) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_platform ON public.user_onboarding(onboarding_platform) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_onboarding_verification ON public.user_onboarding(email_verified) WHERE deleted_at IS NULL;

-- Add table comments
COMMENT ON TABLE public.user_onboarding IS 'Tracks user onboarding progress, consent management, and completion status';
COMMENT ON COLUMN public.user_onboarding.completion_percentage IS 'Overall completion percentage of the onboarding process';
COMMENT ON COLUMN public.user_onboarding.step_history IS 'JSON array tracking timestamps and duration of each step completion';
COMMENT ON COLUMN public.user_onboarding.marketing_preferences IS 'Detailed marketing preferences by channel';
COMMENT ON COLUMN public.user_onboarding.device_info IS 'Information about the device used during onboarding';

-- Grants for user_onboarding
GRANT SELECT ON public.user_onboarding TO authenticated;
GRANT ALL ON public.user_onboarding TO service_role;

-- Trigger for updating timestamp
CREATE TRIGGER set_timestamp
    BEFORE UPDATE ON public.user_onboarding
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

-- Entity Contact Tables
-- =====================================================================================

-- Entity Email Table
CREATE TABLE public.entity_emails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    email TEXT NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verification_token TEXT,
    token_expires_at TIMESTAMPTZ,
    type TEXT CHECK (type IN ('personal', 'work', 'other')),
    label TEXT,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL,

    CONSTRAINT unique_primary_email UNIQUE (user_id, is_primary) WHERE is_primary = true AND deleted_at IS NULL,
    CONSTRAINT unique_email UNIQUE (email, deleted_at)
);

-- Entity Phone Table
CREATE TABLE public.entity_phones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    phone_number TEXT NOT NULL CHECK (phone_number ~* '^\+[1-9]\d{1,14}$'),
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verification_code TEXT,
    code_expires_at TIMESTAMPTZ,
    type public.phone_type,
    label TEXT,
    country_code TEXT,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL,

    CONSTRAINT unique_primary_phone UNIQUE (user_id, is_primary) WHERE is_primary = true AND deleted_at IS NULL,
    CONSTRAINT unique_phone UNIQUE (phone_number, deleted_at)
);

-- Entity Address Table
CREATE TABLE public.entity_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    is_primary BOOLEAN DEFAULT false,
    type public.address_type,
    label TEXT,
    
    -- Address fields
    street_address TEXT NOT NULL,
    street_address2 TEXT,
    city TEXT NOT NULL,
    state TEXT,
    postal_code TEXT,
    country TEXT NOT NULL,
    
    -- Additional fields
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    delivery_instructions TEXT,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL,

    CONSTRAINT unique_primary_address UNIQUE (user_id, is_primary) WHERE is_primary = true AND deleted_at IS NULL,
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR 
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
);

-- Create indexes for entity tables
CREATE INDEX idx_entity_emails_user ON public.entity_emails(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_emails_verified ON public.entity_emails(is_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_phones_user ON public.entity_phones(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_phones_verified ON public.entity_phones(is_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_addresses_user ON public.entity_addresses(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_addresses_location ON public.entity_addresses USING gist (ll_to_earth(latitude, longitude)) WHERE deleted_at IS NULL;

-- Add RLS policies for entity tables
ALTER TABLE public.entity_emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_phones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_addresses ENABLE ROW LEVEL SECURITY;

-- Grants for entity tables
GRANT SELECT ON public.entity_emails TO authenticated;
GRANT SELECT ON public.entity_phones TO authenticated;
GRANT SELECT ON public.entity_addresses TO authenticated;
GRANT ALL ON public.entity_emails TO service_role;
GRANT ALL ON public.entity_phones TO service_role;
GRANT ALL ON public.entity_addresses TO service_role;

-- Add triggers for entity tables
CREATE TRIGGER set_timestamp_emails
    BEFORE UPDATE ON public.entity_emails
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_phones
    BEFORE UPDATE ON public.entity_phones
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_addresses
    BEFORE UPDATE ON public.entity_addresses
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

-- RBAC (Role-Based Access Control) Tables
-- =====================================================================================

-- Roles table: Defines the available roles in the system
-- =====================================================================================
CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL DEFAULT 'custom',
    is_system BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    permissions TEXT[] DEFAULT ARRAY[]::TEXT[],
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
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
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
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
    user_id UUID NOT NULL,
    role_id UUID NOT NULL REFERENCES public.roles(id),
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
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
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
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

-- Role Delegations table: Tracks temporary role assignments and delegations
-- =====================================================================================
CREATE TABLE public.role_delegations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Delegation details
    delegator_id UUID NOT NULL,
    delegate_id UUID NOT NULL,
    role_id UUID NOT NULL REFERENCES public.roles(id),
    
    -- Time bounds
    starts_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ends_at TIMESTAMPTZ,                                       -- NULL means indefinite
    
    -- Status
    status TEXT NOT NULL DEFAULT 'active',  -- active, expired, revoked
    is_active BOOLEAN DEFAULT true,
    revoked_at TIMESTAMPTZ,
    revoked_by UUID,
    revocation_reason TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL,
    
    -- Constraints
    CONSTRAINT valid_delegation_period CHECK (ends_at IS NULL OR ends_at > starts_at),
    CONSTRAINT no_self_delegation CHECK (delegator_id != delegate_id)
);

-- Indexes for role_delegations
CREATE INDEX idx_role_delegations_delegator ON public.role_delegations(delegator_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_delegate ON public.role_delegations(delegate_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_role ON public.role_delegations(role_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_status ON public.role_delegations(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_active ON public.role_delegations(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_dates ON public.role_delegations(starts_at, ends_at) WHERE deleted_at IS NULL;

-- Grants for role_delegations
GRANT SELECT ON public.role_delegations TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.role_delegations TO service_role;

COMMENT ON TABLE public.role_delegations IS 'Tracks temporary role assignments and delegations between users';

-- CRM Core Tables
-- =====================================================================================

-- CRM Contacts table: Contact information management
CREATE TABLE public.crm_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic Information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(255) GENERATED ALWAYS AS (
        CASE 
            WHEN first_name IS NULL AND last_name IS NULL THEN NULL
            WHEN first_name IS NULL THEN last_name
            WHEN last_name IS NULL THEN first_name
            ELSE first_name || ' ' || last_name
        END
    ) STORED,
    
    -- Business Information
    company_name VARCHAR(255),
    job_title VARCHAR(100),
    department VARCHAR(100),
    industry VARCHAR(100),
    
    -- Classification
    customer_type public.customer_type NOT NULL DEFAULT 'prospect',
    customer_status public.customer_status NOT NULL DEFAULT 'active',
    lead_source VARCHAR(50),
    
    -- Relationship Management
    assigned_to UUID REFERENCES auth.users(id),
    account_manager UUID REFERENCES auth.users(id),
    
    -- Preferences
    preferred_contact_method public.contact_method,
    preferred_contact_time VARCHAR(50),
    communication_frequency VARCHAR(50),
    
    -- Important Dates
    date_of_birth DATE,
    anniversary_date DATE,
    first_contact_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_contact_date TIMESTAMPTZ,
    next_follow_up_date TIMESTAMPTZ,
    
    -- Social Media
    linkedin_url VARCHAR(255),
    twitter_handle VARCHAR(100),
    facebook_url VARCHAR(255),
    
    -- Additional Information
    tags TEXT[],
    notes TEXT,
    
    -- Standard tracking fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

-- CRM Leads table: Potential customers or business opportunities
CREATE TABLE public.crm_leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name TEXT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    source TEXT,
    status public.lead_status DEFAULT 'new' NOT NULL,
    notes TEXT,
    assigned_to UUID,
    contact_id UUID, -- Set when converted to contact
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- CRM Opportunities table: Potential deals or sales
CREATE TABLE public.crm_opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    status public.opportunity_status DEFAULT 'new' NOT NULL,
    value DECIMAL(15,2),
    currency TEXT DEFAULT 'USD',
    probability INTEGER CHECK (probability >= 0 AND probability <= 100),
    expected_close_date DATE,
    actual_close_date DATE,
    assigned_to UUID,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- CRM Quotes table: Price quotes for opportunities
CREATE TABLE public.crm_quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID,
    contact_id UUID NOT NULL,
    quote_number TEXT NOT NULL UNIQUE,
    status public.quote_status DEFAULT 'draft' NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    valid_until DATE,
    notes TEXT,
    terms_and_conditions TEXT,
    line_items JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- CRM Jobs table: Scheduled work or services
CREATE TABLE public.crm_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_number TEXT NOT NULL UNIQUE,
    contact_id UUID NOT NULL,
    opportunity_id UUID,
    quote_id UUID,
    title TEXT NOT NULL,
    description TEXT,
    status public.job_status DEFAULT 'scheduled' NOT NULL,
    priority public.job_priority DEFAULT 'medium' NOT NULL,
    scheduled_start TIMESTAMPTZ NOT NULL,
    scheduled_end TIMESTAMPTZ NOT NULL,
    actual_start TIMESTAMPTZ,
    actual_end TIMESTAMPTZ,
    location JSONB,
    assigned_to UUID,
    team_members UUID[] DEFAULT ARRAY[]::UUID[],
    
    -- Equipment and Supplies
    equipment_needed TEXT[],
    estimated_cost DECIMAL(15,2),
    actual_cost DECIMAL(15,2),
    
    -- Notes and Comments
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    CONSTRAINT valid_schedule CHECK (scheduled_end > scheduled_start),
    CONSTRAINT valid_actual_time CHECK (
        (actual_end IS NULL) OR 
        (actual_start IS NOT NULL AND actual_end > actual_start)
    )
);

-- CRM Referrals table: Tracks customer referrals and referral program management
CREATE TABLE public.crm_referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Referrer information (who made the referral)
    referrer_id UUID REFERENCES public.crm_contacts(id),
    referrer_type VARCHAR(50), -- Could be 'customer', 'partner', 'employee', etc.
    
    -- Referred person/lead information
    referred_name VARCHAR(255) NOT NULL,
    referred_email VARCHAR(255),
    referred_phone VARCHAR(50),
    referred_notes TEXT,
    
    -- Referral details
    status public.referral_status_type NOT NULL DEFAULT 'pending',
    referral_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Tracking
    contact_id UUID REFERENCES public.crm_contacts(id), -- If converted to contact
    lead_id UUID REFERENCES public.crm_leads(id),       -- If converted to lead
    
    -- Incentive program
    incentive_type VARCHAR(50),    -- Type of referral incentive offered
    incentive_status VARCHAR(50),  -- Status of the incentive (pending, paid, etc.)
    incentive_amount DECIMAL(10,2), -- Amount if monetary incentive
    incentive_notes TEXT,
    
    -- Standard tracking fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

-- CRM Products table: Catalog of offerings
CREATE TABLE public.crm_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE,
    category public.product_category NOT NULL,
    description TEXT,
    price DECIMAL(15,2),
    currency TEXT DEFAULT 'USD',
    unit TEXT,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- CRM Pipelines table: Define different sales processes
CREATE TABLE public.crm_pipelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    stages JSONB NOT NULL, -- Array of stage configurations
    is_default BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- CRM Communications table: Track all communications
CREATE TABLE public.crm_communications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    channel public.communication_channel NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('inbound', 'outbound')),
    subject TEXT,
    content TEXT,
    status TEXT NOT NULL CHECK (status IN ('draft', 'sent', 'delivered', 'failed')),
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- CRM Documents table: Store and manage CRM-related documents
CREATE TABLE public.crm_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category public.document_category NOT NULL,
    file_path TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    version INTEGER DEFAULT 1,
    status TEXT NOT NULL CHECK (status IN ('draft', 'final', 'archived')),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- CRM Relationships table: Track relationships between CRM entities
CREATE TABLE public.crm_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_entity_type TEXT NOT NULL,
    from_entity_id UUID NOT NULL,
    to_entity_type TEXT NOT NULL,
    to_entity_id UUID NOT NULL,
    relationship_type TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    CONSTRAINT unique_relationship UNIQUE (from_entity_type, from_entity_id, to_entity_type, to_entity_id, relationship_type)
);

-- CRM Notes table: Universal notes for any CRM entity
CREATE TABLE public.crm_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    title TEXT,
    content TEXT NOT NULL,
    is_private BOOLEAN DEFAULT false,
    pinned BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- Task Management Tables
-- =====================================================================================

-- Task Boards table: Project and task board management
CREATE TABLE public.task_boards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES auth.users(id),
    board_type public.board_type NOT NULL,
    settings JSONB DEFAULT '{}'::jsonb,
    is_template BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Task Lists table: Lists/columns within boards
CREATE TABLE public.task_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    board_id UUID NOT NULL REFERENCES public.task_boards(id),
    name TEXT NOT NULL,
    description TEXT,
    position INTEGER NOT NULL,
    list_type public.list_type NOT NULL,
    settings JSONB DEFAULT '{}'::jsonb,
    is_archived BOOLEAN DEFAULT false,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Tasks table: Core task information
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES public.task_lists(id),
    title TEXT NOT NULL,
    description TEXT,
    position INTEGER NOT NULL,
    due_date TIMESTAMPTZ,
    start_date TIMESTAMPTZ,
    priority public.task_priority,
    status public.task_status NOT NULL,
    estimated_hours DECIMAL(10,2),
    actual_hours DECIMAL(10,2),
    completion_percentage INTEGER DEFAULT 0,
    is_archived BOOLEAN DEFAULT false,
    
    -- Task metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Task Assignments table: Task assignments to users
CREATE TABLE public.task_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES public.tasks(id),
    assignee_id UUID NOT NULL REFERENCES auth.users(id),
    role TEXT,
    assigned_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    status TEXT NOT NULL,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Task Dependencies table: Dependencies between tasks
CREATE TABLE public.task_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    predecessor_id UUID NOT NULL REFERENCES public.tasks(id),
    successor_id UUID NOT NULL REFERENCES public.tasks(id),
    dependency_type TEXT NOT NULL,
    lag_time INTEGER DEFAULT 0,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Task Comments table: Comments on tasks
CREATE TABLE public.task_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES public.tasks(id),
    parent_id UUID REFERENCES public.task_comments(id),
    comment_text TEXT NOT NULL,
    mentions JSONB DEFAULT '[]'::jsonb,
    is_edited BOOLEAN DEFAULT false,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Task Attachments table: Files attached to tasks
CREATE TABLE public.task_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES public.tasks(id),
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    file_url TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    thumbnail_url TEXT,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Task Labels table: Labels/tags for tasks
CREATE TABLE public.task_labels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    name TEXT NOT NULL,
    color TEXT NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES public.task_labels(id),
    usage_count INTEGER DEFAULT 0,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Task Templates table: Reusable task templates
CREATE TABLE public.task_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    template_type TEXT NOT NULL,
    template_data JSONB NOT NULL,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Task Time Entries table: Time tracking for tasks
CREATE TABLE public.task_time_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES public.tasks(id),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    duration INTEGER, -- in seconds
    description TEXT,
    is_billable BOOLEAN DEFAULT false,
    billing_rate DECIMAL(10,2),
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Create indexes for task management tables
CREATE INDEX idx_task_boards_workspace ON public.task_boards(workspace_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_lists_board ON public.task_lists(board_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_list ON public.tasks(list_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_assignments_task ON public.task_assignments(task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_assignments_user ON public.task_assignments(assignee_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_dependencies_pred ON public.task_dependencies(predecessor_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_dependencies_succ ON public.task_dependencies(successor_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_comments_task ON public.task_comments(task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_attachments_task ON public.task_attachments(task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_labels_workspace ON public.task_labels(workspace_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_time_entries_task ON public.task_time_entries(task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_time_entries_user ON public.task_time_entries(user_id) WHERE deleted_at IS NULL;

-- Add RLS policies for task management tables
ALTER TABLE public.task_boards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_dependencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_labels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_time_entries ENABLE ROW LEVEL SECURITY;

-- Grants for task management tables
GRANT SELECT ON public.task_boards TO authenticated;
GRANT SELECT ON public.task_lists TO authenticated;
GRANT SELECT ON public.tasks TO authenticated;
GRANT SELECT ON public.task_assignments TO authenticated;
GRANT SELECT ON public.task_dependencies TO authenticated;
GRANT SELECT ON public.task_comments TO authenticated;
GRANT SELECT ON public.task_attachments TO authenticated;
GRANT SELECT ON public.task_labels TO authenticated;
GRANT SELECT ON public.task_templates TO authenticated;
GRANT SELECT ON public.task_time_entries TO authenticated;

GRANT ALL ON public.task_boards TO service_role;
GRANT ALL ON public.task_lists TO service_role;
GRANT ALL ON public.tasks TO service_role;
GRANT ALL ON public.task_assignments TO service_role;
GRANT ALL ON public.task_dependencies TO service_role;
GRANT ALL ON public.task_comments TO service_role;
GRANT ALL ON public.task_attachments TO service_role;
GRANT ALL ON public.task_labels TO service_role;
GRANT ALL ON public.task_templates TO service_role;
GRANT ALL ON public.task_time_entries TO service_role;

-- System Audit Tables
-- =====================================================================================

-- Audit Logs table: System change tracking
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,       -- Which table was affected
    record_id UUID NOT NULL,        -- ID of the changed record
    action TEXT NOT NULL,           -- INSERT, UPDATE, DELETE
    old_data JSONB,                -- Previous state (for updates/deletes)
    new_data JSONB,                -- New state (for inserts/updates)
    changed_fields TEXT[],         -- Array of changed field names
    performed_by UUID NOT NULL,
    performed_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    reason TEXT,                   -- Optional reason for change
    ip_address TEXT,               -- IP address of the user
    application_context JSONB,      -- Additional application context
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Indexes for audit_logs - Optimized for common queries
CREATE INDEX idx_audit_logs_table_record ON public.audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_performed_by ON public.audit_logs(performed_by);
CREATE INDEX idx_audit_logs_performed_at ON public.audit_logs(performed_at);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX idx_audit_logs_changed_fields ON public.audit_logs USING gin(changed_fields);
CREATE INDEX idx_audit_logs_data ON public.audit_logs USING gin(old_data jsonb_path_ops, new_data jsonb_path_ops);

-- Error Logs table: Critical backend system errors and exceptions
CREATE TABLE public.error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    severity public.error_severity_type NOT NULL,
    component TEXT NOT NULL,      -- Which system component generated the error
    error_code TEXT,             -- Specific error code if applicable
    message TEXT NOT NULL,        -- Error message
    stack_trace TEXT,            -- Stack trace for backend errors
    metadata JSONB,              -- Additional context
    user_id UUID,                -- User affected if applicable
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Indexes for error_logs
CREATE INDEX idx_error_logs_severity ON public.error_logs(severity);
CREATE INDEX idx_error_logs_component ON public.error_logs(component);
CREATE INDEX idx_error_logs_created_at ON public.error_logs(created_at);
CREATE INDEX idx_error_logs_user_id ON public.error_logs(user_id);
CREATE INDEX idx_error_logs_error_code ON public.error_logs(error_code) WHERE error_code IS NOT NULL;

-- User Activities table: User interaction tracking
CREATE TABLE public.user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    activity_type TEXT NOT NULL,    -- Login, Logout, Create, Update, Delete, etc.
    entity_type TEXT NOT NULL,      -- Which type of record was affected (e.g., 'contact', 'opportunity')
    entity_id UUID,                 -- ID of the affected record
    description TEXT NOT NULL,      -- Human-readable description
    metadata JSONB,                 -- Additional context (e.g., changes made, filters used)
    ip_address TEXT,                -- User's IP address
    user_agent TEXT,                -- Browser/client information
    session_id TEXT,                -- To group activities in the same session
    location JSONB,                 -- Geo-location data if available
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    version INTEGER DEFAULT 1 NOT NULL
);

-- Indexes for user_activities
CREATE INDEX idx_user_activities_user_id ON public.user_activities(user_id);
CREATE INDEX idx_user_activities_created_at ON public.user_activities(created_at);
CREATE INDEX idx_user_activities_entity ON public.user_activities(entity_type, entity_id);
CREATE INDEX idx_user_activities_type ON public.user_activities(activity_type);
CREATE INDEX idx_user_activities_session ON public.user_activities(session_id) WHERE session_id IS NOT NULL;
CREATE INDEX idx_user_activities_metadata ON public.user_activities USING gin(metadata jsonb_path_ops);
CREATE INDEX idx_user_activities_ip ON public.user_activities(ip_address) WHERE ip_address IS NOT NULL;

-- Enable RLS for audit tables
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.error_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;

-- Grants for audit tables
GRANT SELECT ON public.audit_logs TO authenticated;
GRANT SELECT ON public.error_logs TO authenticated;
GRANT SELECT ON public.user_activities TO authenticated;

GRANT ALL ON public.audit_logs TO service_role;
GRANT ALL ON public.error_logs TO service_role;
GRANT ALL ON public.user_activities TO service_role;

-- Inventory Tables
-- =====================================================================================

-- Inventory Locations table: Physical locations for inventory
CREATE TABLE public.inventory_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE,
    type public.inventory_location_type NOT NULL,
    address JSONB,
    contact_info JSONB,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
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
    last_counted_by UUID,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    CONSTRAINT unique_product_location UNIQUE (product_id, location_id)
);

-- Inventory Transactions table: Track all inventory movements
CREATE TABLE public.inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_type public.inventory_transaction_type NOT NULL,
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
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- Purchase Orders table
CREATE TABLE public.purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_number TEXT UNIQUE NOT NULL,
    supplier_id UUID NOT NULL,
    status public.purchase_order_status DEFAULT 'draft' NOT NULL,
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
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
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
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- Accounting Integration Tables
-- =====================================================================================

-- Chart of Accounts table
CREATE TABLE public.chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    account_type public.account_type NOT NULL,
    parent_account_id UUID REFERENCES public.chart_of_accounts(id),
    is_active BOOLEAN DEFAULT true,
    external_id TEXT, -- For third-party integration
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
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
    posted_by UUID,
    external_id TEXT, -- For third-party integration
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
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
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
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
    payment_method public.payment_method NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    status public.payment_status DEFAULT 'pending' NOT NULL,
    reference_type TEXT, -- 'invoice', 'purchase_order', etc.
    reference_id UUID,
    payment_details JSONB, -- Store payment gateway details
    external_id TEXT, -- For third-party integration
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

-- Update table definitions to use enums
ALTER TABLE public.profiles 
    ALTER COLUMN gender TYPE public.gender_type USING gender::public.gender_type,
    ALTER COLUMN theme_preference TYPE public.theme_type USING theme_preference::public.theme_type;

ALTER TABLE public.entity_phones
    ALTER COLUMN type TYPE public.phone_type USING type::public.phone_type;

ALTER TABLE public.entity_addresses
    ALTER COLUMN type TYPE public.address_type USING type::public.address_type;

ALTER TABLE public.crm_leads
    ALTER COLUMN status TYPE public.lead_status USING status::public.lead_status;

ALTER TABLE public.crm_opportunities
    ALTER COLUMN status TYPE public.opportunity_status USING status::public.opportunity_status;

ALTER TABLE public.crm_quotes
    ALTER COLUMN status TYPE public.quote_status USING status::public.quote_status;

ALTER TABLE public.crm_jobs
    ALTER COLUMN status TYPE public.job_status USING status::public.job_status,
    ALTER COLUMN priority TYPE public.job_priority USING priority::public.job_priority;

ALTER TABLE public.crm_products
    ALTER COLUMN category TYPE public.product_category USING category::public.product_category;

ALTER TABLE public.crm_communications
    ALTER COLUMN channel TYPE public.communication_channel USING channel::public.communication_channel;

ALTER TABLE public.crm_documents
    ALTER COLUMN category TYPE public.document_category USING category::public.document_category;

ALTER TABLE public.task_boards
    ALTER COLUMN board_type TYPE public.board_type USING board_type::public.board_type;

ALTER TABLE public.task_lists
    ALTER COLUMN list_type TYPE public.list_type USING list_type::public.list_type;

ALTER TABLE public.tasks
    ALTER COLUMN status TYPE public.task_status USING status::public.task_status,
    ALTER COLUMN priority TYPE public.task_priority USING priority::public.task_priority;

ALTER TABLE public.inventory_locations
    ALTER COLUMN type TYPE public.inventory_location_type USING type::public.inventory_location_type;

ALTER TABLE public.inventory_transactions
    ALTER COLUMN transaction_type TYPE public.inventory_transaction_type USING transaction_type::public.inventory_transaction_type;

ALTER TABLE public.purchase_orders
    ALTER COLUMN status TYPE public.purchase_order_status USING status::public.purchase_order_status;

ALTER TABLE public.payment_transactions
    ALTER COLUMN payment_method TYPE public.payment_method USING payment_method::public.payment_method,
    ALTER COLUMN status TYPE public.payment_status USING status::public.payment_status;

ALTER TABLE public.chart_of_accounts
    ALTER COLUMN account_type TYPE public.account_type USING account_type::public.account_type;

ALTER TABLE public.journal_entries
    ALTER COLUMN entry_type TYPE public.journal_entry_type USING entry_type::public.journal_entry_type;

ALTER TABLE public.error_logs
    ALTER COLUMN severity TYPE public.error_severity_type USING severity::public.error_severity_type;

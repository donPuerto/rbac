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
-- Description: Core user management tables including profiles, preferences, security
--             settings, and onboarding tracking
-- Version: 1.0.0
-- Last Updated: 2024-12-20
-- Dependencies:
--   - auth.users: For user authentication
--   - public.gender_type: Gender options enum
--   - public.date_format_type: Date format enum
--   - public.time_format_type: Time format enum
--   - public.display_density_type: UI density enum
--   - public.theme_type: UI theme enum
--   - public.two_factor_method_type: 2FA methods enum
--   - public.onboarding_platform_type: Onboarding platform enum
--   - public.communication_language_type: Communication language enum
-- Notes:
--   - Central user information storage with social and verification features
--   - Manages user preferences and security settings
--   - Tracks onboarding progress and consent management
--   - Optimized for Supabase and NuxtJS integration
-- =====================================================================================

-- Drop existing tables and dependencies
DROP TRIGGER IF EXISTS audit_profiles ON public.profiles;
DROP TRIGGER IF EXISTS audit_user_preferences ON public.user_preferences;
DROP TRIGGER IF EXISTS audit_user_security_settings ON public.user_security_settings;
DROP TRIGGER IF EXISTS audit_user_onboarding ON public.user_onboarding;

DROP TRIGGER IF EXISTS soft_delete_profiles ON public.profiles;
DROP TRIGGER IF EXISTS soft_delete_user_preferences ON public.user_preferences;
DROP TRIGGER IF EXISTS soft_delete_user_security_settings ON public.user_security_settings;
DROP TRIGGER IF EXISTS soft_delete_user_onboarding ON public.user_onboarding;

DROP FUNCTION IF EXISTS public.handle_audit_fields() CASCADE;
DROP FUNCTION IF EXISTS public.handle_soft_delete() CASCADE;

DROP INDEX IF EXISTS idx_profiles_user_id;
DROP INDEX IF EXISTS idx_profiles_handle;
DROP INDEX IF EXISTS idx_profiles_username;
DROP INDEX IF EXISTS idx_profiles_search_vector;
DROP INDEX IF EXISTS idx_profiles_created_at;
DROP INDEX IF EXISTS idx_profiles_updated_at;
DROP INDEX IF EXISTS idx_profiles_deleted_at;

DROP INDEX IF EXISTS idx_user_preferences_user_id;
DROP INDEX IF EXISTS idx_user_preferences_created_at;
DROP INDEX IF EXISTS idx_user_preferences_updated_at;
DROP INDEX IF EXISTS idx_user_preferences_deleted_at;

DROP INDEX IF EXISTS idx_user_security_settings_user_id;
DROP INDEX IF EXISTS idx_user_security_settings_last_login;
DROP INDEX IF EXISTS idx_user_security_settings_last_active;
DROP INDEX IF EXISTS idx_user_security_settings_created_at;
DROP INDEX IF EXISTS idx_user_security_settings_updated_at;
DROP INDEX IF EXISTS idx_user_security_settings_deleted_at;

DROP INDEX IF EXISTS idx_user_onboarding_user_id;
DROP INDEX IF EXISTS idx_user_onboarding_completed;
DROP INDEX IF EXISTS idx_user_onboarding_created_at;
DROP INDEX IF EXISTS idx_user_onboarding_updated_at;
DROP INDEX IF EXISTS idx_user_onboarding_deleted_at;

DROP TABLE IF EXISTS public.user_onboarding CASCADE;
DROP TABLE IF EXISTS public.user_security_settings CASCADE;
DROP TABLE IF EXISTS public.user_preferences CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- =====================================================================================
-- Profiles Table
-- =====================================================================================
-- Description: Stores essential user profile data and public information
-- Dependencies: 
--   - auth.users (for user authentication)
--   - public.gender_type (enum for gender options)
-- Notes: 
--   - Central user information storage with social and verification features
--   - Optimized for Supabase and NuxtJS integration
--   - Includes social features and verification system
--   - Uses JSONB for flexible metadata storage
--   - Implements full-text search capabilities
--   - Supports soft deletion and versioning
-- =====================================================================================

CREATE TABLE public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Basic Information
    handle TEXT UNIQUE CHECK (handle ~* '^[a-zA-Z0-9_]{3,50}$'),
    username TEXT CHECK (username ~* '^[a-zA-Z0-9\s]{2,50}$'),
    full_name TEXT,
    display_name TEXT,
    avatar_url TEXT CHECK (avatar_url IS NULL OR avatar_url ~* '^https?://'),
    banner_url TEXT CHECK (banner_url IS NULL OR banner_url ~* '^https?://'),
    
    -- Profile Details
    bio TEXT CHECK (char_length(bio) <= 500),
    tagline TEXT CHECK (char_length(tagline) <= 160),
    website TEXT CHECK (website IS NULL OR website ~* '^https?://'),
    birth_date DATE CHECK (birth_date <= CURRENT_DATE),
    gender public.gender_type DEFAULT 'prefer_not_to_say',
    pronouns TEXT CHECK (char_length(pronouns) <= 50),
    
    -- Location Information
    country TEXT,
    city TEXT,
    timezone TEXT DEFAULT 'UTC',
    
    -- Status and Metrics
    is_verified BOOLEAN DEFAULT false,
    verification_level INTEGER DEFAULT 0,
    reputation_score INTEGER DEFAULT 0 CHECK (reputation_score >= 0),
    trust_score INTEGER DEFAULT 0 CHECK (trust_score >= 0),
    followers_count INTEGER DEFAULT 0 CHECK (followers_count >= 0),
    following_count INTEGER DEFAULT 0 CHECK (following_count >= 0),
    profile_views INTEGER DEFAULT 0 CHECK (profile_views >= 0),
    last_active_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Social Links
    social_links JSONB DEFAULT '{
        "twitter": null,
        "facebook": null,
        "linkedin": null,
        "github": null,
        "instagram": null
    }'::jsonb,
    
    -- Extended Data
    metadata JSONB DEFAULT jsonb_build_object(
        'interests', '[]'::jsonb,
        'skills', '[]'::jsonb,
        'languages', '[]'::jsonb,
        'achievements', '[]'::jsonb,
        'preferences', '{}'::jsonb,
        'notifications', '{
            "email": true,
            "push": true,
            "marketing": false
        }'::jsonb
    ),
    
    -- Search Optimization
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(full_name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(username, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(bio, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(tagline, '')), 'B')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    CONSTRAINT valid_handle CHECK (handle IS NOT NULL AND length(handle) >= 3),
    CONSTRAINT valid_username CHECK (username IS NULL OR length(username) >= 2),
    CONSTRAINT valid_scores CHECK (
        verification_level >= 0 AND
        reputation_score >= 0 AND
        trust_score >= 0
    ),
    CONSTRAINT valid_social_links CHECK (jsonb_typeof(social_links) = 'object'),
    CONSTRAINT valid_metadata CHECK (jsonb_typeof(metadata) = 'object')
);

-- =====================================================================================
-- User Preferences Table
-- =====================================================================================
-- Description: Stores user-specific settings and customization preferences
-- Dependencies:
--   - public.profiles (for user reference)
--   - public.date_format_type (enum for date format)
--   - public.time_format_type (enum for time format)
--   - public.display_density_type (enum for UI density)
--   - public.theme_type (enum for UI theme)
-- Notes:
--   - Manages UI/UX preferences
--   - Handles notification settings
--   - Controls privacy and visibility options
--   - Supports internationalization settings
--   - Implements soft deletion and versioning
-- =====================================================================================

CREATE TABLE public.user_preferences (
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
    notification_frequency TEXT DEFAULT 'instant',
    
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
    font_size TEXT DEFAULT 'medium',
    
    -- Privacy preferences
    profile_visibility TEXT DEFAULT 'public',
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

-- =====================================================================================
-- User Security Settings Table
-- =====================================================================================
-- Description: Manages user security configurations and authentication preferences
-- Dependencies:
--   - auth.users (for user authentication)
--   - public.two_factor_method_type (enum for 2FA methods)
-- Notes:
--   - Handles two-factor authentication settings
--   - Tracks login attempts and security events
--   - Manages trusted devices and IP addresses
--   - Stores security audit information
--   - Implements password policies and history
--   - Supports soft deletion and versioning
-- =====================================================================================

CREATE TABLE public.user_security_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Security settings
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_method public.two_factor_method_type,
    recovery_email TEXT CHECK (recovery_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    recovery_phone TEXT CHECK (recovery_phone ~* '^\+[1-9]\d{1,14}$'),
    last_password_change TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
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
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    -- Additional constraints
    CONSTRAINT unique_user_security UNIQUE(user_id, deleted_at),
    CONSTRAINT valid_password_expiry CHECK (password_expires_at > last_password_change),
    CONSTRAINT valid_lock_period CHECK (locked_until > CURRENT_TIMESTAMP OR locked_until IS NULL),
    CONSTRAINT valid_2fa_config CHECK (
        (two_factor_enabled = false) OR 
        (two_factor_enabled = true AND two_factor_method IS NOT NULL)
    ),
    CONSTRAINT valid_security_questions CHECK (jsonb_typeof(security_questions) = 'object'),
    CONSTRAINT valid_trusted_devices CHECK (jsonb_typeof(trusted_devices) = 'array'),
    CONSTRAINT valid_known_ips CHECK (jsonb_typeof(known_ips) = 'array'),
    CONSTRAINT valid_verification_documents CHECK (jsonb_typeof(verification_documents) = 'array'),
    CONSTRAINT valid_password_history CHECK (jsonb_typeof(password_history) = 'array')
);

-- =====================================================================================
-- User Onboarding Table
-- =====================================================================================
-- Description: Tracks user onboarding progress and manages consent records
-- Dependencies:
--   - auth.users (for user authentication)
--   - public.onboarding_platform_type (enum for platform)
--   - public.communication_language_type (enum for language)
-- Notes:
--   - Tracks onboarding progress and completion
--   - Manages legal consent and agreements
--   - Handles marketing preferences
--   - Records platform and device information
--   - Supports step-by-step progress tracking
--   - Implements soft deletion and versioning
-- =====================================================================================

CREATE TABLE public.user_onboarding (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    
    -- Onboarding progress tracking
    onboarding_completed BOOLEAN DEFAULT false,
    onboarding_step INTEGER DEFAULT 1 CHECK (onboarding_step BETWEEN 1 AND 10),
    current_step_started_at TIMESTAMPTZ,
    onboarding_started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
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
    communication_language public.communication_language_type DEFAULT 'en',
    
    -- Additional tracking
    device_info JSONB,
    referral_source TEXT,
    utm_parameters JSONB,
    onboarding_platform public.onboarding_platform_type,
    last_active_step INTEGER,
    step_history JSONB DEFAULT '[]'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
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
    ),
    CONSTRAINT valid_marketing_consent CHECK (
        (marketing_consent = false) OR 
        (marketing_consent = true AND marketing_consent_at IS NOT NULL)
    ),
    CONSTRAINT valid_step_progress CHECK (
        last_active_step IS NULL OR 
        (last_active_step >= 1 AND last_active_step <= onboarding_step)
    )
);

-- =====================================================================================
-- Indexes
-- =====================================================================================

-- Profiles indexes
CREATE INDEX idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX idx_profiles_handle ON public.profiles(handle);
CREATE INDEX idx_profiles_username ON public.profiles(username);
CREATE INDEX idx_profiles_search_vector ON public.profiles USING gin(search_vector);
CREATE INDEX idx_profiles_created_at ON public.profiles(created_at);
CREATE INDEX idx_profiles_updated_at ON public.profiles(updated_at);
CREATE INDEX idx_profiles_deleted_at ON public.profiles(deleted_at) WHERE deleted_at IS NOT NULL;

-- User preferences indexes
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id);
CREATE INDEX idx_user_preferences_created_at ON public.user_preferences(created_at);
CREATE INDEX idx_user_preferences_updated_at ON public.user_preferences(updated_at);
CREATE INDEX idx_user_preferences_deleted_at ON public.user_preferences(deleted_at) WHERE deleted_at IS NOT NULL;

-- User security settings indexes
CREATE INDEX idx_user_security_settings_user_id ON public.user_security_settings(user_id);
CREATE INDEX idx_user_security_settings_last_login ON public.user_security_settings(last_login_at);
CREATE INDEX idx_user_security_settings_last_active ON public.user_security_settings(last_active_at);
CREATE INDEX idx_user_security_settings_created_at ON public.user_security_settings(created_at);
CREATE INDEX idx_user_security_settings_updated_at ON public.user_security_settings(updated_at);
CREATE INDEX idx_user_security_settings_deleted_at ON public.user_security_settings(deleted_at) WHERE deleted_at IS NOT NULL;

-- User onboarding indexes
CREATE INDEX idx_user_onboarding_user_id ON public.user_onboarding(user_id);
CREATE INDEX idx_user_onboarding_completed ON public.user_onboarding(onboarding_completed);
CREATE INDEX idx_user_onboarding_created_at ON public.user_onboarding(created_at);
CREATE INDEX idx_user_onboarding_updated_at ON public.user_onboarding(updated_at);
CREATE INDEX idx_user_onboarding_deleted_at ON public.user_onboarding(deleted_at) WHERE deleted_at IS NOT NULL;

-- =====================================================================================
-- Row Level Security (RLS)
-- =====================================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_security_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_onboarding ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own profile"
    ON public.profiles FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Service role has full access to profiles"
    ON public.profiles FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Public can view non-private profiles"
    ON public.profiles FOR SELECT
    TO anon
    USING (
        EXISTS (
            SELECT 1 FROM public.user_preferences up
            WHERE up.user_id = profiles.id
            AND up.profile_visibility = 'public'
            AND up.deleted_at IS NULL
        )
    );

-- User preferences policies
CREATE POLICY "Users can view their own preferences"
    ON public.user_preferences FOR SELECT
    TO authenticated
    USING (auth.uid() = (SELECT user_id FROM public.profiles WHERE id = user_preferences.user_id));

CREATE POLICY "Users can update their own preferences"
    ON public.user_preferences FOR UPDATE
    TO authenticated
    USING (auth.uid() = (SELECT user_id FROM public.profiles WHERE id = user_preferences.user_id))
    WITH CHECK (auth.uid() = (SELECT user_id FROM public.profiles WHERE id = user_preferences.user_id));

CREATE POLICY "Service role has full access to preferences"
    ON public.user_preferences FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- User security settings policies
CREATE POLICY "Users can view their own security settings"
    ON public.user_security_settings FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own security settings"
    ON public.user_security_settings FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role has full access to security settings"
    ON public.user_security_settings FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- User onboarding policies
CREATE POLICY "Users can view their own onboarding"
    ON public.user_onboarding FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own onboarding"
    ON public.user_onboarding FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role has full access to onboarding"
    ON public.user_onboarding FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- =====================================================================================
-- Triggers
-- =====================================================================================

-- Audit trigger function
CREATE OR REPLACE FUNCTION public.handle_audit_fields()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
        NEW.updated_by = auth.uid();
        NEW.version = OLD.version + 1;
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        NEW.created_at = CURRENT_TIMESTAMP;
        NEW.created_by = auth.uid();
        NEW.updated_at = CURRENT_TIMESTAMP;
        NEW.updated_by = auth.uid();
        NEW.version = 1;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Soft delete trigger function
CREATE OR REPLACE FUNCTION public.handle_soft_delete()
RETURNS TRIGGER AS $$
BEGIN
    NEW.deleted_at = CURRENT_TIMESTAMP;
    NEW.deleted_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply audit triggers to all tables
CREATE TRIGGER audit_profiles
    BEFORE INSERT OR UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_audit_fields();

CREATE TRIGGER audit_user_preferences
    BEFORE INSERT OR UPDATE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION public.handle_audit_fields();

CREATE TRIGGER audit_user_security_settings
    BEFORE INSERT OR UPDATE ON public.user_security_settings
    FOR EACH ROW EXECUTE FUNCTION public.handle_audit_fields();

CREATE TRIGGER audit_user_onboarding
    BEFORE INSERT OR UPDATE ON public.user_onboarding
    FOR EACH ROW EXECUTE FUNCTION public.handle_audit_fields();

-- Apply soft delete triggers to all tables
CREATE TRIGGER soft_delete_profiles
    BEFORE DELETE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_soft_delete();

CREATE TRIGGER soft_delete_user_preferences
    BEFORE DELETE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION public.handle_soft_delete();

CREATE TRIGGER soft_delete_user_security_settings
    BEFORE DELETE ON public.user_security_settings
    FOR EACH ROW EXECUTE FUNCTION public.handle_soft_delete();

CREATE TRIGGER soft_delete_user_onboarding
    BEFORE DELETE ON public.user_onboarding
    FOR EACH ROW EXECUTE FUNCTION public.handle_soft_delete();

-- =====================================================================================
-- Grants
-- =====================================================================================

-- Grant access to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_preferences TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_security_settings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_onboarding TO authenticated;

-- Grant access to anonymous users (public profiles only)
GRANT SELECT ON public.profiles TO anon;

-- Grant full access to service role
GRANT ALL ON public.profiles TO service_role;
GRANT ALL ON public.user_preferences TO service_role;
GRANT ALL ON public.user_security_settings TO service_role;
GRANT ALL ON public.user_onboarding TO service_role;

-- Grant usage on sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- =====================================================================================
-- Comments
-- =====================================================================================

COMMENT ON TABLE public.profiles IS 'Stores user profile information and preferences';
COMMENT ON TABLE public.user_preferences IS 'Stores user-specific settings and preferences';
COMMENT ON TABLE public.user_security_settings IS 'Stores user security settings and authentication preferences';
COMMENT ON TABLE public.user_onboarding IS 'Tracks user onboarding progress and consent management';

-- Add detailed column comments for better documentation
COMMENT ON COLUMN public.profiles.handle IS 'Unique username handle for the user (3-50 chars, alphanumeric and underscore only)';
COMMENT ON COLUMN public.profiles.search_vector IS 'Computed column for full text search on profile data';
COMMENT ON COLUMN public.profiles.metadata IS 'Flexible JSONB field for storing additional profile attributes';

COMMENT ON COLUMN public.user_preferences.theme IS 'User interface theme preference';
COMMENT ON COLUMN public.user_preferences.display_density IS 'UI density setting (comfortable, compact, etc.)';
COMMENT ON COLUMN public.user_preferences.notification_frequency IS 'How often to send notifications (instant, hourly, daily, weekly)';

COMMENT ON COLUMN public.user_security_settings.two_factor_enabled IS 'Whether two-factor authentication is enabled';
COMMENT ON COLUMN public.user_security_settings.password_history IS 'List of previous password hashes to prevent reuse';
COMMENT ON COLUMN public.user_security_settings.trusted_devices IS 'List of devices that have been marked as trusted';

COMMENT ON COLUMN public.user_onboarding.onboarding_step IS 'Current step in the onboarding process (1-10)';
COMMENT ON COLUMN public.user_onboarding.terms_accepted IS 'Whether the user has accepted the terms of service';
COMMENT ON COLUMN public.user_onboarding.marketing_preferences IS 'User marketing communication preferences';


-- =====================================================================================
-- Entity Contact Tables
-- =====================================================================================
-- Description: Tables for managing entity contact information including emails, phones,
--             and addresses
-- Version: 1.0.0
-- Last Updated: 2024-12-20
-- Dependencies:
--   - auth.users: For user management
--   - public.email_type: Email type enum
--   - public.phone_type: Phone type enum
--   - public.address_type: Address type enum
-- =====================================================================================

-- Drop existing tables and dependencies
DROP TABLE IF EXISTS public.entity_addresses CASCADE;
DROP TABLE IF EXISTS public.entity_phones CASCADE;
DROP TABLE IF EXISTS public.entity_emails CASCADE;

-- Create tables
CREATE TABLE public.entity_emails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    email TEXT NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    
    -- Email status
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verification_token TEXT,
    token_expires_at TIMESTAMPTZ,
    type public.email_type NOT NULL,
    label TEXT,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    CONSTRAINT unique_primary_email UNIQUE (user_id, is_primary) WHERE is_primary = true AND deleted_at IS NULL,
    CONSTRAINT unique_email UNIQUE (email, deleted_at),
    CONSTRAINT valid_verification CHECK (
        (is_verified = false) OR 
        (is_verified = true AND verified_at IS NOT NULL)
    ),
    CONSTRAINT valid_token_expiry CHECK (
        verification_token IS NULL OR 
        (token_expires_at > created_at)
    )
);

CREATE TABLE public.entity_phones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    phone_number TEXT NOT NULL CHECK (phone_number ~* '^\+[1-9]\d{1,14}$'),
    
    -- Phone status
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verification_code TEXT,
    code_expires_at TIMESTAMPTZ,
    type public.phone_type NOT NULL,
    label TEXT,
    country_code TEXT,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    CONSTRAINT unique_primary_phone UNIQUE (user_id, is_primary) WHERE is_primary = true AND deleted_at IS NULL,
    CONSTRAINT unique_phone UNIQUE (phone_number, deleted_at),
    CONSTRAINT valid_verification CHECK (
        (is_verified = false) OR 
        (is_verified = true AND verified_at IS NOT NULL)
    ),
    CONSTRAINT valid_code_expiry CHECK (
        verification_code IS NULL OR 
        (code_expires_at > created_at)
    )
);

CREATE TABLE public.entity_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    is_primary BOOLEAN DEFAULT false,
    type public.address_type NOT NULL,
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
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    CONSTRAINT unique_primary_address UNIQUE (user_id, is_primary) WHERE is_primary = true AND deleted_at IS NULL,
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR 
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    ),
    CONSTRAINT valid_verification CHECK (
        (is_verified = false) OR 
        (is_verified = true AND verified_at IS NOT NULL)
    )
);

-- Create indexes
CREATE INDEX idx_entity_emails_user ON public.entity_emails(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_emails_email ON public.entity_emails(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_emails_verified ON public.entity_emails(is_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_emails_type ON public.entity_emails(type) WHERE deleted_at IS NULL;

CREATE INDEX idx_entity_phones_user ON public.entity_phones(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_phones_phone ON public.entity_phones(phone_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_phones_verified ON public.entity_phones(is_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_phones_type ON public.entity_phones(type) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_phones_country ON public.entity_phones(country_code) WHERE deleted_at IS NULL;

CREATE INDEX idx_entity_addresses_user ON public.entity_addresses(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_addresses_type ON public.entity_addresses(type) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_addresses_verified ON public.entity_addresses(is_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_addresses_country ON public.entity_addresses(country_code) WHERE deleted_at IS NULL;
CREATE INDEX idx_entity_addresses_location ON public.entity_addresses USING gist (ll_to_earth(latitude, longitude)) WHERE deleted_at IS NULL AND latitude IS NOT NULL AND longitude IS NOT NULL;

-- Enable Row Level Security
ALTER TABLE public.entity_emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_phones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_addresses ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their own email contacts"
    ON public.entity_emails
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own email contacts"
    ON public.entity_emails
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own phone contacts"
    ON public.entity_phones
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own phone contacts"
    ON public.entity_phones
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own addresses"
    ON public.entity_addresses
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own addresses"
    ON public.entity_addresses
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Grant permissions
GRANT SELECT ON public.entity_emails TO authenticated;
GRANT SELECT ON public.entity_phones TO authenticated;
GRANT SELECT ON public.entity_addresses TO authenticated;

GRANT ALL ON public.entity_emails TO service_role;
GRANT ALL ON public.entity_phones TO service_role;
GRANT ALL ON public.entity_addresses TO service_role;

-- Add triggers
CREATE TRIGGER set_timestamp_entity_emails
    BEFORE UPDATE ON public.entity_emails
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_entity_phones
    BEFORE UPDATE ON public.entity_phones
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_entity_addresses
    BEFORE UPDATE ON public.entity_addresses
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();


-- =====================================================================================
-- RBAC (Role-Based Access Control) Tables
-- =====================================================================================
-- Description: Core tables for the Role-Based Access Control system
-- Version: 1.0.0
-- Last Updated: 2024-12-19
-- Dependencies:
--   - auth.users: For user references
--   - public.role_type: Role types
--   - public.role_status_type: Role status options
--   - public.permission_category_type: Permission categories
--   - public.delegation_status_type: Delegation status options
-- =====================================================================================

-- Roles: Core role definitions
CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info
    name TEXT NOT NULL,
    description TEXT,
    type public.role_type NOT NULL DEFAULT 'custom',
    status public.role_status_type NOT NULL DEFAULT 'active',
    
    -- Configuration
    is_system BOOLEAN DEFAULT false,
    permissions TEXT[] DEFAULT ARRAY[]::TEXT[],
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Validity Period
    valid_from TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMPTZ,
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    -- Constraints
    CONSTRAINT unique_role_name UNIQUE(name, deleted_at),
    CONSTRAINT valid_temporary_role CHECK (
        (type != 'temporary') OR 
        (type = 'temporary' AND valid_until IS NOT NULL AND valid_until > valid_from)
    ),
    CONSTRAINT valid_system_role CHECK (
        (NOT is_system) OR 
        (is_system AND type = 'system')
    )
);

-- Permissions: Available system permissions
CREATE TABLE public.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info
    name TEXT NOT NULL,
    description TEXT,
    category public.permission_category_type NOT NULL,
    
    -- Configuration
    is_system BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    -- Constraints
    CONSTRAINT unique_permission_name UNIQUE(name, deleted_at),
    CONSTRAINT system_permission_category CHECK (
        NOT is_system OR (is_system AND category = 'system')
    )
);

-- User Roles: Maps users to roles
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Mapping
    user_id UUID NOT NULL REFERENCES auth.users(id),
    role_id UUID NOT NULL REFERENCES public.roles(id),
    
    -- Configuration
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    -- Constraints
    CONSTRAINT unique_user_role UNIQUE(user_id, role_id, deleted_at)
);

-- Role Permissions: Maps roles to permissions
CREATE TABLE public.role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Mapping
    role_id UUID NOT NULL REFERENCES public.roles(id),
    permission_id UUID NOT NULL REFERENCES public.permissions(id),
    
    -- Configuration
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    -- Constraints
    CONSTRAINT unique_role_permission UNIQUE(role_id, permission_id, deleted_at)
);

-- Role Delegations: Temporary role assignments
CREATE TABLE public.role_delegations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Delegation Details
    delegator_id UUID NOT NULL REFERENCES auth.users(id),
    delegate_id UUID NOT NULL REFERENCES auth.users(id),
    role_id UUID NOT NULL REFERENCES public.roles(id),
    
    -- Time Bounds
    starts_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ends_at TIMESTAMPTZ,
    
    -- Status
    status public.delegation_status_type NOT NULL DEFAULT 'active',
    is_active BOOLEAN GENERATED ALWAYS AS (
        status = 'active' AND 
        (ends_at IS NULL OR ends_at > now())
    ) STORED,
    
    -- Revocation
    revoked_at TIMESTAMPTZ,
    revoked_by UUID REFERENCES auth.users(id),
    revocation_reason TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,
    
    -- Constraints
    CONSTRAINT valid_delegation_period CHECK (ends_at IS NULL OR ends_at > starts_at),
    CONSTRAINT no_self_delegation CHECK (delegator_id != delegate_id)
);

-- Indexes
CREATE INDEX idx_roles_name ON public.roles(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_roles_type ON public.roles(type) WHERE deleted_at IS NULL;
CREATE INDEX idx_roles_status ON public.roles(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_roles_is_system ON public.roles(is_system) WHERE deleted_at IS NULL;
CREATE INDEX idx_roles_validity ON public.roles(valid_from, valid_until) 
    WHERE deleted_at IS NULL AND type = 'temporary';

CREATE INDEX idx_permissions_name ON public.permissions(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_permissions_category ON public.permissions(category) WHERE deleted_at IS NULL;
CREATE INDEX idx_permissions_is_active ON public.permissions(is_active) WHERE deleted_at IS NULL;

CREATE INDEX idx_user_roles_user ON public.user_roles(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_roles_role ON public.user_roles(role_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_roles_is_active ON public.user_roles(is_active) WHERE deleted_at IS NULL;

CREATE INDEX idx_role_permissions_role ON public.role_permissions(role_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_permissions_permission ON public.role_permissions(permission_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_permissions_is_active ON public.role_permissions(is_active) WHERE deleted_at IS NULL;

CREATE INDEX idx_role_delegations_delegator ON public.role_delegations(delegator_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_delegate ON public.role_delegations(delegate_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_role ON public.role_delegations(role_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_status ON public.role_delegations(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_active ON public.role_delegations(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_role_delegations_dates ON public.role_delegations(starts_at, ends_at) WHERE deleted_at IS NULL;

-- Enable Row Level Security
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_delegations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Everyone can view non-system roles" ON public.roles
    FOR SELECT TO authenticated
    USING (NOT is_system OR auth.uid() IN (
        SELECT user_id FROM public.user_roles WHERE role_name = 'admin'
    ));

CREATE POLICY "Only admins can manage roles" ON public.roles
    FOR ALL TO authenticated
    USING (auth.uid() IN (
        SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL
    ))
    WITH CHECK (auth.uid() IN (
        SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL
    ));

CREATE POLICY "Permissions are viewable by authenticated users" ON public.permissions
    FOR SELECT TO authenticated
    USING ((NOT is_system AND is_active AND deleted_at IS NULL) OR
           auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL));

CREATE POLICY "Only admins can manage permissions" ON public.permissions
    FOR ALL TO authenticated
    USING (auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL))
    WITH CHECK (auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL));

CREATE POLICY "Users can view their own roles" ON public.user_roles
    FOR SELECT TO authenticated
    USING (auth.uid() = user_id OR
           auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL));

CREATE POLICY "Only admins can manage user roles" ON public.user_roles
    FOR ALL TO authenticated
    USING (auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL))
    WITH CHECK (auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL));

CREATE POLICY "Role permissions are viewable by authenticated users" ON public.role_permissions
    FOR SELECT TO authenticated
    USING (auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_id IN (
               SELECT role_id FROM public.role_permissions WHERE permission_id = role_permissions.permission_id
           ) AND deleted_at IS NULL) OR
           auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL));

CREATE POLICY "Only admins can manage role permissions" ON public.role_permissions
    FOR ALL TO authenticated
    USING (auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL))
    WITH CHECK (auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL));

CREATE POLICY "Users can view their own delegations" ON public.role_delegations
    FOR SELECT TO authenticated
    USING (auth.uid() = delegator_id OR auth.uid() = delegate_id OR
           auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL));

CREATE POLICY "Users can manage their own delegations" ON public.role_delegations
    FOR ALL TO authenticated
    USING (auth.uid() = delegator_id OR
           auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL))
    WITH CHECK (auth.uid() = delegator_id OR
                auth.uid() IN (SELECT user_id FROM public.user_roles WHERE role_name = 'admin' AND deleted_at IS NULL));

-- Grants
GRANT SELECT ON public.roles TO authenticated;
GRANT SELECT ON public.permissions TO authenticated;
GRANT SELECT ON public.user_roles TO authenticated;
GRANT SELECT ON public.role_permissions TO authenticated;
GRANT SELECT ON public.role_delegations TO authenticated;

GRANT ALL ON public.roles TO service_role;
GRANT ALL ON public.permissions TO service_role;
GRANT ALL ON public.user_roles TO service_role;
GRANT ALL ON public.role_permissions TO service_role;
GRANT ALL ON public.role_delegations TO service_role;

-- Add Triggers
CREATE TRIGGER set_timestamp_roles
    BEFORE UPDATE ON public.roles
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_permissions
    BEFORE UPDATE ON public.permissions
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_user_roles
    BEFORE UPDATE ON public.user_roles
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_role_permissions
    BEFORE UPDATE ON public.role_permissions
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_role_delegations
    BEFORE UPDATE ON public.role_delegations
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


-- =====================================================================================
-- System Audit Tables
-- =====================================================================================
-- Description: Tables for comprehensive system auditing and activity tracking
-- Version: 1.0.0
-- Last Updated: 2024-12-19
-- Dependencies:
--   - auth.users: For user references
--   - public.audit_action_type: Audit action types
--   - public.activity_type: User activity types
--   - public.audit_status_type: Audit record status
--   - public.data_sensitivity_type: Data sensitivity levels
--   - public.audit_category_type: Audit categories
--   - public.compliance_status_type: Compliance status
-- =====================================================================================

-- Audit Logs: Comprehensive system-wide audit trailing
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Audit Info
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action public.audit_action_type NOT NULL,
    category public.audit_category_type NOT NULL,
    status public.audit_status_type DEFAULT 'completed',
    
    -- Data Changes
    old_data JSONB,
    new_data JSONB,
    changed_fields TEXT[],
    data_sensitivity public.data_sensitivity_type DEFAULT 'internal',
    
    -- Context Information
    performed_by UUID NOT NULL REFERENCES auth.users(id),
    performed_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    reason TEXT,
    notes TEXT,
    
    -- Technical Details
    ip_address TEXT,
    user_agent TEXT,
    session_id TEXT,
    request_id UUID,
    correlation_id UUID,
    
    -- Location Information
    location JSONB,
    geo_coordinates POINT,
    
    -- Compliance
    compliance_status public.compliance_status_type,
    retention_period INTERVAL,
    expires_at TIMESTAMPTZ,
    
    -- Metadata
    custom_fields JSONB DEFAULT '{}'::jsonb,
    tags TEXT[],
    
    -- Version Control
    version INTEGER DEFAULT 1,
    
    -- Standard Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),

    -- Constraints
    CONSTRAINT valid_audit_dates CHECK (
        performed_at <= created_at AND
        (expires_at IS NULL OR expires_at > created_at)
    ),
    CONSTRAINT valid_data_changes CHECK (
        (action = 'create' AND old_data IS NULL AND new_data IS NOT NULL) OR
        (action = 'update' AND old_data IS NOT NULL AND new_data IS NOT NULL) OR
        (action = 'delete' AND old_data IS NOT NULL AND new_data IS NULL) OR
        (action NOT IN ('create', 'update', 'delete'))
    )
);

-- User Activities: Detailed user interaction tracking
CREATE TABLE public.user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Activity Details
    user_id UUID NOT NULL REFERENCES auth.users(id),
    activity_type public.activity_type NOT NULL,
    status public.audit_status_type DEFAULT 'completed',
    
    -- Context
    entity_type TEXT NOT NULL,
    entity_id UUID,
    description TEXT NOT NULL,
    category public.audit_category_type DEFAULT 'user',
    
    -- Technical Details
    ip_address TEXT,
    user_agent TEXT,
    session_id TEXT,
    request_id UUID,
    
    -- Location
    location JSONB,
    geo_coordinates POINT,
    
    -- Additional Data
    metadata JSONB DEFAULT '{}'::jsonb,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    tags TEXT[],
    
    -- Performance Metrics
    duration_ms INTEGER,
    resource_usage JSONB,
    
    -- Standard Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1,

    -- Constraints
    CONSTRAINT valid_activity_entity CHECK (
        (entity_id IS NULL AND entity_type = 'system') OR
        (entity_id IS NOT NULL)
    ),
    CONSTRAINT valid_duration CHECK (
        duration_ms IS NULL OR duration_ms >= 0
    )
);

-- Security Events: Security-specific audit events
CREATE TABLE public.security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Event Details
    event_type TEXT NOT NULL,
    severity TEXT NOT NULL,
    status public.audit_status_type DEFAULT 'pending',
    
    -- Context
    user_id UUID REFERENCES auth.users(id),
    source TEXT NOT NULL,
    description TEXT NOT NULL,
    
    -- Technical Details
    ip_address TEXT,
    user_agent TEXT,
    request_id UUID,
    
    -- Additional Data
    metadata JSONB DEFAULT '{}'::jsonb,
    evidence JSONB,
    
    -- Resolution
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES auth.users(id),
    resolution_notes TEXT,
    
    -- Standard Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1,

    -- Constraints
    CONSTRAINT valid_resolution CHECK (
        (resolved_at IS NULL AND resolved_by IS NULL) OR
        (resolved_at IS NOT NULL AND resolved_by IS NOT NULL)
    )
);

-- Compliance Logs: Compliance-specific audit records
CREATE TABLE public.compliance_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Compliance Details
    requirement_id TEXT NOT NULL,
    status public.compliance_status_type NOT NULL,
    framework TEXT NOT NULL,
    
    -- Assessment
    assessed_at TIMESTAMPTZ NOT NULL,
    assessed_by UUID NOT NULL REFERENCES auth.users(id),
    evidence JSONB NOT NULL,
    
    -- Findings
    findings TEXT[],
    risk_level TEXT,
    impact_level TEXT,
    
    -- Remediation
    remediation_plan TEXT,
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    completed_by UUID REFERENCES auth.users(id),
    
    -- Additional Data
    metadata JSONB DEFAULT '{}'::jsonb,
    attachments JSONB,
    
    -- Standard Audit Fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1,

    -- Constraints
    CONSTRAINT valid_completion CHECK (
        (completed_at IS NULL AND completed_by IS NULL) OR
        (completed_at IS NOT NULL AND completed_by IS NOT NULL)
    ),
    CONSTRAINT valid_assessment_dates CHECK (
        assessed_at <= created_at AND
        (due_date IS NULL OR due_date > assessed_at) AND
        (completed_at IS NULL OR completed_at > assessed_at)
    )
);

-- Indexes for audit_logs
CREATE INDEX idx_audit_logs_table_record ON public.audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX idx_audit_logs_category ON public.audit_logs(category);
CREATE INDEX idx_audit_logs_status ON public.audit_logs(status);
CREATE INDEX idx_audit_logs_performed_by ON public.audit_logs(performed_by);
CREATE INDEX idx_audit_logs_performed_at ON public.audit_logs(performed_at);
CREATE INDEX idx_audit_logs_session ON public.audit_logs(session_id);
CREATE INDEX idx_audit_logs_request ON public.audit_logs(request_id);
CREATE INDEX idx_audit_logs_correlation ON public.audit_logs(correlation_id);
CREATE INDEX idx_audit_logs_compliance ON public.audit_logs(compliance_status);
CREATE INDEX idx_audit_logs_sensitivity ON public.audit_logs(data_sensitivity);
CREATE INDEX idx_audit_logs_expires ON public.audit_logs(expires_at);
CREATE INDEX idx_audit_logs_tags ON public.audit_logs USING gin(tags);
CREATE INDEX idx_audit_logs_changed_fields ON public.audit_logs USING gin(changed_fields);
CREATE INDEX idx_audit_logs_data ON public.audit_logs USING gin(old_data jsonb_path_ops, new_data jsonb_path_ops);
CREATE INDEX idx_audit_logs_custom_fields ON public.audit_logs USING gin(custom_fields);

-- Indexes for user_activities
CREATE INDEX idx_user_activities_user ON public.user_activities(user_id);
CREATE INDEX idx_user_activities_type ON public.user_activities(activity_type);
CREATE INDEX idx_user_activities_status ON public.user_activities(status);
CREATE INDEX idx_user_activities_entity ON public.user_activities(entity_type, entity_id);
CREATE INDEX idx_user_activities_category ON public.user_activities(category);
CREATE INDEX idx_user_activities_session ON public.user_activities(session_id);
CREATE INDEX idx_user_activities_request ON public.user_activities(request_id);
CREATE INDEX idx_user_activities_created ON public.user_activities(created_at);
CREATE INDEX idx_user_activities_tags ON public.user_activities USING gin(tags);
CREATE INDEX idx_user_activities_metadata ON public.user_activities USING gin(metadata);
CREATE INDEX idx_user_activities_custom_fields ON public.user_activities USING gin(custom_fields);

-- Indexes for security_events
CREATE INDEX idx_security_events_type ON public.security_events(event_type);
CREATE INDEX idx_security_events_severity ON public.security_events(severity);
CREATE INDEX idx_security_events_status ON public.security_events(status);
CREATE INDEX idx_security_events_user ON public.security_events(user_id);
CREATE INDEX idx_security_events_source ON public.security_events(source);
CREATE INDEX idx_security_events_ip ON public.security_events(ip_address);
CREATE INDEX idx_security_events_request ON public.security_events(request_id);
CREATE INDEX idx_security_events_resolved ON public.security_events(resolved_at);
CREATE INDEX idx_security_events_metadata ON public.security_events USING gin(metadata);
CREATE INDEX idx_security_events_evidence ON public.security_events USING gin(evidence);

-- Indexes for compliance_logs
CREATE INDEX idx_compliance_logs_requirement ON public.compliance_logs(requirement_id);
CREATE INDEX idx_compliance_logs_status ON public.compliance_logs(status);
CREATE INDEX idx_compliance_logs_framework ON public.compliance_logs(framework);
CREATE INDEX idx_compliance_logs_assessed ON public.compliance_logs(assessed_at);
CREATE INDEX idx_compliance_logs_assessor ON public.compliance_logs(assessed_by);
CREATE INDEX idx_compliance_logs_risk ON public.compliance_logs(risk_level);
CREATE INDEX idx_compliance_logs_impact ON public.compliance_logs(impact_level);
CREATE INDEX idx_compliance_logs_due ON public.compliance_logs(due_date);
CREATE INDEX idx_compliance_logs_completed ON public.compliance_logs(completed_at);
CREATE INDEX idx_compliance_logs_findings ON public.compliance_logs USING gin(findings);
CREATE INDEX idx_compliance_logs_metadata ON public.compliance_logs USING gin(metadata);
CREATE INDEX idx_compliance_logs_attachments ON public.compliance_logs USING gin(attachments);

-- Enable Row Level Security
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compliance_logs ENABLE ROW LEVEL SECURITY;

-- Grants for audit tables
GRANT SELECT ON public.audit_logs TO authenticated;
GRANT SELECT ON public.user_activities TO authenticated;
GRANT SELECT ON public.security_events TO authenticated;
GRANT SELECT ON public.compliance_logs TO authenticated;

GRANT ALL ON public.audit_logs TO service_role;
GRANT ALL ON public.user_activities TO service_role;
GRANT ALL ON public.security_events TO service_role;
GRANT ALL ON public.compliance_logs TO service_role;


-- =====================================================================================
-- CRM Core Tables
-- =====================================================================================
-- Description: Core CRM system tables including contacts, leads, opportunities,
--             quotes, and related business entities
-- Version: 1.0.0
-- Last Updated: 2024-12-20
-- Dependencies:
--   - auth.users: For user authentication and assignments
--   - public.customer_type: Customer relationship types
--   - public.customer_status: Customer account statuses
--   - public.customer_segment_type: Business segments
--   - public.lead_status: Lead lifecycle stages
--   - public.lead_source: Lead acquisition sources
--   - public.opportunity_status: Sales opportunity stages
--   - public.quote_status: Quote lifecycle stages
--   - public.currency_type: Supported currencies
--   - public.communication_channel: Communication preferences
--   - public.communication_language_type: Language preferences
-- Notes:
--   - Implements comprehensive CRM functionality
--   - Supports B2B and B2C relationships
--   - Includes full audit trail and versioning
--   - Optimized for Supabase and PostgreSQL
-- =====================================================================================

-- Drop all existing objects first to ensure clean setup
-- =====================================================================================

-- Drop triggers for all CRM tables
DROP TRIGGER IF EXISTS set_timestamp_crm_jobs ON public.crm_jobs CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_crm_referrals ON public.crm_referrals CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_crm_products ON public.crm_products CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_crm_pipelines ON public.crm_pipelines CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_crm_communications ON public.crm_communications CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_crm_documents ON public.crm_documents CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_crm_notes ON public.crm_notes CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_crm_relationships ON public.crm_relationships CASCADE;

-- Drop existing indexes for all CRM tables
DROP INDEX IF EXISTS idx_crm_jobs_number CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_status CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_contact CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_dates CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_priority CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_team CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_equipment CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_search CASCADE;

DROP INDEX IF EXISTS idx_crm_referrals_number CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_referrer CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_referee CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_status CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_type CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_tags CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_child CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_search CASCADE;

DROP INDEX IF EXISTS idx_crm_products_sku CASCADE;
DROP INDEX IF EXISTS idx_crm_products_name CASCADE;
DROP INDEX IF EXISTS idx_crm_products_status CASCADE;
DROP INDEX IF EXISTS idx_crm_products_type CASCADE;
DROP INDEX IF EXISTS idx_crm_products_category CASCADE;
DROP INDEX IF EXISTS idx_crm_products_price CASCADE;
DROP INDEX IF EXISTS idx_crm_products_inventory CASCADE;
DROP INDEX IF EXISTS idx_crm_products_related CASCADE;
DROP INDEX IF EXISTS idx_crm_products_features CASCADE;
DROP INDEX IF EXISTS idx_crm_products_search CASCADE;

DROP INDEX IF EXISTS idx_crm_pipelines_code CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_name CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_status CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_type CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_default CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_stages CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_automations CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_search CASCADE;

-- Drop RLS policies for all CRM tables
DROP POLICY IF EXISTS "Users can view jobs they manage" ON public.crm_jobs CASCADE;
DROP POLICY IF EXISTS "Users can manage their assigned jobs" ON public.crm_jobs CASCADE;

DROP POLICY IF EXISTS "Users can view referrals they manage" ON public.crm_referrals CASCADE;
DROP POLICY IF EXISTS "Users can manage referrals" ON public.crm_referrals CASCADE;

DROP POLICY IF EXISTS "Users can view active products" ON public.crm_products CASCADE;
DROP POLICY IF EXISTS "Users can manage products" ON public.crm_products CASCADE;

DROP POLICY IF EXISTS "Users can view active pipelines" ON public.crm_pipelines CASCADE;
DROP POLICY IF EXISTS "Users can manage pipelines" ON public.crm_pipelines CASCADE;

-- Revoke all permissions
REVOKE ALL ON public.crm_jobs FROM authenticated CASCADE;
REVOKE ALL ON public.crm_jobs FROM service_role CASCADE;

REVOKE ALL ON public.crm_referrals FROM authenticated CASCADE;
REVOKE ALL ON public.crm_referrals FROM service_role CASCADE;

REVOKE ALL ON public.crm_products FROM authenticated CASCADE;
REVOKE ALL ON public.crm_products FROM service_role CASCADE;

REVOKE ALL ON public.crm_pipelines FROM authenticated CASCADE;
REVOKE ALL ON public.crm_pipelines FROM service_role CASCADE;

-- Drop tables in correct order
DROP TABLE IF EXISTS public.crm_notes CASCADE;
DROP TABLE IF EXISTS public.crm_documents CASCADE;
DROP TABLE IF EXISTS public.crm_communications CASCADE;
DROP TABLE IF EXISTS public.crm_relationships CASCADE;
DROP TABLE IF EXISTS public.crm_pipelines CASCADE;
DROP TABLE IF EXISTS public.crm_products CASCADE;
DROP TABLE IF EXISTS public.crm_referrals CASCADE;
DROP TABLE IF EXISTS public.crm_jobs CASCADE;

-- CRM Contacts table: Core contact and customer information
-- =====================================================================================
-- Description: Stores essential contact information and manages customer relationships
-- Dependencies: 
--   - auth.users (for user authentication and assignments)
--   - public.customer_type (for relationship classification)
--   - public.customer_status (for account status tracking)
--   - public.customer_segment_type (for business segmentation)
-- Notes: 
--   - Central contact information storage
--   - Supports both B2B and B2C relationships
--   - Includes social and professional networks
--   - Uses JSONB for flexible metadata storage
--   - Implements full audit trail
--   - Optimized for search and reporting
-- =====================================================================================

-- Create table
CREATE TABLE public.crm_contacts (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
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
    customer_segment public.customer_segment_type,
    lead_source VARCHAR(50),
    
    -- Relationship Management
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    account_manager UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    parent_company_id UUID REFERENCES public.crm_contacts(id) ON DELETE SET NULL,
    
    -- Contact Preferences
    preferred_communication_channel public.communication_channel,
    preferred_contact_time VARCHAR(50),
    communication_frequency VARCHAR(50),
    communication_language public.communication_language_type DEFAULT 'en',
    
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
    instagram_handle VARCHAR(100),
    
    -- Business Metrics
    total_revenue DECIMAL(15,2),
    lifetime_value DECIMAL(15,2),
    credit_limit DECIMAL(15,2),
    payment_terms INTEGER, -- Days
    
    -- Additional Information
    tags TEXT[],
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(first_name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(last_name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(company_name, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(notes, '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Constraints
    CONSTRAINT valid_name CHECK (
        first_name IS NOT NULL OR last_name IS NOT NULL
    ),
    CONSTRAINT valid_dates CHECK (
        (first_contact_date IS NULL OR last_contact_date IS NULL OR first_contact_date <= last_contact_date) AND
        (last_contact_date IS NULL OR next_follow_up_date IS NULL OR last_contact_date <= next_follow_up_date)
    ),
    CONSTRAINT valid_metrics CHECK (
        (total_revenue IS NULL OR total_revenue >= 0) AND
        (lifetime_value IS NULL OR lifetime_value >= 0) AND
        (credit_limit IS NULL OR credit_limit >= 0) AND
        (payment_terms IS NULL OR payment_terms >= 0)
    ),
    CONSTRAINT valid_metadata CHECK (jsonb_typeof(metadata) = 'object')
);

-- Add table comments
COMMENT ON TABLE public.crm_contacts IS 'Core table for managing customer and prospect information';
COMMENT ON COLUMN public.crm_contacts.id IS 'Unique identifier for the contact';
COMMENT ON COLUMN public.crm_contacts.first_name IS 'Contact''s first name';
COMMENT ON COLUMN public.crm_contacts.last_name IS 'Contact''s last name';
COMMENT ON COLUMN public.crm_contacts.full_name IS 'Computed full name from first and last name';
COMMENT ON COLUMN public.crm_contacts.company_name IS 'Name of the company the contact works for';
COMMENT ON COLUMN public.crm_contacts.customer_type IS 'Type of customer relationship';
COMMENT ON COLUMN public.crm_contacts.customer_status IS 'Current status of the customer';
COMMENT ON COLUMN public.crm_contacts.customer_segment IS 'Business segment classification';
COMMENT ON COLUMN public.crm_contacts.assigned_to IS 'User responsible for this contact';
COMMENT ON COLUMN public.crm_contacts.account_manager IS 'Account manager for this contact';
COMMENT ON COLUMN public.crm_contacts.metadata IS 'Additional flexible data stored as JSONB';
COMMENT ON COLUMN public.crm_contacts.search_vector IS 'Full text search vector';
COMMENT ON COLUMN public.crm_contacts.version IS 'Version number for optimistic locking';

-- Create indexes
CREATE INDEX idx_crm_contacts_name ON public.crm_contacts(full_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_contacts_company ON public.crm_contacts(company_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_contacts_customer ON public.crm_contacts(customer_type, customer_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_contacts_assigned ON public.crm_contacts(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_contacts_tags ON public.crm_contacts USING gin(tags) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_contacts_search ON public.crm_contacts USING gin(search_vector);
CREATE INDEX idx_crm_contacts_parent ON public.crm_contacts(parent_company_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_contacts_metrics ON public.crm_contacts(total_revenue, lifetime_value) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_contacts_dates ON public.crm_contacts(first_contact_date, last_contact_date, next_follow_up_date) WHERE deleted_at IS NULL;

-- Enable Row Level Security
ALTER TABLE public.crm_contacts ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view contacts they manage"
    ON public.crm_contacts FOR SELECT
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() = account_manager OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Users can manage their assigned contacts"
    ON public.crm_contacts FOR ALL
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() = account_manager OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() = assigned_to OR
        auth.uid() = account_manager OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Service role has full access to contacts"
    ON public.crm_contacts FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.crm_contacts TO authenticated;
GRANT ALL ON public.crm_contacts TO service_role;

-- Add triggers
CREATE TRIGGER audit_crm_contacts
    BEFORE INSERT OR UPDATE ON public.crm_contacts
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_audit_fields();

CREATE TRIGGER soft_delete_crm_contacts
    BEFORE DELETE ON public.crm_contacts
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_soft_delete();

-- CRM Leads table: Sales lead tracking and management
-- =====================================================================================
-- Description: Manages sales leads through their lifecycle from initial contact to conversion
-- Dependencies: 
--   - auth.users (for user authentication and assignments)
--   - public.lead_status (for lead stage tracking)
--   - public.lead_source (for lead origin tracking)
--   - public.crm_contacts (for contact association)
-- Notes: 
--   - Tracks lead lifecycle from capture to conversion
--   - Supports lead scoring and qualification
--   - Includes conversion tracking and analytics
--   - Uses JSONB for flexible metadata storage
--   - Implements full audit trail
--   - Optimized for sales pipeline reporting
-- =====================================================================================

-- Create table
CREATE TABLE public.crm_leads (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Lead Information
    title VARCHAR(255) NOT NULL,
    description TEXT,
    contact_id UUID REFERENCES public.crm_contacts(id) ON DELETE SET NULL,
    
    -- Lead Classification
    lead_status public.lead_status NOT NULL DEFAULT 'new',
    lead_source public.lead_source,
    lead_score INTEGER CHECK (lead_score >= 0 AND lead_score <= 100),
    
    -- Lead Details
    company_size VARCHAR(50),
    annual_revenue DECIMAL(15,2),
    budget_range VARCHAR(50),
    decision_timeline VARCHAR(50),
    
    -- Assignment and Ownership
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    
    -- Important Dates
    inquiry_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    qualification_date TIMESTAMPTZ,
    last_contact_date TIMESTAMPTZ,
    next_follow_up_date TIMESTAMPTZ,
    expected_close_date TIMESTAMPTZ,
    
    -- Lead Tracking
    campaign_id VARCHAR(100),
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),
    referral_source VARCHAR(100),
    
    -- Conversion Data
    is_converted BOOLEAN DEFAULT FALSE,
    converted_date TIMESTAMPTZ,
    converted_to_opportunity_id UUID,
    conversion_value DECIMAL(15,2),
    
    -- Additional Information
    tags TEXT[],
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(notes, '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Constraints
    CONSTRAINT valid_dates CHECK (
        (inquiry_date IS NULL OR qualification_date IS NULL OR inquiry_date <= qualification_date) AND
        (last_contact_date IS NULL OR next_follow_up_date IS NULL OR last_contact_date <= next_follow_up_date) AND
        (inquiry_date IS NULL OR expected_close_date IS NULL OR inquiry_date <= expected_close_date)
    ),
    CONSTRAINT valid_conversion CHECK (
        (NOT is_converted OR converted_date IS NOT NULL) AND
        (NOT is_converted OR converted_to_opportunity_id IS NOT NULL)
    ),
    CONSTRAINT valid_metadata CHECK (jsonb_typeof(metadata) = 'object')
);

-- Add table comments
COMMENT ON TABLE public.crm_leads IS 'Tracks and manages sales leads through their lifecycle';
COMMENT ON COLUMN public.crm_leads.id IS 'Unique identifier for the lead';
COMMENT ON COLUMN public.crm_leads.title IS 'Title or name of the lead opportunity';
COMMENT ON COLUMN public.crm_leads.contact_id IS 'Associated contact for this lead';
COMMENT ON COLUMN public.crm_leads.lead_status IS 'Current status in the lead lifecycle';
COMMENT ON COLUMN public.crm_leads.lead_score IS 'Numeric score indicating lead quality (0-100)';
COMMENT ON COLUMN public.crm_leads.assigned_to IS 'User responsible for this lead';
COMMENT ON COLUMN public.crm_leads.is_converted IS 'Whether the lead has been converted to an opportunity';
COMMENT ON COLUMN public.crm_leads.metadata IS 'Additional flexible data stored as JSONB';
COMMENT ON COLUMN public.crm_leads.search_vector IS 'Full text search vector';
COMMENT ON COLUMN public.crm_leads.version IS 'Version number for optimistic locking';

-- Create indexes
CREATE INDEX idx_crm_leads_contact ON public.crm_leads(contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_leads_status ON public.crm_leads(lead_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_leads_source ON public.crm_leads(lead_source) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_leads_assigned ON public.crm_leads(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_leads_score ON public.crm_leads(lead_score) WHERE deleted_at IS NULL AND NOT is_converted;
CREATE INDEX idx_crm_leads_dates ON public.crm_leads(inquiry_date, qualification_date, expected_close_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_leads_search ON public.crm_leads USING gin(search_vector);

-- Enable Row Level Security
ALTER TABLE public.crm_leads ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their leads"
    ON public.crm_leads FOR SELECT
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Users can manage their assigned leads"
    ON public.crm_leads FOR ALL
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Service role has full access to leads"
    ON public.crm_leads FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.crm_leads TO authenticated;
GRANT ALL ON public.crm_leads TO service_role;

-- Add triggers
CREATE TRIGGER audit_crm_leads
    BEFORE INSERT OR UPDATE ON public.crm_leads
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_audit_fields();

CREATE TRIGGER soft_delete_crm_leads
    BEFORE DELETE ON public.crm_leads
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_soft_delete();

-- CRM Opportunities table: Sales opportunity tracking and pipeline management
-- =====================================================================================
-- Description: Manages sales opportunities through the sales pipeline
-- Dependencies: 
--   - auth.users (for user authentication and assignments)
--   - public.opportunity_status (for pipeline stage tracking)
--   - public.crm_contacts (for customer association)
--   - public.crm_leads (for lead conversion tracking)
--   - public.currency_type (for monetary values)
-- Notes: 
--   - Tracks opportunities through sales pipeline stages
--   - Supports revenue forecasting and pipeline analytics
--   - Includes win/loss tracking and analysis
--   - Uses JSONB for flexible metadata storage
--   - Implements full audit trail
--   - Optimized for sales reporting and forecasting
-- =====================================================================================

-- Create table
CREATE TABLE public.crm_opportunities (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Opportunity Information
    name VARCHAR(255) NOT NULL,
    description TEXT,
    contact_id UUID NOT NULL REFERENCES public.crm_contacts(id) ON DELETE RESTRICT,
    lead_id UUID REFERENCES public.crm_leads(id) ON DELETE SET NULL,
    
    -- Pipeline Information
    opportunity_status public.opportunity_status NOT NULL DEFAULT 'qualification',
    probability INTEGER CHECK (probability >= 0 AND probability <= 100),
    win_reason TEXT,
    loss_reason TEXT,
    competitor TEXT,
    
    -- Financial Information
    currency public.currency_type NOT NULL DEFAULT 'USD',
    amount DECIMAL(15,2) NOT NULL CHECK (amount >= 0),
    expected_revenue DECIMAL(15,2) GENERATED ALWAYS AS (amount * probability / 100) STORED,
    
    -- Assignment and Ownership
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    
    -- Important Dates
    start_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    close_date TIMESTAMPTZ,
    last_activity_date TIMESTAMPTZ,
    next_step_date TIMESTAMPTZ,
    
    -- Product Information
    products JSONB DEFAULT '[]'::jsonb,
    total_products INTEGER GENERATED ALWAYS AS (jsonb_array_length(products)) STORED,
    
    -- Additional Information
    tags TEXT[],
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(notes, '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Constraints
    CONSTRAINT valid_dates CHECK (
        (start_date IS NULL OR close_date IS NULL OR start_date <= close_date) AND
        (last_activity_date IS NULL OR next_step_date IS NULL OR last_activity_date <= next_step_date)
    ),
    CONSTRAINT valid_status_reason CHECK (
        (opportunity_status != 'won' OR win_reason IS NOT NULL) AND
        (opportunity_status != 'lost' OR loss_reason IS NOT NULL)
    ),
    CONSTRAINT valid_products CHECK (jsonb_typeof(products) = 'array'),
    CONSTRAINT valid_metadata CHECK (jsonb_typeof(metadata) = 'object')
);

-- Add table comments
COMMENT ON TABLE public.crm_opportunities IS 'Tracks and manages sales opportunities through the pipeline';
COMMENT ON COLUMN public.crm_opportunities.id IS 'Unique identifier for the opportunity';
COMMENT ON COLUMN public.crm_opportunities.name IS 'Name or title of the sales opportunity';
COMMENT ON COLUMN public.crm_opportunities.contact_id IS 'Associated customer contact';
COMMENT ON COLUMN public.crm_opportunities.lead_id IS 'Original lead if converted';
COMMENT ON COLUMN public.crm_opportunities.opportunity_status IS 'Current stage in sales pipeline';
COMMENT ON COLUMN public.crm_opportunities.probability IS 'Likelihood of winning (0-100)';
COMMENT ON COLUMN public.crm_opportunities.amount IS 'Total value of the opportunity';
COMMENT ON COLUMN public.crm_opportunities.expected_revenue IS 'Calculated expected revenue based on amount and probability';
COMMENT ON COLUMN public.crm_opportunities.products IS 'Array of product information';
COMMENT ON COLUMN public.crm_opportunities.metadata IS 'Additional flexible data stored as JSONB';
COMMENT ON COLUMN public.crm_opportunities.search_vector IS 'Full text search vector';
COMMENT ON COLUMN public.crm_opportunities.version IS 'Version number for optimistic locking';

-- Create indexes
CREATE INDEX idx_crm_opportunities_contact ON public.crm_opportunities(contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_opportunities_lead ON public.crm_opportunities(lead_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_opportunities_status ON public.crm_opportunities(opportunity_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_opportunities_assigned ON public.crm_opportunities(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_opportunities_dates ON public.crm_opportunities(start_date, close_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_opportunities_value ON public.crm_opportunities(amount, expected_revenue) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_opportunities_search ON public.crm_opportunities USING gin(search_vector);

-- Enable Row Level Security
ALTER TABLE public.crm_opportunities ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their opportunities"
    ON public.crm_opportunities FOR SELECT
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Users can manage their assigned opportunities"
    ON public.crm_opportunities FOR ALL
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Service role has full access to opportunities"
    ON public.crm_opportunities FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.crm_opportunities TO authenticated;
GRANT ALL ON public.crm_opportunities TO service_role;

-- Add triggers
CREATE TRIGGER audit_crm_opportunities
    BEFORE INSERT OR UPDATE ON public.crm_opportunities
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_audit_fields();

CREATE TRIGGER soft_delete_crm_opportunities
    BEFORE DELETE ON public.crm_opportunities
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_soft_delete();

-- CRM Quotes table: Sales quotation and proposal management
-- =====================================================================================
-- Description: Manages sales quotes and proposals through their lifecycle
-- Dependencies: 
--   - auth.users (for user authentication and assignments)
--   - public.quote_status (for quote lifecycle tracking)
--   - public.crm_contacts (for customer association)
--   - public.crm_opportunities (for opportunity association)
--   - public.currency_type (for monetary values)
-- Notes: 
--   - Tracks quotes through approval and acceptance process
--   - Supports multiple quote versions and revisions
--   - Includes product line items and pricing
--   - Uses JSONB for flexible metadata storage
--   - Implements full audit trail
--   - Optimized for quote generation and tracking
-- =====================================================================================

-- Create table
CREATE TABLE public.crm_quotes (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Quote Information
    quote_number VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    contact_id UUID NOT NULL REFERENCES public.crm_contacts(id) ON DELETE RESTRICT,
    opportunity_id UUID REFERENCES public.crm_opportunities(id) ON DELETE SET NULL,
    
    -- Quote Status
    quote_status public.quote_status NOT NULL DEFAULT 'draft',
    version_number INTEGER NOT NULL DEFAULT 1,
    parent_quote_id UUID REFERENCES public.crm_quotes(id) ON DELETE SET NULL,
    
    -- Financial Information
    currency public.currency_type NOT NULL DEFAULT 'USD',
    subtotal DECIMAL(15,2) NOT NULL CHECK (subtotal >= 0),
    discount_amount DECIMAL(15,2) DEFAULT 0 CHECK (discount_amount >= 0),
    tax_amount DECIMAL(15,2) DEFAULT 0 CHECK (tax_amount >= 0),
    total_amount DECIMAL(15,2) GENERATED ALWAYS AS (
        subtotal - COALESCE(discount_amount, 0) + COALESCE(tax_amount, 0)
    ) STORED,
    
    -- Line Items
    line_items JSONB NOT NULL DEFAULT '[]'::jsonb,
    total_items INTEGER GENERATED ALWAYS AS (jsonb_array_length(line_items)) STORED,
    
    -- Terms and Conditions
    payment_terms TEXT,
    delivery_terms TEXT,
    validity_period INTEGER, -- Days
    
    -- Assignment and Ownership
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    
    -- Important Dates
    issue_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date TIMESTAMPTZ,
    acceptance_date TIMESTAMPTZ,
    rejection_date TIMESTAMPTZ,
    
    -- Additional Information
    tags TEXT[],
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(quote_number, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(notes, '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Constraints
    CONSTRAINT valid_dates CHECK (
        (issue_date IS NULL OR expiry_date IS NULL OR issue_date <= expiry_date) AND
        (issue_date IS NULL OR acceptance_date IS NULL OR issue_date <= acceptance_date) AND
        (issue_date IS NULL OR rejection_date IS NULL OR issue_date <= rejection_date)
    ),
    CONSTRAINT valid_status_dates CHECK (
        (quote_status != 'accepted' OR acceptance_date IS NOT NULL) AND
        (quote_status != 'rejected' OR rejection_date IS NOT NULL)
    ),
    CONSTRAINT valid_line_items CHECK (jsonb_typeof(line_items) = 'array'),
    CONSTRAINT valid_metadata CHECK (jsonb_typeof(metadata) = 'object')
);

-- Add table comments
COMMENT ON TABLE public.crm_quotes IS 'Tracks and manages sales quotes and proposals';
COMMENT ON COLUMN public.crm_quotes.id IS 'Unique identifier for the quote';
COMMENT ON COLUMN public.crm_quotes.quote_number IS 'Unique quote reference number';
COMMENT ON COLUMN public.crm_quotes.contact_id IS 'Associated customer contact';
COMMENT ON COLUMN public.crm_quotes.opportunity_id IS 'Associated sales opportunity';
COMMENT ON COLUMN public.crm_quotes.quote_status IS 'Current status in quote lifecycle';
COMMENT ON COLUMN public.crm_quotes.version_number IS 'Quote version for revision tracking';
COMMENT ON COLUMN public.crm_quotes.total_amount IS 'Calculated total amount including tax and discounts';
COMMENT ON COLUMN public.crm_quotes.line_items IS 'Array of product/service line items';
COMMENT ON COLUMN public.crm_quotes.metadata IS 'Additional flexible data stored as JSONB';
COMMENT ON COLUMN public.crm_quotes.search_vector IS 'Full text search vector';
COMMENT ON COLUMN public.crm_quotes.version IS 'Version number for optimistic locking';

-- Create indexes
CREATE INDEX idx_crm_quotes_contact ON public.crm_quotes(contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_quotes_opportunity ON public.crm_quotes(opportunity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_quotes_status ON public.crm_quotes(quote_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_quotes_assigned ON public.crm_quotes(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_quotes_dates ON public.crm_quotes(issue_date, expiry_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_quotes_value ON public.crm_quotes(total_amount) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_quotes_search ON public.crm_quotes USING gin(search_vector);

-- Enable Row Level Security
ALTER TABLE public.crm_quotes ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their quotes"
    ON public.crm_quotes FOR SELECT
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Users can manage their assigned quotes"
    ON public.crm_quotes FOR ALL
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() = assigned_to OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Service role has full access to quotes"
    ON public.crm_quotes FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.crm_quotes TO authenticated;
GRANT ALL ON public.crm_quotes TO service_role;

-- Add triggers
CREATE TRIGGER audit_crm_quotes
    BEFORE INSERT OR UPDATE ON public.crm_quotes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_audit_fields();

CREATE TRIGGER soft_delete_crm_quotes
    BEFORE DELETE ON public.crm_quotes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_soft_delete();

-- CRM Jobs table: Scheduled work or services
-- =====================================================================================
-- Description:
--   Core table for managing scheduled jobs and services in the CRM system.
--   Supports comprehensive job lifecycle tracking, resource management, and team coordination.
--   Integrates with opportunities, quotes, and contact management.
--
-- Dependencies:
--   1. Authentication & Users:
--      - auth.users (for user references and assignments)
--      - public.user_roles (for role-based access)
--
--   2. Related Tables:
--      - public.crm_opportunities (for associated opportunities)
--      - public.crm_quotes (for associated quotes)
--      - public.crm_contacts (for customer contacts)
--
--   3. Enumeration Types:
--      - public.job_status (scheduled, in_progress, completed, etc.)
--      - public.job_priority (low, medium, high, urgent)
--
-- Notes:
--   1. Job Management:
--      - Tracks complete job lifecycle
--      - Manages resources and equipment
--      - Supports team coordination
--
--   2. Resource Tracking:
--      - Equipment allocation
--      - Cost estimation and tracking
--      - Time management
--
--   3. Performance & Security:
--      - Implements RLS for data isolation
--      - Optimized indexes for common queries
--      - Audit trail for changes

-- Drop existing objects
DROP TRIGGER IF EXISTS set_timestamp_crm_jobs ON public.crm_jobs CASCADE;
DROP TRIGGER IF EXISTS handle_updated_at ON public.crm_jobs CASCADE;

-- Drop existing indexes
DROP INDEX IF EXISTS idx_crm_jobs_number CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_status CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_contact CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_dates CASCADE;
DROP INDEX IF EXISTS idx_crm_jobs_priority CASCADE;

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view jobs they manage" ON public.crm_jobs CASCADE;
DROP POLICY IF EXISTS "Users can manage their assigned jobs" ON public.crm_jobs CASCADE;

-- Drop table if exists
DROP TABLE IF EXISTS public.crm_jobs CASCADE;

-- Revoke permissions
REVOKE ALL ON public.crm_jobs FROM authenticated CASCADE;
REVOKE ALL ON public.crm_jobs FROM service_role CASCADE;

-- Create table
CREATE TABLE public.crm_jobs (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Relationships
    contact_id UUID NOT NULL REFERENCES public.crm_contacts(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    opportunity_id UUID REFERENCES public.crm_opportunities(id) ON DELETE SET NULL ON UPDATE CASCADE,
    quote_id UUID REFERENCES public.crm_quotes(id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Job Details
    title TEXT NOT NULL,
    description TEXT,
    status public.job_status DEFAULT 'scheduled' NOT NULL,
    priority public.job_priority DEFAULT 'medium' NOT NULL,
    
    -- Scheduling
    scheduled_start TIMESTAMPTZ NOT NULL,
    scheduled_end TIMESTAMPTZ NOT NULL,
    actual_start TIMESTAMPTZ,
    actual_end TIMESTAMPTZ,
    duration_minutes INTEGER GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (COALESCE(actual_end, scheduled_end) - COALESCE(actual_start, scheduled_start)))/60
    ) STORED,
    
    -- Location
    location JSONB,
    site_requirements TEXT,
    access_instructions TEXT,
    
    -- Team Management
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    team_members UUID[] DEFAULT ARRAY[]::UUID[],
    team_notes TEXT,
    
    -- Equipment and Resources
    equipment_needed TEXT[],
    equipment_status JSONB DEFAULT '{}'::JSONB,
    resource_allocation JSONB DEFAULT '{}'::JSONB,
    
    -- Financial Tracking
    estimated_cost DECIMAL(15,2),
    actual_cost DECIMAL(15,2),
    cost_breakdown JSONB DEFAULT '{}'::JSONB,
    billing_status public.billing_status DEFAULT 'pending',
    
    -- Progress Tracking
    completion_percentage INTEGER DEFAULT 0,
    milestones JSONB DEFAULT '[]'::JSONB,
    checklist JSONB DEFAULT '[]'::JSONB,
    
    -- Documentation
    notes TEXT,
    work_logs JSONB DEFAULT '[]'::JSONB,
    attachments JSONB DEFAULT '[]'::JSONB,
    
    -- Additional Information
    tags TEXT[],
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(notes, '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT valid_schedule CHECK (scheduled_end > scheduled_start),
    CONSTRAINT valid_actual_time CHECK (
        (actual_end IS NULL) OR 
        (actual_start IS NOT NULL AND actual_end > actual_start)
    ),
    CONSTRAINT valid_completion CHECK (
        completion_percentage BETWEEN 0 AND 100
    ),
    CONSTRAINT valid_costs CHECK (
        (estimated_cost IS NULL OR estimated_cost >= 0) AND
        (actual_cost IS NULL OR actual_cost >= 0)
    )
);

-- Add comments
COMMENT ON TABLE public.crm_jobs IS 'Core table for managing scheduled jobs and services';
COMMENT ON COLUMN public.crm_jobs.id IS 'Unique identifier for the job';
COMMENT ON COLUMN public.crm_jobs.job_number IS 'Unique business reference number';
COMMENT ON COLUMN public.crm_jobs.version IS 'Version number for optimistic locking';
COMMENT ON COLUMN public.crm_jobs.duration_minutes IS 'Calculated duration in minutes';
COMMENT ON COLUMN public.crm_jobs.equipment_status IS 'Status and condition of assigned equipment';
COMMENT ON COLUMN public.crm_jobs.work_logs IS 'Detailed logs of work performed';
COMMENT ON COLUMN public.crm_jobs.billing_status IS 'Current billing status of the job';

-- Create indexes
CREATE INDEX idx_crm_jobs_number ON public.crm_jobs(job_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_jobs_status ON public.crm_jobs(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_jobs_contact ON public.crm_jobs(contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_jobs_dates ON public.crm_jobs(scheduled_start, scheduled_end) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_jobs_priority ON public.crm_jobs(priority) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_jobs_completion ON public.crm_jobs(completion_percentage) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_jobs_billing ON public.crm_jobs(billing_status) WHERE deleted_at IS NULL;

-- Add missing indexes for CRM Jobs
CREATE INDEX idx_crm_jobs_team ON public.crm_jobs USING gin(team_members);
CREATE INDEX idx_crm_jobs_equipment ON public.crm_jobs USING gin(equipment_needed);

-- Enable Row Level Security
ALTER TABLE public.crm_jobs ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view jobs they manage"
    ON public.crm_jobs
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() = ANY(team_members) OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'service_manager', 'crm_admin') AND deleted_at IS NULL
        )
    );

CREATE POLICY "Users can manage their assigned jobs"
    ON public.crm_jobs
    FOR ALL
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() = ANY(team_members) OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'service_manager', 'crm_admin') AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() = assigned_to OR
        auth.uid() = ANY(team_members) OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'service_manager', 'crm_admin') AND deleted_at IS NULL
        )
    );

-- Grant permissions
GRANT SELECT ON public.crm_jobs TO authenticated;
GRANT ALL ON public.crm_jobs TO service_role;

-- Add trigger
CREATE TRIGGER set_timestamp_crm_jobs
    BEFORE UPDATE ON public.crm_jobs
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- CRM Referrals table: Tracks customer referrals and referral program management
-- =====================================================================================
-- Description:
--   Core table for managing customer referrals and referral programs in the CRM system.
--   Supports comprehensive referral tracking, conversion metrics, and reward management.
--   Integrates with contacts, opportunities, and campaign management.
--
-- Dependencies:
--   1. Authentication & Users:
--      - auth.users (for user references and assignments)
--      - public.user_roles (for role-based access)
--
--   2. Related Tables:
--      - public.crm_contacts (for referrer and referee contacts)
--      - public.crm_opportunities (for conversion tracking)
--      - public.crm_campaigns (for referral program campaigns)
--
--   3. Enumeration Types:
--      - public.referral_status (pending, accepted, converted, etc.)
--      - public.referral_type (customer, partner, employee, etc.)
--
-- Notes:
--   1. Referral Management:
--      - Tracks complete referral lifecycle
--      - Manages reward programs
--      - Supports multi-level referrals
--
--   2. Conversion Tracking:
--      - Records conversion metrics
--      - Tracks reward distribution
--      - Maintains referral history
--
--   3. Performance & Security:
--      - Implements RLS for data isolation
--      - Optimized indexes for common queries
--      - Audit trail for changes

-- Drop existing objects
DROP TRIGGER IF EXISTS set_timestamp_crm_referrals ON public.crm_referrals CASCADE;
DROP TRIGGER IF EXISTS handle_updated_at ON public.crm_referrals CASCADE;

-- Drop existing indexes
DROP INDEX IF EXISTS idx_crm_referrals_referrer CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_referee CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_status CASCADE;
DROP INDEX IF EXISTS idx_crm_referrals_type CASCADE;

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view referrals they manage" ON public.crm_referrals CASCADE;
DROP POLICY IF EXISTS "Users can manage referrals" ON public.crm_referrals CASCADE;

-- Drop table if exists
DROP TABLE IF EXISTS public.crm_referrals CASCADE;

-- Revoke permissions
REVOKE ALL ON public.crm_referrals FROM authenticated CASCADE;
REVOKE ALL ON public.crm_referrals FROM service_role CASCADE;

-- Create table
CREATE TABLE public.crm_referrals (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referral_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Relationships
    referrer_id UUID NOT NULL REFERENCES public.crm_contacts(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    referee_id UUID NOT NULL REFERENCES public.crm_contacts(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    opportunity_id UUID REFERENCES public.crm_opportunities(id) ON DELETE SET NULL ON UPDATE CASCADE,
    campaign_id UUID REFERENCES public.crm_campaigns(id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Referral Details
    referral_type TEXT NOT NULL,
    status public.referral_status DEFAULT 'pending' NOT NULL,
    source TEXT,
    description TEXT,
    
    -- Contact Information
    referee_email TEXT,
    referee_phone TEXT,
    preferred_contact_method TEXT,
    
    -- Program Details
    program_name TEXT,
    reward_type TEXT,
    reward_value DECIMAL(15,2),
    reward_status public.reward_status DEFAULT 'pending',
    reward_notes TEXT,
    
    -- Conversion Tracking
    is_converted BOOLEAN DEFAULT FALSE,
    converted_at TIMESTAMPTZ,
    converted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    conversion_value DECIMAL(15,2),
    conversion_notes TEXT,
    conversion_metrics JSONB DEFAULT '{}'::jsonb,
    
    -- Multi-level Referral
    parent_referral_id UUID REFERENCES public.crm_referrals(id) ON DELETE SET NULL ON UPDATE CASCADE,
    child_referrals UUID[] DEFAULT ARRAY[]::UUID[],
    referral_level INTEGER DEFAULT 1,
    
    -- Communication
    last_contact_date TIMESTAMPTZ,
    next_followup_date TIMESTAMPTZ,
    communication_history JSONB DEFAULT '[]'::jsonb,
    
    -- Documentation
    notes TEXT,
    attachments JSONB DEFAULT '[]'::jsonb,
    
    -- Additional Information
    tags TEXT[],
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(referral_number, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(notes, '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT valid_referral CHECK (referrer_id != referee_id),
    CONSTRAINT valid_conversion CHECK (
        (NOT is_converted OR converted_at IS NOT NULL AND converted_by IS NOT NULL AND conversion_value IS NOT NULL) OR
        (is_converted AND converted_at IS NOT NULL AND converted_by IS NOT NULL)
    ),
    CONSTRAINT valid_values CHECK (
        (reward_value IS NULL OR reward_value >= 0) AND
        (conversion_value IS NULL OR conversion_value >= 0)
    ),
    CONSTRAINT valid_referral_level CHECK (referral_level > 0)
);

-- Add comments
COMMENT ON TABLE public.crm_referrals IS 'Core table for managing customer referrals and referral programs';
COMMENT ON COLUMN public.crm_referrals.id IS 'Unique identifier for the referral';
COMMENT ON COLUMN public.crm_referrals.referral_number IS 'Unique business reference number';
COMMENT ON COLUMN public.crm_referrals.version IS 'Version number for optimistic locking';
COMMENT ON COLUMN public.crm_referrals.referrer_id IS 'Contact who made the referral';
COMMENT ON COLUMN public.crm_referrals.referee_id IS 'Contact who was referred';
COMMENT ON COLUMN public.crm_referrals.conversion_metrics IS 'Detailed metrics about the conversion';
COMMENT ON COLUMN public.crm_referrals.communication_history IS 'History of communications regarding this referral';

-- Create indexes
CREATE INDEX idx_crm_referrals_number ON public.crm_referrals(referral_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_referrals_referrer ON public.crm_referrals(referrer_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_referrals_referee ON public.crm_referrals(referee_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_referrals_status ON public.crm_referrals(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_referrals_type ON public.crm_referrals(referral_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_referrals_program ON public.crm_referrals(program_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_referrals_conversion ON public.crm_referrals(is_converted, converted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_referrals_reward ON public.crm_referrals(reward_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_referrals_dates ON public.crm_referrals(last_contact_date, next_followup_date) WHERE deleted_at IS NULL;

-- Add missing indexes for CRM Referrals
CREATE INDEX idx_crm_referrals_tags ON public.crm_referrals USING gin(tags);
CREATE INDEX idx_crm_referrals_child ON public.crm_referrals USING gin(child_referrals);

-- Enable Row Level Security
ALTER TABLE public.crm_referrals ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view referrals they manage"
    ON public.crm_referrals
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        ) OR
        auth.uid() = created_by OR
        auth.uid() = converted_by
    );

CREATE POLICY "Users can manage referrals"
    ON public.crm_referrals
    FOR ALL
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

-- Grant permissions
GRANT SELECT ON public.crm_referrals TO authenticated;
GRANT ALL ON public.crm_referrals TO service_role;

-- Add trigger
CREATE TRIGGER set_timestamp_crm_referrals
    BEFORE UPDATE ON public.crm_referrals
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- CRM Products table: Product and service catalog management
-- =====================================================================================
-- Description:
--   Core table for managing products and services in the CRM system.
--   Supports comprehensive product lifecycle, pricing strategies, and inventory tracking.
--   Integrates with opportunities, quotes, and order management.
--
-- Dependencies:
--   1. Authentication & Users:
--      - auth.users (for user references and assignments)
--      - public.user_roles (for role-based access)
--
--   2. Related Tables:
--      - public.crm_opportunities (for product opportunities)
--      - public.crm_quotes (for product quotes)
--      - public.crm_categories (for product categorization)
--
--   3. Enumeration Types:
--      - public.product_status (active, discontinued, etc.)
--      - public.product_type (physical, digital, service, etc.)
--
-- Notes:
--   1. Product Management:
--      - Complete product lifecycle tracking
--      - Multiple pricing tiers
--      - Inventory management
--      - Product variants
--
--   2. Pricing & Revenue:
--      - Dynamic pricing support
--      - Cost tracking
--      - Revenue analytics
--      - Discount management
--
--   3. Performance & Security:
--      - Implements RLS for data isolation
--      - Optimized indexes for common queries
--      - Audit trail for changes

-- Drop existing objects
DROP TRIGGER IF EXISTS set_timestamp_crm_products ON public.crm_products CASCADE;
DROP TRIGGER IF EXISTS handle_updated_at ON public.crm_products CASCADE;

-- Drop existing indexes
DROP INDEX IF EXISTS idx_crm_products_sku CASCADE;
DROP INDEX IF EXISTS idx_crm_products_status CASCADE;
DROP INDEX IF EXISTS idx_crm_products_category CASCADE;
DROP INDEX IF EXISTS idx_crm_products_search CASCADE;

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view products" ON public.crm_products CASCADE;
DROP POLICY IF EXISTS "Users can manage products" ON public.crm_products CASCADE;

-- Drop table if exists
DROP TABLE IF EXISTS public.crm_products CASCADE;

-- Revoke permissions
REVOKE ALL ON public.crm_products FROM authenticated CASCADE;
REVOKE ALL ON public.crm_products FROM service_role CASCADE;

-- Create table
CREATE TABLE public.crm_products (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Basic Information
    name TEXT NOT NULL,
    description TEXT,
    product_type public.product_type NOT NULL,
    status public.product_status DEFAULT 'active' NOT NULL,
    
    -- Categorization
    category_id UUID REFERENCES public.crm_categories(id) ON DELETE SET NULL ON UPDATE CASCADE,
    subcategory_id UUID REFERENCES public.crm_categories(id) ON DELETE SET NULL ON UPDATE CASCADE,
    tags TEXT[],
    
    -- Pricing
    base_price DECIMAL(15,2) NOT NULL,
    cost_price DECIMAL(15,2),
    pricing_tiers JSONB DEFAULT '[]'::jsonb,
    discount_rules JSONB DEFAULT '{}'::jsonb,
    tax_rate DECIMAL(5,2),
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Inventory
    sku_variants JSONB DEFAULT '[]'::jsonb,
    stock_quantity INTEGER,
    low_stock_threshold INTEGER,
    reorder_point INTEGER,
    reorder_quantity INTEGER,
    inventory_status TEXT,
    
    -- Product Details
    specifications JSONB DEFAULT '{}'::JSONB,
    features TEXT[],
    benefits TEXT[],
    dimensions JSONB DEFAULT '{}'::JSONB,
    weight DECIMAL(10,2),
    weight_unit VARCHAR(10),
    
    -- Digital Product
    is_digital BOOLEAN DEFAULT FALSE,
    digital_delivery_method TEXT,
    download_url TEXT,
    license_terms TEXT,
    
    -- Service Product
    is_service BOOLEAN DEFAULT FALSE,
    service_duration INTEGER,
    service_unit TEXT,
    delivery_method TEXT,
    
    -- Marketing
    short_description TEXT,
    long_description TEXT,
    highlights TEXT[],
    keywords TEXT[],
    meta_title TEXT,
    meta_description TEXT,
    
    -- Media
    primary_image_url TEXT,
    image_urls TEXT[],
    video_urls TEXT[],
    document_urls TEXT[],
    
    -- Relationships
    related_products UUID[],
    substitute_products UUID[],
    bundle_products JSONB DEFAULT '[]'::jsonb,
    
    -- Analytics
    view_count INTEGER DEFAULT 0,
    purchase_count INTEGER DEFAULT 0,
    rating_average DECIMAL(3,2),
    review_count INTEGER DEFAULT 0,
    performance_metrics JSONB DEFAULT '{}'::jsonb,
    
    -- Additional Information
    notes TEXT,
    internal_notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(array_to_string(tags, ' '), '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT valid_prices CHECK (
        base_price >= 0 AND
        (cost_price IS NULL OR cost_price >= 0) AND
        (tax_rate IS NULL OR tax_rate >= 0)
    ),
    CONSTRAINT valid_inventory CHECK (
        (stock_quantity IS NULL OR stock_quantity >= 0) AND
        (low_stock_threshold IS NULL OR low_stock_threshold >= 0) AND
        (reorder_point IS NULL OR reorder_point >= 0) AND
        (reorder_quantity IS NULL OR reorder_quantity > 0)
    ),
    CONSTRAINT valid_service CHECK (
        (NOT is_service OR service_duration IS NOT NULL) AND
        (NOT is_service OR service_unit IS NOT NULL)
    ),
    CONSTRAINT valid_metrics CHECK (
        view_count >= 0 AND
        purchase_count >= 0 AND
        (rating_average IS NULL OR (rating_average >= 0 AND rating_average <= 5)) AND
        review_count >= 0
    )
);

-- Add comments
COMMENT ON TABLE public.crm_products IS 'Core table for managing products and services';
COMMENT ON COLUMN public.crm_products.id IS 'Unique identifier for the product';
COMMENT ON COLUMN public.crm_products.sku IS 'Stock keeping unit - unique product identifier';
COMMENT ON COLUMN public.crm_products.version IS 'Version number for optimistic locking';
COMMENT ON COLUMN public.crm_products.pricing_tiers IS 'Different pricing tiers and volume discounts';
COMMENT ON COLUMN public.crm_products.sku_variants IS 'Product variations (size, color, etc.)';
COMMENT ON COLUMN public.crm_products.specifications IS 'Technical specifications and details';
COMMENT ON COLUMN public.crm_products.performance_metrics IS 'Sales and performance analytics';

-- Create indexes
CREATE INDEX idx_crm_products_sku ON public.crm_products(sku) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_products_name ON public.crm_products(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_products_status ON public.crm_products(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_products_type ON public.crm_products(product_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_products_category ON public.crm_products(category_id, subcategory_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_products_price ON public.crm_products(base_price) WHERE deleted_at IS NULL AND status = 'active';
CREATE INDEX idx_crm_products_inventory ON public.crm_products(stock_quantity) 
    WHERE deleted_at IS NULL AND status = 'active' AND NOT is_digital AND NOT is_service;
CREATE INDEX idx_crm_products_search ON public.crm_products USING gin(search_vector);

-- Add missing indexes for CRM Products
CREATE INDEX idx_crm_products_related ON public.crm_products USING gin(related_products);
CREATE INDEX idx_crm_products_features ON public.crm_products USING gin(features);

-- Enable Row Level Security
ALTER TABLE public.crm_products ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view active products"
    ON public.crm_products
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL AND
        status = 'active'
    );

CREATE POLICY "Users can manage products"
    ON public.crm_products
    FOR ALL
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'product_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'product_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

-- Grant permissions
GRANT SELECT ON public.crm_products TO authenticated;
GRANT ALL ON public.crm_products TO service_role;

-- Add trigger
CREATE TRIGGER set_timestamp_crm_products
    BEFORE UPDATE ON public.crm_products
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- CRM Pipelines table: Sales process and pipeline management
-- =====================================================================================
-- Description:
--   Core table for managing sales pipelines and processes in the CRM system.
--   Supports multiple pipeline configurations, stage management, and automation rules.
--   Integrates with opportunities, leads, and analytics.
--
-- Dependencies:
--   1. Authentication & Users:
--      - auth.users (for user references and assignments)
--      - public.user_roles (for role-based access)
--
--   2. Related Tables:
--      - public.crm_opportunities (for pipeline stages)
--      - public.crm_leads (for pipeline stages)
--
-- Notes:
--   1. Pipeline Management:
--      - Multiple pipeline support
--      - Stage configuration
--      - Automation rules
--
--   2. Analytics & Reporting:
--      - Pipeline performance metrics
--      - Conversion analytics
--      - Stage duration tracking
--
--   3. Performance & Security:
--      - Implements RLS for data isolation
--      - Optimized indexes for common queries
--      - Audit trail for changes

-- Drop existing objects
DROP TRIGGER IF EXISTS set_timestamp_crm_pipelines ON public.crm_pipelines CASCADE;
DROP TRIGGER IF EXISTS handle_updated_at ON public.crm_pipelines CASCADE;

-- Drop existing indexes
DROP INDEX IF EXISTS idx_crm_pipelines_name CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_status CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_type CASCADE;
DROP INDEX IF EXISTS idx_crm_pipelines_search CASCADE;

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view pipelines" ON public.crm_pipelines CASCADE;
DROP POLICY IF EXISTS "Users can manage pipelines" ON public.crm_pipelines CASCADE;

-- Drop table if exists
DROP TABLE IF EXISTS public.crm_pipelines CASCADE;

-- Revoke permissions
REVOKE ALL ON public.crm_pipelines FROM authenticated CASCADE;
REVOKE ALL ON public.crm_pipelines FROM service_role CASCADE;

-- Create table
CREATE TABLE public.crm_pipelines (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Basic Information
    name TEXT NOT NULL,
    description TEXT,
    pipeline_type public.pipeline_type NOT NULL,
    status public.pipeline_status DEFAULT 'active' NOT NULL,
    
    -- Pipeline Configuration
    stages JSONB NOT NULL DEFAULT '[]'::JSONB,
    stage_requirements JSONB DEFAULT '{}'::JSONB,
    stage_automations JSONB DEFAULT '{}'::JSONB,
    stage_notifications JSONB DEFAULT '{}'::JSONB,
    
    -- Pipeline Settings
    is_default BOOLEAN DEFAULT false,
    allow_skip_stages BOOLEAN DEFAULT false,
    require_stage_completion BOOLEAN DEFAULT true,
    auto_progress_enabled BOOLEAN DEFAULT false,
    
    -- Time Management
    stage_slas JSONB DEFAULT '{}'::JSONB,
    reminder_settings JSONB DEFAULT '{}'::JSONB,
    escalation_rules JSONB DEFAULT '{}'::JSONB,
    
    -- Automation
    entry_criteria JSONB DEFAULT '{}'::JSONB,
    exit_criteria JSONB DEFAULT '{}'::JSONB,
    automation_rules JSONB DEFAULT '[]'::jsonb,
    workflow_triggers JSONB DEFAULT '[]'::jsonb,
    
    -- Team Management
    team_assignments JSONB DEFAULT '{}'::JSONB,
    role_permissions JSONB DEFAULT '{}'::JSONB,
    approval_workflows JSONB DEFAULT '[]'::jsonb,
    
    -- Analytics
    conversion_goals JSONB DEFAULT '{}'::JSONB,
    performance_metrics JSONB DEFAULT '{}'::JSONB,
    stage_metrics JSONB DEFAULT '[]'::jsonb,
    
    -- Integration
    webhook_config JSONB DEFAULT '{}'::JSONB,
    external_integrations JSONB DEFAULT '{}'::JSONB,
    api_settings JSONB DEFAULT '{}'::JSONB,
    
    -- Additional Information
    notes TEXT,
    internal_notes TEXT,
    metadata JSONB DEFAULT '{}'::JSONB,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT valid_stages CHECK (
        jsonb_array_length(stages) > 0
    ),
    CONSTRAINT valid_status CHECK (
        status IN ('active', 'inactive', 'archived')
    ),
    CONSTRAINT unique_default_pipeline CHECK (
        NOT (is_default AND deleted_at IS NOT NULL)
    )
);

-- Add comments
COMMENT ON TABLE public.crm_pipelines IS 'Core table for managing sales pipelines and processes';
COMMENT ON COLUMN public.crm_pipelines.id IS 'Unique identifier for the pipeline';
COMMENT ON COLUMN public.crm_pipelines.code IS 'Unique code for the pipeline';
COMMENT ON COLUMN public.crm_pipelines.version IS 'Version number for optimistic locking';
COMMENT ON COLUMN public.crm_pipelines.stages IS 'Configuration of pipeline stages';
COMMENT ON COLUMN public.crm_pipelines.automation_rules IS 'Automation rules for the pipeline';
COMMENT ON COLUMN public.crm_pipelines.performance_metrics IS 'Pipeline performance analytics';

-- Create indexes
CREATE INDEX idx_crm_pipelines_code ON public.crm_pipelines(code) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_pipelines_name ON public.crm_pipelines(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_pipelines_status ON public.crm_pipelines(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_pipelines_type ON public.crm_pipelines(pipeline_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_pipelines_default ON public.crm_pipelines(is_default) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_pipelines_search ON public.crm_pipelines USING gin(search_vector);

-- Add missing indexes for CRM Pipelines
CREATE INDEX idx_crm_pipelines_stages ON public.crm_pipelines USING gin(stages);
CREATE INDEX idx_crm_pipelines_automations ON public.crm_pipelines USING gin(automation_rules);

-- Enable Row Level Security
ALTER TABLE public.crm_pipelines ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view active pipelines"
    ON public.crm_pipelines
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL AND
        status = 'active'
    );

CREATE POLICY "Users can manage pipelines"
    ON public.crm_pipelines
    FOR ALL
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

-- Grant permissions
GRANT SELECT ON public.crm_pipelines TO authenticated;
GRANT ALL ON public.crm_pipelines TO service_role;

-- Add trigger
CREATE TRIGGER set_timestamp_crm_pipelines
    BEFORE UPDATE ON public.crm_pipelines
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- CRM Communications table: Comprehensive communication tracking
-- =====================================================================================
-- Description:
--   Core table for managing all types of communications in the CRM system.
--   Supports emails, calls, meetings, messages, and other communication types.
--   Integrates with contacts, opportunities, and other CRM entities.
--
-- Dependencies:
--   1. Authentication & Users:
--      - auth.users (for user references and assignments)
--      - public.user_roles (for role-based access)
--
--   2. Related Tables:
--      - public.crm_contacts (for contact communications)
--      - public.crm_opportunities (for opportunity communications)
--      - public.crm_leads (for lead communications)
--
-- Notes:
--   1. Communication Management:
--      - Multiple communication types
--      - Thread tracking
--      - Status monitoring
--
--   2. Analytics & Reporting:
--      - Communication metrics
--      - Response tracking
--      - Engagement analysis
--
--   3. Performance & Security:
--      - Implements RLS for data isolation
--      - Optimized indexes for common queries
--      - Audit trail for changes

-- Drop existing objects
DROP TRIGGER IF EXISTS set_timestamp_crm_communications ON public.crm_communications CASCADE;
DROP TRIGGER IF EXISTS handle_updated_at ON public.crm_communications CASCADE;

-- Drop existing indexes
DROP INDEX IF EXISTS idx_crm_communications_type CASCADE;
DROP INDEX IF EXISTS idx_crm_communications_status CASCADE;
DROP INDEX IF EXISTS idx_crm_communications_entity CASCADE;
DROP INDEX IF EXISTS idx_crm_communications_search CASCADE;

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view communications" ON public.crm_communications CASCADE;
DROP POLICY IF EXISTS "Users can manage communications" ON public.crm_communications CASCADE;

-- Drop table if exists
DROP TABLE IF EXISTS public.crm_communications CASCADE;

-- Revoke permissions
REVOKE ALL ON public.crm_communications FROM authenticated CASCADE;
REVOKE ALL ON public.crm_communications FROM service_role CASCADE;

-- Create table
CREATE TABLE public.crm_communications (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    communication_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Basic Information
    subject TEXT,
    body TEXT,
    communication_type public.communication_type NOT NULL,
    status public.communication_status DEFAULT 'pending' NOT NULL,
    priority public.priority_level DEFAULT 'normal' NOT NULL,
    
    -- Entity References
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    parent_communication_id UUID REFERENCES public.crm_communications(id),
    thread_id UUID,
    
    -- Communication Details
    direction public.communication_direction NOT NULL,
    channel TEXT NOT NULL,
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    duration INTEGER, -- in seconds
    
    -- Participants
    from_contact UUID REFERENCES public.crm_contacts(id),
    to_contacts UUID[] NOT NULL,
    cc_contacts UUID[],
    bcc_contacts UUID[],
    assigned_to UUID REFERENCES auth.users(id),
    
    -- Email Specific
    email_headers JSONB DEFAULT '{}'::JSONB,
    email_attachments JSONB DEFAULT '[]'::jsonb,
    email_tracking JSONB DEFAULT '{}'::jsonb,
    
    -- Call Specific
    call_recording_url TEXT,
    call_transcript TEXT,
    call_notes TEXT,
    call_outcome TEXT,
    
    -- Meeting Specific
    location TEXT,
    meeting_url TEXT,
    meeting_notes TEXT,
    meeting_agenda TEXT,
    meeting_minutes TEXT,
    
    -- Message Specific
    message_template_id UUID,
    message_variables JSONB DEFAULT '{}'::JSONB,
    delivery_status JSONB DEFAULT '{}'::jsonb,
    
    -- Follow-up
    requires_followup BOOLEAN DEFAULT false,
    followup_date TIMESTAMPTZ,
    followup_notes TEXT,
    followup_assigned_to UUID REFERENCES auth.users(id),
    
    -- Analytics
    sentiment_score DECIMAL(3,2),
    response_time INTEGER, -- in seconds
    engagement_metrics JSONB DEFAULT '{}'::jsonb,
    
    -- Integration
    external_reference TEXT,
    external_system TEXT,
    external_data JSONB DEFAULT '{}'::jsonb,
    
    -- Additional Information
    tags TEXT[],
    categories TEXT[],
    notes TEXT,
    internal_notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(subject, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(body, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(notes, '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    version INTEGER DEFAULT 1 NOT NULL,

    -- Constraints
    CONSTRAINT valid_duration CHECK (
        (duration IS NULL OR duration >= 0)
    ),
    CONSTRAINT valid_dates CHECK (
        (start_time IS NULL OR end_time IS NULL OR end_time >= start_time)
    ),
    CONSTRAINT valid_sentiment CHECK (
        (sentiment_score IS NULL OR (sentiment_score >= -1 AND sentiment_score <= 1))
    ),
    CONSTRAINT valid_response_time CHECK (
        (response_time IS NULL OR response_time >= 0)
    )
);

-- Add comments
COMMENT ON TABLE public.crm_communications IS 'Core table for managing all types of communications';
COMMENT ON COLUMN public.crm_communications.id IS 'Unique identifier for the communication';
COMMENT ON COLUMN public.crm_communications.communication_number IS 'Unique communication reference number';
COMMENT ON COLUMN public.crm_communications.version IS 'Version number for optimistic locking';
COMMENT ON COLUMN public.crm_communications.thread_id IS 'ID for grouping related communications';
COMMENT ON COLUMN public.crm_communications.engagement_metrics IS 'Metrics for measuring communication effectiveness';

-- Create indexes
CREATE INDEX idx_crm_communications_number ON public.crm_communications(communication_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_communications_type ON public.crm_communications(communication_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_communications_status ON public.crm_communications(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_communications_priority ON public.crm_communications(priority) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_communications_entity ON public.crm_communications(entity_type, entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_communications_thread ON public.crm_communications(thread_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_communications_dates ON public.crm_communications(start_time, end_time) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_communications_participants ON public.crm_communications(from_contact, assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_communications_followup ON public.crm_communications(requires_followup, followup_date) 
    WHERE deleted_at IS NULL AND requires_followup = true;
CREATE INDEX idx_crm_communications_search ON public.crm_communications USING gin(search_vector);
CREATE INDEX idx_crm_communications_tags ON public.crm_communications USING gin(tags) WHERE deleted_at IS NULL;

-- Enable Row Level Security
ALTER TABLE public.crm_communications ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view communications they have access to"
    ON public.crm_communications
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL AND
        (
            -- User is assigned to the communication
            assigned_to = auth.uid() OR
            followup_assigned_to = auth.uid() OR
            -- User has access through role
            auth.uid() IN (
                SELECT user_id FROM public.user_roles 
                WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
                AND deleted_at IS NULL
            )
        )
    );

CREATE POLICY "Users can manage their assigned communications"
    ON public.crm_communications
    FOR ALL
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        ) OR
        assigned_to = auth.uid() OR
        followup_assigned_to = auth.uid()
    )
    WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'sales_manager', 'crm_admin')
            AND deleted_at IS NULL
        ) OR
        assigned_to = auth.uid() OR
        followup_assigned_to = auth.uid()
    );

-- Grant permissions
GRANT SELECT ON public.crm_communications TO authenticated;
GRANT ALL ON public.crm_communications TO service_role;

-- Add trigger
CREATE TRIGGER set_timestamp_crm_communications
    BEFORE UPDATE ON public.crm_communications
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- CRM Documents table: Document and file management system
-- =====================================================================================
-- Description:
--   Core table for managing documents and files in the CRM system.
--   Supports version control, access management, and document workflows.
--   Integrates with contacts, opportunities, and other CRM entities.
--
-- Dependencies:
--   1. Authentication & Users:
--      - auth.users (for user references and assignments)
--      - public.user_roles (for role-based access)
--
--   2. Related Tables:
--      - public.crm_contacts (for document sharing)
--      - public.crm_opportunities (for opportunity documents)
--      - public.crm_categories (for document categorization)
--
-- Notes:
--   1. Document Management:
--      - Version control
--      - Access permissions
--      - Document workflows
--
--   2. Storage & Security:
--      - File metadata tracking
--      - Access logging
--      - Encryption support
--
--   3. Performance & Integration:
--      - Optimized for large files
--      - External storage support
--      - API integration ready

-- Drop existing objects
DROP TRIGGER IF EXISTS set_timestamp_crm_documents ON public.crm_documents CASCADE;
DROP TRIGGER IF EXISTS handle_updated_at ON public.crm_documents CASCADE;

-- Drop existing indexes
DROP INDEX IF EXISTS idx_crm_documents_type CASCADE;
DROP INDEX IF EXISTS idx_crm_documents_status CASCADE;
DROP INDEX IF EXISTS idx_crm_documents_entity CASCADE;
DROP INDEX IF EXISTS idx_crm_documents_search CASCADE;

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view documents" ON public.crm_documents CASCADE;
DROP POLICY IF EXISTS "Users can manage documents" ON public.crm_documents CASCADE;

-- Drop table if exists
DROP TABLE IF EXISTS public.crm_documents CASCADE;

-- Revoke permissions
REVOKE ALL ON public.crm_documents FROM authenticated CASCADE;
REVOKE ALL ON public.crm_documents FROM service_role CASCADE;

-- Create table
CREATE TABLE public.crm_documents (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Basic Information
    title TEXT NOT NULL,
    description TEXT,
    document_type public.document_type NOT NULL,
    status public.document_status DEFAULT 'draft' NOT NULL,
    
    -- File Information
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    file_url TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    mime_type TEXT,
    checksum TEXT,
    
    -- Version Control
    parent_version_id UUID REFERENCES public.crm_documents(id),
    version_number TEXT,
    version_notes TEXT,
    is_latest_version BOOLEAN DEFAULT true,
    
    -- Entity References
    entity_type TEXT,
    entity_id UUID,
    category_id UUID REFERENCES public.crm_categories(id),
    folder_path TEXT,
    
    -- Access Control
    access_level public.access_level DEFAULT 'private' NOT NULL,
    owner_id UUID REFERENCES auth.users(id),
    shared_with UUID[],
    permissions JSONB DEFAULT '{}'::jsonb,
    encryption_details JSONB DEFAULT '{}'::jsonb,
    
    -- Document Properties
    page_count INTEGER,
    language TEXT,
    author TEXT,
    keywords TEXT[],
    custom_properties JSONB DEFAULT '{}'::jsonb,
    
    -- Document Processing
    ocr_status TEXT,
    ocr_content TEXT,
    extracted_text TEXT,
    content_analysis JSONB DEFAULT '{}'::jsonb,
    
    -- Workflow
    approval_status public.approval_status DEFAULT 'pending',
    approval_history JSONB DEFAULT '[]'::jsonb,
    workflow_state TEXT,
    workflow_data JSONB DEFAULT '{}'::jsonb,
    
    -- Retention
    retention_period INTERVAL,
    retention_start_date TIMESTAMPTZ,
    expiry_date TIMESTAMPTZ,
    disposition_action TEXT,
    
    -- Usage Tracking
    view_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMPTZ,
    last_accessed_by UUID REFERENCES auth.users(id),
    
    -- Storage
    storage_location TEXT,
    storage_provider TEXT,
    storage_metadata JSONB DEFAULT '{}'::jsonb,
    backup_status TEXT,
    
    -- Integration
    external_reference TEXT,
    external_system TEXT,
    external_data JSONB DEFAULT '{}'::jsonb,
    
    -- Additional Information
    tags TEXT[],
    categories TEXT[],
    notes TEXT,
    internal_notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(extracted_text, '')), 'C')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT valid_file_size CHECK (
        file_size IS NULL OR file_size >= 0
    ),
    CONSTRAINT valid_page_count CHECK (
        page_count IS NULL OR page_count >= 0
    ),
    CONSTRAINT valid_counts CHECK (
        view_count >= 0 AND
        download_count >= 0
    ),
    CONSTRAINT valid_dates CHECK (
        (retention_start_date IS NULL OR expiry_date IS NULL OR expiry_date >= retention_start_date)
    ),
    CONSTRAINT valid_version CHECK (
        (parent_version_id IS NULL OR version_number IS NOT NULL)
    )
);

-- Add comments
COMMENT ON TABLE public.crm_documents IS 'Core table for managing documents and files';
COMMENT ON COLUMN public.crm_documents.id IS 'Unique identifier for the document';
COMMENT ON COLUMN public.crm_documents.document_number IS 'Unique document reference number';
COMMENT ON COLUMN public.crm_documents.version IS 'Version number for optimistic locking';
COMMENT ON COLUMN public.crm_documents.checksum IS 'File integrity check value';
COMMENT ON COLUMN public.crm_documents.encryption_details IS 'Document encryption information';

-- Create indexes
CREATE INDEX idx_crm_documents_number ON public.crm_documents(document_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_documents_type ON public.crm_documents(document_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_documents_status ON public.crm_documents(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_documents_entity ON public.crm_documents(entity_type, entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_documents_category ON public.crm_documents(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_documents_owner ON public.crm_documents(owner_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_documents_access ON public.crm_documents(access_level) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_documents_workflow ON public.crm_documents(workflow_state, approval_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_documents_retention ON public.crm_documents(retention_start_date, expiry_date) 
    WHERE deleted_at IS NULL AND expiry_date IS NOT NULL;
CREATE INDEX idx_crm_documents_search ON public.crm_documents USING gin(search_vector);
CREATE INDEX idx_crm_documents_tags ON public.crm_documents USING gin(tags) WHERE deleted_at IS NULL;

-- Enable Row Level Security
ALTER TABLE public.crm_documents ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view documents they have access to"
    ON public.crm_documents
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL AND
        (
            -- Document is public
            access_level = 'public' OR
            -- User is owner
            owner_id = auth.uid() OR
            -- User is shared with
            auth.uid() = ANY(shared_with) OR
            -- User has access through role
            auth.uid() IN (
                SELECT user_id FROM public.user_roles 
                WHERE role_name IN ('admin', 'document_manager', 'crm_admin')
                AND deleted_at IS NULL
            )
        )
    );

CREATE POLICY "Users can manage documents they own"
    ON public.crm_documents
    FOR ALL
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'document_manager', 'crm_admin')
            AND deleted_at IS NULL
        ) OR
        owner_id = auth.uid()
    )
    WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'document_manager', 'crm_admin')
            AND deleted_at IS NULL
        ) OR
        owner_id = auth.uid()
    );

-- Grant permissions
GRANT SELECT ON public.crm_documents TO authenticated;
GRANT ALL ON public.crm_documents TO service_role;

-- Add trigger
CREATE TRIGGER set_timestamp_crm_documents
    BEFORE UPDATE ON public.crm_documents
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- CRM Relationships table: Manages entity relationships and interactions
-- =====================================================================================
-- Description: Core table for managing relationships between different CRM entities
-- Dependencies:
--   - auth.users (for user references and assignments)
--   - public.user_roles (for role-based access)
--   - public.relationship_status (enum for relationship states)
--   - public.relationship_strength (enum for connection strength)
--   - public.relationship_direction (enum for relationship direction)
--   - public.interaction_outcome (enum for interaction results)
--   - public.workflow_status (enum for process states)
-- Notes:
--   - Manages bi-directional and hierarchical relationships between entities
--   - Tracks interaction history and relationship strength metrics
--   - Supports workflow automation and team collaboration
--   - Implements comprehensive audit trail and security policies
--   - Uses JSONB for flexible metadata and interaction storage
-- =====================================================================================

-- Drop existing objects to ensure clean installation
DROP TRIGGER IF EXISTS set_timestamp_crm_relationships ON public.crm_relationships CASCADE;
DROP TRIGGER IF EXISTS audit_crm_relationships ON public.crm_relationships CASCADE;
DROP INDEX IF EXISTS idx_crm_relationships_entities CASCADE;
DROP INDEX IF EXISTS idx_crm_relationships_type CASCADE;
DROP INDEX IF EXISTS idx_crm_relationships_status CASCADE;
DROP INDEX IF EXISTS idx_crm_relationships_strength CASCADE;
DROP INDEX IF EXISTS idx_crm_relationships_dates CASCADE;
DROP INDEX IF EXISTS idx_crm_relationships_search CASCADE;
DROP POLICY IF EXISTS "Users can view relationships they manage" ON public.crm_relationships CASCADE;
DROP POLICY IF EXISTS "Users can manage relationships" ON public.crm_relationships CASCADE;
DROP TABLE IF EXISTS public.crm_relationships CASCADE;
REVOKE ALL ON public.crm_relationships FROM authenticated CASCADE;
REVOKE ALL ON public.crm_relationships FROM service_role CASCADE;

CREATE TABLE public.crm_relationships (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    relationship_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Entity References
    entity1_type TEXT NOT NULL,
    entity1_id UUID NOT NULL,
    entity2_type TEXT NOT NULL,
    entity2_id UUID NOT NULL,
    parent_relationship_id UUID REFERENCES public.crm_relationships(id),
    
    -- Relationship Details
    relationship_type TEXT NOT NULL,
    relationship_status public.relationship_status DEFAULT 'active' NOT NULL,
    relationship_strength public.relationship_strength DEFAULT 'moderate' NOT NULL,
    relationship_direction public.relationship_direction DEFAULT 'unidirectional' NOT NULL,
    
    -- Relationship Metrics
    interaction_count INTEGER DEFAULT 0,
    last_interaction_date TIMESTAMPTZ,
    next_interaction_date TIMESTAMPTZ,
    relationship_score DECIMAL(5,2),
    
    -- Interaction History
    interactions JSONB DEFAULT '[]'::jsonb,
    interaction_outcomes JSONB DEFAULT '{}'::jsonb,
    interaction_metrics JSONB DEFAULT '{}'::jsonb,
    
    -- Relationship Management
    assigned_to UUID REFERENCES auth.users(id),
    team_members UUID[] DEFAULT ARRAY[]::UUID[],
    review_date TIMESTAMPTZ,
    
    -- Automation
    workflow_status public.workflow_status,
    automation_rules JSONB DEFAULT '[]'::jsonb,
    notification_settings JSONB DEFAULT '{}'::jsonb,
    
    -- Documentation
    notes TEXT,
    attachments JSONB DEFAULT '[]'::jsonb,
    
    -- Additional Information
    tags TEXT[],
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(relationship_type, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(notes, '')), 'B')
    ) STORED,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    audit_trail JSONB DEFAULT '[]'::jsonb,
    
    -- Constraints
    CONSTRAINT valid_relationship_number CHECK (relationship_number ~ '^REL-[0-9]{6}$'),
    CONSTRAINT different_entities CHECK (
        (entity1_type != entity2_type) OR 
        (entity1_type = entity2_type AND entity1_id != entity2_id)
    ),
    CONSTRAINT valid_relationship_score CHECK (
        relationship_score IS NULL OR 
        (relationship_score >= 0 AND relationship_score <= 100)
    ),
    CONSTRAINT valid_interaction_count CHECK (interaction_count >= 0)
);

-- Add table and column comments
COMMENT ON TABLE public.crm_relationships IS 'Core table for managing relationships between CRM entities';
COMMENT ON COLUMN public.crm_relationships.id IS 'Unique identifier for the relationship';
COMMENT ON COLUMN public.crm_relationships.relationship_number IS 'Business reference number (REL-XXXXXX format)';
COMMENT ON COLUMN public.crm_relationships.version IS 'Optimistic locking version number';
COMMENT ON COLUMN public.crm_relationships.entity1_type IS 'Type of the first entity in the relationship';
COMMENT ON COLUMN public.crm_relationships.entity1_id IS 'UUID of the first entity';
COMMENT ON COLUMN public.crm_relationships.entity2_type IS 'Type of the second entity in the relationship';
COMMENT ON COLUMN public.crm_relationships.entity2_id IS 'UUID of the second entity';
COMMENT ON COLUMN public.crm_relationships.relationship_type IS 'Classification of the relationship';
COMMENT ON COLUMN public.crm_relationships.relationship_score IS 'Calculated strength score (0-100)';
COMMENT ON COLUMN public.crm_relationships.interaction_count IS 'Number of recorded interactions';
COMMENT ON COLUMN public.crm_relationships.interactions IS 'Detailed history of interactions';
COMMENT ON COLUMN public.crm_relationships.workflow_status IS 'Current status in workflow';
COMMENT ON COLUMN public.crm_relationships.audit_trail IS 'Complete change history';

-- Create indexes
CREATE INDEX idx_crm_relationships_number ON public.crm_relationships(relationship_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_entities ON public.crm_relationships(entity1_type, entity1_id, entity2_type, entity2_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_type ON public.crm_relationships(relationship_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_status ON public.crm_relationships(relationship_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_strength ON public.crm_relationships(relationship_strength) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_dates ON public.crm_relationships(last_interaction_date, next_interaction_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_score ON public.crm_relationships(relationship_score) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_assigned ON public.crm_relationships(assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_team ON public.crm_relationships USING gin(team_members) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_tags ON public.crm_relationships USING gin(tags) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_relationships_search ON public.crm_relationships USING gin(search_vector);

-- Enable Row Level Security
ALTER TABLE public.crm_relationships ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view relationships they manage"
    ON public.crm_relationships
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = assigned_to OR
        auth.uid() = ANY(team_members) OR
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'relationship_manager', 'crm_admin')
            AND deleted_at IS NULL
        ) OR
        auth.uid() = created_by
    );

CREATE POLICY "Users can manage relationships"
    ON public.crm_relationships
    FOR ALL
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'relationship_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    )
    WITH CHECK (
        auth.uid() IN (
            SELECT user_id FROM public.user_roles 
            WHERE role_name IN ('admin', 'relationship_manager', 'crm_admin')
            AND deleted_at IS NULL
        )
    );

-- Grant permissions
GRANT SELECT ON public.crm_relationships TO authenticated;
GRANT ALL ON public.crm_relationships TO service_role;

-- Create triggers
CREATE TRIGGER set_timestamp_crm_relationships
    BEFORE UPDATE ON public.crm_relationships
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER audit_crm_relationships
    BEFORE INSERT OR UPDATE ON public.crm_relationships
    FOR EACH ROW
    EXECUTE FUNCTION public.process_audit_trail();

-- CRM Notes table: Universal notes for any CRM entity
-- =====================================================================================
-- Description:
--   Universal notes system for all CRM entities (contacts, companies, opportunities, etc.)
--   Provides rich text support, categorization, version control, and access management.
--
-- Dependencies:
--   - auth.users: For user management and ownership
--   - user_access_levels: For managing entity-level access control
--
-- Features:
--   - Rich text content with multiple format support
--   - Hierarchical categorization with tags
--   - Version control and change tracking
--   - Fine-grained access control and sharing
--   - Follow-up and reminder system
--   - Full-text search capabilities
--   - Comprehensive audit trail
--
-- Notes:
--   - Use content_format to specify the format of note content
--   - Tags can be used for flexible categorization and filtering
--   - Access control is managed through RLS policies
--   - Version control tracks note history and changes
--   - Search vector enables efficient full-text search

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view notes they manage" ON public.crm_notes CASCADE;
DROP POLICY IF EXISTS "Users can manage their assigned notes" ON public.crm_notes CASCADE;

-- Drop table if exists
DROP TABLE IF EXISTS public.crm_notes CASCADE;

CREATE TABLE public.crm_notes (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    note_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Entity Reference
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    
    -- Note Content
    title TEXT,
    content TEXT NOT NULL,
    content_format TEXT DEFAULT 'plain_text',
    content_preview TEXT,
    
    -- Categorization
    category TEXT,
    subcategory TEXT,
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Organization
    is_private BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    priority INTEGER CHECK (priority BETWEEN 1 AND 5),
    
    -- Rich Content
    attachments JSONB DEFAULT '[]'::jsonb,
    mentions TEXT[] DEFAULT ARRAY[]::TEXT[],
    links JSONB DEFAULT '[]'::jsonb,
    
    -- Access Control
    access_level TEXT DEFAULT 'private',
    shared_with UUID[],
    permissions JSONB DEFAULT '{}'::jsonb,
    
    -- Version Control
    parent_note_id UUID REFERENCES public.crm_notes(id),
    revision_notes TEXT,
    change_summary JSONB DEFAULT '{}'::jsonb,
    
    -- Additional Details
    source TEXT,
    follow_up_date DATE,
    reminder_date TIMESTAMPTZ,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search Vector
    search_vector tsvector,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT valid_entity_types CHECK (
        entity_type = ANY(ARRAY['contact', 'company', 'opportunity', 'lead', 'product', 'quote', 'job'])
    ),
    CONSTRAINT valid_content_format CHECK (
        content_format = ANY(ARRAY['plain_text', 'markdown', 'html', 'rich_text'])
    )
);

-- Add comments
COMMENT ON TABLE public.crm_notes IS 'Universal notes system for all CRM entities';
COMMENT ON COLUMN public.crm_notes.note_number IS 'Unique identifier for the note';
COMMENT ON COLUMN public.crm_notes.version IS 'Version number for optimistic locking';
COMMENT ON COLUMN public.crm_notes.content_format IS 'Format of the note content (plain_text, markdown, html, rich_text)';
COMMENT ON COLUMN public.crm_notes.content_preview IS 'Preview/summary of the note content';
COMMENT ON COLUMN public.crm_notes.access_level IS 'Privacy level of the note (private, shared, public)';
COMMENT ON COLUMN public.crm_notes.search_vector IS 'Full text search vector';

-- Create indexes
CREATE INDEX idx_crm_notes_entity ON public.crm_notes(entity_type, entity_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_notes_category ON public.crm_notes(category, subcategory) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_notes_priority ON public.crm_notes(priority) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_notes_dates ON public.crm_notes(follow_up_date, reminder_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_notes_tags ON public.crm_notes USING gin(tags) WHERE deleted_at IS NULL;
CREATE INDEX idx_crm_notes_search ON public.crm_notes USING gin(search_vector);

-- Enable Row Level Security
ALTER TABLE public.crm_notes ENABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT SELECT ON public.crm_notes TO authenticated;
GRANT ALL ON public.crm_notes TO service_role;

-- Create policies
CREATE POLICY "Users can view notes they manage"
    ON public.crm_notes
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM user_access_levels
            WHERE entity_type = crm_notes.entity_type 
            AND entity_id = crm_notes.entity_id
        )
        OR
        auth.uid() = ANY(shared_with)
        OR
        auth.uid() = created_by
    );

CREATE POLICY "Users can manage their assigned notes"
    ON public.crm_notes
    FOR ALL
    TO authenticated
    USING (
        auth.uid() IN (
            SELECT user_id FROM user_access_levels
            WHERE entity_type = crm_notes.entity_type 
            AND entity_id = crm_notes.entity_id
        )
        OR
        auth.uid() = created_by
    );

-- Add trigger for timestamp
CREATE TRIGGER set_timestamp_crm_notes
    BEFORE UPDATE ON public.crm_notes
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- Add missing fields, constraints, and audit functionality to CRM tables
ALTER TABLE public.crm_jobs
    ADD COLUMN IF NOT EXISTS workflow_status public.workflow_status,
    ADD COLUMN IF NOT EXISTS integration_status public.integration_status,
    ADD COLUMN IF NOT EXISTS time_unit public.time_unit DEFAULT 'hour',
    ADD CONSTRAINT valid_job_number CHECK (job_number ~ '^JOB-[0-9]{6}$');

ALTER TABLE public.crm_referrals
    ADD COLUMN IF NOT EXISTS workflow_status public.workflow_status,
    ADD COLUMN IF NOT EXISTS approval_status public.approval_status,
    ADD CONSTRAINT valid_referral_number CHECK (referral_number ~ '^REF-[0-9]{6}$');

ALTER TABLE public.crm_products
    ADD COLUMN IF NOT EXISTS approval_workflow JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS integration_config JSONB DEFAULT '{}'::jsonb,
    ADD CONSTRAINT valid_sku CHECK (sku ~ '^PRD-[0-9A-Z]{8}$');

ALTER TABLE public.crm_pipelines
    ADD COLUMN IF NOT EXISTS notification_settings JSONB DEFAULT '{}'::jsonb,
    ADD COLUMN IF NOT EXISTS audit_trail JSONB DEFAULT '[]'::jsonb,
    ADD CONSTRAINT valid_pipeline_code CHECK (code ~ '^PIP-[0-9]{6}$');

CREATE OR REPLACE FUNCTION public.process_audit_trail()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.audit_trail = COALESCE(NEW.audit_trail, '[]'::jsonb) || jsonb_build_object(
            'action', 'create',
            'timestamp', CURRENT_TIMESTAMP,
            'user_id', auth.uid(),
            'changes', row_to_json(NEW)
        );
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.audit_trail = COALESCE(NEW.audit_trail, '[]'::jsonb) || jsonb_build_object(
            'action', 'update',
            'timestamp', CURRENT_TIMESTAMP,
            'user_id', auth.uid(),
            'changes', jsonb_build_object(
                'old', row_to_json(OLD),
                'new', row_to_json(NEW)
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER audit_crm_jobs
    BEFORE INSERT OR UPDATE ON public.crm_jobs
    FOR EACH ROW EXECUTE FUNCTION public.process_audit_trail();

CREATE TRIGGER audit_crm_referrals
    BEFORE INSERT OR UPDATE ON public.crm_referrals
    FOR EACH ROW EXECUTE FUNCTION public.process_audit_trail();

CREATE TRIGGER audit_crm_products
    BEFORE INSERT OR UPDATE ON public.crm_products
    FOR EACH ROW EXECUTE FUNCTION public.process_audit_trail();

CREATE TRIGGER audit_crm_pipelines
    BEFORE INSERT OR UPDATE ON public.crm_pipelines
    FOR EACH ROW EXECUTE FUNCTION public.process_audit_trail();



-- =====================================================================================
-- Task Management Tables
-- =====================================================================================
-- Description:
--   Comprehensive task and project management system with support for boards, lists,
--   tasks, assignments, dependencies, comments, attachments, and time tracking.
--
-- Dependencies:
--   - auth.users: For user management and assignments
--   - public.board_type: Enum for board types
--   - public.list_type: Enum for list types
--   - public.task_type: Enum for task categories
--   - public.task_priority: Enum for task priorities
--   - public.task_status: Enum for task statuses
--   - public.task_assignment_role: Enum for assignment roles
--   - public.task_dependency_type: Enum for dependency types
--
-- Features:
--   - Kanban-style board management
--   - Hierarchical task organization
--   - Task assignments and dependencies
--   - Time tracking and billing
--   - File attachments and comments
--   - Template system for reusable tasks
--   - Comprehensive labeling system

-- Drop existing tables and dependencies
DROP TABLE IF EXISTS public.task_time_entries CASCADE;
DROP TABLE IF EXISTS public.task_templates CASCADE;
DROP TABLE IF EXISTS public.task_labels CASCADE;
DROP TABLE IF EXISTS public.task_attachments CASCADE;
DROP TABLE IF EXISTS public.task_comments CASCADE;
DROP TABLE IF EXISTS public.task_dependencies CASCADE;
DROP TABLE IF EXISTS public.task_assignments CASCADE;
DROP TABLE IF EXISTS public.tasks CASCADE;
DROP TABLE IF EXISTS public.task_lists CASCADE;
DROP TABLE IF EXISTS public.task_boards CASCADE;

-- Create tables
CREATE TABLE public.task_boards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    board_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Basic Information
    name TEXT NOT NULL,
    description TEXT,
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES auth.users(id),
    board_type public.board_type NOT NULL,
    
    -- Configuration
    settings JSONB DEFAULT '{}'::jsonb,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Organization
    is_template BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    
    -- Access Control
    access_level TEXT DEFAULT 'private',
    shared_with UUID[],
    permissions JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

CREATE TABLE public.task_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Basic Information
    board_id UUID NOT NULL REFERENCES public.task_boards(id),
    name TEXT NOT NULL,
    description TEXT,
    position INTEGER NOT NULL,
    list_type public.list_type NOT NULL,
    
    -- Configuration
    settings JSONB DEFAULT '{}'::jsonb,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Organization
    is_archived BOOLEAN DEFAULT false,
    
    -- Workflow
    wip_limit INTEGER,
    auto_close BOOLEAN DEFAULT false,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Basic Information
    list_id UUID NOT NULL REFERENCES public.task_lists(id),
    title TEXT NOT NULL,
    description TEXT,
    position INTEGER NOT NULL,
    task_type public.task_type NOT NULL,
    
    -- Scheduling
    due_date TIMESTAMPTZ,
    start_date TIMESTAMPTZ,
    reminder_date TIMESTAMPTZ,
    
    -- Progress
    priority public.task_priority,
    status public.task_status NOT NULL,
    estimated_hours DECIMAL(10,2),
    actual_hours DECIMAL(10,2),
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage BETWEEN 0 AND 100),
    
    -- Organization
    is_archived BOOLEAN DEFAULT false,
    is_locked BOOLEAN DEFAULT false,
    is_template BOOLEAN DEFAULT false,
    
    -- Rich Content
    attachments JSONB DEFAULT '[]'::jsonb,
    checklists JSONB DEFAULT '[]'::jsonb,
    links JSONB DEFAULT '[]'::jsonb,
    
    -- Additional Information
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Search
    search_vector tsvector,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

CREATE TABLE public.task_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Assignment Details
    task_id UUID NOT NULL REFERENCES public.tasks(id),
    assignee_id UUID NOT NULL REFERENCES auth.users(id),
    role public.task_assignment_role NOT NULL,
    assigned_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    
    -- Status
    status TEXT NOT NULL,
    notes TEXT,
    
    -- Time Tracking
    estimated_hours DECIMAL(10,2),
    actual_hours DECIMAL(10,2),
    
    -- Additional Information
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

CREATE TABLE public.task_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dependency_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Dependency Details
    predecessor_id UUID NOT NULL REFERENCES public.tasks(id),
    successor_id UUID NOT NULL REFERENCES public.tasks(id),
    dependency_type public.task_dependency_type NOT NULL,
    
    -- Configuration
    lag_time INTEGER DEFAULT 0,
    is_blocking BOOLEAN DEFAULT true,
    
    -- Additional Information
    notes TEXT,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT different_tasks CHECK (predecessor_id != successor_id)
);

CREATE TABLE public.task_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Comment Details
    task_id UUID NOT NULL REFERENCES public.tasks(id),
    parent_id UUID REFERENCES public.task_comments(id),
    comment_text TEXT NOT NULL,
    
    -- Rich Content
    mentions JSONB DEFAULT '[]'::jsonb,
    attachments JSONB DEFAULT '[]'::jsonb,
    
    -- Status
    is_edited BOOLEAN DEFAULT false,
    is_resolved BOOLEAN DEFAULT false,
    
    -- Additional Information
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

CREATE TABLE public.task_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attachment_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Attachment Details
    task_id UUID NOT NULL REFERENCES public.tasks(id),
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    file_url TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    
    -- Additional Information
    description TEXT,
    thumbnail_url TEXT,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

CREATE TABLE public.task_labels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    label_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Label Details
    workspace_id UUID NOT NULL,
    name TEXT NOT NULL,
    color TEXT NOT NULL,
    description TEXT,
    
    -- Organization
    parent_id UUID REFERENCES public.task_labels(id),
    usage_count INTEGER DEFAULT 0,
    
    -- Additional Information
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

CREATE TABLE public.task_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Template Details
    name TEXT NOT NULL,
    description TEXT,
    template_type TEXT NOT NULL,
    template_data JSONB NOT NULL,
    
    -- Organization
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- Additional Information
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

CREATE TABLE public.task_time_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Time Entry Details
    task_id UUID NOT NULL REFERENCES public.tasks(id),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    duration INTEGER, -- in seconds
    
    -- Billing
    description TEXT,
    is_billable BOOLEAN DEFAULT false,
    billing_rate DECIMAL(10,2),
    
    -- Additional Information
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id)
);

-- Create indexes
CREATE INDEX idx_task_boards_workspace ON public.task_boards(workspace_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_boards_owner ON public.task_boards(owner_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_boards_type ON public.task_boards(board_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_boards_access ON public.task_boards(access_level) WHERE deleted_at IS NULL;

CREATE INDEX idx_task_lists_board ON public.task_lists(board_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_lists_type ON public.task_lists(list_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_lists_position ON public.task_lists(position) WHERE deleted_at IS NULL;

CREATE INDEX idx_tasks_list ON public.tasks(list_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_type ON public.tasks(task_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_status ON public.tasks(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_priority ON public.tasks(priority) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_dates ON public.tasks(due_date, start_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_search ON public.tasks USING gin(search_vector);
CREATE INDEX idx_tasks_tags ON public.tasks USING gin(tags) WHERE deleted_at IS NULL;

CREATE INDEX idx_task_assignments_task ON public.task_assignments(task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_assignments_user ON public.task_assignments(assignee_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_assignments_status ON public.task_assignments(status) WHERE deleted_at IS NULL;

CREATE INDEX idx_task_dependencies_pred ON public.task_dependencies(predecessor_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_dependencies_succ ON public.task_dependencies(successor_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_dependencies_type ON public.task_dependencies(dependency_type) WHERE deleted_at IS NULL;

CREATE INDEX idx_task_comments_task ON public.task_comments(task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_comments_parent ON public.task_comments(parent_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_task_attachments_task ON public.task_attachments(task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_attachments_type ON public.task_attachments(file_type) WHERE deleted_at IS NULL;

CREATE INDEX idx_task_labels_workspace ON public.task_labels(workspace_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_labels_parent ON public.task_labels(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_labels_usage ON public.task_labels(usage_count) WHERE deleted_at IS NULL;

CREATE INDEX idx_task_templates_type ON public.task_templates(template_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_templates_category ON public.task_templates(category) WHERE deleted_at IS NULL;

CREATE INDEX idx_task_time_entries_task ON public.task_time_entries(task_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_time_entries_user ON public.task_time_entries(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_task_time_entries_billable ON public.task_time_entries(is_billable) WHERE deleted_at IS NULL;

-- Enable Row Level Security
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

-- Create RLS Policies
CREATE POLICY "Users can view boards they have access to"
    ON public.task_boards
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = owner_id
        OR auth.uid() = ANY(shared_with)
        OR is_public = true
        OR access_level = 'public'
    );

CREATE POLICY "Users can manage boards they own"
    ON public.task_boards
    FOR ALL
    TO authenticated
    USING (auth.uid() = owner_id);

CREATE POLICY "Users can view lists in accessible boards"
    ON public.task_lists
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.task_boards
            WHERE id = task_lists.board_id
            AND (
                owner_id = auth.uid()
                OR auth.uid() = ANY(shared_with)
                OR is_public = true
                OR access_level = 'public'
            )
        )
    );

CREATE POLICY "Users can manage lists in their boards"
    ON public.task_lists
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.task_boards
            WHERE id = task_lists.board_id
            AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can view tasks they have access to"
    ON public.tasks
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.task_lists tl
            JOIN public.task_boards tb ON tb.id = tl.board_id
            WHERE tl.id = tasks.list_id
            AND (
                tb.owner_id = auth.uid()
                OR auth.uid() = ANY(tb.shared_with)
                OR tb.is_public = true
                OR tb.access_level = 'public'
            )
        )
        OR EXISTS (
            SELECT 1 FROM public.task_assignments
            WHERE task_id = tasks.id
            AND assignee_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage assigned tasks"
    ON public.tasks
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.task_assignments
            WHERE task_id = tasks.id
            AND assignee_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.task_lists tl
            JOIN public.task_boards tb ON tb.id = tl.board_id
            WHERE tl.id = tasks.list_id
            AND tb.owner_id = auth.uid()
        )
    );

-- Grant permissions
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

-- Add triggers for timestamp updates
CREATE TRIGGER set_timestamp_task_boards
    BEFORE UPDATE ON public.task_boards
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_task_lists
    BEFORE UPDATE ON public.task_lists
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_tasks
    BEFORE UPDATE ON public.tasks
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_task_assignments
    BEFORE UPDATE ON public.task_assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_task_dependencies
    BEFORE UPDATE ON public.task_dependencies
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_task_comments
    BEFORE UPDATE ON public.task_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_task_attachments
    BEFORE UPDATE ON public.task_attachments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_task_labels
    BEFORE UPDATE ON public.task_labels
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_task_templates
    BEFORE UPDATE ON public.task_templates
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_task_time_entries
    BEFORE UPDATE ON public.task_time_entries
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

-- =====================================================================================
-- Inventory Management Tables
-- =====================================================================================
-- Description:
--   Comprehensive inventory management system with support for multiple locations,
--   item tracking, transactions, purchase orders, and stock management.
--
-- Dependencies:
--   - auth.users: For user management and audit trails
--   - public.inventory_location_type: Location types
--   - public.inventory_transaction_type: Transaction types
--   - public.purchase_order_status: PO status
--   - public.stock_adjustment_type: Adjustment reasons
--   - public.inventory_valuation_method: Valuation methods
--   - public.quality_status_type: Quality control
--   - public.storage_condition_type: Storage requirements
--   - public.unit_of_measure_type: Units of measure
--   - public.crm_products: Product references
--
-- Features:
--   - Multi-location inventory management
--   - Real-time stock tracking
--   - Purchase order management
--   - Cost tracking and valuation
--   - Inventory movements and transfers
--   - Quality control tracking
--   - Storage condition management
--   - Comprehensive audit trails
--
-- Version: 1.0.0
-- Last Updated: 2024-12-19
-- =====================================================================================

-- Drop triggers
DROP TRIGGER IF EXISTS set_timestamp_inventory_locations ON public.inventory_locations;
DROP TRIGGER IF EXISTS set_timestamp_inventory_items ON public.inventory_items;
DROP TRIGGER IF EXISTS set_timestamp_inventory_transactions ON public.inventory_transactions;
DROP TRIGGER IF EXISTS set_timestamp_purchase_orders ON public.purchase_orders;
DROP TRIGGER IF EXISTS set_timestamp_purchase_order_items ON public.purchase_order_items;

-- Drop indexes
DROP INDEX IF EXISTS idx_inventory_locations_type CASCADE;
DROP INDEX IF EXISTS idx_inventory_items_product CASCADE;
DROP INDEX IF EXISTS idx_inventory_items_location CASCADE;
DROP INDEX IF EXISTS idx_inventory_transactions_product CASCADE;
DROP INDEX IF EXISTS idx_inventory_transactions_locations CASCADE;
DROP INDEX IF EXISTS idx_purchase_orders_supplier CASCADE;
DROP INDEX IF EXISTS idx_purchase_orders_status CASCADE;
DROP INDEX IF EXISTS idx_purchase_order_items_order CASCADE;
DROP INDEX IF EXISTS idx_purchase_order_items_product CASCADE;

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Users can view inventory locations" ON public.inventory_locations CASCADE;
DROP POLICY IF EXISTS "Users can manage inventory locations" ON public.inventory_locations CASCADE;
DROP POLICY IF EXISTS "Users can view inventory items" ON public.inventory_items CASCADE;
DROP POLICY IF EXISTS "Users can manage inventory items" ON public.inventory_items CASCADE;

-- Revoke permissions
REVOKE ALL ON public.inventory_locations FROM authenticated CASCADE;
REVOKE ALL ON public.inventory_items FROM authenticated CASCADE;
REVOKE ALL ON public.inventory_transactions FROM authenticated CASCADE;
REVOKE ALL ON public.purchase_orders FROM authenticated CASCADE;
REVOKE ALL ON public.purchase_order_items FROM authenticated CASCADE;

-- Drop tables
DROP TABLE IF EXISTS public.purchase_order_items CASCADE;
DROP TABLE IF EXISTS public.purchase_orders CASCADE;
DROP TABLE IF EXISTS public.inventory_transactions CASCADE;
DROP TABLE IF EXISTS public.inventory_items CASCADE;
DROP TABLE IF EXISTS public.inventory_locations CASCADE;

-- Create tables
CREATE TABLE public.inventory_locations (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Basic Information
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    type public.inventory_location_type NOT NULL,
    
    -- Contact Details
    address JSONB,
    contact_info JSONB,
    
    -- Storage Information
    storage_conditions public.storage_condition_type[],
    total_capacity DECIMAL(15,2),
    available_capacity DECIMAL(15,2),
    
    -- Organization
    parent_id UUID REFERENCES public.inventory_locations(id),
    is_active BOOLEAN DEFAULT true,
    
    -- Configuration
    settings JSONB DEFAULT '{}'::jsonb,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT valid_capacity CHECK (
        (total_capacity IS NULL AND available_capacity IS NULL) OR
        (total_capacity >= 0 AND available_capacity >= 0 AND available_capacity <= total_capacity)
    )
);

CREATE TABLE public.inventory_items (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Item Details
    product_id UUID REFERENCES public.crm_products(id),
    location_id UUID REFERENCES public.inventory_locations(id),
    
    -- Quantities
    quantity DECIMAL(15,2) NOT NULL DEFAULT 0,
    reserved_quantity DECIMAL(15,2) DEFAULT 0,
    available_quantity DECIMAL(15,2) GENERATED ALWAYS AS (quantity - COALESCE(reserved_quantity, 0)) STORED,
    
    -- Units
    unit_of_measure public.unit_of_measure_type NOT NULL,
    conversion_factor DECIMAL(15,4) DEFAULT 1.0,
    
    -- Quality Control
    quality_status public.quality_status_type DEFAULT 'pending_inspection',
    expiry_date DATE,
    lot_number TEXT,
    serial_numbers TEXT[],
    
    -- Costs and Valuation
    valuation_method public.inventory_valuation_method NOT NULL,
    unit_cost DECIMAL(15,2),
    total_value DECIMAL(15,2) GENERATED ALWAYS AS (quantity * COALESCE(unit_cost, 0)) STORED,
    
    -- Reorder Information
    reorder_point DECIMAL(15,2),
    reorder_quantity DECIMAL(15,2),
    lead_time_days INTEGER,
    
    -- Stock Count
    last_counted_at TIMESTAMPTZ,
    last_counted_by UUID REFERENCES auth.users(id),
    
    -- Additional Information
    storage_location TEXT,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT unique_product_location UNIQUE (product_id, location_id),
    CONSTRAINT positive_quantities CHECK (
        quantity >= 0 AND 
        reserved_quantity >= 0 AND
        conversion_factor > 0
    ),
    CONSTRAINT valid_expiry CHECK (
        expiry_date IS NULL OR expiry_date > created_at::date
    )
);

CREATE TABLE public.inventory_transactions (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Transaction Details
    transaction_type public.inventory_transaction_type NOT NULL,
    transaction_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    -- Item Information
    product_id UUID REFERENCES public.crm_products(id),
    from_location_id UUID REFERENCES public.inventory_locations(id),
    to_location_id UUID REFERENCES public.inventory_locations(id),
    
    -- Quantities and Costs
    quantity DECIMAL(15,2) NOT NULL,
    unit_of_measure public.unit_of_measure_type NOT NULL,
    unit_cost DECIMAL(15,2),
    total_cost DECIMAL(15,2),
    
    -- Quality Information
    quality_status public.quality_status_type,
    lot_number TEXT,
    serial_numbers TEXT[],
    
    -- Adjustment Details
    adjustment_type public.stock_adjustment_type,
    reason_code TEXT,
    
    -- Reference Information
    reference_type TEXT,
    reference_id UUID,
    notes TEXT,
    
    -- Additional Information
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT valid_locations CHECK (
        (from_location_id IS NOT NULL AND to_location_id IS NULL) OR
        (from_location_id IS NULL AND to_location_id IS NOT NULL) OR
        (from_location_id IS NOT NULL AND to_location_id IS NOT NULL AND from_location_id != to_location_id)
    ),
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT valid_costs CHECK (
        (unit_cost IS NULL AND total_cost IS NULL) OR
        (unit_cost >= 0 AND total_cost >= 0 AND total_cost = quantity * unit_cost)
    )
);

CREATE TABLE public.purchase_orders (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Order Details
    supplier_id UUID NOT NULL,
    status public.purchase_order_status DEFAULT 'draft' NOT NULL,
    
    -- Dates
    order_date DATE NOT NULL,
    expected_date DATE,
    delivery_date DATE,
    
    -- Amounts
    currency_code TEXT NOT NULL,
    exchange_rate DECIMAL(15,6) DEFAULT 1.0,
    subtotal DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    
    -- Delivery Information
    shipping_method TEXT,
    tracking_number TEXT,
    
    -- Additional Information
    notes TEXT,
    terms_conditions TEXT,
    shipping_address JSONB,
    billing_address JSONB,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT valid_dates CHECK (
        order_date <= COALESCE(expected_date, order_date) AND
        COALESCE(expected_date, order_date) <= COALESCE(delivery_date, COALESCE(expected_date, order_date))
    ),
    CONSTRAINT valid_amounts CHECK (
        exchange_rate > 0 AND
        subtotal >= 0 AND
        tax_amount >= 0 AND
        total_amount >= 0 AND
        total_amount = subtotal + tax_amount
    )
);

CREATE TABLE public.purchase_order_items (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_number TEXT NOT NULL UNIQUE,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Item Details
    purchase_order_id UUID NOT NULL REFERENCES public.purchase_orders(id),
    product_id UUID NOT NULL REFERENCES public.crm_products(id),
    
    -- Quantities and Amounts
    quantity DECIMAL(15,2) NOT NULL,
    unit_of_measure public.unit_of_measure_type NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    received_quantity DECIMAL(15,2) DEFAULT 0,
    
    -- Quality Control
    quality_status public.quality_status_type DEFAULT 'pending_inspection',
    inspection_notes TEXT,
    
    -- Additional Information
    notes TEXT,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT positive_quantities CHECK (
        quantity > 0 AND
        received_quantity >= 0 AND
        received_quantity <= quantity
    ),
    CONSTRAINT valid_amounts CHECK (
        unit_price >= 0 AND
        tax_rate >= 0 AND
        tax_amount >= 0 AND
        total_amount >= 0 AND
        total_amount = (quantity * unit_price) + tax_amount
    )
);

-- Add comments
COMMENT ON TABLE public.inventory_locations IS 'Physical locations for inventory storage';
COMMENT ON TABLE public.inventory_items IS 'Current inventory levels by product and location';
COMMENT ON TABLE public.inventory_transactions IS 'History of all inventory movements';
COMMENT ON TABLE public.purchase_orders IS 'Purchase orders for inventory procurement';
COMMENT ON TABLE public.purchase_order_items IS 'Line items within purchase orders';

-- Create indexes
CREATE INDEX idx_inventory_locations_type ON public.inventory_locations(type) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_locations_parent ON public.inventory_locations(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_locations_active ON public.inventory_locations(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_locations_conditions ON public.inventory_locations USING gin(storage_conditions) WHERE deleted_at IS NULL;

CREATE INDEX idx_inventory_items_product ON public.inventory_items(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_location ON public.inventory_items(location_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_quantity ON public.inventory_items(quantity) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_quality ON public.inventory_items(quality_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_expiry ON public.inventory_items(expiry_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_lot ON public.inventory_items(lot_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_serial ON public.inventory_items USING gin(serial_numbers) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_items_reorder ON public.inventory_items(reorder_point) WHERE deleted_at IS NULL;

CREATE INDEX idx_inventory_transactions_type ON public.inventory_transactions(transaction_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_date ON public.inventory_transactions(transaction_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_product ON public.inventory_transactions(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_from ON public.inventory_transactions(from_location_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_to ON public.inventory_transactions(to_location_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_quality ON public.inventory_transactions(quality_status) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_lot ON public.inventory_transactions(lot_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_serial ON public.inventory_transactions USING gin(serial_numbers) WHERE deleted_at IS NULL;
CREATE INDEX idx_inventory_transactions_reference ON public.inventory_transactions(reference_type, reference_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_purchase_orders_supplier ON public.purchase_orders(supplier_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_purchase_orders_status ON public.purchase_orders(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_purchase_orders_dates ON public.purchase_orders(order_date, expected_date, delivery_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_purchase_orders_currency ON public.purchase_orders(currency_code) WHERE deleted_at IS NULL;

CREATE INDEX idx_purchase_order_items_order ON public.purchase_order_items(purchase_order_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_purchase_order_items_product ON public.purchase_order_items(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_purchase_order_items_quality ON public.purchase_order_items(quality_status) WHERE deleted_at IS NULL;

-- Enable Row Level Security
ALTER TABLE public.inventory_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_order_items ENABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT SELECT ON public.inventory_locations TO authenticated;
GRANT SELECT ON public.inventory_items TO authenticated;
GRANT SELECT ON public.inventory_transactions TO authenticated;
GRANT SELECT ON public.purchase_orders TO authenticated;
GRANT SELECT ON public.purchase_order_items TO authenticated;

GRANT ALL ON public.inventory_locations TO service_role;
GRANT ALL ON public.inventory_items TO service_role;
GRANT ALL ON public.inventory_transactions TO service_role;
GRANT ALL ON public.purchase_orders TO service_role;
GRANT ALL ON public.purchase_order_items TO service_role;

-- Create RLS Policies
CREATE POLICY "Users can view inventory locations"
    ON public.inventory_locations
    FOR SELECT
    TO authenticated
    USING (
        is_active = true
        OR EXISTS (
            SELECT 1 FROM user_access_levels
            WHERE user_id = auth.uid()
            AND access_level >= 'read'::access_level_type
        )
    );

CREATE POLICY "Users can manage inventory locations"
    ON public.inventory_locations
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_access_levels
            WHERE user_id = auth.uid()
            AND access_level >= 'write'::access_level_type
        )
    );

CREATE POLICY "Users can view inventory items"
    ON public.inventory_items
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM inventory_locations
            WHERE id = inventory_items.location_id
            AND is_active = true
        )
        OR EXISTS (
            SELECT 1 FROM user_access_levels
            WHERE user_id = auth.uid()
            AND access_level >= 'read'::access_level_type
        )
    );

CREATE POLICY "Users can manage inventory items"
    ON public.inventory_items
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_access_levels
            WHERE user_id = auth.uid()
            AND access_level >= 'write'::access_level_type
        )
    );

-- Add triggers
CREATE TRIGGER set_timestamp_inventory_locations
    BEFORE UPDATE ON public.inventory_locations
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_inventory_items
    BEFORE UPDATE ON public.inventory_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_inventory_transactions
    BEFORE UPDATE ON public.inventory_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_purchase_orders
    BEFORE UPDATE ON public.purchase_orders
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER set_timestamp_purchase_order_items
    BEFORE UPDATE ON public.purchase_order_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_timestamp();


-- =====================================================================================
-- Accounting Integration Tables
-- =====================================================================================
-- Description:
--   Comprehensive accounting system with support for double-entry bookkeeping,
--   chart of accounts, journal entries, and payment tracking. Designed to integrate
--   with external accounting systems like Xero, QuickBooks, and other platforms.
--
-- Dependencies:
--   - auth.users: For user management and audit trails
--   - public.account_type: Enum for account types (asset, liability, equity, revenue, expense)
--   - public.payment_method: Enum for payment methods (cash, credit_card, bank_transfer, etc.)
--   - public.payment_status: Enum for payment statuses (pending, completed, failed, etc.)
--   - public.accounting_system_type: Enum for external systems (xero, quickbooks, etc.)
--   - public.sync_status_type: Enum for sync status (pending, synced, failed, etc.)
--
-- Features:
--   - Multi-system Integration:
--     * Support for multiple accounting systems
--     * External ID tracking for each system
--     * Flexible metadata storage for system-specific data
--
--   - Chart of Accounts:
--     * Hierarchical account structure
--     * Account type categorization
--     * External system mappings
--     * Active/inactive status tracking
--
--   - Journal Entries:
--     * Double-entry accounting support
--     * Reference tracking for source transactions
--     * Posting status management
--     * External system synchronization
--
--   - Payment Processing:
--     * Multiple payment method support
--     * Payment gateway integration
--     * Transaction status tracking
--     * External payment reconciliation

-- Drop existing objects
DROP TRIGGER IF EXISTS set_timestamp_chart_of_accounts ON public.chart_of_accounts;
DROP TRIGGER IF EXISTS set_timestamp_journal_entries ON public.journal_entries;
DROP TRIGGER IF EXISTS set_timestamp_journal_entry_lines ON public.journal_entry_lines;
DROP TRIGGER IF EXISTS set_timestamp_payment_transactions ON public.payment_transactions;

DROP INDEX IF EXISTS idx_chart_of_accounts_code;
DROP INDEX IF EXISTS idx_chart_of_accounts_parent;
DROP INDEX IF EXISTS idx_chart_of_accounts_type;
DROP INDEX IF EXISTS idx_chart_of_accounts_external;
DROP INDEX IF EXISTS idx_journal_entries_date;
DROP INDEX IF EXISTS idx_journal_entries_reference;
DROP INDEX IF EXISTS idx_journal_entries_external;
DROP INDEX IF EXISTS idx_journal_entry_lines_entry;
DROP INDEX IF EXISTS idx_journal_entry_lines_account;
DROP INDEX IF EXISTS idx_journal_entry_lines_external;
DROP INDEX IF EXISTS idx_payment_transactions_date;
DROP INDEX IF EXISTS idx_payment_transactions_status;
DROP INDEX IF EXISTS idx_payment_transactions_external;

DROP TABLE IF EXISTS public.payment_transactions CASCADE;
DROP TABLE IF EXISTS public.journal_entry_lines CASCADE;
DROP TABLE IF EXISTS public.journal_entries CASCADE;
DROP TABLE IF EXISTS public.chart_of_accounts CASCADE;
DROP TABLE IF EXISTS public.account_mappings CASCADE;
DROP TABLE IF EXISTS public.sync_logs CASCADE;

-- Revoke permissions
REVOKE ALL ON public.chart_of_accounts FROM authenticated;
REVOKE ALL ON public.journal_entries FROM authenticated;
REVOKE ALL ON public.journal_entry_lines FROM authenticated;
REVOKE ALL ON public.payment_transactions FROM authenticated;

-- Create tables
CREATE TABLE public.chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    name TEXT NOT NULL,
    description TEXT,
    account_type public.account_type NOT NULL,
    parent_account_id UUID REFERENCES public.chart_of_accounts(id) ON DELETE RESTRICT,
    is_active BOOLEAN DEFAULT true,
    
    -- Account balances
    opening_balance DECIMAL(15,2) DEFAULT 0,
    closing_balance DECIMAL(15,2) DEFAULT 0,
    currency_code TEXT DEFAULT 'USD',
    
    -- External System Integration
    external_refs JSONB DEFAULT '{}'::jsonb,      -- Store multiple external system references
    mapping_details JSONB DEFAULT '{}'::jsonb,    -- Store mapping rules
    custom_fields JSONB DEFAULT '{}'::jsonb,      -- System-specific custom fields
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Sync Status
    last_synced_at TIMESTAMPTZ,
    sync_status public.sync_status_type DEFAULT 'pending',
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    CONSTRAINT valid_parent CHECK (id != parent_account_id),
    CONSTRAINT valid_code_format CHECK (code ~ '^[A-Z0-9-]{2,20}$'),
    CONSTRAINT unique_active_code UNIQUE NULLS NOT DISTINCT (code, CASE WHEN deleted_at IS NULL AND is_active THEN 1 END)
);

CREATE TABLE public.journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_number TEXT NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    entry_date DATE NOT NULL,
    description TEXT,
    reference_type TEXT,
    reference_id UUID,
    
    -- Status
    is_posted BOOLEAN DEFAULT false,
    posted_at TIMESTAMPTZ,
    posted_by UUID REFERENCES auth.users(id),
    
    -- External System Integration
    external_refs JSONB DEFAULT '{}'::jsonb,      -- Store multiple external system references
    mapping_details JSONB DEFAULT '{}'::jsonb,    -- Store mapping rules
    custom_fields JSONB DEFAULT '{}'::jsonb,      -- System-specific custom fields
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Sync Status
    last_synced_at TIMESTAMPTZ,
    sync_status public.sync_status_type DEFAULT 'pending',
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    CONSTRAINT unique_active_entry_number UNIQUE NULLS NOT DISTINCT (entry_number, CASE WHEN deleted_at IS NULL THEN 1 END)
);

CREATE TABLE public.journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES public.journal_entries(id) ON DELETE CASCADE,
    line_number TEXT,
    line_order INTEGER NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Line Details
    account_id UUID NOT NULL REFERENCES public.chart_of_accounts(id) ON DELETE RESTRICT,
    description TEXT,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    currency_code TEXT DEFAULT 'USD',
    exchange_rate DECIMAL(15,6) DEFAULT 1.0,
    
    -- External System Integration
    external_refs JSONB DEFAULT '{}'::jsonb,      -- Store multiple external system references
    mapping_details JSONB DEFAULT '{}'::jsonb,    -- Store mapping rules
    custom_fields JSONB DEFAULT '{}'::jsonb,      -- System-specific custom fields
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT valid_amount CHECK (
        (debit_amount = 0 AND credit_amount > 0) OR
        (debit_amount > 0 AND credit_amount = 0)
    ),
    CONSTRAINT positive_amounts CHECK (
        debit_amount >= 0 AND credit_amount >= 0
    ),
    CONSTRAINT valid_exchange_rate CHECK (exchange_rate > 0),
    CONSTRAINT unique_line_number_per_entry UNIQUE (journal_entry_id, line_number),
    CONSTRAINT unique_line_order_per_entry UNIQUE (journal_entry_id, line_order)
);

CREATE TABLE public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_number TEXT NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Transaction Details
    payment_date DATE NOT NULL,
    payment_method public.payment_method NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency_code TEXT DEFAULT 'USD',
    exchange_rate DECIMAL(15,6) DEFAULT 1.0,
    status public.payment_status DEFAULT 'pending',
    payment_reference TEXT,
    reference_type TEXT,
    reference_id UUID,
    journal_entry_id UUID REFERENCES public.journal_entries(id) ON DELETE RESTRICT,
    
    -- Payment Gateway Integration
    payment_details JSONB,                        -- Payment gateway specific details
    gateway_response JSONB,                       -- Store gateway responses
    
    -- External System Integration
    external_refs JSONB DEFAULT '{}'::jsonb,      -- Store multiple external system references
    mapping_details JSONB DEFAULT '{}'::jsonb,    -- Store mapping rules
    custom_fields JSONB DEFAULT '{}'::jsonb,      -- System-specific custom fields
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Sync Status
    last_synced_at TIMESTAMPTZ,
    sync_status public.sync_status_type DEFAULT 'pending',
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT positive_amount CHECK (amount > 0),
    CONSTRAINT valid_exchange_rate CHECK (exchange_rate > 0),
    CONSTRAINT valid_payment_reference CHECK (payment_reference ~ '^[A-Z0-9-]{4,50}$'),
    CONSTRAINT unique_active_transaction_number UNIQUE NULLS NOT DISTINCT (transaction_number, CASE WHEN deleted_at IS NULL THEN 1 END)
);

CREATE TABLE public.account_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version INTEGER NOT NULL DEFAULT 1,
    
    -- Mapping Details
    account_id UUID NOT NULL REFERENCES public.chart_of_accounts(id) ON DELETE CASCADE,
    external_system public.accounting_system_type NOT NULL,
    external_id TEXT NOT NULL,
    external_code TEXT,
    
    -- Additional Details
    mapping_rules JSONB DEFAULT '{}'::jsonb,      -- Specific mapping rules
    custom_fields JSONB DEFAULT '{}'::jsonb,      -- System-specific fields
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    last_synced_at TIMESTAMPTZ,
    sync_status public.sync_status_type DEFAULT 'pending',
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES auth.users(id),
    
    -- Constraints
    CONSTRAINT unique_external_mapping UNIQUE NULLS NOT DISTINCT (
        account_id, 
        external_system, 
        external_id,
        CASE WHEN deleted_at IS NULL AND is_active THEN 1 END
    )
);

CREATE TABLE public.sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Sync Details
    external_system public.accounting_system_type NOT NULL,
    record_type TEXT NOT NULL,                    -- 'account', 'journal_entry', 'payment', etc.
    record_id UUID NOT NULL,
    
    -- Status
    sync_status public.sync_status_type NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    
    -- Results
    success BOOLEAN,
    error_message TEXT,
    sync_details JSONB,                          -- Store detailed sync information
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_by UUID REFERENCES auth.users(id)
);

-- Create indexes
CREATE INDEX idx_chart_of_accounts_code ON public.chart_of_accounts(code) WHERE deleted_at IS NULL;
CREATE INDEX idx_chart_of_accounts_parent ON public.chart_of_accounts(parent_account_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_chart_of_accounts_type ON public.chart_of_accounts(account_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_chart_of_accounts_sync ON public.chart_of_accounts(sync_status, last_synced_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_chart_of_accounts_currency ON public.chart_of_accounts(currency_code) WHERE deleted_at IS NULL;

CREATE INDEX idx_journal_entries_date ON public.journal_entries(entry_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_journal_entries_reference ON public.journal_entries(reference_type, reference_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_journal_entries_sync ON public.journal_entries(sync_status, last_synced_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_journal_entries_posted ON public.journal_entries(is_posted, posted_at) WHERE deleted_at IS NULL;

CREATE INDEX idx_journal_entry_lines_entry ON public.journal_entry_lines(journal_entry_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_journal_entry_lines_account ON public.journal_entry_lines(account_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_journal_entry_lines_currency ON public.journal_entry_lines(currency_code) WHERE deleted_at IS NULL;

CREATE INDEX idx_payment_transactions_date ON public.payment_transactions(payment_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_payment_transactions_sync ON public.payment_transactions(sync_status, last_synced_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_payment_transactions_journal ON public.payment_transactions(journal_entry_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_payment_transactions_currency ON public.payment_transactions(currency_code) WHERE deleted_at IS NULL;

CREATE INDEX idx_account_mappings_account ON public.account_mappings(account_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_account_mappings_external ON public.account_mappings(external_system, external_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_sync_logs_record ON public.sync_logs(record_type, record_id);
CREATE INDEX idx_sync_logs_status ON public.sync_logs(sync_status, started_at);

-- Enable Row Level Security
ALTER TABLE public.chart_of_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entry_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_logs ENABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT SELECT ON public.chart_of_accounts TO authenticated;
GRANT SELECT ON public.journal_entries TO authenticated;
GRANT SELECT ON public.journal_entry_lines TO authenticated;
GRANT SELECT ON public.payment_transactions TO authenticated;
GRANT SELECT ON public.account_mappings TO authenticated;
GRANT SELECT ON public.sync_logs TO authenticated;

GRANT ALL ON public.chart_of_accounts TO service_role;
GRANT ALL ON public.journal_entries TO service_role;
GRANT ALL ON public.journal_entry_lines TO service_role;
GRANT ALL ON public.payment_transactions TO service_role;
GRANT ALL ON public.account_mappings TO service_role;
GRANT ALL ON public.sync_logs TO service_role;

-- Add triggers for updated_at
CREATE TRIGGER set_timestamp_chart_of_accounts
    BEFORE UPDATE ON public.chart_of_accounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_timestamp_journal_entries
    BEFORE UPDATE ON public.journal_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_timestamp_journal_entry_lines
    BEFORE UPDATE ON public.journal_entry_lines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_timestamp_payment_transactions
    BEFORE UPDATE ON public.payment_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_timestamp_account_mappings
    BEFORE UPDATE ON public.account_mappings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_timestamp_sync_logs
    BEFORE UPDATE ON public.sync_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

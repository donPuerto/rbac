-- =====================================================================================
-- RBAC System Enums
-- =====================================================================================
-- Description: Enum type definitions for the Role-Based Access Control (RBAC) system
-- Version: 1.0.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Table of Contents
-- =====================================================================================
-- 1. User and System Enums
--    - gender_type            (User gender options)
--    - status_type           (General status options)
--    - role_type             (User role types)
--    - address_type          (Address classification)
--    - phone_type            (Phone number types)
--    - mfa_type              (Multi-factor authentication types)

-- 2. CRM Enums
--    - customer_segment_type  (Customer categorization)
--    - lead_status           (Lead progression states)
--    - opportunity_status    (Sales opportunity states)
--    - quote_status          (Quote progression states)
--    - job_status            (Job/Project states)
--    - job_priority          (Job priority levels)
--    - crm_entity_type       (CRM entity categories)
--    - pipeline_stage        (Sales pipeline stages)
--    - communication_channel (Communication methods)
--    - product_category      (Product classifications)
--    - document_category     (Document types)

-- 3. Task Management Enums
--    - task_type             (Task categories)
--    - task_status           (Task progression states)
--    - task_priority         (Task importance levels)

-- 4. Inventory and Purchase Enums
--    - inventory_transaction_type (Stock movement types)
--    - inventory_location_type   (Storage location types)
--    - purchase_order_status     (PO progression states)

-- 5. Accounting and Payment Enums
--    - payment_status        (Payment progression states)
--    - payment_method        (Payment methods)
--    - account_type          (Chart of accounts types)
--    - tax_type             (Tax classification)
--    - journal_entry_type    (Types of journal entries)

-- 6. User Interface and Preferences Enums
--    - date_format_type      (Date format options)
--    - time_format_type      (Time format options)
--    - display_density_type  (UI display density options)
--    - theme_type            (UI theme options)

-- 7. Security Enums
--    - two_factor_method_type (Two-factor authentication methods)

-- 8. Permission Enums
--    - permission_status_type (Permission status options)
--    - permission_category_type (Permission category options)

-- Drop all existing enum types
-- =====================================================================================
DROP TYPE IF EXISTS public.gender_type CASCADE;
DROP TYPE IF EXISTS public.status_type CASCADE;
DROP TYPE IF EXISTS public.role_type CASCADE;
DROP TYPE IF EXISTS public.address_type CASCADE;
DROP TYPE IF EXISTS public.phone_type CASCADE;
DROP TYPE IF EXISTS public.error_severity_type CASCADE;
DROP TYPE IF EXISTS public.delegation_status CASCADE;
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
DROP TYPE IF EXISTS public.inventory_transaction_type CASCADE;
DROP TYPE IF EXISTS public.inventory_location_type CASCADE;
DROP TYPE IF EXISTS public.purchase_order_status CASCADE;
DROP TYPE IF EXISTS public.payment_status CASCADE;
DROP TYPE IF EXISTS public.payment_method CASCADE;
DROP TYPE IF EXISTS public.account_type CASCADE;
DROP TYPE IF EXISTS public.referral_status_type CASCADE;
DROP TYPE IF EXISTS public.entity_type CASCADE;
DROP TYPE IF EXISTS public.theme_type CASCADE;
DROP TYPE IF EXISTS public.display_density_type CASCADE;
DROP TYPE IF EXISTS public.time_format_type CASCADE;
DROP TYPE IF EXISTS public.date_format_type CASCADE;
DROP TYPE IF EXISTS public.two_factor_method_type CASCADE;
DROP TYPE IF EXISTS public.onboarding_platform_type CASCADE;
DROP TYPE IF EXISTS public.communication_language_type CASCADE;
DROP TYPE IF EXISTS public.email_type CASCADE;
DROP TYPE IF EXISTS public.role_status_type CASCADE;
DROP TYPE IF EXISTS public.role_type CASCADE;
DROP TYPE IF EXISTS public.permission_status_type CASCADE;
DROP TYPE IF EXISTS public.permission_category_type CASCADE;
DROP TYPE IF EXISTS public.delegation_status_type;

-- Create enum types
-- =====================================================================================

-- 1. User and System Enums
-- --------------------------------------------------------------------------------------

-- Drop existing types
DROP TYPE IF EXISTS public.gender_type;

-- Gender Type
CREATE TYPE public.gender_type AS ENUM (
    'male',
    'female',
    'non_binary',
    'other',
    'prefer_not_to_say'
);

COMMENT ON TYPE public.gender_type IS 'Enumeration of gender options for user profiles';

-- Status options
CREATE TYPE public.status_type AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending'
);
COMMENT ON TYPE public.status_type IS 'General status options for various entities';

-- Role status options
CREATE TYPE public.role_status_type AS ENUM (
    'active',     -- Role is active and can be assigned
    'inactive',   -- Role is temporarily disabled
    'deprecated', -- Role is marked for removal
    'archived'    -- Role is no longer in use but preserved for history
);
COMMENT ON TYPE public.role_status_type IS 'Status options for system roles';

-- Role type options
CREATE TYPE public.role_type AS ENUM (
    -- System Roles
    'super_admin',              -- Highest level administrator with full system access
    'system_admin',             -- System administrator for infrastructure and operations
    'security_admin',           -- Security, compliance, and access control
    'audit_admin',             -- System auditing and monitoring
    
    -- IT & Development Roles
    'it_director',            -- Head of IT/Technology
    'system_architect',       -- System design and technical decisions
    'tech_lead',             -- Technical team leader
    'senior_developer',       -- Senior software developer
    'developer',             -- Software developer
    'database_admin',        -- Database administration and optimization
    'devops_engineer',       -- Infrastructure and deployment
    'qa_engineer',          -- Quality assurance
    'security_engineer',     -- Security implementation
    'ui_ux_designer',        -- User interface and experience
    
    -- Department Roles
    'department_head',       -- Department leader
    'team_lead',            -- Team leader
    'project_manager',       -- Project management
    
    -- CRM Roles
    'crm_admin',                -- CRM system administrator
    'sales_manager',            -- Sales team manager
    'sales_rep',                -- Sales representative
    'account_manager',          -- Client account manager
    'customer_support_manager', -- Customer support team manager
    'customer_support_agent',   -- Customer support representative
    'marketing_manager',        -- Marketing team manager
    'marketing_specialist',     -- Marketing team member
    
    -- Finance Roles
    'finance_admin',         -- Finance system administrator
    'finance_manager',       -- Finance department manager
    'senior_accountant',     -- Senior accounting and control
    'accountant',           -- General accounting
    'accounts_payable',     -- Vendor payments
    'accounts_receivable',  -- Customer payments
    'financial_analyst',    -- Financial analysis and reporting
    'tax_specialist',       -- Tax compliance and planning
    
    -- HR Roles
    'hr_admin',            -- HR system administrator
    'hr_manager',          -- HR team manager
    'hr_specialist',       -- HR operations
    
    -- Standard Roles
    'manager',             -- General management
    'user',               -- Standard user access
    'guest',              -- Limited guest access
    'custom'              -- Custom defined role
);
COMMENT ON TYPE public.role_type IS 'Comprehensive list of system and business roles';

-- Role classification
CREATE TYPE public.role_classification AS ENUM (
    'system',     -- Built-in system roles
    'custom',     -- User-defined custom roles
    'temporary',  -- Temporary roles with expiration
    'group',      -- Group-based roles
    'service'     -- Service account roles
);
COMMENT ON TYPE public.role_classification IS 'Classification of role types in the system';

-- Address type options
CREATE TYPE public.address_type AS ENUM (
    'home',       -- Residential/home address
    'work',       -- Business/work address
    'billing',    -- Billing address
    'shipping',   -- Shipping/delivery address
    'mailing',    -- Mailing address
    'other'       -- Other address types
);
COMMENT ON TYPE public.address_type IS 'Types of addresses for entity contacts';

-- Phone type options
CREATE TYPE public.phone_type AS ENUM (
    'mobile',     -- Mobile/cell phone
    'home',       -- Home landline
    'work',       -- Work/office phone
    'fax',        -- Fax number
    'other'       -- Other phone types
);
COMMENT ON TYPE public.phone_type IS 'Types of phone numbers for entity contacts';

-- Error severity
CREATE TYPE public.error_severity_type AS ENUM (
    'DEBUG',
    'INFO',
    'WARNING',
    'ERROR',
    'CRITICAL'
);
COMMENT ON TYPE public.error_severity_type IS 'Severity levels for error logging';

-- Delegation status
CREATE TYPE public.delegation_status AS ENUM (
    'active',
    'expired',
    'revoked'
);
COMMENT ON TYPE public.delegation_status IS 'Status options for role delegations';

-- MFA type
CREATE TYPE public.mfa_type AS ENUM (
    'sms',
    'email',
    'authenticator',
    'biometric'
);
COMMENT ON TYPE public.mfa_type IS 'Multi-factor authentication types';

-- Entity Types
CREATE TYPE public.entity_type AS ENUM (
    'profile',
    'contact',
    'lead',
    'opportunity',
    'referral'
);
COMMENT ON TYPE public.entity_type IS 'Types of entities that can have contact information';

-- Theme type
CREATE TYPE public.theme_type AS ENUM (
    'system',    -- Use system theme
    'light',     -- Light theme
    'dark'       -- Dark theme
);
COMMENT ON TYPE public.theme_type IS 'UI theme options';

-- Display density type
CREATE TYPE public.display_density_type AS ENUM (
    'compact',      -- Minimal spacing
    'comfortable',  -- Default spacing
    'spacious'     -- Maximum spacing
);
COMMENT ON TYPE public.display_density_type IS 'UI display density options';

-- Time format type
CREATE TYPE public.time_format_type AS ENUM (
    '12h',  -- 12-hour format (AM/PM)
    '24h'   -- 24-hour format
);
COMMENT ON TYPE public.time_format_type IS 'Time display format options';

-- Date format type
CREATE TYPE public.date_format_type AS ENUM (
    'YYYY-MM-DD',     -- 2024-12-31
    'DD-MM-YYYY',     -- 31-12-2024
    'MM-DD-YYYY',     -- 12-31-2024
    'DD/MM/YYYY',     -- 31/12/2024
    'MM/DD/YYYY'      -- 12/31/2024
);
COMMENT ON TYPE public.date_format_type IS 'Date display format options';

-- Onboarding platform options
CREATE TYPE public.onboarding_platform_type AS ENUM (
    'web',
    'ios',
    'android',
    'desktop'
);
COMMENT ON TYPE public.onboarding_platform_type IS 'Supported platforms for user onboarding';

-- Communication language options
CREATE TYPE public.communication_language_type AS ENUM (
    'en',    -- English
    'es',    -- Spanish
    'fr',    -- French
    'de',    -- German
    'zh',    -- Chinese
    'ja',    -- Japanese
    'ko'     -- Korean
);
COMMENT ON TYPE public.communication_language_type IS 'Supported languages for user communications';

-- Email type options
CREATE TYPE public.email_type AS ENUM (
    'personal',    -- Personal email address
    'work',        -- Work/business email address
    'other'        -- Other email address types
);
COMMENT ON TYPE public.email_type IS 'Types of email addresses for entity contacts';

-- 2. CRM Enums
-- --------------------------------------------------------------------------------------

-- CRM specific enums
CREATE TYPE public.customer_type AS ENUM (
    'prospect',
    'lead',
    'customer',
    'partner',
    'vendor',
    'competitor',
    'other'
);

CREATE TYPE public.customer_status AS ENUM (
    'active',
    'inactive',
    'pending',
    'suspended',
    'archived'
);

CREATE TYPE public.customer_segment_type AS ENUM (
    'enterprise',
    'mid_market',
    'small_business',
    'startup',
    'government',
    'non_profit',
    'individual'
);

CREATE TYPE public.lead_source AS ENUM (
    'website',
    'referral',
    'social_media',
    'email_campaign',
    'trade_show',
    'cold_call',
    'partner',
    'other'
);

CREATE TYPE public.lead_status AS ENUM (
    'new',
    'contacted',
    'qualified',
    'unqualified',
    'nurturing',
    'converted',
    'lost'
);

CREATE TYPE public.communication_channel AS ENUM (
    'email',
    'phone',
    'sms',
    'video_call',
    'in_person',
    'social_media',
    'mail'
);

CREATE TYPE public.communication_language_type AS ENUM (
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko'
);

-- Add comments for the new enums
COMMENT ON TYPE public.customer_type IS 'Classification of contacts in the CRM system';
COMMENT ON TYPE public.customer_status IS 'Current status of a customer or contact';
COMMENT ON TYPE public.customer_segment_type IS 'Business segment classification for customers';
COMMENT ON TYPE public.lead_source IS 'Source of lead acquisition';
COMMENT ON TYPE public.lead_status IS 'Current status in the lead lifecycle';
COMMENT ON TYPE public.communication_channel IS 'Preferred communication methods';
COMMENT ON TYPE public.communication_language_type IS 'Supported communication languages';

-- Customer segment
CREATE TYPE public.customer_segment_type AS ENUM (
    'individual',
    'small_business',
    'enterprise',
    'government',
    'non_profit'
);
COMMENT ON TYPE public.customer_segment_type IS 'Customer categorization types';

-- Customer type
CREATE TYPE public.customer_type AS ENUM (
    'prospect',
    'customer',
    'partner',
    'vendor'
);
COMMENT ON TYPE public.customer_type IS 'Types of customer relationships';

-- Lead status
CREATE TYPE public.lead_status AS ENUM (
    'new',
    'contacted',
    'qualified',
    'proposal',
    'negotiation',
    'won',
    'lost',
    'inactive'
);
COMMENT ON TYPE public.lead_status IS 'Status progression for leads';

-- Opportunity status
CREATE TYPE public.opportunity_status AS ENUM (
    'prospecting',
    'qualification',
    'needs_analysis',
    'proposal',
    'negotiation',
    'closed_won',
    'closed_lost'
);
COMMENT ON TYPE public.opportunity_status IS 'Status progression for opportunities';

-- Quote status
CREATE TYPE public.quote_status AS ENUM (
    'draft',
    'sent',
    'viewed',
    'accepted',
    'rejected',
    'expired',
    'revised'
);
COMMENT ON TYPE public.quote_status IS 'Status progression for quotes';

-- Job status
CREATE TYPE public.job_status AS ENUM (
    'not_started',
    'in_progress',
    'on_hold',
    'completed',
    'cancelled'
);
COMMENT ON TYPE public.job_status IS 'Status progression for jobs';

-- Job priority
CREATE TYPE public.job_priority AS ENUM (
    'low',
    'medium',
    'high',
    'urgent',
    'critical'
);
COMMENT ON TYPE public.job_priority IS 'Priority levels for jobs';

-- Task type
CREATE TYPE public.task_type AS ENUM (
    'feature',
    'bug',
    'improvement',
    'documentation',
    'research',
    'meeting',
    'review',
    'other'
);
COMMENT ON TYPE public.task_type IS 'Types of tasks';

-- Task status
CREATE TYPE public.task_status AS ENUM (
    'backlog',
    'todo',
    'in_progress',
    'in_review',
    'blocked',
    'completed',
    'cancelled'
);
COMMENT ON TYPE public.task_status IS 'Status progression for tasks';

-- Task priority
CREATE TYPE public.task_priority AS ENUM (
    'lowest',
    'low',
    'medium',
    'high',
    'highest',
    'critical'
);
COMMENT ON TYPE public.task_priority IS 'Priority levels for tasks';

-- Campaign type
CREATE TYPE public.campaign_type AS ENUM (
    'email',
    'social',
    'event',
    'webinar',
    'direct_mail',
    'phone'
);
COMMENT ON TYPE public.campaign_type IS 'Types of marketing campaigns';

-- Campaign status
CREATE TYPE public.campaign_status_type AS ENUM (
    'draft',
    'scheduled',
    'active',
    'paused',
    'completed',
    'cancelled'
);
COMMENT ON TYPE public.campaign_status_type IS 'Status options for campaigns';

-- CRM entity type
CREATE TYPE public.crm_entity_type AS ENUM (
    'lead',
    'contact',
    'account',
    'opportunity',
    'quote',
    'job',
    'product',
    'referral'
);
COMMENT ON TYPE public.crm_entity_type IS 'Types of CRM entities';

-- Communication channel
CREATE TYPE public.communication_channel AS ENUM (
    'email',
    'phone',
    'sms',
    'meeting',
    'video_call',
    'chat',
    'social_media',
    'mail'
);
COMMENT ON TYPE public.communication_channel IS 'Communication methods';

-- Product category
CREATE TYPE public.product_category AS ENUM (
    'software',
    'hardware',
    'service',
    'subscription',
    'consulting',
    'training',
    'support',
    'other'
);
COMMENT ON TYPE public.product_category IS 'Categories of products';

-- Pipeline stage
CREATE TYPE public.pipeline_stage AS ENUM (
    'lead_in',
    'qualification',
    'meeting_scheduled',
    'proposal_sent',
    'negotiation',
    'contract_sent',
    'closed_won',
    'closed_lost'
);
COMMENT ON TYPE public.pipeline_stage IS 'Stages in the sales pipeline';

-- Document category
CREATE TYPE public.document_category AS ENUM (
    'contract',
    'proposal',
    'invoice',
    'quote',
    'specification',
    'report',
    'presentation',
    'other'
);
COMMENT ON TYPE public.document_category IS 'Categories of documents';

-- Referral Status Types
CREATE TYPE public.referral_status_type AS ENUM (
    'pending',      -- Initial state when referral is created
    'contacted',    -- Referral has been contacted
    'qualified',    -- Referral has been qualified as a potential lead
    'converted',    -- Referral has been converted to a customer
    'declined',     -- Referral declined or not interested
    'expired'       -- Referral offer has expired
);
COMMENT ON TYPE public.referral_status_type IS 'Status options for referrals';

-- Board type
CREATE TYPE public.board_type AS ENUM (
    'kanban',
    'scrum',
    'project',
    'personal',
    'team'
);
COMMENT ON TYPE public.board_type IS 'Types of task boards';

-- List type
CREATE TYPE public.list_type AS ENUM (
    'standard',
    'backlog',
    'sprint',
    'done',
    'archive'
);
COMMENT ON TYPE public.list_type IS 'Types of task lists';

-- 3. Inventory Enums
-- --------------------------------------------------------------------------------------

-- Inventory location type
CREATE TYPE public.inventory_location_type AS ENUM (
    'warehouse',
    'store',
    'supplier',
    'customer',
    'transit',
    'virtual'
);
COMMENT ON TYPE public.inventory_location_type IS 'Types of inventory locations';

-- Inventory transaction type
CREATE TYPE public.inventory_transaction_type AS ENUM (
    'purchase',
    'sale',
    'transfer',
    'adjustment',
    'return',
    'write_off',
    'count'
);
COMMENT ON TYPE public.inventory_transaction_type IS 'Types of inventory transactions';

-- Purchase order status
CREATE TYPE public.purchase_order_status AS ENUM (
    'draft',
    'pending',
    'approved',
    'ordered',
    'partial_received',
    'received',
    'cancelled'
);
COMMENT ON TYPE public.purchase_order_status IS 'Status progression for purchase orders';

-- 4. Finance Enums
-- --------------------------------------------------------------------------------------

-- Payment method
CREATE TYPE public.payment_method AS ENUM (
    'cash',
    'credit_card',
    'debit_card',
    'bank_transfer',
    'check',
    'paypal',
    'crypto',
    'other'
);
COMMENT ON TYPE public.payment_method IS 'Payment methods';

-- Payment status
CREATE TYPE public.payment_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded',
    'cancelled'
);
COMMENT ON TYPE public.payment_status IS 'Status progression for payments';

-- Account type
CREATE TYPE public.account_type AS ENUM (
    'asset',
    'liability',
    'equity',
    'revenue',
    'expense'
);
COMMENT ON TYPE public.account_type IS 'Types of accounting accounts';

-- Tax type
CREATE TYPE public.tax_type AS ENUM (
    'vat',
    'sales_tax',
    'service_tax',
    'withholding',
    'none'
);
COMMENT ON TYPE public.tax_type IS 'Types of taxes';

-- Journal entry type
CREATE TYPE public.journal_entry_type AS ENUM (
    'standard',
    'adjustment',
    'closing',
    'reversing',
    'recurring'
);
COMMENT ON TYPE public.journal_entry_type IS 'Types of journal entries';

-- 6. User Interface and Preferences Enums
-- --------------------------------------------------------------------------------------

-- Date Format Type
CREATE TYPE public.date_format_type AS ENUM (
    'YYYY-MM-DD',      -- 2024-12-18
    'DD-MM-YYYY',      -- 18-12-2024
    'MM-DD-YYYY',      -- 12-18-2024
    'DD/MM/YYYY',      -- 18/12/2024
    'MM/DD/YYYY'       -- 12/18/2024
);

COMMENT ON TYPE public.date_format_type IS 'Available date format options for user preferences';

-- Time Format Type
CREATE TYPE public.time_format_type AS ENUM (
    '12h',    -- 12-hour format with AM/PM
    '24h'     -- 24-hour format
);

COMMENT ON TYPE public.time_format_type IS 'Available time format options for user preferences';

-- Display Density Type
CREATE TYPE public.display_density_type AS ENUM (
    'compact',      -- Minimal spacing, more content per view
    'comfortable',  -- Balanced spacing
    'spacious'     -- Maximum spacing, enhanced readability
);

COMMENT ON TYPE public.display_density_type IS 'UI display density options for user preferences';

-- Theme Type
CREATE TYPE public.theme_type AS ENUM (
    'light',   -- Light theme
    'dark',    -- Dark theme
    'system'   -- Follow system preference
);

COMMENT ON TYPE public.theme_type IS 'UI theme options for user preferences';

-- Security Enums
-- =====================================================================================

-- Two Factor Authentication Method
CREATE TYPE public.two_factor_method_type AS ENUM (
    'app',     -- Authenticator app (e.g., Google Authenticator)
    'sms',     -- SMS-based verification
    'email'    -- Email-based verification
);

COMMENT ON TYPE public.two_factor_method_type IS 'Available two-factor authentication methods';

-- Delegation status type

CREATE TYPE public.delegation_status_type AS ENUM (
    'active',    -- Delegation is currently active
    'expired',   -- Delegation has passed its end date
    'revoked'    -- Delegation was manually revoked
);
COMMENT ON TYPE public.delegation_status_type IS 'Status types for role delegations';

-- Permission status options
CREATE TYPE public.permission_status_type AS ENUM (
    'active',     -- Permission is active and can be granted
    'inactive',   -- Permission is temporarily disabled
    'deprecated', -- Permission is marked for removal
    'archived'    -- Permission is no longer in use but preserved for history
);
COMMENT ON TYPE public.permission_status_type IS 'Status options for system permissions';

-- Permission category options
CREATE TYPE public.permission_category_type AS ENUM (
    'system',       -- System-level permissions
    'user',         -- User management permissions
    'role',         -- Role management permissions
    'data',         -- Data access permissions
    'api',          -- API access permissions
    'file',         -- File system permissions
    'audit',        -- Audit and logging permissions
    'configuration' -- System configuration permissions
);
COMMENT ON TYPE public.permission_category_type IS 'Categories of system permissions';


-- Sync Status Type
CREATE TYPE public.sync_status_type AS ENUM (
    'pending',
    'syncing',
    'synced',
    'failed',
    'skipped'
);

-- Accounting System Type
CREATE TYPE public.accounting_system_type AS ENUM (
    'xero',
    'quickbooks',
    'sage',
    'myob',
    'other'
);

-- =====================================================================================
-- Core User System Enums
-- =====================================================================================
-- Description: Enum type definitions for the core user system
-- Version: 1.0.0
-- Last Updated: 2024-12-20
-- =====================================================================================

-- Drop existing enum types
DROP TYPE IF EXISTS public.gender_type CASCADE;
DROP TYPE IF EXISTS public.date_format_type CASCADE;
DROP TYPE IF EXISTS public.time_format_type CASCADE;
DROP TYPE IF EXISTS public.display_density_type CASCADE;
DROP TYPE IF EXISTS public.theme_type CASCADE;
DROP TYPE IF EXISTS public.two_factor_method_type CASCADE;
DROP TYPE IF EXISTS public.onboarding_platform_type CASCADE;
DROP TYPE IF EXISTS public.communication_language_type CASCADE;

-- Gender Type
CREATE TYPE public.gender_type AS ENUM (
    'male',                 -- Male gender
    'female',              -- Female gender
    'non_binary',          -- Non-binary gender
    'other',               -- Other gender identity
    'prefer_not_to_say'    -- Prefers not to disclose
);
COMMENT ON TYPE public.gender_type IS 'Gender options for user profiles';

-- Date Format Type
CREATE TYPE public.date_format_type AS ENUM (
    'YYYY-MM-DD',          -- 2024-12-20
    'DD-MM-YYYY',          -- 20-12-2024
    'MM-DD-YYYY',          -- 12-20-2024
    'DD/MM/YYYY',          -- 20/12/2024
    'MM/DD/YYYY'           -- 12/20/2024
);
COMMENT ON TYPE public.date_format_type IS 'Date format preferences';

-- Time Format Type
CREATE TYPE public.time_format_type AS ENUM (
    '12h',                 -- 12-hour format with AM/PM
    '24h'                  -- 24-hour format
);
COMMENT ON TYPE public.time_format_type IS 'Time format preferences';

-- Display Density Type
CREATE TYPE public.display_density_type AS ENUM (
    'comfortable',         -- Spacious layout
    'cozy',               -- Balanced layout
    'compact'             -- Condensed layout
);
COMMENT ON TYPE public.display_density_type IS 'UI display density options';

-- Theme Type
CREATE TYPE public.theme_type AS ENUM (
    'light',              -- Light theme
    'dark',               -- Dark theme
    'system',             -- Follow system theme
    'high_contrast'       -- High contrast theme
);
COMMENT ON TYPE public.theme_type IS 'UI theme options';

-- Two Factor Method Type
CREATE TYPE public.two_factor_method_type AS ENUM (
    'app',                -- Authenticator app
    'sms',                -- SMS verification
    'email',              -- Email verification
    'security_key',       -- Physical security key
    'backup_codes'        -- Backup codes
);
COMMENT ON TYPE public.two_factor_method_type IS 'Two-factor authentication methods';

-- Onboarding Platform Type
CREATE TYPE public.onboarding_platform_type AS ENUM (
    'web',                -- Web browser
    'ios',                -- iOS mobile app
    'android',            -- Android mobile app
    'desktop'             -- Desktop application
);
COMMENT ON TYPE public.onboarding_platform_type IS 'Platforms where users can complete onboarding';

-- Communication Language Type
CREATE TYPE public.communication_language_type AS ENUM (
    'en',                 -- English
    'es',                 -- Spanish
    'fr',                 -- French
    'de',                 -- German
    'it',                 -- Italian
    'pt',                 -- Portuguese
    'ru',                 -- Russian
    'zh',                 -- Chinese
    'ja',                 -- Japanese
    'ko'                  -- Korean
);
COMMENT ON TYPE public.communication_language_type IS 'Supported languages for communication';


-- =====================================================================================
-- Entity Contact System Enums
-- =====================================================================================
-- Description: Enum type definitions for the entity contact system
-- Version: 1.0.0
-- Last Updated: 2024-12-20
-- =====================================================================================

-- Drop existing enum types
DROP TYPE IF EXISTS public.email_type CASCADE;
DROP TYPE IF EXISTS public.phone_type CASCADE;
DROP TYPE IF EXISTS public.address_type CASCADE;

-- Email Type
CREATE TYPE public.email_type AS ENUM (
    'personal',         -- Personal email
    'work',            -- Work email
    'school',          -- School/education email
    'recovery',        -- Account recovery email
    'billing',         -- Billing notifications
    'notifications',   -- System notifications
    'other'            -- Other email type
);
COMMENT ON TYPE public.email_type IS 'Types of email addresses';

-- Phone Type
CREATE TYPE public.phone_type AS ENUM (
    'mobile',          -- Mobile phone
    'home',            -- Home phone
    'work',            -- Work phone
    'fax',             -- Fax number
    'pager',           -- Pager number
    'other'            -- Other phone type
);
COMMENT ON TYPE public.phone_type IS 'Types of phone numbers';

-- Address Type
CREATE TYPE public.address_type AS ENUM (
    'home',            -- Home address
    'work',            -- Work address
    'billing',         -- Billing address
    'shipping',        -- Shipping address
    'mailing',         -- Mailing address
    'temporary',       -- Temporary address
    'other'            -- Other address type
);
COMMENT ON TYPE public.address_type IS 'Types of addresses';


-- =====================================================================================
-- RBAC (Role-Based Access Control) Enums
-- =====================================================================================
-- Description: Enum type definitions for the RBAC system
-- Version: 1.0.0
-- Last Updated: 2024-12-19
-- =====================================================================================

-- Drop existing RBAC enum types
DROP TYPE IF EXISTS public.role_type CASCADE;
DROP TYPE IF EXISTS public.role_status_type CASCADE;
DROP TYPE IF EXISTS public.permission_category_type CASCADE;
DROP TYPE IF EXISTS public.delegation_status_type CASCADE;

-- Role Type
CREATE TYPE public.role_type AS ENUM (
    'system',           -- Built-in system roles
    'custom',           -- User-defined roles
    'temporary',        -- Time-limited roles
    'group',           -- Group-based roles
    'application',     -- Application-specific roles
    'service',         -- Service account roles
    'restricted'       -- Limited access roles
);
COMMENT ON TYPE public.role_type IS 'Types of roles in the system';

-- Role Status Type
CREATE TYPE public.role_status_type AS ENUM (
    'active',           -- Currently active
    'inactive',         -- Temporarily disabled
    'pending',          -- Awaiting activation
    'suspended',        -- Suspended for review
    'expired',          -- Past valid period
    'archived',         -- Archived/historical
    'revoked'           -- Permanently disabled
);
COMMENT ON TYPE public.role_status_type IS 'Status options for roles';

-- Permission Category Type
CREATE TYPE public.permission_category_type AS ENUM (
    'system',           -- System administration
    'security',         -- Security controls
    'data',            -- Data access
    'user',            -- User management
    'configuration',    -- System configuration
    'integration',      -- External integrations
    'reporting',        -- Reporting and analytics
    'workflow',         -- Process management
    'api',             -- API access
    'audit',           -- Audit controls
    'custom'           -- Custom permissions
);
COMMENT ON TYPE public.permission_category_type IS 'Categories of system permissions';

-- Delegation Status Type
CREATE TYPE public.delegation_status_type AS ENUM (
    'pending',          -- Awaiting activation
    'active',           -- Currently active
    'suspended',        -- Temporarily suspended
    'revoked',          -- Manually revoked
    'expired',          -- Past end date
    'cancelled',        -- Cancelled before start
    'completed'         -- Successfully completed
);
COMMENT ON TYPE public.delegation_status_type IS 'Status options for role delegations';


-- =====================================================================================
-- System Audit Enums
-- =====================================================================================
-- Description: Enum type definitions for the audit and logging system
-- Version: 1.0.0
-- Last Updated: 2024-12-19
-- =====================================================================================

-- Drop existing audit enum types
DROP TYPE IF EXISTS public.audit_action_type CASCADE;
DROP TYPE IF EXISTS public.activity_type CASCADE;
DROP TYPE IF EXISTS public.audit_status_type CASCADE;
DROP TYPE IF EXISTS public.data_sensitivity_type CASCADE;
DROP TYPE IF EXISTS public.audit_category_type CASCADE;
DROP TYPE IF EXISTS public.compliance_status_type CASCADE;

-- Audit Action Type
CREATE TYPE public.audit_action_type AS ENUM (
    -- Data Operations
    'create',               -- Record creation
    'read',                -- Record access
    'update',              -- Record modification
    'delete',              -- Record deletion
    'restore',             -- Record restoration
    'archive',             -- Record archival
    
    -- System Operations
    'login',               -- User login
    'logout',              -- User logout
    'failed_login',        -- Failed login attempt
    'password_change',     -- Password modification
    'password_reset',      -- Password reset request
    'mfa_enable',          -- MFA activation
    'mfa_disable',         -- MFA deactivation
    'api_access',          -- API endpoint access
    
    -- Security Operations
    'permission_grant',    -- Permission assignment
    'permission_revoke',   -- Permission removal
    'role_assignment',     -- Role assignment
    'role_removal',        -- Role removal
    'access_denied',       -- Access rejection
    'security_alert',      -- Security warning
    
    -- System Administration
    'config_change',       -- Configuration modification
    'backup',             -- System backup
    'restore',            -- System restoration
    'maintenance',        -- System maintenance
    'deployment',         -- System deployment
    
    -- Data Management
    'import',             -- Data import
    'export',             -- Data export
    'bulk_update',        -- Mass update
    'bulk_delete',        -- Mass deletion
    'data_sync',          -- Data synchronization
    
    -- Integration
    'api_key_generate',   -- API key creation
    'webhook_trigger',    -- Webhook execution
    'integration_sync',   -- Integration update
    'external_access'     -- External system access
);
COMMENT ON TYPE public.audit_action_type IS 'Types of actions tracked in the audit system';

-- Activity Type
CREATE TYPE public.activity_type AS ENUM (
    -- User Session Activities
    'session_start',        -- Session initiation
    'session_end',         -- Session termination
    'session_timeout',     -- Session timeout
    'session_refresh',     -- Session renewal
    
    -- Data Activities
    'data_view',           -- Record viewing
    'data_create',         -- Record creation
    'data_modify',         -- Record modification
    'data_remove',         -- Record removal
    'data_export',         -- Data export
    'data_import',         -- Data import
    
    -- System Interaction
    'search_perform',      -- Search execution
    'report_generate',     -- Report creation
    'file_upload',         -- File upload
    'file_download',       -- File download
    'print_document',      -- Document printing
    'email_send',          -- Email transmission
    
    -- Configuration
    'settings_change',     -- Settings modification
    'profile_update',      -- Profile update
    'preference_change',   -- Preference modification
    
    -- Workflow
    'workflow_start',      -- Process initiation
    'workflow_complete',   -- Process completion
    'task_assign',         -- Task assignment
    'task_complete',       -- Task completion
    'approval_request',    -- Approval request
    'approval_decision'    -- Approval decision
);
COMMENT ON TYPE public.activity_type IS 'Types of user activities tracked in the system';

-- Audit Status Type
CREATE TYPE public.audit_status_type AS ENUM (
    'pending',            -- Awaiting processing
    'processing',         -- Currently processing
    'completed',          -- Successfully processed
    'failed',            -- Processing failed
    'requires_review',   -- Needs manual review
    'archived',          -- Archived for retention
    'deleted'            -- Marked for deletion
);
COMMENT ON TYPE public.audit_status_type IS 'Status options for audit records';

-- Data Sensitivity Type
CREATE TYPE public.data_sensitivity_type AS ENUM (
    'public',            -- Publicly accessible
    'internal',          -- Internal use only
    'confidential',      -- Confidential data
    'restricted',        -- Restricted access
    'sensitive',         -- Sensitive information
    'personal',          -- Personal data (PII)
    'financial',         -- Financial records
    'health'             -- Health information
);
COMMENT ON TYPE public.data_sensitivity_type IS 'Classification of data sensitivity levels';

-- Audit Category Type
CREATE TYPE public.audit_category_type AS ENUM (
    'security',          -- Security-related
    'compliance',        -- Compliance-related
    'operational',       -- Operations-related
    'financial',         -- Finance-related
    'system',           -- System-related
    'user',             -- User-related
    'data',             -- Data-related
    'integration'       -- Integration-related
);
COMMENT ON TYPE public.audit_category_type IS 'Categories of audit records';

-- Compliance Status Type
CREATE TYPE public.compliance_status_type AS ENUM (
    'compliant',         -- Meets requirements
    'non_compliant',     -- Does not meet requirements
    'partially_compliant', -- Partially meets requirements
    'under_review',      -- Being reviewed
    'remediation_required', -- Needs fixing
    'not_applicable',    -- Requirements don't apply
    'waiver_granted'     -- Compliance waiver given
);
COMMENT ON TYPE public.compliance_status_type IS 'Compliance status indicators';

-- =====================================================================================
-- CRM System Enums
-- =====================================================================================
-- Description: Enum type definitions for the CRM system
-- Version: 1.0.0
-- Last Updated: 2024-12-20
-- =====================================================================================

-- Drop existing enum types
DROP TYPE IF EXISTS public.customer_type CASCADE;
DROP TYPE IF EXISTS public.customer_status CASCADE;
DROP TYPE IF EXISTS public.customer_segment_type CASCADE;
DROP TYPE IF EXISTS public.lead_status CASCADE;
DROP TYPE IF EXISTS public.lead_source CASCADE;
DROP TYPE IF EXISTS public.opportunity_status CASCADE;
DROP TYPE IF EXISTS public.quote_status CASCADE;
DROP TYPE IF EXISTS public.currency_type CASCADE;

-- Drop additional enum types
DROP TYPE IF EXISTS public.job_status CASCADE;
DROP TYPE IF EXISTS public.job_priority CASCADE;
DROP TYPE IF EXISTS public.billing_status CASCADE;
DROP TYPE IF EXISTS public.referral_status CASCADE;
DROP TYPE IF EXISTS public.reward_status CASCADE;
DROP TYPE IF EXISTS public.product_status CASCADE;
DROP TYPE IF EXISTS public.product_type CASCADE;
DROP TYPE IF EXISTS public.pipeline_status CASCADE;
DROP TYPE IF EXISTS public.pipeline_type CASCADE;
DROP TYPE IF EXISTS public.communication_type CASCADE;
DROP TYPE IF EXISTS public.communication_status CASCADE;
DROP TYPE IF EXISTS public.communication_direction CASCADE;
DROP TYPE IF EXISTS public.priority_level CASCADE;
DROP TYPE IF EXISTS public.document_status CASCADE;
DROP TYPE IF EXISTS public.document_type CASCADE;
DROP TYPE IF EXISTS public.access_level CASCADE;
DROP TYPE IF EXISTS public.workflow_status CASCADE;
DROP TYPE IF EXISTS public.approval_status CASCADE;
DROP TYPE IF EXISTS public.integration_status CASCADE;
DROP TYPE IF EXISTS public.notification_type CASCADE;
DROP TYPE IF EXISTS public.time_unit CASCADE;
DROP TYPE IF EXISTS public.audit_action CASCADE;
DROP TYPE IF EXISTS public.relationship_status CASCADE;
DROP TYPE IF EXISTS public.relationship_strength CASCADE;
DROP TYPE IF EXISTS public.relationship_direction CASCADE;
DROP TYPE IF EXISTS public.interaction_outcome CASCADE;

-- Customer Type
CREATE TYPE public.customer_type AS ENUM (
    'prospect',          -- Potential customer
    'lead',             -- Qualified prospect
    'customer',         -- Active customer
    'former_customer',  -- Past customer
    'partner',          -- Business partner
    'competitor',       -- Competitor
    'other'            -- Other relationship
);
COMMENT ON TYPE public.customer_type IS 'Types of customer relationships';

-- Customer Status
CREATE TYPE public.customer_status AS ENUM (
    'active',           -- Currently active
    'inactive',         -- Temporarily inactive
    'pending',          -- Pending activation
    'suspended',        -- Account suspended
    'closed'           -- Account closed
);
COMMENT ON TYPE public.customer_status IS 'Status of customer accounts';

-- Customer Segment Type
CREATE TYPE public.customer_segment_type AS ENUM (
    'enterprise',       -- Large enterprise
    'mid_market',       -- Mid-sized business
    'small_business',   -- Small business
    'startup',          -- Startup company
    'individual',       -- Individual customer
    'government',       -- Government entity
    'non_profit'       -- Non-profit organization
);
COMMENT ON TYPE public.customer_segment_type IS 'Business segment classification';

-- Lead Status
CREATE TYPE public.lead_status AS ENUM (
    'new',              -- New lead
    'contacted',        -- Initial contact made
    'qualified',        -- Qualified lead
    'unqualified',      -- Not qualified
    'nurturing',        -- In nurturing process
    'converted',        -- Converted to opportunity
    'lost'             -- Lost/Dead lead
);
COMMENT ON TYPE public.lead_status IS 'Status of sales leads';

-- Lead Source
CREATE TYPE public.lead_source AS ENUM (
    'website',          -- Company website
    'referral',         -- Customer referral
    'campaign',         -- Marketing campaign
    'social_media',     -- Social media
    'trade_show',       -- Trade show/event
    'cold_call',        -- Cold calling
    'partner',          -- Partner referral
    'other'            -- Other sources
);
COMMENT ON TYPE public.lead_source IS 'Source of lead acquisition';

-- Opportunity Status
CREATE TYPE public.opportunity_status AS ENUM (
    'prospecting',      -- Initial prospecting
    'qualification',    -- Qualification stage
    'needs_analysis',   -- Analyzing needs
    'proposal',         -- Proposal stage
    'negotiation',      -- In negotiations
    'closed_won',       -- Deal won
    'closed_lost'      -- Deal lost
);
COMMENT ON TYPE public.opportunity_status IS 'Status of sales opportunities';

-- Quote Status
CREATE TYPE public.quote_status AS ENUM (
    'draft',            -- Quote being drafted
    'review',           -- Under review
    'sent',             -- Sent to customer
    'negotiation',      -- In negotiation
    'accepted',         -- Quote accepted
    'rejected',         -- Quote rejected
    'expired'          -- Quote expired
);
COMMENT ON TYPE public.quote_status IS 'Status of price quotes';

-- Currency Type
CREATE TYPE public.currency_type AS ENUM (
    'USD',              -- US Dollar
    'EUR',              -- Euro
    'GBP',              -- British Pound
    'JPY',              -- Japanese Yen
    'CNY',              -- Chinese Yuan
    'AUD',              -- Australian Dollar
    'CAD'              -- Canadian Dollar
);
COMMENT ON TYPE public.currency_type IS 'Supported currency types';

-- Job Status
CREATE TYPE public.job_status AS ENUM (
    'scheduled',        -- Job scheduled
    'in_progress',      -- Job in progress
    'completed',        -- Job completed
    'cancelled',        -- Job cancelled
    'on_hold'          -- Job on hold
);
COMMENT ON TYPE public.job_status IS 'Status of service jobs';

-- Job Priority
CREATE TYPE public.job_priority AS ENUM (
    'low',             -- Low priority
    'medium',          -- Medium priority
    'high',            -- High priority
    'urgent'           -- Urgent priority
);
COMMENT ON TYPE public.job_priority IS 'Priority levels for jobs';

-- Billing Status
CREATE TYPE public.billing_status AS ENUM (
    'pending',         -- Pending billing
    'invoiced',        -- Invoice sent
    'paid',            -- Payment received
    'overdue',         -- Payment overdue
    'cancelled'        -- Billing cancelled
);
COMMENT ON TYPE public.billing_status IS 'Status of job billing';

-- Referral Status
CREATE TYPE public.referral_status AS ENUM (
    'pending',         -- Pending processing
    'contacted',       -- Initial contact made
    'qualified',       -- Qualified referral
    'converted',       -- Converted to customer
    'declined',        -- Referral declined
    'expired'          -- Referral expired
);
COMMENT ON TYPE public.referral_status IS 'Status of customer referrals';

-- Reward Status
CREATE TYPE public.reward_status AS ENUM (
    'pending',         -- Reward pending
    'approved',        -- Reward approved
    'issued',          -- Reward issued
    'claimed',         -- Reward claimed
    'expired',         -- Reward expired
    'cancelled'        -- Reward cancelled
);
COMMENT ON TYPE public.reward_status IS 'Status of referral rewards';

-- Product Status
CREATE TYPE public.product_status AS ENUM (
    'draft',           -- Product draft
    'active',          -- Active product
    'inactive',        -- Inactive product
    'discontinued',    -- Discontinued product
    'out_of_stock'     -- Out of stock
);
COMMENT ON TYPE public.product_status IS 'Status of products';

-- Product Type
CREATE TYPE public.product_type AS ENUM (
    'physical',        -- Physical product
    'digital',         -- Digital product
    'service',         -- Service product
    'subscription',    -- Subscription product
    'bundle'           -- Product bundle
);
COMMENT ON TYPE public.product_type IS 'Types of products';

-- Pipeline Status
CREATE TYPE public.pipeline_status AS ENUM (
    'active',          -- Active pipeline
    'inactive',        -- Inactive pipeline
    'archived'         -- Archived pipeline
);
COMMENT ON TYPE public.pipeline_status IS 'Status of sales pipelines';

-- Pipeline Type
CREATE TYPE public.pipeline_type AS ENUM (
    'sales',           -- Sales pipeline
    'lead',            -- Lead pipeline
    'service',         -- Service pipeline
    'support'          -- Support pipeline
);
COMMENT ON TYPE public.pipeline_type IS 'Types of business pipelines';

-- Communication Type
CREATE TYPE public.communication_type AS ENUM (
    'email',           -- Email communication
    'call',            -- Phone call
    'meeting',         -- Meeting
    'chat',            -- Chat message
    'note',            -- Internal note
    'sms',             -- SMS message
    'social'           -- Social media
);
COMMENT ON TYPE public.communication_type IS 'Types of communications';

-- Communication Status
CREATE TYPE public.communication_status AS ENUM (
    'pending',         -- Pending
    'sent',            -- Sent
    'delivered',       -- Delivered
    'read',            -- Read/Received
    'replied',         -- Replied to
    'failed',          -- Failed
    'cancelled'        -- Cancelled
);
COMMENT ON TYPE public.communication_status IS 'Status of communications';

-- Communication Direction
CREATE TYPE public.communication_direction AS ENUM (
    'inbound',         -- Incoming communication
    'outbound',        -- Outgoing communication
    'internal'         -- Internal communication
);
COMMENT ON TYPE public.communication_direction IS 'Direction of communications';

-- Priority Level
CREATE TYPE public.priority_level AS ENUM (
    'low',             -- Low priority
    'normal',          -- Normal priority
    'high',            -- High priority
    'urgent',          -- Urgent priority
    'critical'         -- Critical priority
);
COMMENT ON TYPE public.priority_level IS 'Priority levels for various entities';

-- Document Status
CREATE TYPE public.document_status AS ENUM (
    'draft',           -- Document draft
    'review',          -- Under review
    'approved',        -- Approved
    'published',       -- Published
    'archived',        -- Archived
    'obsolete'         -- Obsolete
);
COMMENT ON TYPE public.document_status IS 'Status of documents';

-- Document Type
CREATE TYPE public.document_type AS ENUM (
    'contract',        -- Legal contract
    'proposal',        -- Business proposal
    'invoice',         -- Invoice
    'report',          -- Report
    'presentation',    -- Presentation
    'specification',   -- Specification
    'other'           -- Other document
);
COMMENT ON TYPE public.document_type IS 'Types of documents';

-- Access Level
CREATE TYPE public.access_level AS ENUM (
    'public',          -- Public access
    'internal',        -- Internal only
    'confidential',    -- Confidential
    'restricted',      -- Restricted access
    'private'          -- Private access
);
COMMENT ON TYPE public.access_level IS 'Access levels for documents';

-- Workflow Status
CREATE TYPE public.workflow_status AS ENUM (
    'pending',         -- Pending start
    'in_progress',     -- In progress
    'completed',       -- Completed
    'failed',          -- Failed
    'cancelled',       -- Cancelled
    'on_hold'          -- On hold
);
COMMENT ON TYPE public.workflow_status IS 'Status of workflow processes';

-- Approval Status
CREATE TYPE public.approval_status AS ENUM (
    'pending',         -- Pending approval
    'approved',        -- Approved
    'rejected',        -- Rejected
    'review',          -- Under review
    'cancelled'        -- Cancelled
);
COMMENT ON TYPE public.approval_status IS 'Status of approval processes';

-- Integration Status
CREATE TYPE public.integration_status AS ENUM (
    'active',          -- Integration active
    'inactive',        -- Integration inactive
    'error',           -- Integration error
    'suspended',       -- Integration suspended
    'configuring'      -- Being configured
);
COMMENT ON TYPE public.integration_status IS 'Status of system integrations';

-- Notification Type
CREATE TYPE public.notification_type AS ENUM (
    'info',            -- Information
    'warning',         -- Warning
    'error',           -- Error
    'success',         -- Success
    'alert'           -- Alert
);
COMMENT ON TYPE public.notification_type IS 'Types of system notifications';

-- Time Unit
CREATE TYPE public.time_unit AS ENUM (
    'minute',          -- Minutes
    'hour',            -- Hours
    'day',             -- Days
    'week',            -- Weeks
    'month',           -- Months
    'year'            -- Years
);
COMMENT ON TYPE public.time_unit IS 'Time measurement units';

-- Audit Action
CREATE TYPE public.audit_action AS ENUM (
    'create',          -- Create action
    'update',          -- Update action
    'delete',          -- Delete action
    'view',            -- View action
    'export',          -- Export action
    'import'          -- Import action
);
COMMENT ON TYPE public.audit_action IS 'Types of auditable actions';

-- Relationship Status
CREATE TYPE public.relationship_status AS ENUM (
    'active',          -- Active relationship
    'inactive',        -- Inactive relationship
    'pending',         -- Pending approval/activation
    'suspended',       -- Temporarily suspended
    'terminated'       -- Permanently terminated
);
COMMENT ON TYPE public.relationship_status IS 'Status of entity relationships';

-- Relationship Strength
CREATE TYPE public.relationship_strength AS ENUM (
    'weak',            -- Weak connection
    'moderate',        -- Moderate connection
    'strong',          -- Strong connection
    'critical'         -- Critical relationship
);
COMMENT ON TYPE public.relationship_strength IS 'Strength of entity relationships';

-- Relationship Direction
CREATE TYPE public.relationship_direction AS ENUM (
    'unidirectional',  -- One-way relationship
    'bidirectional',   -- Two-way relationship
    'hierarchical'     -- Parent-child relationship
);
COMMENT ON TYPE public.relationship_direction IS 'Direction of entity relationships';

-- Interaction Outcome
CREATE TYPE public.interaction_outcome AS ENUM (
    'positive',        -- Positive outcome
    'neutral',         -- Neutral outcome
    'negative',        -- Negative outcome
    'follow_up'        -- Requires follow-up
);
COMMENT ON TYPE public.interaction_outcome IS 'Outcome of entity interactions';


-- =====================================================================================
-- Task Management System Enums
-- =====================================================================================
-- Description: Enum type definitions for the task management system
-- Version: 1.0.0
-- Last Updated: 2024-12-19
-- =====================================================================================

-- Drop existing task enum types
DROP TYPE IF EXISTS public.board_type CASCADE;
DROP TYPE IF EXISTS public.list_type CASCADE;
DROP TYPE IF EXISTS public.task_type CASCADE;
DROP TYPE IF EXISTS public.task_priority CASCADE;
DROP TYPE IF EXISTS public.task_status CASCADE;
DROP TYPE IF EXISTS public.task_assignment_role CASCADE;
DROP TYPE IF EXISTS public.task_dependency_type CASCADE;

-- Board Type
CREATE TYPE public.board_type AS ENUM (
    'kanban',           -- Kanban-style board
    'scrum',            -- Scrum/sprint board
    'project',          -- Project management board
    'personal',         -- Personal task board
    'team',             -- Team collaboration board
    'workflow',         -- Workflow management board
    'custom'            -- Custom board type
);
COMMENT ON TYPE public.board_type IS 'Types of task boards in the system';

-- List Type
CREATE TYPE public.list_type AS ENUM (
    'backlog',          -- Upcoming tasks
    'todo',             -- To-do tasks
    'in_progress',      -- Tasks in progress
    'review',           -- Tasks under review
    'done',             -- Completed tasks
    'blocked',          -- Blocked tasks
    'archived',         -- Archived tasks
    'custom'            -- Custom list type
);
COMMENT ON TYPE public.list_type IS 'Types of lists within task boards';

-- Task Type
CREATE TYPE public.task_type AS ENUM (
    'task',             -- Regular task
    'bug',              -- Bug/issue
    'feature',          -- Feature request
    'improvement',      -- Improvement task
    'epic',             -- Epic/large initiative
    'story',            -- User story
    'subtask',          -- Subtask of parent task
    'milestone',        -- Project milestone
    'maintenance',      -- Maintenance task
    'research',         -- Research task
    'documentation',    -- Documentation task
    'custom'            -- Custom task type
);
COMMENT ON TYPE public.task_type IS 'Types of tasks in the system';

-- Task Priority
CREATE TYPE public.task_priority AS ENUM (
    'critical',         -- Critical priority
    'high',             -- High priority
    'medium',           -- Medium priority
    'low',              -- Low priority
    'none'              -- No priority set
);
COMMENT ON TYPE public.task_priority IS 'Priority levels for tasks';

-- Task Status
CREATE TYPE public.task_status AS ENUM (
    'backlog',          -- In backlog
    'todo',             -- To do
    'in_progress',      -- In progress
    'review',           -- Under review
    'testing',          -- In testing
    'blocked',          -- Blocked
    'completed',        -- Completed
    'cancelled',        -- Cancelled
    'archived'          -- Archived
);
COMMENT ON TYPE public.task_status IS 'Status options for tasks';

-- Task Assignment Role
CREATE TYPE public.task_assignment_role AS ENUM (
    'owner',            -- Task owner
    'assignee',         -- Task assignee
    'reviewer',         -- Task reviewer
    'watcher',          -- Task watcher
    'contributor',      -- Task contributor
    'custom'            -- Custom role
);
COMMENT ON TYPE public.task_assignment_role IS 'Roles for task assignments';

-- Task Dependency Type
CREATE TYPE public.task_dependency_type AS ENUM (
    'blocks',           -- Task blocks another task
    'blocked_by',       -- Task is blocked by another task
    'relates_to',       -- Task relates to another task
    'duplicates',       -- Task duplicates another task
    'parent_of',        -- Task is parent of another task
    'child_of',         -- Task is child of another task
    'follows',          -- Task follows another task
    'precedes'          -- Task precedes another task
);
COMMENT ON TYPE public.task_dependency_type IS 'Types of task dependencies';


-- =====================================================================================
-- Inventory Management Enums
-- =====================================================================================
-- Description: Enum type definitions specific to the inventory management system
-- Version: 1.0.0
-- Last Updated: 2024-12-19
-- =====================================================================================

-- Drop existing inventory enum types
DROP TYPE IF EXISTS public.inventory_location_type CASCADE;
DROP TYPE IF EXISTS public.inventory_transaction_type CASCADE;
DROP TYPE IF EXISTS public.purchase_order_status CASCADE;
DROP TYPE IF EXISTS public.stock_adjustment_type CASCADE;
DROP TYPE IF EXISTS public.inventory_valuation_method CASCADE;
DROP TYPE IF EXISTS public.quality_status_type CASCADE;
DROP TYPE IF EXISTS public.storage_condition_type CASCADE;
DROP TYPE IF EXISTS public.unit_of_measure_type CASCADE;

-- Inventory Location Type
CREATE TYPE public.inventory_location_type AS ENUM (
    'warehouse',            -- Main storage facility
    'distribution_center', -- Regional distribution hub
    'retail_store',       -- Physical retail location
    'supplier_location',  -- External supplier location
    'customer_location',  -- Customer storage location
    'transit_point',      -- Temporary transit storage
    'returns_center',     -- Returns processing center
    'virtual',           -- Virtual/digital storage
    'consignment',       -- Consignment location
    'production',        -- Manufacturing facility
    'quality_control',   -- QC inspection area
    'disposal',          -- Disposal/write-off location
    'repair_center'      -- Repair and maintenance
);
COMMENT ON TYPE public.inventory_location_type IS 'Types of inventory storage locations';

-- Inventory Transaction Type
CREATE TYPE public.inventory_transaction_type AS ENUM (
    -- Inbound Transactions
    'purchase_receipt',        -- Receipt from purchase
    'return_receipt',         -- Customer return
    'production_receipt',     -- Manufacturing output
    'transfer_in',           -- Transfer from another location
    'adjustment_in',         -- Positive adjustment
    
    -- Outbound Transactions
    'sales_issue',           -- Sales fulfillment
    'return_issue',          -- Return to supplier
    'production_issue',      -- Manufacturing consumption
    'transfer_out',          -- Transfer to another location
    'adjustment_out',        -- Negative adjustment
    'disposal',              -- Write-off/disposal
    
    -- Internal Transactions
    'internal_transfer',     -- Movement between locations
    'quality_inspection',    -- QC status change
    'revaluation',          -- Cost adjustment
    'cycle_count',          -- Stock count adjustment
    'reservation',          -- Stock reservation
    'unreservation'         -- Release reservation
);
COMMENT ON TYPE public.inventory_transaction_type IS 'Types of inventory movements and adjustments';

-- Purchase Order Status
CREATE TYPE public.purchase_order_status AS ENUM (
    'draft',                -- Initial creation
    'pending_approval',     -- Awaiting approval
    'approved',            -- Approved for processing
    'sent_to_supplier',    -- Transmitted to supplier
    'acknowledged',        -- Confirmed by supplier
    'partially_received',  -- Some items received
    'fully_received',      -- All items received
    'completed',          -- Order fully processed
    'cancelled',          -- Order cancelled
    'on_hold',            -- Temporarily suspended
    'disputed'            -- Issue with order
);
COMMENT ON TYPE public.purchase_order_status IS 'Status progression for purchase orders';

-- Stock Adjustment Type
CREATE TYPE public.stock_adjustment_type AS ENUM (
    'damage',              -- Damaged goods
    'expiry',             -- Expired items
    'loss',               -- Lost or missing items
    'theft',              -- Stolen items
    'quality_issue',      -- Quality problems
    'count_adjustment',   -- Stock count corrections
    'system_adjustment',  -- System reconciliation
    'revaluation',       -- Value adjustment
    'conversion',        -- Unit conversion
    'sample',            -- Sample usage
    'gift',              -- Promotional giveaway
    'write_off'          -- Complete write-off
);
COMMENT ON TYPE public.stock_adjustment_type IS 'Reasons for inventory adjustments';

-- Inventory Valuation Method
CREATE TYPE public.inventory_valuation_method AS ENUM (
    'fifo',              -- First In, First Out
    'lifo',              -- Last In, First Out
    'average_cost',      -- Weighted Average Cost
    'specific_cost',     -- Specific Identification
    'standard_cost',     -- Standard Costing
    'retail_method',     -- Retail Inventory Method
    'replacement_cost'   -- Current Replacement Cost
);
COMMENT ON TYPE public.inventory_valuation_method IS 'Methods for valuing inventory';

-- Quality Status Type
CREATE TYPE public.quality_status_type AS ENUM (
    'pending_inspection',    -- Awaiting QC check
    'passed',               -- Passed QC check
    'failed',               -- Failed QC check
    'under_review',         -- Under investigation
    'quarantined',          -- Temporarily held
    'rework',               -- Needs rework
    'scrapped',             -- Cannot be used
    'conditionally_passed'  -- Passed with conditions
);
COMMENT ON TYPE public.quality_status_type IS 'Quality control status options';

-- Storage Condition Type
CREATE TYPE public.storage_condition_type AS ENUM (
    'room_temperature',     -- Standard conditions
    'refrigerated',        -- Cold storage
    'frozen',              -- Freezer storage
    'climate_controlled',  -- Specific temperature/humidity
    'hazardous',          -- Hazardous materials
    'bulk_storage',       -- Large quantity storage
    'high_security',      -- Secured storage
    'outdoor',            -- External storage
    'specialized'         -- Special requirements
);
COMMENT ON TYPE public.storage_condition_type IS 'Required storage conditions';

-- Unit of Measure Type
CREATE TYPE public.unit_of_measure_type AS ENUM (
    -- Weight
    'kilogram',           -- kg
    'gram',              -- g
    'pound',             -- lb
    'ounce',             -- oz
    
    -- Volume
    'liter',             -- L
    'milliliter',        -- mL
    'gallon',            -- gal
    'fluid_ounce',       -- fl oz
    
    -- Length
    'meter',             -- m
    'centimeter',        -- cm
    'inch',              -- in
    'foot',              -- ft
    
    -- Area
    'square_meter',      -- m²
    'square_foot',       -- ft²
    
    -- Count
    'piece',             -- pc
    'box',               -- box
    'case',              -- case
    'pallet',            -- pallet
    
    -- Time
    'hour',              -- hr
    'day',               -- day
    'month',             -- month
    
    -- Digital
    'byte',              -- B
    'kilobyte',          -- KB
    'megabyte',          -- MB
    'gigabyte'           -- GB
);
COMMENT ON TYPE public.unit_of_measure_type IS 'Standard units of measurement';



-- =====================================================================================
-- Accounting System Enums
-- =====================================================================================
-- Description: Enum type definitions specific to the accounting system
-- Version: 1.0.0
-- Last Updated: 2024-12-19
-- =====================================================================================

-- Drop existing accounting enum types
DROP TYPE IF EXISTS public.accounting_system_type CASCADE;
DROP TYPE IF EXISTS public.journal_entry_status CASCADE;
DROP TYPE IF EXISTS public.reconciliation_status CASCADE;
DROP TYPE IF EXISTS public.accounting_period_status CASCADE;
DROP TYPE IF EXISTS public.account_category_type CASCADE;
DROP TYPE IF EXISTS public.transaction_type CASCADE;
DROP TYPE IF EXISTS public.currency_status_type CASCADE;

-- Accounting System Type
CREATE TYPE public.accounting_system_type AS ENUM (
    'quickbooks_online',    -- QuickBooks Online integration
    'quickbooks_desktop',   -- QuickBooks Desktop integration
    'xero',                -- Xero integration
    'sage_intacct',        -- Sage Intacct integration
    'sage_business',       -- Sage Business Cloud integration
    'netsuite',            -- NetSuite integration
    'freshbooks',          -- FreshBooks integration
    'wave',               -- Wave Accounting integration
    'zoho_books',         -- Zoho Books integration
    'custom'              -- Custom accounting system
);
COMMENT ON TYPE public.accounting_system_type IS 'Types of accounting systems that can be integrated';

-- Journal Entry Status
CREATE TYPE public.journal_entry_status AS ENUM (
    'draft',              -- Initial state when created
    'pending_review',     -- Awaiting first level review
    'pending_approval',   -- Awaiting final approval
    'approved',           -- Approved but not posted
    'posted',            -- Posted to the general ledger
    'rejected',          -- Rejected during approval process
    'voided',            -- Voided after posting
    'reversed',          -- Reversed by a new entry
    'scheduled',         -- Scheduled for future posting
    'recurring',         -- Template for recurring entries
    'on_hold'           -- Temporarily suspended
);
COMMENT ON TYPE public.journal_entry_status IS 'Status progression for journal entries';

-- Reconciliation Status
CREATE TYPE public.reconciliation_status AS ENUM (
    'unreconciled',         -- Not yet reconciled
    'in_progress',          -- Reconciliation in progress
    'pending_review',       -- Awaiting reconciliation review
    'reconciled',           -- Fully reconciled
    'partially_matched',    -- Some items matched
    'disputed',             -- Discrepancy found
    'adjusted',             -- Reconciled with adjustments
    'auto_reconciled',      -- Automatically reconciled by system
    'needs_investigation'   -- Requires further investigation
);
COMMENT ON TYPE public.reconciliation_status IS 'Status options for bank reconciliation';

-- Accounting Period Status
CREATE TYPE public.accounting_period_status AS ENUM (
    'future',           -- Future period
    'open',             -- Current active period
    'pending_close',    -- In process of closing
    'closed',           -- Period closed for posting
    'locked',           -- Period locked (no changes allowed)
    'adjusted',         -- Period has post-closing adjustments
    'reopened',         -- Previously closed period that was reopened
    'archived'          -- Historical period archived
);
COMMENT ON TYPE public.accounting_period_status IS 'Status options for accounting periods';

-- Account Category Type
CREATE TYPE public.account_category_type AS ENUM (
    -- Asset Categories
    'current_asset',           -- Cash, receivables, inventory
    'fixed_asset',            -- Property, plant, equipment
    'intangible_asset',       -- Patents, goodwill
    'investment',             -- Long-term investments
    
    -- Liability Categories
    'current_liability',      -- Payables, short-term debt
    'long_term_liability',    -- Long-term debt, bonds
    'deferred_liability',     -- Deferred tax, revenue
    
    -- Equity Categories
    'owner_equity',           -- Owner's capital
    'retained_earnings',      -- Accumulated earnings
    'reserves',               -- Legal, statutory reserves
    
    -- Income Categories
    'operating_revenue',      -- Primary business revenue
    'other_revenue',          -- Secondary revenue sources
    'financial_revenue',      -- Interest, investment income
    
    -- Expense Categories
    'operating_expense',      -- Direct business expenses
    'administrative_expense', -- Administrative costs
    'financial_expense',      -- Interest, bank charges
    'tax_expense'            -- Income tax, property tax
);
COMMENT ON TYPE public.account_category_type IS 'Detailed categorization of account types';

-- Transaction Type
CREATE TYPE public.transaction_type AS ENUM (
    -- Standard Transactions
    'sale',                     -- Sales transactions
    'purchase',                 -- Purchase transactions
    'payment_received',         -- Customer payments
    'payment_made',             -- Vendor payments
    'refund_issued',           -- Customer refunds
    'refund_received',         -- Vendor refunds
    
    -- Journal Entries
    'general_journal',          -- Standard journal entries
    'adjusting_entry',         -- Period-end adjustments
    'closing_entry',           -- Year-end closing entries
    'reversing_entry',         -- Automatic reversals
    
    -- Banking
    'bank_deposit',            -- Bank deposits
    'bank_withdrawal',         -- Bank withdrawals
    'bank_transfer',           -- Inter-account transfers
    'bank_fee',                -- Bank service charges
    
    -- Other
    'depreciation',            -- Asset depreciation
    'amortization',            -- Intangible amortization
    'accrual',                 -- Revenue/expense accruals
    'allocation',              -- Cost allocations
    'reclassification',        -- Account reclassifications
    'exchange_rate_adjustment' -- Currency adjustments
);
COMMENT ON TYPE public.transaction_type IS 'Types of accounting transactions';

-- Currency Status Type
CREATE TYPE public.currency_status_type AS ENUM (
    'active',                -- Currently in use
    'inactive',              -- No longer in use
    'pending_activation',    -- Planned for future use
    'restricted',            -- Limited use only
    'deprecated',            -- Being phased out
    'historical'             -- Kept for historical records
);
COMMENT ON TYPE public.currency_status_type IS 'Status options for currency records';

-- =====================================================================================
-- System-wide Enum Types
-- =====================================================================================
-- Description: Core enum types used across the system
-- Version: 1.0.0
-- Last Updated: 2024-12-20
-- =====================================================================================

-- Drop all existing enum types to ensure clean setup
DROP TYPE IF EXISTS public.user_status CASCADE;
DROP TYPE IF EXISTS public.verification_type CASCADE;
DROP TYPE IF EXISTS public.notification_type CASCADE;
DROP TYPE IF EXISTS public.privacy_level CASCADE;
DROP TYPE IF EXISTS public.onboarding_status CASCADE;
DROP TYPE IF EXISTS public.email_type CASCADE;
DROP TYPE IF EXISTS public.phone_type CASCADE;
DROP TYPE IF EXISTS public.address_type CASCADE;
DROP TYPE IF EXISTS public.role_type CASCADE;
DROP TYPE IF EXISTS public.permission_category CASCADE;
DROP TYPE IF EXISTS public.delegation_status CASCADE;
DROP TYPE IF EXISTS public.audit_action CASCADE;

-- 1. Core User Enums
-- =====================================================================================

-- User Status
CREATE TYPE public.user_status AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending',
    'archived'
);
COMMENT ON TYPE public.user_status IS 'Status options for user accounts';

-- Verification Type
CREATE TYPE public.verification_type AS ENUM (
    'email',
    'phone',
    'document',
    'two_factor',
    'biometric'
);
COMMENT ON TYPE public.verification_type IS 'Types of user verification methods';

-- Privacy Level
CREATE TYPE public.privacy_level AS ENUM (
    'public',
    'private',
    'restricted',
    'custom'
);
COMMENT ON TYPE public.privacy_level IS 'Privacy level settings for user content';

-- Onboarding Status
CREATE TYPE public.onboarding_status AS ENUM (
    'not_started',
    'in_progress',
    'completed',
    'skipped'
);
COMMENT ON TYPE public.onboarding_status IS 'Status of user onboarding process';

-- 2. Entity Contact Enums
-- =====================================================================================

-- Email Type
CREATE TYPE public.email_type AS ENUM (
    'personal',
    'work',
    'billing',
    'support',
    'other'
);
COMMENT ON TYPE public.email_type IS 'Categories of email addresses';

-- Phone Type
CREATE TYPE public.phone_type AS ENUM (
    'mobile',
    'work',
    'home',
    'fax',
    'other'
);
COMMENT ON TYPE public.phone_type IS 'Categories of phone numbers';

-- Address Type
CREATE TYPE public.address_type AS ENUM (
    'home',
    'work',
    'billing',
    'shipping',
    'other'
);
COMMENT ON TYPE public.address_type IS 'Categories of addresses';

-- 3. RBAC Enums
-- =====================================================================================

-- Role Type
CREATE TYPE public.role_type AS ENUM (
    'system',
    'custom',
    'temporary',
    'restricted'
);
COMMENT ON TYPE public.role_type IS 'Types of system roles';

-- Permission Category
CREATE TYPE public.permission_category AS ENUM (
    'system',
    'user',
    'content',
    'billing',
    'admin'
);
COMMENT ON TYPE public.permission_category IS 'Categories of system permissions';

-- Delegation Status
CREATE TYPE public.delegation_status AS ENUM (
    'active',
    'scheduled',
    'expired',
    'revoked'
);
COMMENT ON TYPE public.delegation_status IS 'Status of role delegations';

-- 4. System Audit Enums
-- =====================================================================================

-- Audit Action
CREATE TYPE public.audit_action AS ENUM (
    'create',
    'read',
    'update',
    'delete',
    'login',
    'logout',
    'export',
    'import'
);
COMMENT ON TYPE public.audit_action IS 'Types of auditable system actions';

-- 5. CRM Enums
-- =====================================================================================

-- Customer Type
CREATE TYPE public.customer_type AS ENUM (
    'prospect',
    'lead',
    'customer',
    'partner',
    'former_customer'
);
COMMENT ON TYPE public.customer_type IS 'Types of customer relationships';

-- Customer Status
CREATE TYPE public.customer_status AS ENUM (
    'active',
    'inactive',
    'pending',
    'suspended',
    'closed'
);
COMMENT ON TYPE public.customer_status IS 'Status of customer accounts';

-- Lead Status
CREATE TYPE public.lead_status AS ENUM (
    'new',
    'contacted',
    'qualified',
    'unqualified',
    'converted'
);
COMMENT ON TYPE public.lead_status IS 'Status of sales leads';

-- Lead Source
CREATE TYPE public.lead_source AS ENUM (
    'website',
    'referral',
    'campaign',
    'social_media',
    'trade_show',
    'other'
);
COMMENT ON TYPE public.lead_source IS 'Source of lead acquisition';

-- Opportunity Status
CREATE TYPE public.opportunity_status AS ENUM (
    'prospecting',
    'qualification',
    'proposal',
    'negotiation',
    'closed_won',
    'closed_lost'
);
COMMENT ON TYPE public.opportunity_status IS 'Status of sales opportunities';

-- Quote Status
CREATE TYPE public.quote_status AS ENUM (
    'draft',
    'review',
    'sent',
    'accepted',
    'rejected',
    'expired'
);
COMMENT ON TYPE public.quote_status IS 'Status of price quotes';

-- Job Status
CREATE TYPE public.job_status AS ENUM (
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
    'on_hold'
);
COMMENT ON TYPE public.job_status IS 'Status of service jobs';

-- Product Status
CREATE TYPE public.product_status AS ENUM (
    'active',
    'inactive',
    'discontinued',
    'out_of_stock'
);
COMMENT ON TYPE public.product_status IS 'Status of products';

-- Pipeline Status
CREATE TYPE public.pipeline_status AS ENUM (
    'active',
    'inactive',
    'archived'
);
COMMENT ON TYPE public.pipeline_status IS 'Status of sales pipelines';

-- Communication Type
CREATE TYPE public.communication_type AS ENUM (
    'email',
    'call',
    'meeting',
    'chat',
    'note'
);
COMMENT ON TYPE public.communication_type IS 'Types of communications';

-- Document Status
CREATE TYPE public.document_status AS ENUM (
    'draft',
    'review',
    'approved',
    'published',
    'archived'
);
COMMENT ON TYPE public.document_status IS 'Status of documents';

-- Relationship Status
CREATE TYPE public.relationship_status AS ENUM (
    'active',
    'inactive',
    'pending',
    'suspended'
);
COMMENT ON TYPE public.relationship_status IS 'Status of entity relationships';

-- 6. Task Management Enums
-- =====================================================================================

-- Task Status
CREATE TYPE public.task_status AS ENUM (
    'backlog',
    'todo',
    'in_progress',
    'review',
    'done',
    'archived'
);
COMMENT ON TYPE public.task_status IS 'Status of tasks';

-- Task Priority
CREATE TYPE public.task_priority AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);
COMMENT ON TYPE public.task_priority IS 'Priority levels for tasks';

-- Task Label Type
CREATE TYPE public.task_label_type AS ENUM (
    'category',
    'priority',
    'status',
    'custom'
);
COMMENT ON TYPE public.task_label_type IS 'Types of task labels';

-- 7. Inventory Enums
-- =====================================================================================

-- Location Type
CREATE TYPE public.location_type AS ENUM (
    'warehouse',
    'store',
    'transit',
    'supplier',
    'customer'
);
COMMENT ON TYPE public.location_type IS 'Types of inventory locations';

-- Transaction Type
CREATE TYPE public.transaction_type AS ENUM (
    'purchase',
    'sale',
    'transfer',
    'adjustment',
    'return'
);
COMMENT ON TYPE public.transaction_type IS 'Types of inventory transactions';

-- Purchase Order Status
CREATE TYPE public.purchase_order_status AS ENUM (
    'draft',
    'pending',
    'approved',
    'shipped',
    'received',
    'cancelled'
);
COMMENT ON TYPE public.purchase_order_status IS 'Status of purchase orders';

-- 8. Accounting Enums
-- =====================================================================================

-- Account Type
CREATE TYPE public.account_type AS ENUM (
    'asset',
    'liability',
    'equity',
    'revenue',
    'expense'
);
COMMENT ON TYPE public.account_type IS 'Types of accounting accounts';

-- Transaction Status
CREATE TYPE public.transaction_status AS ENUM (
    'pending',
    'completed',
    'failed',
    'reversed',
    'reconciled'
);
COMMENT ON TYPE public.transaction_status IS 'Status of financial transactions';

-- Payment Method
CREATE TYPE public.payment_method AS ENUM (
    'cash',
    'credit_card',
    'bank_transfer',
    'check',
    'digital_wallet'
);
COMMENT ON TYPE public.payment_method IS 'Types of payment methods';

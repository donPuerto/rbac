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

-- Create enum types
-- =====================================================================================

-- 1. User and System Enums
-- --------------------------------------------------------------------------------------

-- Gender options
CREATE TYPE public.gender_type AS ENUM (
    'male',
    'female',
    'other',
    'prefer_not_to_say'
);
COMMENT ON TYPE public.gender_type IS 'Gender options for user profiles';

-- Status options
CREATE TYPE public.status_type AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending'
);
COMMENT ON TYPE public.status_type IS 'General status options for various entities';

-- Role types
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

-- Phone types
CREATE TYPE public.phone_type AS ENUM (
    'mobile',
    'work',
    'home',
    'fax',
    'other'
);
COMMENT ON TYPE public.phone_type IS 'Types of phone numbers';

-- Address types
CREATE TYPE public.address_type AS ENUM (
    'home',
    'work',
    'billing',
    'shipping',
    'other'
);
COMMENT ON TYPE public.address_type IS 'Types of addresses';

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

-- 2. CRM Enums
-- --------------------------------------------------------------------------------------

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

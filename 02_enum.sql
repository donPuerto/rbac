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

-- 3. Task Management Enums
--    - task_type             (Task categories)
--    - task_status           (Task progression states)
--    - task_priority         (Task importance levels)

-- 4. Campaign Management Enums
--    - campaign_type         (Campaign categories)
--    - campaign_status       (Campaign states)

-- 5. Inventory and Purchase Enums
--    - inventory_transaction_type (Stock movement types)
--    - inventory_location_type   (Storage location types)
--    - purchase_order_status     (PO progression states)

-- 6. Accounting and Payment Enums
--    - payment_status        (Payment progression states)
--    - payment_method        (Payment methods)
--    - account_type          (Chart of accounts types)
--    - tax_type             (Tax classification)

-- Drop all existing enum types in reverse order of dependency
-- =====================================================================================
DO $$ BEGIN
    -- Drop custom types if they exist
    DROP TYPE IF EXISTS customer_segment_type CASCADE;
    DROP TYPE IF EXISTS campaign_status_type CASCADE;
    DROP TYPE IF EXISTS campaign_type CASCADE;
    DROP TYPE IF EXISTS task_status_type CASCADE;
    DROP TYPE IF EXISTS task_type CASCADE;
    DROP TYPE IF EXISTS address_type CASCADE;
    DROP TYPE IF EXISTS phone_type CASCADE;
    DROP TYPE IF EXISTS status_type CASCADE;
    DROP TYPE IF EXISTS gender_type CASCADE;
    DROP TYPE IF EXISTS role_type CASCADE;
    DROP TYPE IF EXISTS lead_status CASCADE;
    DROP TYPE IF EXISTS opportunity_status CASCADE;
    DROP TYPE IF EXISTS quote_status CASCADE;
    DROP TYPE IF EXISTS job_status CASCADE;
    DROP TYPE IF EXISTS job_priority CASCADE;
    DROP TYPE IF EXISTS crm_entity_type CASCADE;
    DROP TYPE IF EXISTS public.task_type CASCADE;
    DROP TYPE IF EXISTS public.task_priority CASCADE;
    DROP TYPE IF EXISTS public.task_status CASCADE;
    DROP TYPE IF EXISTS public.pipeline_stage CASCADE;
    DROP TYPE IF EXISTS public.communication_channel CASCADE;
    DROP TYPE IF EXISTS public.product_category CASCADE;
    DROP TYPE IF EXISTS public.inventory_transaction_type CASCADE;
    DROP TYPE IF EXISTS public.inventory_location_type CASCADE;
    DROP TYPE IF EXISTS public.purchase_order_status CASCADE;
    DROP TYPE IF EXISTS public.payment_status CASCADE;
    DROP TYPE IF EXISTS public.payment_method CASCADE;
    DROP TYPE IF EXISTS public.account_type CASCADE;
    DROP TYPE IF EXISTS public.tax_type CASCADE;
EXCEPTION
    WHEN OTHERS THEN NULL;
END $$;

-- Role Types
-- =====================================================================================
-- Description: Defines the hierarchical role types in the system
-- Hierarchy (highest to lowest):
--   1. super_admin        - Complete system control
--   2. system_admin       - System-wide administration
--   3. sales_director     - Oversees all sales operations
--   3. marketing_director - Oversees all marketing operations
--   4. sales_manager      - Manages sales team
--   4. marketing_manager  - Manages marketing team
--   5. senior_sales       - Senior sales representative
--   5. senior_marketing   - Senior marketing specialist
--   6. sales_rep         - Sales representative
--   6. marketing_specialist - Marketing team member
--   7. account_manager    - Client account management
--   8. support_specialist - Customer support
--   9. standard_user      - Regular user access
--   10. guest_user        - Limited access
CREATE TYPE role_type AS ENUM (
    'super_admin',         -- Complete system control
    'system_admin',        -- System-wide administration
    'sales_director',      -- Oversees all sales operations
    'marketing_director',  -- Oversees all marketing operations
    'sales_manager',       -- Manages sales team
    'marketing_manager',   -- Manages marketing team
    'senior_sales',        -- Senior sales representative
    'senior_marketing',    -- Senior marketing specialist
    'sales_rep',          -- Sales representative
    'marketing_specialist',-- Marketing team member
    'account_manager',     -- Client account management
    'support_specialist',  -- Customer support
    'standard_user',       -- Regular user access
    'guest_user'          -- Limited access
);
COMMENT ON TYPE role_type IS 'Hierarchical role types for CRM RBAC system';

-- Gender Types
CREATE TYPE gender_type AS ENUM (
    'male',
    'female',
    'other',
    'prefer_not_to_say'
);
COMMENT ON TYPE gender_type IS 'Gender options for user profiles';

-- Status Types
CREATE TYPE status_type AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending'
);
COMMENT ON TYPE status_type IS 'General status options for various entities';

-- Phone Types
CREATE TYPE phone_type AS ENUM (
    'mobile',
    'work',
    'home',
    'fax',
    'other'
);
COMMENT ON TYPE phone_type IS 'Types of phone numbers';

-- Address Types
CREATE TYPE address_type AS ENUM (
    'home',
    'work',
    'billing',
    'shipping',
    'other'
);
COMMENT ON TYPE address_type IS 'Types of addresses';

-- CRM Entity Type Enum
CREATE TYPE public.crm_entity_type AS ENUM (
    'lead',
    'contact',
    'opportunity',
    'quote',
    'job'
);
COMMENT ON TYPE public.crm_entity_type IS 'CRM entity types';

-- Task Type Enum
CREATE TYPE public.task_type AS ENUM (
    'call',
    'meeting',
    'email',
    'follow_up',
    'site_visit',
    'proposal',
    'quote',
    'invoice',
    'payment',
    'service',
    'support',
    'other'
);
COMMENT ON TYPE public.task_type IS 'Task types for CRM';

-- Task Priority Enum
CREATE TYPE public.task_priority AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);
COMMENT ON TYPE public.task_priority IS 'Task priority options for CRM';

-- Task Status Enum
CREATE TYPE public.task_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'cancelled',
    'on_hold',
    'deferred'
);
COMMENT ON TYPE public.task_status IS 'Task status options for CRM';

-- Pipeline Stage Enum
CREATE TYPE public.pipeline_stage AS ENUM (
    'lead_in',
    'qualifying',
    'meeting_scheduled',
    'proposal_sent',
    'negotiating',
    'closed_won',
    'closed_lost'
);
COMMENT ON TYPE public.pipeline_stage IS 'Sales pipeline stages';

-- Communication Channel Enum
CREATE TYPE public.communication_channel AS ENUM (
    'email',
    'phone',
    'sms',
    'chat',
    'meeting',
    'social_media',
    'mail',
    'other'
);
COMMENT ON TYPE public.communication_channel IS 'Communication channels for CRM';

-- Product Category Enum
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
COMMENT ON TYPE public.product_category IS 'Product categories';

-- Customer Segment Types
CREATE TYPE public.customer_segment_type AS ENUM (
    'enterprise',
    'mid_market',
    'small_business',
    'startup',
    'individual'
);
COMMENT ON TYPE public.customer_segment_type IS 'Customer segmentation categories';

-- Campaign Types
CREATE TYPE campaign_type AS ENUM (
    'email_campaign',
    'sms_campaign',
    'social_media',
    'webinar',
    'event',
    'newsletter',
    'drip_campaign',
    'lead_nurturing',
    'customer_onboarding',
    'retention_campaign'
);
COMMENT ON TYPE campaign_type IS 'Types of marketing campaigns';

-- Campaign Status Types
CREATE TYPE campaign_status_type AS ENUM (
    'draft',
    'scheduled',
    'active',
    'paused',
    'completed',
    'cancelled'
);
COMMENT ON TYPE campaign_status_type IS 'Status options for marketing campaigns';

-- CRM Status Enums
CREATE TYPE public.lead_status AS ENUM (
    'new',
    'contacted',
    'qualified',
    'unqualified',
    'converted'
);
COMMENT ON TYPE public.lead_status IS 'Lead status options for CRM';

CREATE TYPE public.opportunity_status AS ENUM (
    'new',
    'discovery',
    'proposal',
    'negotiation',
    'closed_won',
    'closed_lost'
);
COMMENT ON TYPE public.opportunity_status IS 'Opportunity status options for CRM';

CREATE TYPE public.quote_status AS ENUM (
    'draft',
    'sent',
    'accepted',
    'rejected',
    'expired'
);
COMMENT ON TYPE public.quote_status IS 'Quote status options for CRM';

CREATE TYPE public.job_status AS ENUM (
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
    'on_hold'
);
COMMENT ON TYPE public.job_status IS 'Job status options for CRM';

CREATE TYPE public.job_priority AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);
COMMENT ON TYPE public.job_priority IS 'Job priority options for CRM';

-- Inventory Related Enums
CREATE TYPE public.inventory_transaction_type AS ENUM (
    'purchase',
    'sale',
    'return',
    'adjustment',
    'transfer',
    'write_off',
    'count'
);
COMMENT ON TYPE public.inventory_transaction_type IS 'Inventory transaction types';

CREATE TYPE public.inventory_location_type AS ENUM (
    'warehouse',
    'store',
    'transit',
    'supplier',
    'customer',
    'virtual'
);
COMMENT ON TYPE public.inventory_location_type IS 'Inventory location types';

CREATE TYPE public.purchase_order_status AS ENUM (
    'draft',
    'pending',
    'approved',
    'ordered',
    'partial_received',
    'received',
    'cancelled'
);
COMMENT ON TYPE public.purchase_order_status IS 'Purchase order status options';

CREATE TYPE public.payment_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded',
    'cancelled'
);
COMMENT ON TYPE public.payment_status IS 'Payment transaction status options';

CREATE TYPE public.payment_method AS ENUM (
    'cash',
    'credit_card',
    'debit_card',
    'bank_transfer',
    'check',
    'wire_transfer',
    'digital_wallet'
);
COMMENT ON TYPE public.payment_method IS 'Payment method options';

CREATE TYPE public.account_type AS ENUM (
    'asset',
    'liability',
    'equity',
    'revenue',
    'expense'
);
COMMENT ON TYPE public.account_type IS 'Chart of accounts types';

CREATE TYPE public.tax_type AS ENUM (
    'vat',
    'sales_tax',
    'service_tax',
    'withholding_tax',
    'exempt'
);
COMMENT ON TYPE public.tax_type IS 'Tax classification types';

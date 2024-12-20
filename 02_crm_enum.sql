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

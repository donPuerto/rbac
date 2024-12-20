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

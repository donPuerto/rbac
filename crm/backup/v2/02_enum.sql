-- =====================================================================================
-- Enum Type Definitions
-- =====================================================================================
-- Description: Defines all the enum types used across the RBAC system
-- Version: 1.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Table of Contents
-- =====================================================================================
-- 1. Core User Enums
--    - gender_type               (Gender options)
--    - status_type              (General status)
--    - role_type                (User role types)
--    - verification_type        (Verification methods)
--    - privacy_level            (Privacy settings)
--    - onboarding_status       (Onboarding progress)
--    - entity_type             (Entity classification)
--    - security_level          (Security classification)

-- 2. User Interface and Preferences
--    - theme_type               (UI theme options)
--    - display_density_type     (UI display density)
--    - date_format_type         (Date format preferences)
--    - time_format_type         (Time format preferences)
--    - communication_language_type (Language preferences)
--    - notification_frequency    (Notification timing preferences)

-- 3. Entity Contact Enums
--    - email_type               (Email address types)
--    - phone_type               (Phone number types)
--    - address_type             (Address types)
--    - subscription_status      (Email subscription states)

-- 4. RBAC (Role-Based Access Control)
--    - role_status_type         (Role states)
--    - permission_category_type (Permission grouping)
--    - permission_status_type   (Permission states)
--    - delegation_status_type   (Delegation states)

-- 5. Security Enums
--    - two_factor_method_type   (2FA methods)
--    - mfa_type                 (Multi-factor auth)
--    - security_question_type   (Security questions)

-- 6. System Audit Enums
--    - audit_action_type        (Audit actions)
--    - audit_category_type      (Audit categories)
--    - audit_status_type        (Audit status)
--    - data_sensitivity_type    (Data sensitivity)
--    - compliance_status_type   (Compliance status)

-- 7. CRM Enums
--    - customer_type            (Customer categories)
--    - customer_segment_type    (Business segments)
--    - customer_status          (Customer states)
--    - lead_status             (Lead progression)
--    - lead_source             (Lead origins)
--    - opportunity_status      (Opportunity stages)
--    - quote_status            (Quote progression)
--    - communication_channel   (Contact methods)
--    - communication_direction (Message direction)
--    - communication_status    (Message states)

-- 8. Task Management Enums
--    - task_type               (Task categories)
--    - task_status            (Task states)
--    - task_priority          (Task importance)
--    - task_assignment_role   (Assignment types)
--    - task_dependency_type   (Dependencies)
--    - board_type            (Board categories)
--    - list_type             (List categories)
--    - task_label_type        (Task labels)
--    - task_template_type     (Task templates)
--    - time_tracking_type      (Time tracking)
--    - label_color_type        (Label colors)
--    - label_group_type        (Label groups)

-- 9. Document Management
--    - document_type          (Document categories)
--    - document_status       (Document states)
--    - access_level         (Access permissions)
--    - workflow_status      (Workflow states)
--    - approval_status      (Approval states)

-- 10. Inventory Management
--    - inventory_location_type    (Storage locations)
--    - inventory_transaction_type (Stock movements)
--    - stock_adjustment_type     (Adjustment reasons)
--    - quality_status_type       (QC states)
--    - storage_condition_type    (Storage requirements)
--    - unit_of_measure_type     (Measurement units)
--    - product_status           (Product states)
--    - product_type            (Product categories)

-- 11. Financial Management
--    - transaction_type         (Transaction types)
--    - payment_status          (Payment states)
--    - payment_method          (Payment methods)
--    - account_type            (Account categories)
--    - currency_type           (Currency options)
--    - tax_type               (Tax categories)
--    - journal_entry_type     (Journal entries)

-- 12. Accounting and Finance
--    - account_type              (Account categories)
--    - transaction_type          (Transaction types)
--    - payment_status           (Payment states)
--    - payment_method           (Payment methods)
--    - currency_type            (Currency options)
--    - tax_type                (Tax categories)
--    - journal_entry_type      (Journal entries)

-- Create enum types
-- =====================================================================================

-- 1. Core User Enums
-- --------------------------------------------------------------------------------------

-- Gender Type
CREATE TYPE public.gender_type AS ENUM (
    'male',                 -- Male gender
    'female',              -- Female gender
    'non_binary',          -- Non-binary gender
    'other',               -- Other gender identity
    'prefer_not_to_say'    -- Prefers not to disclose
);
COMMENT ON TYPE public.gender_type IS 'Gender options for user profiles';

-- Status Type
CREATE TYPE public.status_type AS ENUM (
    'active',           -- Currently active
    'inactive',         -- Temporarily inactive
    'pending',          -- Awaiting activation
    'suspended',        -- Account suspended
    'closed'           -- Account closed
);
COMMENT ON TYPE public.status_type IS 'Status options for user accounts';

CREATE TYPE public.role_type AS ENUM (
    -- 1. System Administration Roles
    -- Highest level system access and control
    'super_admin',              -- Complete system access and control
    'system_admin',             -- System-wide administration
    'security_admin',           -- Security and compliance management
    'audit_admin',              -- Audit and monitoring management
    
    -- 2. Technical Leadership Roles
    -- Technical direction and architecture
    'it_director',              -- IT/Technology leadership
    'system_architect',         -- System architecture and design
    'tech_lead',               -- Technical team leadership
    
    -- 3. Development and Engineering Roles
    -- Software development and maintenance
    'senior_developer',         -- Senior development
    'developer',               -- General development
    'database_admin',          -- Database management
    'devops_engineer',         -- DevOps and infrastructure
    'qa_engineer',             -- Quality assurance
    'security_engineer',       -- Security implementation
    'ui_ux_designer',          -- UI/UX design
    
    -- 4. Management Roles
    -- Team and department leadership
    'department_head',         -- Department management
    'team_lead',              -- Team leadership
    'project_manager',         -- Project management
    'manager',                -- General management
    
    -- 5. CRM and Sales Roles
    -- Customer relationship and sales
    'crm_admin',              -- CRM system administration
    'sales_manager',          -- Sales team management
    'sales_rep',              -- Sales operations
    'account_manager',        -- Account management
    
    -- 6. Customer Support Roles
    -- Customer service and support
    'customer_support_manager', -- Support team management
    'customer_support_agent',  -- Customer support
    
    -- 7. Marketing Roles
    -- Marketing and communications
    'marketing_manager',       -- Marketing team management
    'marketing_specialist',    -- Marketing operations
    
    -- 8. Finance and Accounting Roles
    -- Financial management and accounting
    'finance_admin',          -- Finance system administration
    'finance_manager',        -- Finance department management
    'senior_accountant',      -- Senior accounting
    'accountant',             -- General accounting
    'accounts_payable',       -- AP operations
    'accounts_receivable',    -- AR operations
    'financial_analyst',      -- Financial analysis
    'tax_specialist',         -- Tax management
    
    -- 9. Human Resources Roles
    -- HR and personnel management
    'hr_admin',              -- HR system administration
    'hr_manager',            -- HR department management
    'hr_specialist',         -- HR operations
    
    -- 10. Basic Access Roles
    -- Standard and restricted access
    'standard_user',         -- Regular user access
    'guest',                -- Limited access
    
    -- 11. Special Purpose Roles
    -- Utility and temporary roles
    'custom',               -- Custom defined roles
    'temporary'             -- Time-limited access
);

-- Add comment to the enum type
COMMENT ON TYPE public.role_type IS 'Comprehensive role hierarchy for system access control';

-- Verification Type
CREATE TYPE public.verification_type AS ENUM (
    'email',           -- Email verification
    'phone',           -- Phone verification
    'document',        -- Document verification
    'two_factor',      -- Two-factor authentication
    'biometric'        -- Biometric verification
);
COMMENT ON TYPE public.verification_type IS 'Types of user verification methods';

-- Privacy Level
CREATE TYPE public.privacy_level AS ENUM (
    'public',          -- Publicly accessible
    'private',         -- Private access only
    'restricted',      -- Restricted access
    'custom'           -- Custom privacy settings
);
COMMENT ON TYPE public.privacy_level IS 'Privacy level settings for user content';

-- Onboarding Status
CREATE TYPE public.onboarding_status AS ENUM (
    'not_started',     -- Onboarding not initiated
    'in_progress',     -- Onboarding in progress
    'completed',       -- Onboarding completed
    'skipped'          -- Onboarding skipped
);
COMMENT ON TYPE public.onboarding_status IS 'Status of user onboarding process';

-- Entity Type
CREATE TYPE public.entity_type AS ENUM (
    'user_profile',        -- User profile entity
    'crm_lead',           -- Sales lead entity
    'crm_contact',        -- Contact/customer entity
    'crm_opportunity',    -- Sales opportunity entity
    'crm_referral',       -- Referral entity
    'system'              -- System/automated entity
);
COMMENT ON TYPE public.entity_type IS 'Types of entities in the CRM system';

-- Security Level
CREATE TYPE public.security_level AS ENUM (
    'low',             -- Low security level
    'medium',          -- Medium security level
    'high',            -- High security level
    'critical'         -- Critical security level
);
COMMENT ON TYPE public.security_level IS 'Security classification levels';

-- 2. User Interface and Preferences
-- --------------------------------------------------------------------------------------

-- Theme Type
CREATE TYPE public.theme_type AS ENUM (
    'light',              -- Light theme
    'dark',               -- Dark theme
    'system',             -- Follow system theme
    'high_contrast'       -- High contrast theme
);
COMMENT ON TYPE public.theme_type IS 'UI theme options';

-- Display Density Type
CREATE TYPE public.display_density_type AS ENUM (
    'comfortable',         -- Spacious layout
    'cozy',               -- Balanced layout
    'compact'             -- Condensed layout
);
COMMENT ON TYPE public.display_density_type IS 'UI display density options';

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

-- Notification Frequency
CREATE TYPE public.notification_frequency AS ENUM (
    'immediate',          -- Immediate notification
    'daily',              -- Daily summary
    'weekly',             -- Weekly summary
    'monthly',            -- Monthly summary
    'quarterly',          -- Quarterly summary
    'annually'            -- Annual summary
);
COMMENT ON TYPE public.notification_frequency IS 'Notification timing preferences';

-- 3. Entity Contact Enums
-- --------------------------------------------------------------------------------------

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

-- Subscription Status
CREATE TYPE public.subscription_status AS ENUM (
    'active',           -- Currently active
    'inactive',         -- Temporarily inactive
    'pending',          -- Awaiting activation
    'suspended',        -- Account suspended
    'closed'           -- Account closed
);
COMMENT ON TYPE public.subscription_status IS 'Status of email subscriptions';

-- 4. RBAC (Role-Based Access Control)
-- --------------------------------------------------------------------------------------

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

-- Permission Status Type
CREATE TYPE public.permission_status_type AS ENUM (
    'active',           -- Currently active
    'inactive',         -- Temporarily disabled
    'pending',          -- Awaiting activation
    'suspended',        -- Suspended for review
    'expired',          -- Past valid period
    'archived',         -- Archived/historical
    'revoked'           -- Permanently disabled
);
COMMENT ON TYPE public.permission_status_type IS 'Status options for permissions';

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

-- 5. Security Enums
-- --------------------------------------------------------------------------------------

-- Two Factor Method Type
CREATE TYPE public.two_factor_method_type AS ENUM (
    'app',                -- Authenticator app
    'sms',                -- SMS verification
    'email',              -- Email verification
    'security_key',       -- Physical security key
    'backup_codes'        -- Backup codes
);
COMMENT ON TYPE public.two_factor_method_type IS 'Two-factor authentication methods';

-- MFA Type
CREATE TYPE public.mfa_type AS ENUM (
    'sms',                -- SMS verification
    'email',              -- Email verification
    'authenticator',      -- Authenticator app
    'security_key',       -- Physical security key
    'biometric'           -- Biometric authentication
);
COMMENT ON TYPE public.mfa_type IS 'Multi-factor authentication types';

-- Security Question Type
CREATE TYPE public.security_question_type AS ENUM (
    'mother_maiden_name',  -- Mother's maiden name
    'first_pet',          -- First pet's name
    'childhood_friend',   -- Childhood friend's name
    'favorite_food',      -- Favorite food
    'dream_vacation'      -- Dream vacation spot
);
COMMENT ON TYPE public.security_question_type IS 'Security question options';

-- 6. System Audit Enums
-- --------------------------------------------------------------------------------------

-- Audit Action Type
CREATE TYPE public.audit_action_type AS ENUM (
    -- Data Operations
    'create',               -- Record creation
    'read',                -- Record access
    'update',              -- Record modification
    'delete',              -- Record deletion
    'record_restore',       -- Record restoration
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
    'system_restore',      -- System restoration
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

-- 7. CRM Enums
-- --------------------------------------------------------------------------------------

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

-- Customer Status
CREATE TYPE public.customer_status AS ENUM (
    'active',           -- Currently active
    'inactive',         -- Temporarily inactive
    'pending',          -- Pending activation
    'suspended',        -- Account suspended
    'closed'           -- Account closed
);
COMMENT ON TYPE public.customer_status IS 'Status of customer accounts';

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

-- Communication Channel
CREATE TYPE public.communication_channel AS ENUM (
    'email',           -- Email communication
    'call',            -- Phone call
    'meeting',         -- Meeting
    'chat',            -- Chat message
    'note',            -- Internal note
    'sms',             -- SMS message
    'social'           -- Social media
);
COMMENT ON TYPE public.communication_channel IS 'Types of communications';

-- Communication Direction
CREATE TYPE public.communication_direction AS ENUM (
    'inbound',         -- Incoming communication
    'outbound',        -- Outgoing communication
    'internal'         -- Internal communication
);
COMMENT ON TYPE public.communication_direction IS 'Direction of communications';

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

-- 8. Task Management Enums
-- --------------------------------------------------------------------------------------

-- Task Type
CREATE TYPE public.task_type AS ENUM (
    'story',        -- User story
    'bug',          -- Bug fix
    'feature',      -- Feature development
    'improvement',  -- Improvement task
    'maintenance',  -- Maintenance task
    'research',     -- Research task
    'documentation',-- Documentation task
    'review',       -- Review task
    'meeting',      -- Meeting task
    'other'         -- Other task type
);
COMMENT ON TYPE public.task_type IS 'Types of tasks';

-- Task Priority
CREATE TYPE public.task_priority AS ENUM (
    'critical',     -- Critical priority
    'high',         -- High priority
    'medium',       -- Medium priority
    'low',          -- Low priority
    'none'          -- No priority
);
COMMENT ON TYPE public.task_priority IS 'Priority levels for tasks';

-- Task Status
CREATE TYPE public.task_status AS ENUM (
    'backlog',      -- In backlog
    'planned',      -- Planned
    'in_progress',  -- In progress
    'blocked',      -- Blocked
    'review',       -- In review
    'testing',      -- In testing
    'completed',    -- Completed
    'cancelled'     -- Cancelled
);
COMMENT ON TYPE public.task_status IS 'Status options for tasks';

-- Task Assignment Role
CREATE TYPE public.task_assignment_role AS ENUM (
    'owner',        -- Task owner
    'assignee',     -- Task assignee
    'reviewer',     -- Task reviewer
    'observer',     -- Task observer
    'contributor'   -- Task contributor
);
COMMENT ON TYPE public.task_assignment_role IS 'Roles for task assignments';

-- Board Type
CREATE TYPE public.board_type AS ENUM (
    'kanban',       -- Kanban board
    'scrum',        -- Scrum board
    'project',      -- Project board
    'workflow',     -- Workflow board
    'timeline',     -- Timeline board
    'custom'        -- Custom board type
);
COMMENT ON TYPE public.board_type IS 'Types of task boards';

-- List Type
CREATE TYPE public.list_type AS ENUM (
    'backlog',      -- Backlog list
    'todo',         -- To-do list
    'in_progress',  -- In progress list
    'review',       -- Review list
    'done',         -- Done list
    'archive',      -- Archive list
    'custom'        -- Custom list type
);
COMMENT ON TYPE public.list_type IS 'Types of task lists';

-- Task Dependency Type
CREATE TYPE public.task_dependency_type AS ENUM (
    'finish_to_start',      -- Task must finish before dependent can start
    'start_to_start',       -- Task must start before dependent can start
    'finish_to_finish',     -- Task must finish before dependent can finish
    'start_to_finish',      -- Task must start before dependent can finish
    'blocks',               -- Task blocks the dependent
    'is_blocked_by'         -- Task is blocked by the dependent
);
COMMENT ON TYPE public.task_dependency_type IS 'Types of task dependencies';

-- 9. Document Management
-- --------------------------------------------------------------------------------------

-- Document Type
CREATE TYPE public.document_type AS ENUM (
    'contract',        -- Legal contract
    'proposal',        -- Business proposal
    'invoice',         -- Invoice
    'report',          -- Report
    'presentation',    -- Presentation
    'specification',   -- Specification
    'policy',         -- Policy document
    'procedure',      -- Procedure document
    'template',       -- Document template
    'form',           -- Form document
    'other'           -- Other document
);
COMMENT ON TYPE public.document_type IS 'Types of documents in the system';

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

-- 10. Inventory Management
-- --------------------------------------------------------------------------------------

-- Inventory Location Type
CREATE TYPE public.inventory_location_type AS ENUM (
    'warehouse',    -- Main warehouse
    'store',        -- Retail store
    'transit',      -- In transit
    'supplier',     -- At supplier
    'customer',     -- At customer
    'repair',       -- Repair center
    'disposal'      -- Disposal location
);
COMMENT ON TYPE public.inventory_location_type IS 'Types of inventory locations';

-- Inventory Transaction Type
CREATE TYPE public.inventory_transaction_type AS ENUM (
    'purchase',     -- Purchase receipt
    'sale',         -- Sales issue
    'transfer',     -- Location transfer
    'return',       -- Customer return
    'adjustment',   -- Stock adjustment
    'scrap',        -- Scrap disposal
    'production'    -- Production consumption/output
);
COMMENT ON TYPE public.inventory_transaction_type IS 'Types of inventory transactions';

-- Stock Adjustment Type
CREATE TYPE public.stock_adjustment_type AS ENUM (
    'count',        -- Stock count adjustment
    'damage',       -- Damage write-off
    'expiry',       -- Expiry write-off
    'theft',        -- Theft write-off
    'quality',      -- Quality issue
    'correction'    -- Data correction
);
COMMENT ON TYPE public.stock_adjustment_type IS 'Reasons for stock adjustments';

-- Quality Status Type
CREATE TYPE public.quality_status_type AS ENUM (
    'pending',      -- Pending inspection
    'passed',       -- Passed QC
    'failed',       -- Failed QC
    'quarantine',   -- In quarantine
    'rework',       -- Needs rework
    'scrapped'      -- Scrapped
);
COMMENT ON TYPE public.quality_status_type IS 'Quality control status options';

-- Inventory Valuation Method
CREATE TYPE public.inventory_valuation_method AS ENUM (
    'fifo',         -- First In First Out
    'lifo',         -- Last In First Out
    'avg_cost',     -- Average Cost
    'specific',     -- Specific Identification
    'standard'      -- Standard Cost
);
COMMENT ON TYPE public.inventory_valuation_method IS 'Methods for valuing inventory items';

-- Storage Condition Type
CREATE TYPE public.storage_condition_type AS ENUM (
    'room_temp',     -- Room Temperature
    'refrigerated',  -- Refrigerated Storage
    'frozen',        -- Frozen Storage
    'heated',        -- Heated Storage
    'humidity_ctrl', -- Humidity Controlled
    'cold_chain',    -- Cold Chain
    'hazmat',        -- Hazardous Materials
    'secure'         -- Secure Storage
);
COMMENT ON TYPE public.storage_condition_type IS 'Required storage conditions for inventory locations';

-- Unit of Measure Type
CREATE TYPE public.unit_of_measure_type AS ENUM (
    -- Length
    'meter',
    'centimeter',
    'inch',
    'foot',
    -- Weight
    'kilogram',
    'gram',
    'pound',
    'ounce',
    -- Volume
    'liter',
    'milliliter',
    'gallon',
    'fluid_ounce',
    -- Quantity
    'piece',
    'dozen',
    'box',
    'pallet',
    -- Area
    'square_meter',
    'square_foot',
    -- Time
    'hour',
    'day',
    'month'
);
COMMENT ON TYPE public.unit_of_measure_type IS 'Units of measure for inventory items';

-- 11. Purchase and Order Management
-- --------------------------------------------------------------------------------------

-- Purchase Order Status
CREATE TYPE public.purchase_order_status AS ENUM (
    'draft',          -- Initial draft
    'pending',        -- Pending approval
    'approved',       -- Approved for order
    'ordered',        -- Order placed
    'partial',        -- Partially received
    'complete',       -- Fully received
    'cancelled'       -- Order cancelled
);
COMMENT ON TYPE public.purchase_order_status IS 'Status of purchase orders';

-- Product Status
CREATE TYPE public.product_status AS ENUM (
    'active',       -- Active product
    'inactive',     -- Inactive product
    'discontinued', -- Discontinued
    'pending',      -- Pending approval
    'draft',        -- Draft product
    'archived'      -- Archived product
);
COMMENT ON TYPE public.product_status IS 'Status of products';

-- Product Type
CREATE TYPE public.product_type AS ENUM (
    'physical',     -- Physical product
    'digital',      -- Digital product
    'service',      -- Service product
    'subscription', -- Subscription product
    'bundle',       -- Product bundle
    'variant'       -- Product variant
);
COMMENT ON TYPE public.product_type IS 'Types of products';

-- Transaction Type
CREATE TYPE public.transaction_type AS ENUM (
    'sale',         -- Sales transaction
    'purchase',     -- Purchase transaction
    'refund',       -- Refund transaction
    'credit',       -- Credit note
    'debit',        -- Debit note
    'transfer',     -- Fund transfer
    'adjustment'    -- Adjustment entry
);
COMMENT ON TYPE public.transaction_type IS 'Types of financial transactions';

-- Payment Status
CREATE TYPE public.payment_status AS ENUM (
    'pending',      -- Pending payment
    'processing',   -- Processing payment
    'completed',    -- Payment completed
    'failed',       -- Payment failed
    'refunded',     -- Payment refunded
    'cancelled',    -- Payment cancelled
    'disputed'      -- Payment disputed
);
COMMENT ON TYPE public.payment_status IS 'Status of payments';

-- Payment Method
CREATE TYPE public.payment_method AS ENUM (
    'cash',         -- Cash payment
    'card',         -- Card payment
    'bank_transfer',-- Bank transfer
    'check',        -- Check payment
    'digital_wallet',-- Digital wallet
    'credit',       -- Credit payment
    'other'         -- Other methods
);
COMMENT ON TYPE public.payment_method IS 'Methods of payment';

-- 12. Accounting and Finance
-- --------------------------------------------------------------------------------------

-- Account Type
CREATE TYPE public.account_type AS ENUM (
    'asset',            -- Asset accounts
    'liability',        -- Liability accounts
    'equity',          -- Equity accounts
    'revenue',         -- Revenue accounts
    'expense',         -- Expense accounts
    'contra_asset',    -- Contra asset accounts
    'contra_liability',-- Contra liability accounts
    'contra_equity',   -- Contra equity accounts
    'contra_revenue',  -- Contra revenue accounts
    'contra_expense'   -- Contra expense accounts
);
COMMENT ON TYPE public.account_type IS 'Types of accounts in the chart of accounts';

-- Currency Type
CREATE TYPE public.currency_type AS ENUM (
    'USD',            -- US Dollar
    'EUR',            -- Euro
    'GBP',            -- British Pound
    'JPY',            -- Japanese Yen
    'CNY',            -- Chinese Yuan
    'AUD',            -- Australian Dollar
    'CAD'            -- Canadian Dollar
);
COMMENT ON TYPE public.currency_type IS 'Supported currency types';

-- Tax Type
CREATE TYPE public.tax_type AS ENUM (
    'sales',          -- Sales tax
    'vat',            -- Value added tax
    'service',        -- Service tax
    'import',         -- Import duty
    'withholding',    -- Withholding tax
    'exempt'          -- Tax exempt
);
COMMENT ON TYPE public.tax_type IS 'Types of taxes';

-- Journal Entry Type
CREATE TYPE public.journal_entry_type AS ENUM (
    'general',       -- General journal entries
    'adjusting',     -- Adjusting entries
    'closing',       -- Closing entries
    'reversing',     -- Reversing entries
    'recurring',     -- Recurring entries
    'correcting',    -- Correcting entries
    'opening',       -- Opening balance entries
    'transfer'       -- Transfer entries
);
COMMENT ON TYPE public.journal_entry_type IS 'Types of journal entries';

-- Communication Channel Type
CREATE TYPE public.communication_channel_type AS ENUM (
    'email',        -- Email communication
    'phone',        -- Phone calls
    'sms',          -- Text messages
    'chat',         -- Chat/messaging
    'video',        -- Video calls
    'in_person',    -- In-person meetings
    'mail',         -- Physical mail
    'social'        -- Social media
);
COMMENT ON TYPE public.communication_channel_type IS 'Types of communication channels';

-- Grant permissions for CRM-related enums
GRANT USAGE ON TYPE public.lead_status TO authenticated;
GRANT USAGE ON TYPE public.lead_source TO authenticated;
GRANT USAGE ON TYPE public.opportunity_status TO authenticated;
GRANT USAGE ON TYPE public.quote_status TO authenticated;
GRANT USAGE ON TYPE public.communication_direction TO authenticated;
GRANT USAGE ON TYPE public.communication_status TO authenticated;
GRANT USAGE ON TYPE public.document_type TO authenticated;
GRANT USAGE ON TYPE public.document_status TO authenticated;

-- Grant permissions
GRANT USAGE ON TYPE public.gender_type TO authenticated;
GRANT USAGE ON TYPE public.status_type TO authenticated;
GRANT USAGE ON TYPE public.role_type TO authenticated;
GRANT USAGE ON TYPE public.verification_type TO authenticated;
GRANT USAGE ON TYPE public.privacy_level TO authenticated;
GRANT USAGE ON TYPE public.onboarding_status TO authenticated;
GRANT USAGE ON TYPE public.theme_type TO authenticated;
GRANT USAGE ON TYPE public.display_density_type TO authenticated;
GRANT USAGE ON TYPE public.date_format_type TO authenticated;
GRANT USAGE ON TYPE public.time_format_type TO authenticated;
GRANT USAGE ON TYPE public.communication_language_type TO authenticated;
GRANT USAGE ON TYPE public.email_type TO authenticated;
GRANT USAGE ON TYPE public.phone_type TO authenticated;
GRANT USAGE ON TYPE public.address_type TO authenticated;
GRANT USAGE ON TYPE public.role_status_type TO authenticated;
GRANT USAGE ON TYPE public.permission_category_type TO authenticated;
GRANT USAGE ON TYPE public.permission_status_type TO authenticated;
GRANT USAGE ON TYPE public.delegation_status_type TO authenticated;
GRANT USAGE ON TYPE public.two_factor_method_type TO authenticated;
GRANT USAGE ON TYPE public.mfa_type TO authenticated;
GRANT USAGE ON TYPE public.security_question_type TO authenticated;
GRANT USAGE ON TYPE public.audit_action_type TO authenticated;
GRANT USAGE ON TYPE public.audit_category_type TO authenticated;
GRANT USAGE ON TYPE public.audit_status_type TO authenticated;
GRANT USAGE ON TYPE public.data_sensitivity_type TO authenticated;
GRANT USAGE ON TYPE public.compliance_status_type TO authenticated;
GRANT USAGE ON TYPE public.customer_type TO authenticated;
GRANT USAGE ON TYPE public.customer_segment_type TO authenticated;
GRANT USAGE ON TYPE public.customer_status TO authenticated;
GRANT USAGE ON TYPE public.lead_status TO authenticated;
GRANT USAGE ON TYPE public.lead_source TO authenticated;
GRANT USAGE ON TYPE public.opportunity_status TO authenticated;
GRANT USAGE ON TYPE public.quote_status TO authenticated;
GRANT USAGE ON TYPE public.communication_channel TO authenticated;
GRANT USAGE ON TYPE public.communication_direction TO authenticated;
GRANT USAGE ON TYPE public.communication_status TO authenticated;
GRANT USAGE ON TYPE public.task_type TO authenticated;
GRANT USAGE ON TYPE public.task_status TO authenticated;
GRANT USAGE ON TYPE public.task_priority TO authenticated;
GRANT USAGE ON TYPE public.task_assignment_role TO authenticated;
GRANT USAGE ON TYPE public.board_type TO authenticated;
GRANT USAGE ON TYPE public.list_type TO authenticated;
GRANT USAGE ON TYPE public.task_dependency_type TO authenticated;
GRANT USAGE ON TYPE public.document_type TO authenticated;
GRANT USAGE ON TYPE public.document_status TO authenticated;
GRANT USAGE ON TYPE public.access_level TO authenticated;
GRANT USAGE ON TYPE public.workflow_status TO authenticated;
GRANT USAGE ON TYPE public.approval_status TO authenticated;
GRANT USAGE ON TYPE public.inventory_location_type TO authenticated;
GRANT USAGE ON TYPE public.inventory_transaction_type TO authenticated;
GRANT USAGE ON TYPE public.stock_adjustment_type TO authenticated;
GRANT USAGE ON TYPE public.quality_status_type TO authenticated;
GRANT USAGE ON TYPE public.inventory_valuation_method TO authenticated;
GRANT USAGE ON TYPE public.storage_condition_type TO authenticated;
GRANT USAGE ON TYPE public.unit_of_measure_type TO authenticated;
GRANT USAGE ON TYPE public.purchase_order_status TO authenticated;
GRANT USAGE ON TYPE public.product_status TO authenticated;
GRANT USAGE ON TYPE public.product_type TO authenticated;
GRANT USAGE ON TYPE public.account_type TO authenticated;
GRANT USAGE ON TYPE public.transaction_type TO authenticated;
GRANT USAGE ON TYPE public.payment_status TO authenticated;
GRANT USAGE ON TYPE public.payment_method TO authenticated;
GRANT USAGE ON TYPE public.currency_type TO authenticated;
GRANT USAGE ON TYPE public.tax_type TO authenticated;
GRANT USAGE ON TYPE public.journal_entry_type TO authenticated;

-- Grant permissions for new enums
GRANT USAGE ON TYPE public.communication_channel_type TO authenticated;
GRANT USAGE ON TYPE public.entity_type TO authenticated;
GRANT USAGE ON TYPE public.security_level TO authenticated;
GRANT USAGE ON TYPE public.subscription_status TO authenticated;
GRANT USAGE ON TYPE public.notification_frequency TO authenticated;

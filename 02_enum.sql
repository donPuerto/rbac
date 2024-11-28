-- =====================================================================================
-- RBAC System Enums
-- =====================================================================================
-- Description: Enum type definitions for the Role-Based Access Control (RBAC) system
-- Version: 1.0.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Drop existing enum types
-- =====================================================================================
DROP TYPE IF EXISTS role_type CASCADE;

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

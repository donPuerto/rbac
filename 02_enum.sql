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
--   1. super_admin    - Complete system control
--   2. system_admin   - System-wide administration
--   3. user_admin     - User management
--   3. audit_admin    - Audit and logging (same level as user_admin)
--   4. standard_user  - Regular user access
--   5. guest_user     - Limited access
CREATE TYPE role_type AS ENUM (
    'super_admin',     -- Complete system control
    'system_admin',    -- System-wide administration
    'user_admin',      -- User management
    'audit_admin',     -- Audit and logging
    'standard_user',   -- Regular user access
    'guest_user'       -- Limited access
);
COMMENT ON TYPE role_type IS 'Hierarchical role types for RBAC system';

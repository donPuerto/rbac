-- =====================================================================================
-- ENUM Types for RBAC System
-- =====================================================================================
-- Description: This file defines the role types for the Role-Based Access Control system.
-- Each role has a specific level in the hierarchy, with higher numbers indicating more
-- privileges. The roles are ordered from highest (7) to lowest (1) privilege level.
-- =====================================================================================

-- Drop the enum type if exists
DROP TYPE IF EXISTS role_type CASCADE;

-- Create role type enum with hierarchical structure
CREATE TYPE role_type AS ENUM (
    'super_admin',    -- Level 7: Full system access
    'admin',          -- Level 6: System administration
    'manager',        -- Level 5: User and content management
    'moderator',      -- Level 4: Content moderation
    'editor',         -- Level 3: Content management
    'user',           -- Level 2: Standard user access
    'guest'           -- Level 1: Limited access
);

-- Add descriptive comment to the enum type
COMMENT ON TYPE role_type IS 'Hierarchical role system for RBAC, levels 1-7 with super_admin having highest privileges';

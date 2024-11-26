-- =====================================================================================
-- RBAC System Indexes
-- =====================================================================================
-- Description: Performance-optimized indexes for the RBAC system
-- Version: 1.0
-- Last Updated: 2024
-- =====================================================================================

-- Drop existing indexes
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_users_auth_id;
DROP INDEX IF EXISTS public.idx_users_active;
DROP INDEX IF EXISTS public.idx_user_roles_user_id;
DROP INDEX IF EXISTS public.idx_user_roles_tenant_id;
DROP INDEX IF EXISTS public.idx_tenants_default;
DROP INDEX IF EXISTS public.idx_roles_parent_role_id;
DROP INDEX IF EXISTS public.idx_roles_role_type;
DROP INDEX IF EXISTS public.idx_user_roles_role_id;
DROP INDEX IF EXISTS public.idx_roles_hierarchy_type;
DROP INDEX IF EXISTS public.idx_user_roles_hierarchy;
DROP INDEX IF EXISTS public.idx_roles_active_type;

-- User Management Indexes
CREATE UNIQUE INDEX idx_users_email 
ON public.users (email) 
WHERE deleted_at IS NULL;

-- Role Management Indexes
CREATE INDEX idx_user_roles_user_id 
ON public.user_roles (user_id) 
WHERE deleted_at IS NULL;

CREATE INDEX idx_user_roles_tenant_id 
ON public.user_roles (tenant_id) 
WHERE deleted_at IS NULL;

-- Permission Management Indexes
CREATE INDEX IF NOT EXISTS idx_permissions_resource_action 
ON public.permissions (resource, action) 
WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_role_permissions_role 
ON public.role_permissions (role_id) 
WHERE deleted_at IS NULL;

-- Delegation Management Indexes
CREATE INDEX IF NOT EXISTS idx_role_delegations_delegate 
ON public.role_delegations (delegate_id) 
WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_role_delegations_delegator 
ON public.role_delegations (delegator_id) 
WHERE deleted_at IS NULL;

-- Audit and Activity Indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_record 
ON public.audit_logs (table_name, record_id);

CREATE INDEX IF NOT EXISTS idx_user_activities_user_type 
ON public.user_activities (user_id, activity_type);

-- Task Management Indexes
CREATE INDEX IF NOT EXISTS idx_scheduled_tasks_execution 
ON public.scheduled_tasks (execute_at) 
WHERE is_processed = false;

-- Tenant Management Indexes
CREATE INDEX idx_tenants_default 
ON public.tenants (is_default) 
WHERE deleted_at IS NULL AND is_active = true;

-- User Authentication Indexes
CREATE UNIQUE INDEX idx_users_auth_id 
ON public.users (auth_id) 
WHERE deleted_at IS NULL;

CREATE INDEX idx_users_active 
ON public.users (is_active) 
WHERE deleted_at IS NULL;

-- Role Hierarchy Indexes
CREATE INDEX IF NOT EXISTS idx_roles_parent_role_id
    ON public.roles (parent_role_id)
    WHERE deleted_at IS NULL AND is_active = true;

CREATE INDEX IF NOT EXISTS idx_roles_role_type
    ON public.roles (role_type)
    WHERE deleted_at IS NULL AND is_active = true;

CREATE INDEX IF NOT EXISTS idx_user_roles_role_id
    ON public.user_roles (role_id)
    WHERE deleted_at IS NULL AND is_active = true;

-- Role Hierarchy Validation Indexes
CREATE INDEX idx_roles_hierarchy_type
    ON public.roles (role_type)
    WHERE deleted_at IS NULL AND is_active = true;

CREATE INDEX idx_user_roles_hierarchy
    ON public.user_roles (role_id, user_id)
    WHERE deleted_at IS NULL AND is_active = true;

CREATE INDEX idx_roles_active_type
    ON public.roles (id, role_type)
    WHERE deleted_at IS NULL AND is_active = true;

-- Add helpful comments
COMMENT ON INDEX public.idx_users_email IS 'Ensures unique email addresses for active users';
COMMENT ON INDEX public.idx_users_auth_id IS 'Ensures unique auth_id mapping for active users';
COMMENT ON INDEX public.idx_users_active IS 'Optimizes queries filtering by user active status';
COMMENT ON INDEX public.idx_user_roles_user_id IS 'Optimizes role lookups by user';
COMMENT ON INDEX public.idx_user_roles_tenant_id IS 'Optimizes user-role lookups by tenant';
COMMENT ON INDEX public.idx_tenants_default IS 'Optimizes lookup of default tenant';
COMMENT ON INDEX public.idx_permissions_resource_action IS 'Optimizes permission lookups by resource/action';
COMMENT ON INDEX public.idx_role_permissions_role IS 'Optimizes permission lookups for a role';
COMMENT ON INDEX public.idx_role_delegations_delegate IS 'Optimizes delegation lookups for delegates';
COMMENT ON INDEX public.idx_role_delegations_delegator IS 'Optimizes delegation lookups for delegators';
COMMENT ON INDEX public.idx_audit_logs_table_record IS 'Optimizes audit log lookups by table and record';
COMMENT ON INDEX public.idx_user_activities_user_type IS 'Optimizes activity lookups by user and type';
COMMENT ON INDEX public.idx_scheduled_tasks_execution IS 'Optimizes pending task lookups';
COMMENT ON INDEX public.idx_roles_parent_role_id IS 'Optimizes role hierarchy lookups by parent role';
COMMENT ON INDEX public.idx_roles_role_type IS 'Optimizes role hierarchy lookups by role type';
COMMENT ON INDEX public.idx_user_roles_role_id IS 'Optimizes role hierarchy lookups by role';
COMMENT ON INDEX public.idx_roles_hierarchy_type IS 'Optimizes role type lookups for hierarchy validation';
COMMENT ON INDEX public.idx_user_roles_hierarchy IS 'Optimizes user role assignment checks for hierarchy validation';
COMMENT ON INDEX public.idx_roles_active_type IS 'Optimizes active role lookups by type for hierarchy validation';

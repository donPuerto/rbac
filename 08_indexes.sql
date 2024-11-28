-- =====================================================================================
-- RBAC System Indexes
-- =====================================================================================
-- Description: Performance-optimized indexes for the RBAC system
-- Version: 1.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Drop existing indexes
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_users_status;
DROP INDEX IF EXISTS public.idx_users_active;
DROP INDEX IF EXISTS public.idx_users_search;
DROP INDEX IF EXISTS public.idx_user_roles_user_id;
DROP INDEX IF EXISTS public.idx_user_roles_role_id;
DROP INDEX IF EXISTS public.idx_roles_role_type;
DROP INDEX IF EXISTS public.idx_permissions_resource_action;
DROP INDEX IF EXISTS public.idx_role_permissions_role;
DROP INDEX IF EXISTS public.idx_role_delegations_delegate;
DROP INDEX IF EXISTS public.idx_role_delegations_delegator;
DROP INDEX IF EXISTS public.idx_audit_logs_table_record;
DROP INDEX IF EXISTS public.idx_user_activities_user_type;
DROP INDEX IF EXISTS public.idx_scheduled_tasks_execution;
DROP INDEX IF EXISTS public.idx_users_full_text_search;

-- User Management Indexes
CREATE UNIQUE INDEX idx_users_email 
ON public.users (email) 
WHERE deleted_at IS NULL;

CREATE INDEX idx_users_status
ON public.users (status) 
WHERE deleted_at IS NULL;

CREATE INDEX idx_users_active 
ON public.users (is_active) 
WHERE deleted_at IS NULL;

-- Full Text Search Index for User Search Function
CREATE INDEX idx_users_full_text_search
ON public.users USING gin(
    to_tsvector('english',
        coalesce(first_name,'') || ' ' ||
        coalesce(last_name,'') || ' ' ||
        coalesce(email,'') || ' ' ||
        coalesce(display_name,'') || ' ' ||
        coalesce(bio,'')
    )
)
WHERE deleted_at IS NULL;

-- Role Management Indexes
CREATE INDEX idx_user_roles_user_id 
ON public.user_roles (user_id, assigned_at DESC) 
WHERE deleted_at IS NULL AND is_active = true;

CREATE INDEX idx_user_roles_role_id
ON public.user_roles (role_id, assigned_at DESC)
WHERE deleted_at IS NULL AND is_active = true;

-- Composite Index for Role Type and Status
CREATE INDEX idx_roles_role_type
ON public.roles (type, is_active) 
WHERE deleted_at IS NULL;

-- Permission Management Indexes
CREATE INDEX idx_permissions_resource_action 
ON public.permissions (resource, action, is_active) 
WHERE deleted_at IS NULL;

CREATE INDEX idx_role_permissions_role 
ON public.role_permissions (role_id, permission_id, granted_at DESC) 
WHERE deleted_at IS NULL AND is_active = true;

-- Delegation Management Indexes
CREATE INDEX idx_role_delegations_delegate 
ON public.role_delegations (delegate_id) 
WHERE deleted_at IS NULL AND is_active = true;

CREATE INDEX idx_role_delegations_delegator 
ON public.role_delegations (delegator_id) 
WHERE deleted_at IS NULL AND is_active = true;

-- Audit and Activity Indexes
CREATE INDEX idx_audit_logs_table_record 
ON public.audit_logs (table_name, record_id, performed_at DESC);

CREATE INDEX idx_user_activities_user_type 
ON public.user_activities (user_id, activity_type, created_at DESC);

-- Task Management Indexes
CREATE INDEX idx_scheduled_tasks_execution 
ON public.scheduled_tasks (task_type, execute_at) 
WHERE NOT is_processed;

-- Add helpful comments
COMMENT ON INDEX public.idx_users_email IS 'Ensures unique email addresses for active users';
COMMENT ON INDEX public.idx_users_status IS 'Optimizes queries filtering by user status';
COMMENT ON INDEX public.idx_users_active IS 'Optimizes queries filtering by user active status';
COMMENT ON INDEX public.idx_users_full_text_search IS 'Enables efficient full-text search across user fields';
COMMENT ON INDEX public.idx_user_roles_user_id IS 'Optimizes role lookups by user with assignment time sorting';
COMMENT ON INDEX public.idx_user_roles_role_id IS 'Optimizes user lookups by role with assignment time sorting';
COMMENT ON INDEX public.idx_roles_role_type IS 'Optimizes role lookups by type and status';
COMMENT ON INDEX public.idx_permissions_resource_action IS 'Optimizes permission lookups by resource/action with status';
COMMENT ON INDEX public.idx_role_permissions_role IS 'Optimizes permission lookups for a role with grant time sorting';
COMMENT ON INDEX public.idx_role_delegations_delegate IS 'Optimizes delegation lookups for delegates';
COMMENT ON INDEX public.idx_role_delegations_delegator IS 'Optimizes delegation lookups for delegators';
COMMENT ON INDEX public.idx_audit_logs_table_record IS 'Optimizes audit log lookups with performed_at ordering';
COMMENT ON INDEX public.idx_user_activities_user_type IS 'Optimizes activity lookups with created_at ordering';
COMMENT ON INDEX public.idx_scheduled_tasks_execution IS 'Optimizes task execution lookups by type and schedule';

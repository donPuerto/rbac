-- =====================================================================================
-- RBAC System Row Level Security Policies
-- =====================================================================================
-- Description: Row Level Security (RLS) policies for the RBAC system
-- Version: 1.0
-- Last Updated: 2024
-- =====================================================================================

-- Drop existing policies
-- =====================================================================================
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "User admins can create users" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Only super admins can delete users" ON public.users;
DROP POLICY IF EXISTS "Anyone can view active roles" ON public.roles;
DROP POLICY IF EXISTS "Only super admins can manage roles" ON public.roles;
DROP POLICY IF EXISTS "Anyone can view permissions" ON public.permissions;
DROP POLICY IF EXISTS "Only super admins can manage permissions" ON public.permissions;
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Only admins can manage user roles" ON public.user_roles;
DROP POLICY IF EXISTS "Anyone can view role permissions" ON public.role_permissions;
DROP POLICY IF EXISTS "Only super admins can manage role permissions" ON public.role_permissions;
DROP POLICY IF EXISTS "Users can view their delegations" ON public.role_delegations;
DROP POLICY IF EXISTS "Only admins can manage delegations" ON public.role_delegations;
DROP POLICY IF EXISTS "Users can view and manage their phone numbers" ON public.user_phone_numbers;
DROP POLICY IF EXISTS "Users can view and manage their addresses" ON public.user_addresses;
DROP POLICY IF EXISTS "Users can view relevant audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Audit admins can manage audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Users can view their activities" ON public.user_activities;
DROP POLICY IF EXISTS "System can manage activities" ON public.user_activities;
DROP POLICY IF EXISTS "Admins can view scheduled tasks" ON public.scheduled_tasks;
DROP POLICY IF EXISTS "System can manage scheduled tasks" ON public.scheduled_tasks;
DROP POLICY IF EXISTS "Only audit admins can view audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Users can view relevant audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Audit admins can manage audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Users can view their own activities" ON public.user_activities;
DROP POLICY IF EXISTS "Users can view their activities" ON public.user_activities;
DROP POLICY IF EXISTS "Only system admins can manage scheduled tasks" ON public.scheduled_tasks;


-- Enable RLS on Tables
-- =====================================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_delegations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheduled_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_phone_numbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;

-- Users Table Policies
-- =====================================================================================
CREATE POLICY "Users can view their own profile"
    ON public.users
    FOR SELECT
    TO authenticated
    USING (
        auth.uid() = id
        OR has_permission(auth.uid(), 'user', 'read')
    );
COMMENT ON POLICY "Users can view their own profile" ON public.users IS 'Users can view their own profile or profiles they have permission to read';

CREATE POLICY "User admins can create users"
    ON public.users
    FOR INSERT
    TO authenticated
    WITH CHECK (
        has_permission(auth.uid(), 'user', 'create')
    );
COMMENT ON POLICY "User admins can create users" ON public.users IS 'Only users with user creation permission can create new users';

CREATE POLICY "Users can update their own profile"
    ON public.users
    FOR UPDATE
    TO authenticated
    USING (
        auth.uid() = id
        OR has_permission(auth.uid(), 'user', 'update')
    )
    WITH CHECK (
        auth.uid() = id
        OR has_permission(auth.uid(), 'user', 'update')
    );
COMMENT ON POLICY "Users can update their own profile" ON public.users IS 'Users can update their own profile or profiles they have permission to update';

CREATE POLICY "Only super admins can delete users"
    ON public.users
    FOR DELETE
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    );
COMMENT ON POLICY "Only super admins can delete users" ON public.users IS 'Only super admins can delete users';

-- Roles Table Policies
-- =====================================================================================
CREATE POLICY "Anyone can view active roles"
    ON public.roles
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL
        AND is_active = true
    );
COMMENT ON POLICY "Anyone can view active roles" ON public.roles IS 'Anyone can view active roles';

CREATE POLICY "Only super admins can manage roles"
    ON public.roles
    FOR ALL
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    )
    WITH CHECK (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    );
COMMENT ON POLICY "Only super admins can manage roles" ON public.roles IS 'Only super admins can manage roles';

-- Permissions Table Policies
-- =====================================================================================
CREATE POLICY "Anyone can view permissions"
    ON public.permissions
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL
        AND is_active = true
    );
COMMENT ON POLICY "Anyone can view permissions" ON public.permissions IS 'Anyone can view permissions';

CREATE POLICY "Only super admins can manage permissions"
    ON public.permissions
    FOR ALL
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    )
    WITH CHECK (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    );
COMMENT ON POLICY "Only super admins can manage permissions" ON public.permissions IS 'Only super admins can manage permissions';

-- User Roles Table Policies
-- =====================================================================================
CREATE POLICY "Users can view their own roles"
    ON public.user_roles
    FOR SELECT
    TO authenticated
    USING (
        user_id = auth.uid()
        OR has_permission(auth.uid(), 'role', 'read')
    );
COMMENT ON POLICY "Users can view their own roles" ON public.user_roles IS 'Users can view their own roles or roles they have permission to read';

CREATE POLICY "Only admins can manage user roles"
    ON public.user_roles
    FOR ALL
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin', 'user_admin']::role_type[])
    )
    WITH CHECK (
        has_any_role(auth.uid(), ARRAY['super_admin', 'user_admin']::role_type[])
    );
COMMENT ON POLICY "Only admins can manage user roles" ON public.user_roles IS 'Only admins can manage user roles';

-- Role Permissions Table Policies
-- =====================================================================================
CREATE POLICY "Anyone can view role permissions"
    ON public.role_permissions
    FOR SELECT
    TO authenticated
    USING (
        deleted_at IS NULL
        AND is_active = true
    );
COMMENT ON POLICY "Anyone can view role permissions" ON public.role_permissions IS 'Anyone can view role permissions';

CREATE POLICY "Only super admins can manage role permissions"
    ON public.role_permissions
    FOR ALL
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    )
    WITH CHECK (
        has_any_role(auth.uid(), ARRAY['super_admin']::role_type[])
    );
COMMENT ON POLICY "Only super admins can manage role permissions" ON public.role_permissions IS 'Only super admins can manage role permissions';

-- Role Delegations Table Policies
-- =====================================================================================
CREATE POLICY "Users can view their delegations"
    ON public.role_delegations
    FOR SELECT
    TO authenticated
    USING (
        delegator_id = auth.uid()
        OR delegate_id = auth.uid()
        OR has_any_role(auth.uid(), ARRAY['super_admin', 'user_admin']::role_type[])
    );
COMMENT ON POLICY "Users can view their delegations" ON public.role_delegations IS 'Users can view their own delegations or delegations they have permission to view';

CREATE POLICY "Only admins can manage delegations"
    ON public.role_delegations
    FOR ALL
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin', 'user_admin']::role_type[])
    )
    WITH CHECK (
        has_any_role(auth.uid(), ARRAY['super_admin', 'user_admin']::role_type[])
    );
COMMENT ON POLICY "Only admins can manage delegations" ON public.role_delegations IS 'Only admins can manage delegations';

-- Audit Logs Table Policies
-- =====================================================================================
CREATE POLICY "Only audit admins can view audit logs"
    ON public.audit_logs
    FOR SELECT
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin', 'audit_admin']::role_type[])
    );
COMMENT ON POLICY "Only audit admins can view audit logs" ON public.audit_logs IS 'Only audit admins can view audit logs';

-- User Activities Table Policies
-- =====================================================================================
CREATE POLICY "Users can view their own activities"
    ON public.user_activities
    FOR SELECT
    TO authenticated
    USING (
        user_id = auth.uid()
        OR has_any_role(auth.uid(), ARRAY['super_admin', 'audit_admin']::role_type[])
    );
COMMENT ON POLICY "Users can view their own activities" ON public.user_activities IS 'Users can view their own activities or activities they have permission to view';

-- User Phone Numbers Table Policies
-- =====================================================================================
CREATE POLICY "Users can view and manage their phone numbers"
    ON public.user_phone_numbers
    FOR ALL
    TO authenticated
    USING (
        user_id = auth.uid()
        OR has_permission(auth.uid(), 'user_contact', 'manage')
    )
    WITH CHECK (
        user_id = auth.uid()
        OR has_permission(auth.uid(), 'user_contact', 'manage')
    );
COMMENT ON POLICY "Users can view and manage their phone numbers" ON public.user_phone_numbers IS 'Users can manage their own phone numbers or those they have permission to manage';

-- User Addresses Table Policies
-- =====================================================================================
CREATE POLICY "Users can view and manage their addresses"
    ON public.user_addresses
    FOR ALL
    TO authenticated
    USING (
        user_id = auth.uid()
        OR has_permission(auth.uid(), 'user_contact', 'manage')
    )
    WITH CHECK (
        user_id = auth.uid()
        OR has_permission(auth.uid(), 'user_contact', 'manage')
    );
COMMENT ON POLICY "Users can view and manage their addresses" ON public.user_addresses IS 'Users can manage their own addresses or those they have permission to manage';

-- Scheduled Tasks Table Policies
-- =====================================================================================
CREATE POLICY "Only system admins can manage scheduled tasks"
    ON public.scheduled_tasks
    FOR ALL
    TO authenticated
    USING (
        has_any_role(auth.uid(), ARRAY['super_admin', 'system_admin']::role_type[])
    )
    WITH CHECK (
        has_any_role(auth.uid(), ARRAY['super_admin', 'system_admin']::role_type[])
    );
COMMENT ON POLICY "Only system admins can manage scheduled tasks" ON public.scheduled_tasks IS 'Only system admins can manage scheduled tasks';
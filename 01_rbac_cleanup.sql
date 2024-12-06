-- =====================================================================================
-- RBAC System Cleanup
-- =====================================================================================
-- Description: Drops all components of the RBAC system in the correct dependency order
-- Version: 1.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================-- Table of Contents
-- =====================================================================================
-- 1. Enum Types (01_enum.sql)
--    - role_type            (Hierarchical role types)
--
-- 2. Core Tables (02_tables.sql)
--    - users                (Core user information and profile data)
--    - roles                (System role definitions)
--    - permissions          (Available system permissions)
--    - user_roles           (User-role assignments)
--    - role_permissions     (Role-permission mappings)
--    - role_delegations     (Role management delegations)
--    - scheduled_tasks      (Task scheduling for role expiration)
--
-- 3. Supporting Tables (02_tables.sql)
--    - user_phone_numbers   (User contact information)
--    - user_addresses       (User physical addresses)
--    - audit_logs           (System change tracking)
--    - user_activities      (User behavior tracking)
--
-- 4. Core Functions (03_functions.sql)
--    - User Management
--      * handle_new_user()
--      * soft_delete_user()
--      * restore_deleted_user()
--      * update_user_status()
--    - Role Management
--      * manage_user_role()
--      * has_any_role()
--      * get_user_roles()
--      * delegate_role_management()
--    - Permission Management
--      * has_permission()
--      * grant_permission()
--      * revoke_permission()
--      * get_role_permissions()
--    - Audit & Logging
--      * process_audit()
--      * log_audit_event()
--      * log_activity()-- Table of Contents
-- =====================================================================================
-- 1. Enum Types (01_enum.sql)
--    - role_type            (Hierarchical role types)
--
-- 2. Core Tables (02_tables.sql)
--    - users                (Core user information and profile data)
--    - roles                (System role definitions)
--    - permissions          (Available system permissions)
--    - user_roles           (User-role assignments)
--    - role_permissions     (Role-permission mappings)
--    - role_delegations     (Role management delegations)
--    - scheduled_tasks      (Task scheduling for role expiration)
--
-- 3. Supporting Tables (02_tables.sql)
--    - user_phone_numbers   (User contact information)
--    - user_addresses       (User physical addresses)
--    - audit_logs           (System change tracking)
--    - user_activities      (User behavior tracking)
--
-- 4. Core Functions (03_functions.sql)
--    - User Management
--      * handle_new_user()
--      * soft_delete_user()
--      * restore_deleted_user()
--      * update_user_status()
--    - Role Management
--      * manage_user_role()
--      * has_any_role()
--      * get_user_roles()
--      * delegate_role_management()
--    - Permission Management
--      * has_permission()
--      * grant_permission()
--      * revoke_permission()
--      * get_role_permissions()
--    - Audit & Logging
--      * process_audit()
--      * log_audit_event()
--      * log_activity()-- Table of Contents
-- =====================================================================================
-- 1. Enum Types (01_enum.sql)
--    - role_type            (Hierarchical role types)
--
-- 2. Core Tables (02_tables.sql)
--    - users                (Core user information and profile data)
--    - roles                (System role definitions)
--    - permissions          (Available system permissions)
--    - user_roles           (User-role assignments)
--    - role_permissions     (Role-permission mappings)
--    - role_delegations     (Role management delegations)
--    - scheduled_tasks      (Task scheduling for role expiration)
--
-- 3. Supporting Tables (02_tables.sql)
--    - user_phone_numbers   (User contact information)
--    - user_addresses       (User physical addresses)
--    - audit_logs           (System change tracking)
--    - user_activities      (User behavior tracking)
--
-- 4. Core Functions (03_functions.sql)
--    - User Management
--      * handle_new_user()
--      * soft_delete_user()
--      * restore_deleted_user()
--      * update_user_status()
--    - Role Management
--      * manage_user_role()
--      * has_any_role()
--      * get_user_roles()
--      * delegate_role_management()
--    - Permission Management
--      * has_permission()
--      * grant_permission()
--      * revoke_permission()
--      * get_role_permissions()
--    - Audit & Logging
--      * process_audit()
--      * log_audit_event()
--      * log_activity()

-- Revoke Grants and Permissions
-- =====================================================================================
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authenticated;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM authenticated;
REVOKE ALL ON SCHEMA public FROM authenticated;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon;
REVOKE ALL ON SCHEMA public FROM anon;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM service_role;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM service_role;
REVOKE ALL ON SCHEMA public FROM service_role;

-- Disable RLS on all tables first (only if they exist)
-- =====================================================================================
DO $$ 
BEGIN
    -- Disable RLS for each table if it exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_activities') THEN
        ALTER TABLE public.user_activities DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_logs') THEN
        ALTER TABLE public.audit_logs DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_addresses') THEN
        ALTER TABLE public.user_addresses DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_phone_numbers') THEN
        ALTER TABLE public.user_phone_numbers DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'scheduled_tasks') THEN
        ALTER TABLE public.scheduled_tasks DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'role_delegations') THEN
        ALTER TABLE public.role_delegations DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'role_permissions') THEN
        ALTER TABLE public.role_permissions DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_roles') THEN
        ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'permissions') THEN
        ALTER TABLE public.permissions DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'roles') THEN
        ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
        ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'error_logs') THEN
        ALTER TABLE public.error_logs DISABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- Drop RLS Policies (only if tables exist)
-- =====================================================================================
DO $$ 
BEGIN
    -- Drop User Activities Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_activities') THEN
        DROP POLICY IF EXISTS "Users can view their own activities" ON public.user_activities;
        DROP POLICY IF EXISTS "System can manage activities" ON public.user_activities;
        DROP POLICY IF EXISTS "Users can view their activities" ON public.user_activities;
    END IF;

    -- Drop Audit Log Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_logs') THEN
        DROP POLICY IF EXISTS "Only audit admins can view audit logs" ON public.audit_logs;
        DROP POLICY IF EXISTS "Users can view relevant audit logs" ON public.audit_logs;
        DROP POLICY IF EXISTS "Audit admins can manage audit logs" ON public.audit_logs;
    END IF;

    -- Drop Scheduled Task Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'scheduled_tasks') THEN
        DROP POLICY IF EXISTS "Only system admins can manage scheduled tasks" ON public.scheduled_tasks;
        DROP POLICY IF EXISTS "Admins can view scheduled tasks" ON public.scheduled_tasks;
        DROP POLICY IF EXISTS "System can manage scheduled tasks" ON public.scheduled_tasks;
    END IF;

    -- Drop Role Delegation Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'role_delegations') THEN
        DROP POLICY IF EXISTS "Users can view their delegations" ON public.role_delegations;
        DROP POLICY IF EXISTS "Only admins can manage delegations" ON public.role_delegations;
    END IF;

    -- Drop User Address Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_addresses') THEN
        DROP POLICY IF EXISTS "Users can view and manage their addresses" ON public.user_addresses;
    END IF;

    -- Drop User Phone Number Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_phone_numbers') THEN
        DROP POLICY IF EXISTS "Users can view and manage their phone numbers" ON public.user_phone_numbers;
    END IF;

    -- Drop Role Permission Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'role_permissions') THEN
        DROP POLICY IF EXISTS "Anyone can view role permissions" ON public.role_permissions;
        DROP POLICY IF EXISTS "Only super admins can manage role permissions" ON public.role_permissions;
    END IF;

    -- Drop User Role Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_roles') THEN
        DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
        DROP POLICY IF EXISTS "Only admins can manage user roles" ON public.user_roles;
    END IF;

    -- Drop Permission Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'permissions') THEN
        DROP POLICY IF EXISTS "Anyone can view permissions" ON public.permissions;
        DROP POLICY IF EXISTS "Only super admins can manage permissions" ON public.permissions;
    END IF;

    -- Drop Role Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'roles') THEN
        DROP POLICY IF EXISTS "Anyone can view active roles" ON public.roles;
        DROP POLICY IF EXISTS "Only super admins can manage roles" ON public.roles;
    END IF;

    -- Drop User Policies if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
        DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
        DROP POLICY IF EXISTS "User admins can create users" ON public.users;
        DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
        DROP POLICY IF EXISTS "Only super admins can delete users" ON public.users;
    END IF;
END $$;

-- Drop Indexes
-- =====================================================================================
DROP INDEX IF EXISTS public.idx_users_email CASCADE;
DROP INDEX IF EXISTS public.idx_users_status CASCADE;
DROP INDEX IF EXISTS public.idx_users_created_at CASCADE;
DROP INDEX IF EXISTS public.idx_users_updated_at CASCADE;
DROP INDEX IF EXISTS public.idx_users_deleted_at CASCADE;

DROP INDEX IF EXISTS public.idx_roles_name CASCADE;
DROP INDEX IF EXISTS public.idx_roles_type CASCADE;
DROP INDEX IF EXISTS public.idx_roles_is_active CASCADE;

DROP INDEX IF EXISTS public.idx_permissions_name CASCADE;
DROP INDEX IF EXISTS public.idx_permissions_resource_action CASCADE;
DROP INDEX IF EXISTS public.idx_permissions_is_active CASCADE;

DROP INDEX IF EXISTS public.idx_user_roles_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_user_roles_role_id CASCADE;
DROP INDEX IF EXISTS public.idx_user_roles_assigned_at CASCADE;
DROP INDEX IF EXISTS public.idx_user_roles_is_active CASCADE;

DROP INDEX IF EXISTS public.idx_role_permissions_role_id CASCADE;
DROP INDEX IF EXISTS public.idx_role_permissions_permission_id CASCADE;
DROP INDEX IF EXISTS public.idx_role_permissions_granted_at CASCADE;

DROP INDEX IF EXISTS public.idx_role_delegations_delegator CASCADE;
DROP INDEX IF EXISTS public.idx_role_delegations_delegate CASCADE;
DROP INDEX IF EXISTS public.idx_role_delegations_role CASCADE;
DROP INDEX IF EXISTS public.idx_role_delegations_expires CASCADE;

DROP INDEX IF EXISTS public.idx_error_logs_severity CASCADE;
DROP INDEX IF EXISTS public.idx_error_logs_created_at CASCADE;
DROP INDEX IF EXISTS public.idx_error_logs_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_error_logs_function CASCADE;

DROP INDEX IF EXISTS public.idx_audit_logs_table_name CASCADE;
DROP INDEX IF EXISTS public.idx_audit_logs_record_id CASCADE;
DROP INDEX IF EXISTS public.idx_audit_logs_action CASCADE;
DROP INDEX IF EXISTS public.idx_audit_logs_performed_by CASCADE;
DROP INDEX IF EXISTS public.idx_audit_logs_created_at CASCADE;

DROP INDEX IF EXISTS public.idx_user_activities_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_user_activities_type CASCADE;
DROP INDEX IF EXISTS public.idx_user_activities_created_at CASCADE;

DROP INDEX IF EXISTS public.idx_scheduled_tasks_type CASCADE;
DROP INDEX IF EXISTS public.idx_scheduled_tasks_status CASCADE;
DROP INDEX IF EXISTS public.idx_scheduled_tasks_execute_at CASCADE;

DROP INDEX IF EXISTS public.idx_phone_numbers_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_phone_numbers_type CASCADE;
DROP INDEX IF EXISTS public.idx_phone_numbers_is_primary CASCADE;

DROP INDEX IF EXISTS public.idx_addresses_user_id CASCADE;
DROP INDEX IF EXISTS public.idx_addresses_type CASCADE;
DROP INDEX IF EXISTS public.idx_addresses_is_primary CASCADE;

-- Drop Triggers
-- =====================================================================================
DROP TRIGGER IF EXISTS prevent_id_change ON public.scheduled_tasks;
DROP TRIGGER IF EXISTS prevent_id_change ON public.user_activities;
DROP TRIGGER IF EXISTS prevent_id_change ON public.audit_logs;
DROP TRIGGER IF EXISTS prevent_id_change ON public.error_logs;
DROP TRIGGER IF EXISTS prevent_id_change ON public.role_delegations;
DROP TRIGGER IF EXISTS prevent_id_change ON public.role_permissions;
DROP TRIGGER IF EXISTS prevent_id_change ON public.user_roles;
DROP TRIGGER IF EXISTS prevent_id_change ON public.roles;
DROP TRIGGER IF EXISTS prevent_id_change ON public.permissions;
DROP TRIGGER IF EXISTS prevent_id_change ON public.users;

DROP TRIGGER IF EXISTS update_timestamp ON public.scheduled_tasks;
DROP TRIGGER IF EXISTS update_timestamp ON public.user_activities;
DROP TRIGGER IF EXISTS update_timestamp ON public.audit_logs;
DROP TRIGGER IF EXISTS update_timestamp ON public.error_logs;
DROP TRIGGER IF EXISTS update_timestamp ON public.role_delegations;
DROP TRIGGER IF EXISTS update_timestamp ON public.role_permissions;
DROP TRIGGER IF EXISTS update_timestamp ON public.user_roles;
DROP TRIGGER IF EXISTS update_timestamp ON public.roles;
DROP TRIGGER IF EXISTS update_timestamp ON public.permissions;
DROP TRIGGER IF EXISTS update_timestamp ON public.users;

DROP TRIGGER IF EXISTS audit_changes ON public.scheduled_tasks;
DROP TRIGGER IF EXISTS audit_changes ON public.user_activities;
DROP TRIGGER IF EXISTS audit_changes ON public.audit_logs;
DROP TRIGGER IF EXISTS audit_changes ON public.error_logs;
DROP TRIGGER IF EXISTS audit_changes ON public.role_delegations;
DROP TRIGGER IF EXISTS audit_changes ON public.role_permissions;
DROP TRIGGER IF EXISTS audit_changes ON public.user_roles;
DROP TRIGGER IF EXISTS audit_changes ON public.roles;
DROP TRIGGER IF EXISTS audit_changes ON public.permissions;
DROP TRIGGER IF EXISTS audit_changes ON public.users;

-- Drop Functions (in dependency order)
-- =====================================================================================
DO $$ 
DECLARE
    func record;
BEGIN
    -- Get all functions in public schema
    FOR func IN 
        SELECT routine_name, routine_schema 
        FROM information_schema.routines 
        WHERE routine_schema = 'public'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || func.routine_name || ' CASCADE;';
    END LOOP;
END $$;

-- Explicitly drop known functions in case any remain
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.is_user_active(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.soft_delete_user(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.restore_deleted_user(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.handle_user_soft_delete() CASCADE;
DROP FUNCTION IF EXISTS public.user_exists(UUID, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_profile(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.update_user_status(UUID, TEXT, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.search_users(TEXT, TEXT[], role_type[]) CASCADE;
DROP FUNCTION IF EXISTS public.validate_user_access(UUID, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.manage_user_role(UUID, role_type, UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_roles(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.check_user_role(UUID, role_type, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS public.get_role_hierarchy_level(role_type) CASCADE;
DROP FUNCTION IF EXISTS public.get_role_assignments_history(UUID, TIMESTAMPTZ, TIMESTAMPTZ) CASCADE;
DROP FUNCTION IF EXISTS public.validate_role_hierarchy_change(UUID, role_type) CASCADE;
DROP FUNCTION IF EXISTS public.get_users_by_role(role_type, BOOLEAN, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS public.check_role_conflicts(UUID, role_type) CASCADE;
DROP FUNCTION IF EXISTS public.assign_temporary_role(UUID, role_type, TIMESTAMPTZ, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.schedule_role_expiration(UUID, role_type, TIMESTAMPTZ) CASCADE;
DROP FUNCTION IF EXISTS public.revoke_expired_roles() CASCADE;
DROP FUNCTION IF EXISTS public.has_any_role(UUID, role_type[]) CASCADE;
DROP FUNCTION IF EXISTS public.get_role_permissions(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.manage_role_delegation(UUID, UUID, UUID, role_type, TIMESTAMPTZ) CASCADE;
DROP FUNCTION IF EXISTS public.validate_delegation(UUID, UUID, role_type) CASCADE;
DROP FUNCTION IF EXISTS public.prevent_id_modification() CASCADE;
DROP FUNCTION IF EXISTS public.update_timestamp() CASCADE;
DROP FUNCTION IF EXISTS public.log_audit_event(TEXT, TEXT, UUID, JSONB, JSONB, JSONB) CASCADE;
DROP FUNCTION IF EXISTS public.log_user_activity(UUID, TEXT, TEXT, JSONB) CASCADE;

-- Drop Tables
-- =====================================================================================
DROP TABLE IF EXISTS public.user_activities CASCADE;
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.error_logs CASCADE;
DROP TABLE IF EXISTS public.scheduled_tasks CASCADE;
DROP TABLE IF EXISTS public.role_delegations CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;
DROP TABLE IF EXISTS public.user_roles CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;
DROP TABLE IF EXISTS public.permissions CASCADE;
DROP TABLE IF EXISTS public.user_addresses CASCADE;
DROP TABLE IF EXISTS public.user_phone_numbers CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- Drop Types and Enums
-- =====================================================================================
DROP TYPE IF EXISTS role_type CASCADE;
DROP TYPE IF EXISTS user_status CASCADE;
DROP TYPE IF EXISTS address_type CASCADE;
DROP TYPE IF EXISTS phone_type CASCADE;
DROP TYPE IF EXISTS severity_level CASCADE;
DROP TYPE IF EXISTS task_status CASCADE;

-- =====================================================================================
-- Database Cleanup for RBAC System
-- =====================================================================================
-- Description: This file contains DROP statements for all database objects in the correct
-- order to avoid dependency conflicts. Objects are dropped in reverse order of creation:
-- 1. Triggers (they depend on tables and functions)
-- 2. Functions (they may depend on tables)
-- 3. Tables (dropped in order of dependencies)
-- 4. Types (dropped last as they might be used by other objects)
-- =====================================================================================

-- Drop Triggers
-- =====================================================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_role_audit ON public.roles;
DROP TRIGGER IF EXISTS on_permission_audit ON public.permissions;
DROP TRIGGER IF EXISTS on_role_permission_audit ON public.role_permissions;
DROP TRIGGER IF EXISTS on_user_role_audit ON public.user_roles;
DROP TRIGGER IF EXISTS on_address_audit ON public.user_addresses;
DROP TRIGGER IF EXISTS on_user_phone_number_change ON public.user_phone_numbers;
DROP TRIGGER IF EXISTS on_user_address_change ON public.user_addresses;
DROP TRIGGER IF EXISTS on_user_role_change ON public.user_roles;
DROP TRIGGER IF EXISTS before_user_delete ON public.users;
DROP TRIGGER IF EXISTS handle_user_soft_delete_trigger ON public.users;

-- Drop Activity and Audit Tables
-- =====================================================================================
DROP TABLE IF EXISTS public.user_activities CASCADE;        -- User action tracking
DROP TABLE IF EXISTS public.audit_logs CASCADE;             -- System-level audit logs

-- Drop Junction Tables
-- =====================================================================================
DROP TABLE IF EXISTS public.role_permissions CASCADE;       -- Role-Permission assignments
DROP TABLE IF EXISTS public.user_roles CASCADE;             -- User-Role assignments

-- Drop Supporting Tables
-- =====================================================================================
DROP TABLE IF EXISTS public.user_addresses CASCADE;         -- User addresses
DROP TABLE IF EXISTS public.user_phone_numbers CASCADE;     -- User phone numbers

-- Drop Core Tables
-- =====================================================================================
DROP TABLE IF EXISTS public.permissions CASCADE;            -- System permissions
DROP TABLE IF EXISTS public.roles CASCADE;                  -- User roles
DROP TABLE IF EXISTS public.users CASCADE;                  -- Core users table

-- Drop Functions
-- =====================================================================================
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.is_user_active(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.soft_delete_user(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.restore_deleted_user(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.handle_user_soft_delete() CASCADE;
DROP FUNCTION IF EXISTS public.user_exists(UUID, BOOLEAN) CASCADE;
DROP FUNCTION IF EXISTS public.handle_user_phone_number();
DROP FUNCTION IF EXISTS public.handle_user_address();
DROP FUNCTION IF EXISTS public.prevent_id_modification();
DROP FUNCTION IF EXISTS public.handle_user_role_change();
DROP FUNCTION IF EXISTS public.set_super_admin(UUID);
DROP FUNCTION IF EXISTS public.initialize_default_roles();
DROP FUNCTION IF EXISTS public.assign_role_to_user(UUID, role_type, UUID);
DROP FUNCTION IF EXISTS public.manage_user_role(UUID, role_type, UUID, TEXT);
DROP FUNCTION IF EXISTS public.check_user_role(UUID, role_type, BOOLEAN);
DROP FUNCTION IF EXISTS public.user_has_role(UUID, role_type);
DROP FUNCTION IF EXISTS public.get_role_hierarchy_level(role_type);
DROP FUNCTION IF EXISTS public.revoke_user_role(UUID, role_type, UUID);
DROP FUNCTION IF EXISTS public.get_user_roles(UUID);
DROP FUNCTION IF EXISTS public.is_admin();
DROP FUNCTION IF EXISTS public.is_super_admin();
DROP FUNCTION IF EXISTS public.get_user_permissions(UUID);
DROP FUNCTION IF EXISTS public.handle_role_soft_delete();
DROP FUNCTION IF EXISTS public.log_activity();
DROP FUNCTION IF EXISTS public.log_audit_event();
DROP FUNCTION IF EXISTS public.process_audit();
DROP FUNCTION IF EXISTS public.update_timestamp();

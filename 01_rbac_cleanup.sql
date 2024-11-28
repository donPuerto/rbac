-- =====================================================================================
-- RBAC System Policy Drops
-- =====================================================================================
-- Description: Drops all RLS policies in the correct order to handle dependencies
-- Version: 1.0
-- Last Updated: 2024
-- =====================================================================================

-- Drop User Activities Policies (these use has_any_role)
DROP POLICY IF EXISTS "Users can view their own activities" ON public.user_activities;
DROP POLICY IF EXISTS "System can manage activities" ON public.user_activities;
DROP POLICY IF EXISTS "Users can view their activities" ON public.user_activities;

-- Drop Audit Log Policies (these use has_any_role)
DROP POLICY IF EXISTS "Only audit admins can view audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Users can view relevant audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Audit admins can manage audit logs" ON public.audit_logs;

-- Drop Scheduled Task Policies (these use has_any_role)
DROP POLICY IF EXISTS "Only system admins can manage scheduled tasks" ON public.scheduled_tasks;
DROP POLICY IF EXISTS "Admins can view scheduled tasks" ON public.scheduled_tasks;
DROP POLICY IF EXISTS "System can manage scheduled tasks" ON public.scheduled_tasks;

-- Drop Role Delegation Policies (these use has_any_role)
DROP POLICY IF EXISTS "Users can view their delegations" ON public.role_delegations;
DROP POLICY IF EXISTS "Only admins can manage delegations" ON public.role_delegations;

-- Drop User Address Policies (these use has_permission)
DROP POLICY IF EXISTS "Users can view and manage their addresses" ON public.user_addresses;

-- Drop User Phone Number Policies (these use has_permission)
DROP POLICY IF EXISTS "Users can view and manage their phone numbers" ON public.user_phone_numbers;

-- Drop Role Permission Policies
DROP POLICY IF EXISTS "Anyone can view role permissions" ON public.role_permissions;
DROP POLICY IF EXISTS "Only super admins can manage role permissions" ON public.role_permissions;

-- Drop User Role Policies
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Only admins can manage user roles" ON public.user_roles;

-- Drop Permission Policies
DROP POLICY IF EXISTS "Anyone can view permissions" ON public.permissions;
DROP POLICY IF EXISTS "Only super admins can manage permissions" ON public.permissions;

-- Drop Role Policies
DROP POLICY IF EXISTS "Anyone can view active roles" ON public.roles;
DROP POLICY IF EXISTS "Only super admins can manage roles" ON public.roles;

-- Drop User Policies (Drop these last as they're often referenced by other policies)
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "User admins can create users" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Only super admins can delete users" ON public.users;

-- Disable RLS on all tables
ALTER TABLE IF EXISTS public.user_activities DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.audit_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_addresses DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_phone_numbers DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.scheduled_tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.role_delegations DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.role_permissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.permissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.users DISABLE ROW LEVEL SECURITY;

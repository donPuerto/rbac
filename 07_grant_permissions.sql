
-- =====================================================================================
-- RBAC System Grant Permissions
-- =====================================================================================
-- Description: Grant necessary permissions to roles for the RBAC system
-- Version: 1.0
-- Last Updated: 2024
-- =====================================================================================

-- Revoke all permissions first
-- =====================================================================================
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated;

-- Grant permissions to authenticated users
-- =====================================================================================

-- Core Tables Permissions
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.roles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.permissions TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.user_roles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.role_permissions TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.role_delegations TO authenticated;
GRANT SELECT, INSERT ON public.audit_logs TO authenticated;
GRANT SELECT, INSERT ON public.user_activities TO authenticated;
GRANT SELECT ON public.scheduled_tasks TO authenticated;

-- Sequence Permissions
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Type Permissions
GRANT USAGE ON TYPE public.role_type TO authenticated;

-- Anonymous users (minimal permissions)
-- =====================================================================================
GRANT SELECT (id, type, name, description, is_system_role) ON public.roles TO anon;
GRANT SELECT (id, name, description) ON public.permissions TO anon;

-- Schema Usage
-- =====================================================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
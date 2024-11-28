-- =====================================================================================
-- RBAC System Initial Data
-- =====================================================================================
-- Description: Initial data setup for the Role-Based Access Control (RBAC) system
-- Version: 1.0
-- Last Updated: 2024
-- Author: Don Puerto
-- =====================================================================================

-- Default System Roles
-- =====================================================================================
INSERT INTO public.roles (name, description, type, is_system_role, is_active)
SELECT 
    name, 
    description, 
    type::role_type,  -- Cast string to role_type enum
    is_system_role, 
    is_active
FROM (VALUES
    ('Super Admin', 'Complete system access with all permissions', 'super_admin', true, true),
    ('System Admin', 'System administration and configuration', 'system_admin', true, true),
    ('User Admin', 'User management and role assignment', 'user_admin', true, true),
    ('Audit Admin', 'Access to audit logs and system monitoring', 'audit_admin', true, true),
    ('Standard User', 'Regular user with basic permissions', 'standard_user', true, true),
    ('Guest User', 'Limited access for temporary users', 'guest_user', true, true)
) AS v(name, description, type, is_system_role, is_active)
WHERE NOT EXISTS (
    SELECT 1 FROM public.roles WHERE roles.name = v.name
);

-- Default System Permissions
-- =====================================================================================
INSERT INTO public.permissions (name, description, resource, action, is_system_permission)
SELECT name, description, resource, action, is_system_permission
FROM (VALUES
    -- User Management Permissions
    ('user.create', 'Create new users', 'user', 'create', true),
    ('user.read', 'View user profiles', 'user', 'read', true),
    ('user.update', 'Update user profiles', 'user', 'update', true),
    ('user.delete', 'Delete users', 'user', 'delete', true),
    ('user.restore', 'Restore deleted users', 'user', 'restore', true),
    
    -- Role Management Permissions
    ('role.create', 'Create new roles', 'role', 'create', true),
    ('role.read', 'View roles', 'role', 'read', true),
    ('role.update', 'Update roles', 'role', 'update', true),
    ('role.delete', 'Delete roles', 'role', 'delete', true),
    ('role.assign', 'Assign roles to users', 'role', 'assign', true),
    
    -- Permission Management
    ('permission.create', 'Create new permissions', 'permission', 'create', true),
    ('permission.read', 'View permissions', 'permission', 'read', true),
    ('permission.update', 'Update permissions', 'permission', 'update', true),
    ('permission.delete', 'Delete permissions', 'permission', 'delete', true),
    ('permission.assign', 'Assign permissions to roles', 'permission', 'assign', true),
    
    -- Audit Management
    ('audit.read', 'View audit logs', 'audit', 'read', true),
    ('audit.export', 'Export audit logs', 'audit', 'export', true),
    
    -- System Management
    ('system.config', 'Manage system configuration', 'system', 'config', true),
    ('system.monitor', 'Monitor system status', 'system', 'monitor', true),
    ('system.backup', 'Manage system backups', 'system', 'backup', true)
) AS v(name, description, resource, action, is_system_permission)
WHERE NOT EXISTS (
    SELECT 1 FROM public.permissions WHERE permissions.name = v.name
);

-- Role-Permission Assignments
-- =====================================================================================
-- Clear existing role-permission assignments first
DELETE FROM public.role_permissions;

-- Super Admin Role Permissions (All permissions)
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'super_admin'::role_type
AND NOT EXISTS (
    SELECT 1 FROM public.role_permissions rp
    WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- System Admin Role Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'system_admin'::role_type
AND p.name IN (
    'user.read', 'user.update',
    'role.read', 'role.update',
    'permission.read',
    'system.config', 'system.monitor', 'system.backup'
)
AND NOT EXISTS (
    SELECT 1 FROM public.role_permissions rp
    WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- User Admin Role Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'user_admin'::role_type
AND p.name IN (
    'user.create', 'user.read', 'user.update', 'user.delete', 'user.restore',
    'role.read', 'role.assign'
)
AND NOT EXISTS (
    SELECT 1 FROM public.role_permissions rp
    WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- Audit Admin Role Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'audit_admin'::role_type
AND p.name IN (
    'audit.read', 'audit.export',
    'user.read',
    'role.read',
    'permission.read',
    'system.monitor'
)
AND NOT EXISTS (
    SELECT 1 FROM public.role_permissions rp
    WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- Standard User Role Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'standard_user'::role_type
AND p.name IN (
    'user.read'
)
AND NOT EXISTS (
    SELECT 1 FROM public.role_permissions rp
    WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- Guest User Role Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'guest_user'::role_type
AND p.name IN (
    'user.read'
)
AND NOT EXISTS (
    SELECT 1 FROM public.role_permissions rp
    WHERE rp.role_id = r.id AND rp.permission_id = p.id
);


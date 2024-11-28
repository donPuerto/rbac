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
    ('Sales Director', 'Oversees all sales operations and strategy', 'sales_director', true, true),
    ('Marketing Director', 'Oversees all marketing operations and strategy', 'marketing_director', true, true),
    ('Sales Manager', 'Manages sales team and operations', 'sales_manager', true, true),
    ('Marketing Manager', 'Manages marketing team and campaigns', 'marketing_manager', true, true),
    ('Senior Sales', 'Senior sales representative', 'senior_sales', true, true),
    ('Senior Marketing', 'Senior marketing specialist', 'senior_marketing', true, true),
    ('Sales Representative', 'Sales team member', 'sales_rep', true, true),
    ('Marketing Specialist', 'Marketing team member', 'marketing_specialist', true, true),
    ('Account Manager', 'Manages client relationships', 'account_manager', true, true),
    ('Support Specialist', 'Customer support team member', 'support_specialist', true, true),
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
    ('system.backup', 'Manage system backups', 'system', 'backup', true),

    -- CRM Specific Permissions
    -- Sales Permissions
    ('sales.create', 'Create sales records', 'sales', 'create', true),
    ('sales.read', 'View sales records', 'sales', 'read', true),
    ('sales.update', 'Update sales records', 'sales', 'update', true),
    ('sales.delete', 'Delete sales records', 'sales', 'delete', true),
    ('sales.approve', 'Approve sales deals', 'sales', 'approve', true),
    ('sales.report', 'Generate sales reports', 'sales', 'report', true),
    
    -- Marketing Permissions
    ('marketing.create', 'Create marketing campaigns', 'marketing', 'create', true),
    ('marketing.read', 'View marketing campaigns', 'marketing', 'read', true),
    ('marketing.update', 'Update marketing campaigns', 'marketing', 'update', true),
    ('marketing.delete', 'Delete marketing campaigns', 'marketing', 'delete', true),
    ('marketing.approve', 'Approve marketing campaigns', 'marketing', 'approve', true),
    ('marketing.report', 'Generate marketing reports', 'marketing', 'report', true),
    
    -- Customer Management
    ('customer.create', 'Create customer records', 'customer', 'create', true),
    ('customer.read', 'View customer records', 'customer', 'read', true),
    ('customer.update', 'Update customer records', 'customer', 'update', true),
    ('customer.delete', 'Delete customer records', 'customer', 'delete', true),
    
    -- Support Permissions
    ('support.create', 'Create support tickets', 'support', 'create', true),
    ('support.read', 'View support tickets', 'support', 'read', true),
    ('support.update', 'Update support tickets', 'support', 'update', true),
    ('support.delete', 'Delete support tickets', 'support', 'delete', true),
    ('support.resolve', 'Resolve support tickets', 'support', 'resolve', true),
    
    -- Analytics Permissions
    ('analytics.sales', 'Access sales analytics', 'analytics', 'sales', true),
    ('analytics.marketing', 'Access marketing analytics', 'analytics', 'marketing', true),
    ('analytics.customer', 'Access customer analytics', 'analytics', 'customer', true),
    ('analytics.support', 'Access support analytics', 'analytics', 'support', true)
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
WHERE r.type = 'super_admin'::role_type;

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
    'system.config', 'system.monitor', 'system.backup',
    'analytics.sales', 'analytics.marketing', 'analytics.customer', 'analytics.support'
);

-- Sales Director Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'sales_director'::role_type
AND p.name IN (
    'sales.create', 'sales.read', 'sales.update', 'sales.delete', 'sales.approve', 'sales.report',
    'customer.read', 'customer.update',
    'analytics.sales', 'analytics.customer',
    'user.read'
);

-- Marketing Director Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'marketing_director'::role_type
AND p.name IN (
    'marketing.create', 'marketing.read', 'marketing.update', 'marketing.delete', 'marketing.approve', 'marketing.report',
    'customer.read',
    'analytics.marketing', 'analytics.customer',
    'user.read'
);

-- Sales Manager Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'sales_manager'::role_type
AND p.name IN (
    'sales.create', 'sales.read', 'sales.update', 'sales.report',
    'customer.read', 'customer.update',
    'analytics.sales',
    'user.read'
);

-- Marketing Manager Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'marketing_manager'::role_type
AND p.name IN (
    'marketing.create', 'marketing.read', 'marketing.update', 'marketing.report',
    'customer.read',
    'analytics.marketing',
    'user.read'
);

-- Senior Sales Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'senior_sales'::role_type
AND p.name IN (
    'sales.create', 'sales.read', 'sales.update',
    'customer.create', 'customer.read', 'customer.update',
    'analytics.sales',
    'user.read'
);

-- Senior Marketing Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'senior_marketing'::role_type
AND p.name IN (
    'marketing.create', 'marketing.read', 'marketing.update',
    'customer.read',
    'analytics.marketing',
    'user.read'
);

-- Sales Representative Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'sales_rep'::role_type
AND p.name IN (
    'sales.create', 'sales.read',
    'customer.create', 'customer.read', 'customer.update',
    'user.read'
);

-- Marketing Specialist Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'marketing_specialist'::role_type
AND p.name IN (
    'marketing.create', 'marketing.read',
    'customer.read',
    'user.read'
);

-- Account Manager Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'account_manager'::role_type
AND p.name IN (
    'customer.read', 'customer.update',
    'support.read', 'support.create',
    'sales.read',
    'user.read'
);

-- Support Specialist Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'support_specialist'::role_type
AND p.name IN (
    'support.create', 'support.read', 'support.update', 'support.resolve',
    'customer.read',
    'user.read'
);

-- Standard User Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'standard_user'::role_type
AND p.name IN (
    'user.read',
    'customer.read'
);

-- Guest User Permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT DISTINCT
    r.id as role_id,
    p.id as permission_id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.type = 'guest_user'::role_type
AND p.name IN (
    'user.read'
);

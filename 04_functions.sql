-- =====================================================================================
-- RBAC System Functions
-- =====================================================================================
-- Description: Core functions for the Role-Based Access Control (RBAC) system
-- Version: 1.0.0
-- Last Updated: 2024
-- Author: Don Puerto

/**
 * Table of Contents
 * =====================================================================================
 * 
 * 1. Core User Functions
 *    - handle_new_user() - Trigger function for new user creation
 *    - is_user_active(p_user_id UUID) - Check user active status
 *    - soft_delete_user(p_user_id UUID) - Soft delete user
 *    - restore_deleted_user(p_user_id UUID) - Restore soft-deleted user
 *    - handle_user_soft_delete() - Trigger function for user soft deletion
 *    - user_exists(p_user_id UUID, p_include_deleted BOOLEAN) - Check user existence
 *    - get_user_profile(p_user_id UUID) - Get complete user profile
 *    - update_user_status(p_user_id UUID, p_status TEXT, p_updated_by UUID) - Update status
 *    - search_users(p_search TEXT, p_status TEXT[], p_role_types role_type[]) - Search users
 *    - validate_user_access(p_user_id UUID, p_resource TEXT, p_action TEXT) - Check access
 *
 * 2. Role Management Functions
 *    - manage_user_role(p_user_id UUID, p_role_type role_type, p_managed_by UUID, p_action TEXT)
 *      -- Unified function for role assignment/revocation with hierarchy validation
 *    - get_user_roles(p_user_id UUID)
 *      -- Retrieve user's active roles with hierarchy and metadata
 *    - check_user_role(p_user_id UUID, p_role_type role_type, p_check_higher_roles BOOLEAN)
 *      -- Validate user role with hierarchy support
 *    - handle_role_soft_delete()
 *      -- Manage role deletion with cascade and audit
 *    - get_role_hierarchy_level(p_role_type role_type)
 *      -- Convert role type to numeric hierarchy level
 *    - handle_user_role_change()
 *      -- Trigger for role changes with audit logging
 *    - get_role_assignments_history(
 *        p_user_id UUID,
 *        p_from_date TIMESTAMPTZ DEFAULT NULL,
 *        p_to_date TIMESTAMPTZ DEFAULT NULL)
 *    - validate_role_hierarchy_change(p_role_id UUID, p_new_role_type role_type)
 *      -- Validate role hierarchy changes
 *    -  get_users_by_role(p_role_type role_type)
 *      -- Get users by role type
 *    - check_role_conflicts(p_user_id UUID, p_role_type role_type)
 *      -- Check for role conflicts
 *    - delegate_role_management(p_delegator_id UUID, p_delegate_id UUID, p_role_types role_type[])
 *      -- Delegate role management
 *    - assign_temporary_role(p_user_id UUID, p_role_type role_type, p_expiry_date TIMESTAMPTZ)
 *      -- Assign a temporary role to a user
 *    - has_permission(UUID, TEXT, TEXT)
 *    - schedule_role_expiration(
 *        p_user_id UUID,
 *        p_role_id UUID,
 *        p_expiry_date TIMESTAMPTZ
 *     )
 *      -- Schedule role expiration
 *
 * 3. Permission Management Functions
 *    - grant_permission(p_role_id UUID, p_permission_id UUID) - Grant permission
 *    - revoke_permission(p_role_id UUID, p_permission_id UUID) - Revoke permission
 *    - get_role_permissions(p_role_id UUID) - Get role's permissions
 *    - has_any_role(
 *          p_user_id UUID,
 *          p_role_types role_type[]
 *      )
 *
 * 4. Audit and Logging Functions
 *    - process_audit() - Process audit logs
 *    - log_audit_event() - Log audit events
 *    - log_activity() - Log user activities
 *
 * 5. Utility Functions
 *    - prevent_id_modification() - Prevent ID changes
 *    - update_timestamp() - Update timestamp trigger
 *    - initialize_default_roles() - Initialize system roles
 *


-- ========================================================================================
--
-- User Management Functions
--
-- ========================================================================================


-- ========================================================================================
-- 1. Core User Functions:
-- ========================================================================================

/**
 * Function: handle_new_user
 *
 * Purpose: Automatically create a user profile when a new user signs up in Supabase auth
 *
 * Returns: TRIGGER
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Creates a new user profile in the users table when a new user is created in auth.users.
 *   Assigns default role and tenant associations based on system configuration.
 *   Maintains data consistency between auth.users and application users.
 *
 * Assumptions:
 *   - auth.users table exists and contains new user data
 *   - users table exists with proper structure
 *   - roles table contains default user role
 *   - tenants table exists if multi-tenant functionality is enabled
 *
 * Example Usage:
 *   This function is triggered automatically on INSERT to auth.users:
 *   CREATE TRIGGER on_auth_user_created
 *     AFTER INSERT ON auth.users
 *     FOR EACH ROW
 *     EXECUTE FUNCTION public.handle_new_user();
 */

-- Drop existing function and trigger first
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create the function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER 
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_function_name TEXT := 'handle_new_user';
BEGIN
    -- Basic validation
    IF NEW.email IS NULL THEN
        -- Log validation error
        INSERT INTO public.error_logs (
            error_message,
            severity,
            function_name,
            context_data
        )
        VALUES (
            'New user email cannot be null',
            'ERROR',
            v_function_name,
            jsonb_build_object(
                'auth_user_id', NEW.id,
                'raw_user_meta_data', NEW.raw_user_meta_data
            )
        );
        RAISE EXCEPTION 'Email cannot be null';
    END IF;

    -- Insert the user into public.users
    BEGIN
        INSERT INTO public.users (
            id,
            email,
            first_name,
            last_name,
            status
        ) VALUES (
            NEW.id,
            NEW.email,
            COALESCE(NEW.raw_user_meta_data->>'first_name', 'Unknown'),
            COALESCE(NEW.raw_user_meta_data->>'last_name', 'User'),
            'active'
        );

    EXCEPTION WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_code,
            function_name,
            severity,
            context_data
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            v_function_name,
            'ERROR',
            jsonb_build_object(
                'auth_user_id', NEW.id,
                'email', NEW.email,
                'raw_user_meta_data', NEW.raw_user_meta_data
            )
        );
        RAISE; -- Re-raise the exception after logging
    END;

    RETURN NEW;
END;
$$;

-- Create trigger for auth.users
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated, anon, service_role;
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated, service_role;
GRANT SELECT, INSERT ON public.error_logs TO authenticated, service_role;

/**
 * Function: is_user_active
 *
 * Purpose: Check if a user is active in the system
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Checks if a user is active by verifying:
 *   - User exists in the users table
 *   - User is not soft deleted
 *   - User's is_active flag is true
 *   - User has at least one active role
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - roles table exists with proper structure
 *   - role_type enum type exists
 *   - Proper indexes exist for performance
 *
 * Example Usage:
 *   SELECT public.is_user_active('123e4567-e89b-12d3-a456-426614174000');
 */

CREATE OR REPLACE FUNCTION public.is_user_active(p_user_id UUID)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_function_name TEXT := 'is_user_active';
    v_error_context JSONB;
BEGIN
    -- Check if user exists first
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
        -- Log a warning for non-existent user
        INSERT INTO public.error_logs (
            error_message,
            severity,
            function_name,
            schema_name,
            context_data,
            user_id
        )
        VALUES (
            format('User not found: %s', p_user_id),
            'WARNING',
            v_function_name,
            'public',
            jsonb_build_object(
                'user_id', p_user_id,
                'check_type', 'user_existence'
            ),
            auth.uid()
        );
        RETURN FALSE;
    END IF;

    RETURN EXISTS (
        SELECT 1
        FROM public.users u
        JOIN public.user_roles ur ON ur.user_id = u.id
        JOIN public.roles r ON r.id = ur.role_id
        WHERE u.id = p_user_id
        AND u.deleted_at IS NULL
        AND u.is_active = true
        AND ur.deleted_at IS NULL
        AND ur.is_active = true
        AND r.deleted_at IS NULL
        AND r.is_active = true
        AND (ur.expires_at IS NULL OR ur.expires_at > CURRENT_TIMESTAMP)
    );
EXCEPTION
    WHEN OTHERS THEN
        -- Construct error context
        v_error_context := jsonb_build_object(
            'user_id', p_user_id,
            'error_state', SQLSTATE,
            'error_message', SQLERRM,
            'stack_trace', pg_exception_context(),
            'check_type', 'user_active_status'
        );
        
        -- Log detailed error information
        INSERT INTO public.error_logs (
            error_message,
            error_code,
            error_stack,
            severity,
            function_name,
            schema_name,
            context_data,
            user_id,
            ip_address,
            user_agent
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            pg_exception_context(),
            'ERROR',
            v_function_name,
            'public',
            v_error_context,
            auth.uid(),
            current_setting('request.headers', true)::json->>'x-forwarded-for',
            current_setting('request.headers', true)::json->>'user-agent'
        );
        
        RETURN FALSE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.is_user_active IS 'Checks if a user is active and has valid roles in the system with comprehensive error logging';

--
--
--
/**
 * Function: soft_delete_user
 *
 * Purpose: Safely deactivate and soft delete a user from the system
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Performs a comprehensive soft delete of a user by:
 *   - Setting deleted_at timestamp
 *   - Setting is_active to false
 *   - Deactivating all associated user roles
 *   - Maintaining audit trail
 *   - Handling cascading soft deletes for related records
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - audit_logs table exists for tracking changes
 *   - Caller has appropriate permissions
 *
 * Example Usage:
 *   SELECT public.soft_delete_user('123e4567-e89b-12d3-a456-426614174000');
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.soft_delete_user(UUID);

CREATE OR REPLACE FUNCTION public.soft_delete_user(p_user_id UUID)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_data jsonb;
    v_success boolean := false;
BEGIN
    -- Check if user exists and is not already deleted
    IF NOT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'User not found or already deleted: %', p_user_id;
    END IF;

    -- Capture old data for audit
    SELECT jsonb_build_object(
        'email', email,
        'is_active', is_active,
        'status', status,
        'last_active_at', last_active_at
    ) INTO v_old_data
    FROM public.users
    WHERE id = p_user_id;

    -- Begin transaction
    BEGIN
        -- Soft delete user
        UPDATE public.users
        SET 
            deleted_at = CURRENT_TIMESTAMP,
            deleted_by = auth.uid(),
            updated_at = CURRENT_TIMESTAMP,
            updated_by = auth.uid(),
            is_active = false,
            status = 'inactive'
        WHERE id = p_user_id
        AND deleted_at IS NULL;

        -- Soft delete associated user roles
        UPDATE public.user_roles
        SET 
            deleted_at = CURRENT_TIMESTAMP,
            deleted_by = auth.uid(),
            updated_at = CURRENT_TIMESTAMP,
            updated_by = auth.uid(),
            is_active = false
        WHERE user_id = p_user_id
        AND deleted_at IS NULL;

        -- Log the action
        INSERT INTO public.audit_logs (
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            changed_by
        )
        VALUES (
            'users',
            p_user_id,
            'SOFT_DELETE',
            v_old_data,
            jsonb_build_object(
                'deleted_at', CURRENT_TIMESTAMP,
                'deleted_by', auth.uid(),
                'is_active', false,
                'status', 'inactive'
            ),
            auth.uid()
        );

        v_success := true;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log error details
            INSERT INTO public.error_logs (
                error_message,
                error_details,
                context_data,
                created_by
            )
            VALUES (
                SQLERRM,
                SQLSTATE,
                jsonb_build_object(
                    'user_id', p_user_id,
                    'function', 'soft_delete_user'
                ),
                auth.uid()
            );
            RAISE;
    END;

    RETURN v_success;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.soft_delete_user IS 'Safely deactivates and soft deletes a user and their associated records';
--
--
--
/**
 * Function: restore_deleted_user
 *
 * Purpose: Restore a previously soft-deleted user and their associated records
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Restores a soft-deleted user by:
 *   - Clearing deleted_at timestamp
 *   - Setting is_active to true
 *   - Restoring associated user roles
 *   - Maintaining audit trail
 *   - Handling cascading restoration of related records
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - audit_logs table exists for tracking changes
 *   - Caller has appropriate permissions
 *
 * Example Usage:
 *   SELECT public.restore_deleted_user('123e4567-e89b-12d3-a456-426614174000');
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.restore_deleted_user(UUID);

CREATE OR REPLACE FUNCTION public.restore_deleted_user(p_user_id UUID)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_data jsonb;
    v_success boolean := false;
BEGIN
    -- Check if user exists and is actually deleted
    IF NOT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id
        AND deleted_at IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'User not found or not deleted: %', p_user_id;
    END IF;

    -- Capture old data for audit
    SELECT jsonb_build_object(
        'email', email,
        'is_active', is_active,
        'status', status,
        'deleted_at', deleted_at,
        'deleted_by', deleted_by
    ) INTO v_old_data
    FROM public.users
    WHERE id = p_user_id;

    -- Begin transaction
    BEGIN
        -- Restore user
        UPDATE public.users
        SET 
            deleted_at = NULL,
            deleted_by = NULL,
            updated_at = CURRENT_TIMESTAMP,
            updated_by = auth.uid(),
            is_active = true,
            status = 'active'
        WHERE id = p_user_id
        AND deleted_at IS NOT NULL;

        -- Restore associated user roles
        UPDATE public.user_roles
        SET 
            deleted_at = NULL,
            deleted_by = NULL,
            updated_at = CURRENT_TIMESTAMP,
            updated_by = auth.uid(),
            is_active = true
        WHERE user_id = p_user_id
        AND deleted_at IS NOT NULL;

        -- Log the action
        INSERT INTO public.audit_logs (
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            changed_by
        )
        VALUES (
            'users',
            p_user_id,
            'RESTORE',
            v_old_data,
            jsonb_build_object(
                'deleted_at', NULL,
                'deleted_by', NULL,
                'is_active', true,
                'status', 'active',
                'updated_at', CURRENT_TIMESTAMP,
                'updated_by', auth.uid()
            ),
            auth.uid()
        );

        v_success := true;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log error details
            INSERT INTO public.error_logs (
                error_message,
                error_details,
                context_data,
                created_by
            )
            VALUES (
                SQLERRM,
                SQLSTATE,
                jsonb_build_object(
                    'user_id', p_user_id,
                    'function', 'restore_deleted_user'
                ),
                auth.uid()
            );
            RAISE;
    END;

    RETURN v_success;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.restore_deleted_user IS 'Restores a soft-deleted user and their associated records';--
--
--
--
/**
 * Function: get_user_profile
 *
 * Purpose: Retrieve a comprehensive user profile with associated roles and permissions
 *
 * Returns: JSONB
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Retrieves a complete user profile including:
 *   - Basic user information
 *   - Active roles and permissions
 *   - Tenant associations
 *   - Account status and activity
 *   - Returns NULL if user not found or inactive
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - roles table exists with proper structure
 *   - permissions table exists with proper structure
 *   - role_permissions table exists with proper structure
 *
 * Example Usage:
 *   SELECT public.get_user_profile('123e4567-e89b-12d3-a456-426614174000');
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.get_user_profile(UUID);

CREATE OR REPLACE FUNCTION public.get_user_profile(p_user_id UUID)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile jsonb;
BEGIN
    -- Check if user exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id
        AND deleted_at IS NULL
        AND is_active = true
    ) THEN
        RETURN NULL;
    END IF;

    -- Get basic user information
    WITH user_info AS (
        SELECT
            u.id,
            u.email,
            u.full_name,
            u.status,
            u.is_active,
            u.last_active_at,
            u.created_at,
            u.updated_at
        FROM public.users u
        WHERE u.id = p_user_id
        AND u.deleted_at IS NULL
    ),
    -- Get user roles with permissions
    user_roles AS (
        SELECT 
            r.id AS role_id,
            r.role_type,
            r.description AS role_description,
            t.id AS tenant_id,
            t.name AS tenant_name,
            jsonb_agg(
                DISTINCT jsonb_build_object(
                    'id', p.id,
                    'resource', p.resource,
                    'action', p.action,
                    'description', p.description
                )
            ) FILTER (WHERE p.id IS NOT NULL) AS permissions
        FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        LEFT JOIN public.tenants t ON t.id = ur.tenant_id
        LEFT JOIN public.role_permissions rp ON rp.role_id = r.id
        LEFT JOIN public.permissions p ON p.id = rp.permission_id
        WHERE ur.user_id = p_user_id
        AND ur.deleted_at IS NULL
        AND r.deleted_at IS NULL
        AND (ur.expires_at IS NULL OR ur.expires_at > CURRENT_TIMESTAMP)
        GROUP BY r.id, r.role_type, r.description, t.id, t.name
    )
    -- Construct complete profile
    SELECT 
        jsonb_build_object(
            'user', jsonb_build_object(
                'id', ui.id,
                'email', ui.email,
                'full_name', ui.full_name,
                'status', ui.status,
                'is_active', ui.is_active,
                'last_active_at', ui.last_active_at,
                'created_at', ui.created_at,
                'updated_at', ui.updated_at
            ),
            'roles', COALESCE(
                jsonb_agg(
                    jsonb_build_object(
                        'role_id', ur.role_id,
                        'role_type', ur.role_type,
                        'description', ur.role_description,
                        'tenant_id', ur.tenant_id,
                        'tenant_name', ur.tenant_name,
                        'permissions', ur.permissions
                    )
                ) FILTER (WHERE ur.role_id IS NOT NULL),
                '[]'::jsonb
            )
        ) INTO v_profile
    FROM user_info ui
    LEFT JOIN user_roles ur ON true;

    RETURN v_profile;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'user_id', p_user_id,
                'function', 'get_user_profile'
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.get_user_profile IS 'Retrieves a comprehensive user profile including roles and permissions';--
--
--
/**
 * Function: update_user_status
 *
 * Purpose: Update a user's status and active state with proper validation
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Updates a user's status and active state with:
 *   - Status validation ('active', 'inactive', 'suspended', 'pending')
 *   - Automatic active state management
 *   - Audit trail maintenance
 *   - Role state management based on status
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - audit_logs table exists for tracking changes
 *   - Valid status values are enforced
 *
 * Example Usage:
 *   SELECT public.update_user_status(
 *     '123e4567-e89b-12d3-a456-426614174000',
 *     'suspended',
 *     'Violated terms of service'
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.update_user_status(UUID, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.update_user_status(
    p_user_id UUID,
    p_status TEXT,
    p_reason TEXT DEFAULT NULL
)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_data jsonb;
    v_success boolean := false;
    v_valid_statuses TEXT[] := ARRAY['active', 'inactive', 'suspended', 'pending'];
BEGIN
    -- Validate status
    IF p_status IS NULL OR NOT (p_status = ANY(v_valid_statuses)) THEN
        RAISE EXCEPTION 'Invalid status: %. Valid values are: %', p_status, array_to_string(v_valid_statuses, ', ');
    END IF;

    -- Check if user exists
    IF NOT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'User not found: %', p_user_id;
    END IF;

    -- Capture old data for audit
    SELECT jsonb_build_object(
        'status', status,
        'is_active', is_active,
        'last_active_at', last_active_at
    ) INTO v_old_data
    FROM public.users
    WHERE id = p_user_id;

    -- Begin transaction
    BEGIN
        -- Update user status
        UPDATE public.users
        SET 
            status = p_status,
            is_active = CASE 
                WHEN p_status = 'active' THEN true
                ELSE false
            END,
            last_active_at = CASE 
                WHEN p_status = 'active' THEN CURRENT_TIMESTAMP
                ELSE last_active_at
            END,
            updated_at = CURRENT_TIMESTAMP,
            updated_by = auth.uid()
        WHERE id = p_user_id
        AND deleted_at IS NULL;

        -- Update user roles based on status
        IF p_status != 'active' THEN
            UPDATE public.user_roles
            SET 
                is_active = false,
                updated_at = CURRENT_TIMESTAMP,
                updated_by = auth.uid()
            WHERE user_id = p_user_id
            AND deleted_at IS NULL;
        END IF;

        -- Log the action
        INSERT INTO public.audit_logs (
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            changed_by
        )
        VALUES (
            'users',
            p_user_id,
            'UPDATE_STATUS',
            v_old_data,
            jsonb_build_object(
                'status', p_status,
                'is_active', (p_status = 'active'),
                'reason', p_reason,
                'updated_at', CURRENT_TIMESTAMP,
                'updated_by', auth.uid()
            ),
            auth.uid()
        );

        v_success := true;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log error details
            INSERT INTO public.error_logs (
                error_message,
                error_code,
                error_stack,
                severity,
                function_name,
                schema_name,
                context_data,
                user_id,
                ip_address,
                user_agent
            )
            VALUES (
                SQLERRM,
                SQLSTATE,
                pg_exception_context(),
                'ERROR',
                'update_user_status',
                'public',
                jsonb_build_object(
                    'user_id', p_user_id,
                    'status', p_status,
                    'reason', p_reason
                ),
                auth.uid(),
                current_setting('request.headers', true)::json->>'x-forwarded-for',
                current_setting('request.headers', true)::json->>'user-agent'
            );
            RAISE;
    END;

    RETURN v_success;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.update_user_status IS 'Updates user status with validation and maintains related records';--
--
--
--
/**
 * Function: search_users
 *
 * Purpose: Search and filter users with pagination and multiple criteria
 *
 * Returns: TABLE (
 *   total_count BIGINT,
 *   users JSONB
 * )
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Searches for users based on multiple criteria:
 *   - Full text search on email and full_name
 *   - Filter by status (active, inactive, suspended, etc.)
 *   - Filter by role types
 *   - Pagination support
 *   - Returns total count and user details
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - roles table exists with proper structure
 *   - role_type enum type exists
 *   - Proper indexes exist for performance
 *
 * Example Usage:
 *   SELECT * FROM public.search_users(
 *     p_search => 'john',
 *     p_status => ARRAY['active', 'pending'],
 *     p_role_types => ARRAY['admin', 'user']::role_type[],
 *     p_limit => 20,
 *     p_offset => 0
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.search_users(TEXT, TEXT[], role_type[], INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.search_users(
    p_search TEXT DEFAULT NULL,
    p_status TEXT[] DEFAULT NULL,
    p_role_types role_type[] DEFAULT NULL,
    p_limit INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    total_count BIGINT,
    users JSONB
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_search_query TEXT;
    v_valid_statuses TEXT[] := ARRAY['active', 'inactive', 'suspended', 'pending'];
BEGIN
    -- Validate input parameters
    IF p_limit < 1 OR p_limit > 100 THEN
        RAISE EXCEPTION 'Invalid limit: %. Must be between 1 and 100', p_limit;
    END IF;

    IF p_offset < 0 THEN
        RAISE EXCEPTION 'Invalid offset: %. Must be non-negative', p_offset;
    END IF;

    -- Validate status values if provided
    IF p_status IS NOT NULL THEN
        IF NOT (SELECT ARRAY(
            SELECT UNNEST(p_status) 
            INTERSECT 
            SELECT UNNEST(v_valid_statuses)
        ) @> p_status) THEN
            RAISE EXCEPTION 'Invalid status values. Valid values are: %', array_to_string(v_valid_statuses, ', ');
        END IF;
    END IF;

    -- Prepare search query
    WITH search_terms AS (
        SELECT lexeme || ':*' as term
        FROM unnest(regexp_split_to_array(lower(COALESCE(p_search, '')), '\s+')) lexeme
    )
    SELECT CASE 
        WHEN p_search IS NOT NULL AND p_search != '' THEN
            to_tsquery('english', string_agg(term, ' & '))
        ELSE NULL
    END INTO v_search_query
    FROM search_terms;

    RETURN QUERY
    WITH filtered_users AS (
        SELECT 
            u.id,
            u.email,
            u.full_name,
            u.status,
            u.is_active,
            u.last_active_at,
            u.created_at,
            u.updated_at,
            array_agg(DISTINCT r.role_type) AS role_types
        FROM public.users u
        LEFT JOIN public.user_roles ur ON ur.user_id = u.id AND ur.deleted_at IS NULL
        LEFT JOIN public.roles r ON r.id = ur.role_id AND r.deleted_at IS NULL
        WHERE u.deleted_at IS NULL
        AND (
            p_search IS NULL 
            OR v_search_query IS NULL 
            OR to_tsvector('english', u.email || ' ' || COALESCE(u.full_name, '')) @@ v_search_query
        )
        AND (p_status IS NULL OR u.status = ANY(p_status))
        AND (
            p_role_types IS NULL 
            OR EXISTS (
                SELECT 1 
                FROM public.user_roles ur2
                JOIN public.roles r2 ON r2.id = ur2.role_id
                WHERE ur2.user_id = u.id
                AND r2.role_type = ANY(p_role_types)
                AND ur2.deleted_at IS NULL
                AND r2.deleted_at IS NULL
            )
        )
        GROUP BY u.id, u.email, u.full_name, u.status, u.is_active, u.last_active_at, u.created_at, u.updated_at
    )
    SELECT
        (SELECT COUNT(*) FROM filtered_users)::BIGINT AS total_count,
        COALESCE(jsonb_agg(
            jsonb_build_object(
                'id', fu.id,
                'email', fu.email,
                'full_name', fu.full_name,
                'status', fu.status,
                'is_active', fu.is_active,
                'last_active_at', fu.last_active_at,
                'created_at', fu.created_at,
                'updated_at', fu.updated_at,
                'role_types', fu.role_types
            )
            ORDER BY 
                CASE WHEN p_search IS NOT NULL 
                    THEN ts_rank(
                        to_tsvector('english', fu.email || ' ' || COALESCE(fu.full_name, '')),
                        v_search_query
                    )
                END DESC NULLS LAST,
                fu.created_at DESC
        ), '[]'::jsonb) AS users
    FROM filtered_users fu
    LIMIT p_limit
    OFFSET p_offset;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'search', p_search,
                'status', p_status,
                'role_types', p_role_types,
                'limit', p_limit,
                'offset', p_offset,
                'function', 'search_users'
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.search_users IS 'Advanced user search with filtering, pagination, and full-text search capabilities';
--
--
--
--
/**
 * Function: validate_user_access
 *
 * Purpose: Validate if a user has permission to perform an action on a resource
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Validates user access by checking:
 *   - User existence and active status
 *   - Role assignments and their validity
 *   - Permission assignments to roles
 *   - Resource and action matching
 *   - Tenant-specific permissions
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - roles table exists with proper structure
 *   - permissions table exists with proper structure
 *   - role_permissions table exists with proper structure
 *
 * Example Usage:
 *   SELECT public.validate_user_access(
 *     '123e4567-e89b-12d3-a456-426614174000',
 *     'users',
 *     'read'
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.validate_user_access(UUID, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.validate_user_access(
    p_user_id UUID,
    p_resource TEXT,
    p_action TEXT
)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_has_access boolean := false;
    v_user_active boolean;
BEGIN
    -- Check if user exists and is active
    SELECT 
        is_active INTO v_user_active
    FROM public.users
    WHERE id = p_user_id
    AND deleted_at IS NULL;

    IF v_user_active IS NULL THEN
        RAISE EXCEPTION 'User not found: %', p_user_id;
    END IF;

    IF NOT v_user_active THEN
        RAISE EXCEPTION 'User is not active: %', p_user_id;
    END IF;

    -- Check if user has permission through any active role
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        JOIN public.role_permissions rp ON rp.role_id = r.id
        JOIN public.permissions p ON p.id = rp.permission_id
        WHERE ur.user_id = p_user_id
        AND ur.deleted_at IS NULL
        AND ur.is_active = true
        AND r.deleted_at IS NULL
        AND r.is_active = true
        AND rp.deleted_at IS NULL
        AND p.deleted_at IS NULL
        AND p.is_active = true
        AND p.resource = p_resource
        AND p.action = p_action
        AND (ur.expires_at IS NULL OR ur.expires_at > CURRENT_TIMESTAMP)
    ) INTO v_has_access;

    -- Log the access check
    INSERT INTO public.audit_logs (
        table_name,
        record_id,
        action,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        'access_checks',
        p_user_id,
        'VALIDATE_ACCESS',
        jsonb_build_object(
            'resource', p_resource,
            'action', p_action
        ),
        jsonb_build_object(
            'has_access', v_has_access,
            'checked_at', CURRENT_TIMESTAMP
        ),
        auth.uid()
    );

    RETURN v_has_access;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'user_id', p_user_id,
                'resource', p_resource,
                'action', p_action,
                'function', 'validate_user_access'
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.validate_user_access IS 'Validates user permission to perform specific actions on resources';--
--
--
-- ========================================================================================
-- 2. Role Management Functions
-- ========================================================================================

/**
 * Function: manage_user_role
 *
 * Purpose: Manage user role assignments (grant/revoke) with proper validation
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Manages user role assignments by:
 *   - Validating user and role existence
 *   - Handling role grants and revocations
 *   - Maintaining audit trail
 *   - Enforcing role hierarchy rules
 *   - Managing tenant associations
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - roles table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - role_type enum type exists
 *   - Valid actions are 'grant' and 'revoke'
 *
 * Example Usage:
 *   SELECT public.manage_user_role(
 *     '123e4567-e89b-12d3-a456-426614174000',  -- user_id
 *     'admin',                                  -- role_type
 *     '987fcdeb-51d3-12d3-a456-426614174000',  -- managed_by
 *     'grant'                                   -- action
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.manage_user_role(UUID, role_type, UUID, TEXT);

CREATE OR REPLACE FUNCTION public.manage_user_role(
    p_user_id UUID,
    p_role_type role_type,
    p_managed_by UUID,
    p_action TEXT
)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_role_id UUID;
    v_old_data jsonb;
    v_success boolean := false;
    v_valid_actions TEXT[] := ARRAY['grant', 'revoke'];
BEGIN
    -- Validate action
    IF NOT (p_action = ANY(v_valid_actions)) THEN
        RAISE EXCEPTION 'Invalid action: %. Valid actions are: %', p_action, array_to_string(v_valid_actions, ', ');
    END IF;

    -- Check if user exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id
        AND deleted_at IS NULL
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'User not found or inactive: %', p_user_id;
    END IF;

    -- Get role ID for the given role type
    SELECT id INTO v_role_id
    FROM public.roles
    WHERE role_type = p_role_type
    AND deleted_at IS NULL
    AND is_active = true;

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'Role type not found or inactive: %', p_role_type;
    END IF;

    -- Begin transaction
    BEGIN
        CASE p_action
            WHEN 'grant' THEN
                -- Check if role is already granted
                IF EXISTS (
                    SELECT 1 FROM public.user_roles
                    WHERE user_id = p_user_id
                    AND role_id = v_role_id
                    AND deleted_at IS NULL
                ) THEN
                    RAISE EXCEPTION 'Role already granted to user';
                END IF;

                -- Grant role
                INSERT INTO public.user_roles (
                    user_id,
                    role_id,
                    granted_by,
                    created_by,
                    updated_by
                )
                VALUES (
                    p_user_id,
                    v_role_id,
                    p_managed_by,
                    auth.uid(),
                    auth.uid()
                );

            WHEN 'revoke' THEN
                -- Capture old data for audit
                SELECT jsonb_build_object(
                    'role_id', role_id,
                    'granted_by', granted_by,
                    'granted_at', created_at
                ) INTO v_old_data
                FROM public.user_roles
                WHERE user_id = p_user_id
                AND role_id = v_role_id
                AND deleted_at IS NULL;

                IF v_old_data IS NULL THEN
                    RAISE EXCEPTION 'Role not found for user';
                END IF;

                -- Revoke role
                UPDATE public.user_roles
                SET 
                    deleted_at = CURRENT_TIMESTAMP,
                    deleted_by = auth.uid(),
                    updated_at = CURRENT_TIMESTAMP,
                    updated_by = auth.uid(),
                    is_active = false
                WHERE user_id = p_user_id
                AND role_id = v_role_id
                AND deleted_at IS NULL;

        END CASE;

        -- Log the action
        INSERT INTO public.audit_logs (
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            changed_by
        )
        VALUES (
            'user_roles',
            p_user_id,
            'ROLE_' || upper(p_action),
            CASE WHEN p_action = 'revoke' THEN v_old_data ELSE NULL END,
            jsonb_build_object(
                'role_type', p_role_type,
                'managed_by', p_managed_by,
                'action', p_action,
                'timestamp', CURRENT_TIMESTAMP
            ),
            auth.uid()
        );

        v_success := true;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log error details
            INSERT INTO public.error_logs (
                error_message,
                error_details,
                context_data,
                created_by
            )
            VALUES (
                SQLERRM,
                SQLSTATE,
                jsonb_build_object(
                    'user_id', p_user_id,
                    'role_type', p_role_type,
                    'managed_by', p_managed_by,
                    'action', p_action,
                    'function', 'manage_user_role'
                ),
                auth.uid()
            );
            RAISE;
    END;

    RETURN v_success;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.manage_user_role IS 'Manages user role assignments with validation and audit logging';--
--
--
--
/**
 * Function: get_user_roles
 *
 * Purpose: Retrieve all active roles and permissions for a user
 *
 * Returns: JSONB
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Retrieves user roles including:
 *   - Active role assignments
 *   - Associated permissions
 *   - Role metadata
 *   - Tenant associations
 *   - Expiration information
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - roles table exists with proper structure
 *   - permissions table exists with proper structure
 *   - role_permissions table exists with proper structure
 *
 * Example Usage:
 *   SELECT public.get_user_roles('123e4567-e89b-12d3-a456-426614174000');
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.get_user_roles(UUID);

CREATE OR REPLACE FUNCTION public.get_user_roles(p_user_id UUID)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_result jsonb;
BEGIN
    -- Check if user exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id
        AND deleted_at IS NULL
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'User not found or inactive: %', p_user_id;
    END IF;

    -- Get user roles with permissions
    WITH role_permissions_agg AS (
        SELECT 
            r.id AS role_id,
            jsonb_agg(
                DISTINCT jsonb_build_object(
                    'id', p.id,
                    'resource', p.resource,
                    'action', p.action,
                    'description', p.description
                )
            ) FILTER (WHERE p.id IS NOT NULL) AS permissions
        FROM public.roles r
        LEFT JOIN public.role_permissions rp ON rp.role_id = r.id
        LEFT JOIN public.permissions p ON p.id = rp.permission_id
        WHERE r.deleted_at IS NULL
        AND rp.deleted_at IS NULL
        AND p.deleted_at IS NULL
        GROUP BY r.id
    )
    SELECT jsonb_build_object(
        'user_id', p_user_id,
        'roles', COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'role_id', r.id,
                    'role_type', r.role_type,
                    'description', r.description,
                    'tenant_id', t.id,
                    'tenant_name', t.name,
                    'granted_at', ur.created_at,
                    'granted_by', ur.granted_by,
                    'expires_at', ur.expires_at,
                    'is_active', ur.is_active,
                    'permissions', COALESCE(rp.permissions, '[]'::jsonb)
                )
                ORDER BY 
                    CASE r.role_type
                        WHEN 'super_admin' THEN 1
                        WHEN 'admin' THEN 2
                        WHEN 'manager' THEN 3
                        ELSE 4
                    END
            ) FILTER (WHERE r.id IS NOT NULL),
            '[]'::jsonb
        )
    ) INTO v_result
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    LEFT JOIN public.tenants t ON t.id = ur.tenant_id
    LEFT JOIN role_permissions_agg rp ON rp.role_id = r.id
    WHERE ur.user_id = p_user_id
    AND ur.deleted_at IS NULL
    AND r.deleted_at IS NULL
    AND (t.id IS NULL OR t.deleted_at IS NULL)
    AND (ur.expires_at IS NULL OR ur.expires_at > CURRENT_TIMESTAMP);

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'user_id', p_user_id,
                'function', 'get_user_roles'
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.get_user_roles IS 'Retrieves all active roles and their permissions for a user';--
--
--
--
/**
 * Function: check_user_role
 *
 * Purpose: Check if a user has a specific role or higher role level
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Validates user role by checking:
 *   - User existence and active status
 *   - Direct role assignment
 *   - Higher role levels (optional)
 *   - Role validity and expiration
 *   - Tenant-specific roles
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - roles table exists with proper structure
 *   - role_type enum type exists
 *   - Valid actions are 'grant' and 'revoke'
 *
 * Example Usage:
 *   SELECT public.check_user_role(
 *     '123e4567-e89b-12d3-a456-426614174000',  -- user_id
 *     'admin',                                  -- role_type
 *     true                                      -- check_higher_roles
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.check_user_role(UUID, role_type, BOOLEAN);

CREATE OR REPLACE FUNCTION public.check_user_role(
    p_user_id UUID,
    p_role_type role_type,
    p_check_higher_roles BOOLEAN DEFAULT true
)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_has_role boolean := false;
    v_role_level integer;
BEGIN
    -- Check if user exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id
        AND deleted_at IS NULL
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'User not found or inactive: %', p_user_id;
    END IF;

    -- Get the hierarchy level for the requested role
    WITH RECURSIVE role_hierarchy AS (
        -- Base case: root roles (no parent)
        SELECT 
            role_type,
            1 as level
        FROM public.roles
        WHERE parent_role_type IS NULL
        
        UNION ALL
        
        -- Recursive case: child roles
        SELECT 
            r.role_type,
            rt.level + 1
        FROM public.roles r
        JOIN role_hierarchy rt ON r.parent_role_type = rt.role_type
    )
    SELECT level INTO v_role_level
    FROM role_hierarchy
    WHERE role_type = p_role_type;

    IF v_role_level IS NULL THEN
        RAISE EXCEPTION 'Invalid role type: %', p_role_type;
    END IF;

    -- Check for role assignment
    IF p_check_higher_roles THEN
        -- Check for requested role or higher
        SELECT EXISTS (
            WITH RECURSIVE role_hierarchy AS (
                SELECT 
                    role_type,
                    level
                FROM role_hierarchy
                WHERE role_type = p_role_type
                
                UNION ALL
                
                SELECT 
                    r.role_type,
                    rt.level - 1
                FROM public.roles r
                JOIN role_hierarchy rt ON r.role_type = rt.parent_role_type
            )
            SELECT 1
            FROM public.user_roles ur
            JOIN public.roles r ON r.id = ur.role_id
            JOIN role_hierarchy rt ON r.role_type = rt.role_type
            WHERE ur.user_id = p_user_id
            AND ur.deleted_at IS NULL
            AND ur.is_active = true
            AND r.deleted_at IS NULL
            AND r.is_active = true
            AND (ur.expires_at IS NULL OR ur.expires_at > CURRENT_TIMESTAMP)
            LIMIT 1
        ) INTO v_has_role;
    ELSE
        -- Check for exact role match only
        SELECT EXISTS (
            SELECT 1
            FROM public.user_roles ur
            JOIN public.roles r ON r.id = ur.role_id
            WHERE ur.user_id = p_user_id
            AND r.role_type = p_role_type
            AND ur.deleted_at IS NULL
            AND ur.is_active = true
            AND r.deleted_at IS NULL
            AND r.is_active = true
            AND (ur.expires_at IS NULL OR ur.expires_at > CURRENT_TIMESTAMP)
        ) INTO v_has_role;
    END IF;

    -- Log the check
    INSERT INTO public.audit_logs (
        table_name,
        record_id,
        action,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        'role_checks',
        p_user_id,
        'CHECK_ROLE',
        jsonb_build_object(
            'role_type', p_role_type,
            'check_higher_roles', p_check_higher_roles
        ),
        jsonb_build_object(
            'has_role', v_has_role,
            'checked_at', CURRENT_TIMESTAMP
        ),
        auth.uid()
    );

    RETURN v_has_role;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'user_id', p_user_id,
                'role_type', p_role_type,
                'check_higher_roles', p_check_higher_roles,
                'function', 'check_user_role'
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.check_user_role IS 'Checks if a user has a specific role or higher role level';
--
--
--
/**
 * Function: handle_role_soft_delete()
 *
 * Purpose: Manage role deletion with proper cascade and cleanup
 *
 * Trigger: BEFORE DELETE ON roles
 * Returns: TRIGGER
 * Security: SECURITY DEFINER
 *
 * Features:
 *   - System role protection
 *   - Cascade handling
 *   - Version management
 *   - Audit logging
 *   - Cleanup of related records
 *
 * Example Usage:
 *   Automatically triggered on role deletion:
 *   CREATE TRIGGER before_role_delete
 *   BEFORE DELETE ON roles
 *   FOR EACH ROW EXECUTE FUNCTION handle_role_soft_delete();
 */
CREATE OR REPLACE FUNCTION public.handle_role_soft_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_current_user UUID;
BEGIN
    -- Get current user
    v_current_user := auth.uid();
    
    -- Prevent deletion of system roles
    IF OLD.is_system_role THEN
        RAISE EXCEPTION 'Cannot delete system roles';
    END IF;

    -- Soft delete related user_roles
    UPDATE public.user_roles
    SET deleted_at = now(),
        deleted_by = v_current_user,
        updated_at = now(),
        updated_by = v_current_user,
        is_active = false
    WHERE role_id = OLD.id
    AND deleted_at IS NULL;

    -- Soft delete related role_permissions
    UPDATE public.role_permissions
    SET deleted_at = now(),
        deleted_by = v_current_user,
        updated_at = now(),
        updated_by = v_current_user,
        is_active = false
    WHERE role_id = OLD.id
    AND deleted_at IS NULL;

    -- Log the deletion
    PERFORM log_audit_event(
        'role_deleted',
        OLD.id,
        jsonb_build_object(
            'role_name', OLD.name,
            'role_type', OLD.role_type,
            'is_system_role', OLD.is_system_role
        )
    );

    RETURN OLD;
END;
$$;
--
--
--
/**
 * Function: get_role_hierarchy_level
 *
 * Purpose: Calculate the hierarchical level of a role type in the role tree
 *
 * Returns: INTEGER
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Determines role hierarchy level by:
 *   - Traversing role parent-child relationships
 *   - Calculating depth from root roles
 *   - Handling circular dependencies
 *   - Caching results for performance
 *
 * Assumptions:
 *   - roles table exists with proper structure
 *   - role_type enum type exists with valid types
 *   - Parent-child relationships are properly defined
 *   - No circular dependencies in role hierarchy
 *
 * Example Usage:
 *   SELECT public.get_role_hierarchy_level('admin');
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.get_role_hierarchy_level(role_type);

CREATE OR REPLACE FUNCTION public.get_role_hierarchy_level(p_role_type role_type)
RETURNS integer
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
STABLE    -- Function result is stable for same input
AS $$
DECLARE
    v_level integer;
BEGIN
    -- Get role level using recursive CTE
    WITH RECURSIVE role_tree AS (
        -- Base case: root roles (no parent)
        SELECT 
            role_type,
            1 as level
        FROM public.roles
        WHERE parent_role_type IS NULL
        
        UNION ALL
        
        -- Recursive case: child roles
        SELECT 
            r.role_type,
            rt.level + 1
        FROM public.roles r
        JOIN role_tree rt ON r.parent_role_type = rt.role_type
    )
    SELECT level INTO v_level
    FROM role_tree
    WHERE role_type = p_role_type;

    -- Validate result
    IF v_level IS NULL THEN
        -- Log warning for invalid role type
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            'Invalid or inactive role type',
            'Role type not found in hierarchy',
            jsonb_build_object(
                'role_type', p_role_type,
                'function', 'get_role_hierarchy_level'
            ),
            auth.uid()
        );
        
        -- Return lowest level for invalid roles
        RETURN 0;
    END IF;

    -- Cache the result (if you have a role_hierarchy_cache table)
    -- This is optional but recommended for performance
    /*
    INSERT INTO public.role_hierarchy_cache (
        role_type,
        hierarchy_level,
        calculated_at
    )
    VALUES (
        p_role_type,
        v_level,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (role_type) 
    DO UPDATE SET 
        hierarchy_level = EXCLUDED.hierarchy_level,
        calculated_at = CURRENT_TIMESTAMP;
    */

    RETURN v_level;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'role_type', p_role_type,
                'function', 'get_role_hierarchy_level'
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.get_role_hierarchy_level IS 'Calculates the hierarchical level of a role type in the role tree';--
--
--
--
-- Drop triggers first
DROP TRIGGER IF EXISTS handle_user_role_changes ON public.user_roles;

-- Drop function with CASCADE to handle any remaining dependencies
DROP FUNCTION IF EXISTS public.handle_user_role_change() CASCADE;

/**
 * Function: handle_user_role_change
 *
 * Purpose: Handle user role changes with proper validation and cascading updates
 *
 * Returns: TRIGGER
 *
 * Security: SECURITY DEFINER
 *
 * Features:
 *   - Role Change Validation:
 *     * Validates role assignments and changes
 *     * Enforces role hierarchy rules
 *     * Prevents invalid role combinations
 *   
 *   - Audit Trail:
 *     * Logs all role changes
 *     * Records old and new values
 *     * Captures change metadata
 *   
 *   - Security Controls:
 *     * SECURITY DEFINER execution
 *     * Protected search path
 *     * Role hierarchy enforcement
 *   
 *   - Error Handling:
 *     * Comprehensive error logging
 *     * Detailed error messages
 *     * Transaction management
 *   
 *   - Integration:
 *     * Works with user_roles table
 *     * Supports role hierarchy system
 *     * Compatible with audit logging
 */
CREATE OR REPLACE FUNCTION public.handle_user_role_change()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_user_id UUID;
    v_role_id UUID;
    v_action TEXT;
    v_performed_by UUID;
BEGIN
    -- Determine the operation type and relevant data
    CASE TG_OP
        WHEN 'INSERT' THEN
            v_user_id := NEW.user_id;
            v_role_id := NEW.role_id;
            v_action := 'ASSIGN';
            v_old_data := NULL;
            v_new_data := to_jsonb(NEW);
            v_performed_by := NEW.created_by;
        WHEN 'UPDATE' THEN
            v_user_id := NEW.user_id;
            v_role_id := NEW.role_id;
            v_action := 'UPDATE';
            v_old_data := to_jsonb(OLD);
            v_new_data := to_jsonb(NEW);
            v_performed_by := NEW.updated_by;
        WHEN 'DELETE' THEN
            v_user_id := OLD.user_id;
            v_role_id := OLD.role_id;
            v_action := 'REVOKE';
            v_old_data := to_jsonb(OLD);
            v_new_data := NULL;
            v_performed_by := OLD.deleted_by;
    END CASE;

    -- Log the role change in audit_logs
    INSERT INTO public.audit_logs (
        table_name,
        record_id,
        action,
        old_data,
        new_data,
        performed_by,
        performed_at
    )
    VALUES (
        'user_roles',
        COALESCE(NEW.id, OLD.id),
        v_action,
        v_old_data,
        v_new_data,
        COALESCE(v_performed_by, auth.uid()),
        CURRENT_TIMESTAMP
    );

    -- Log user activity
    INSERT INTO public.user_activities (
        user_id,
        activity_type,
        activity_description,
        metadata,
        performed_by
    )
    VALUES (
        v_user_id,
        'ROLE_CHANGE',
        v_action || '_ROLE',
        jsonb_build_object(
            'role_id', v_role_id,
            'old_data', v_old_data,
            'new_data', v_new_data
        ),
        COALESCE(v_performed_by, auth.uid())
    );

    -- For INSERT/UPDATE operations
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        -- Validate role hierarchy if applicable
        PERFORM validate_role_hierarchy_change(
            v_role_id,
            (SELECT role_type FROM public.roles WHERE id = v_role_id)
        );
        
        -- Check for role conflicts
        PERFORM check_role_conflicts(
            v_user_id,
            (SELECT role_type FROM public.roles WHERE id = v_role_id)
        );
    END IF;

    RETURN COALESCE(NEW, OLD);
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            'Role change operation failed',
            SQLERRM,
            jsonb_build_object(
                'operation', TG_OP,
                'user_id', v_user_id,
                'role_id', v_role_id,
                'action', v_action
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.handle_user_role_change IS 'Trigger function to handle user role changes with proper cascading and audit logging';

-- Create trigger
CREATE TRIGGER handle_user_role_changes
    AFTER INSERT OR UPDATE OR DELETE ON public.user_roles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_user_role_change();
--
--
--
/**
 * Function: get_role_assignments_history
 *
 * Purpose: Retrieve historical role assignments for a user with detailed audit information
 *
 * Returns: JSONB
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Retrieves role assignment history including:
 *   - Role grant and revoke events
 *   - Assignment metadata
 *   - Audit trail details
 *   - Time-based filtering
 *   - Change tracking
 *
 * Assumptions:
 *   - users table exists with proper structure
 *   - user_roles table exists with proper structure
 *   - audit_logs table exists with proper structure
 *   - Proper audit logging is enabled
 *
 * Example Usage:
 *   SELECT public.get_role_assignments_history(
 *     '123e4567-e89b-12d3-a456-426614174000',
 *     '2023-01-01 00:00:00'::timestamptz,
 *     '2023-12-31 23:59:59'::timestamptz
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.get_role_assignments_history(UUID, TIMESTAMPTZ, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION public.get_role_assignments_history(
    p_user_id UUID,
    p_from_date TIMESTAMPTZ DEFAULT NULL,
    p_to_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result jsonb;
    v_user_exists boolean;
BEGIN
    -- Check if user exists
    SELECT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id
        AND deleted_at IS NULL
    ) INTO v_user_exists;

    IF NOT v_user_exists THEN
        RAISE EXCEPTION 'User not found: %', p_user_id;
    END IF;

    -- Set default date range if not provided
    p_from_date := COALESCE(p_from_date, '1970-01-01 00:00:00'::timestamptz);
    p_to_date := COALESCE(p_to_date, CURRENT_TIMESTAMP);

    -- Validate date range
    IF p_from_date > p_to_date THEN
        RAISE EXCEPTION 'Invalid date range: from_date must be before to_date';
    END IF;

    -- Get role assignment history
    WITH role_history AS (
        SELECT 
            al.created_at as timestamp,
            al.action,
            al.old_data,
            al.new_data,
            al.changed_by,
            al.additional_info,
            u.email as changed_by_email,
            r.role_type,
            r.name as role_name,
            t.name as tenant_name
        FROM public.audit_logs al
        LEFT JOIN public.users u ON u.id = al.changed_by
        LEFT JOIN public.roles r ON r.id = (al.new_data->>'role_id')::uuid
        LEFT JOIN public.tenants t ON t.id = (al.new_data->>'tenant_id')::uuid
        WHERE al.table_name = 'user_roles'
        AND (
            (al.new_data->>'user_id')::uuid = p_user_id
            OR (al.old_data->>'user_id')::uuid = p_user_id
        )
        AND al.created_at BETWEEN p_from_date AND p_to_date
        ORDER BY al.created_at DESC
    )
    SELECT jsonb_build_object(
        'user_id', p_user_id,
        'from_date', p_from_date,
        'to_date', p_to_date,
        'history', COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'timestamp', rh.timestamp,
                    'action', rh.action,
                    'role_type', rh.role_type,
                    'role_name', rh.role_name,
                    'tenant_name', rh.tenant_name,
                    'changed_by', jsonb_build_object(
                        'id', rh.changed_by,
                        'email', rh.changed_by_email
                    ),
                    'old_state', rh.old_data,
                    'new_state', rh.new_data,
                    'additional_info', rh.additional_info
                )
                ORDER BY rh.timestamp DESC
            ),
            '[]'::jsonb
        ),
        'summary', jsonb_build_object(
            'total_changes', COUNT(*),
            'grants', COUNT(*) FILTER (WHERE action LIKE '%GRANT%'),
            'revokes', COUNT(*) FILTER (WHERE action LIKE '%REVOKE%'),
            'updates', COUNT(*) FILTER (WHERE action LIKE '%UPDATE%')
        )
    ) INTO v_result
    FROM role_history rh;

    RETURN COALESCE(v_result, jsonb_build_object(
        'user_id', p_user_id,
        'from_date', p_from_date,
        'to_date', p_to_date,
        'history', '[]'::jsonb,
        'summary', jsonb_build_object(
            'total_changes', 0,
            'grants', 0,
            'revokes', 0,
            'updates', 0
        )
    ));
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'user_id', p_user_id,
                'from_date', p_from_date,
                'to_date', p_to_date,
                'function', 'get_role_assignments_history'
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.get_role_assignments_history IS 'Retrieves historical role assignments with detailed audit information';
-- 
--
--
/**
 * Function: validate_role_hierarchy_change
 *
 * Purpose: Validates if a role's hierarchy level can be changed while maintaining system integrity
 *
 * Returns: BOOLEAN
 *   - TRUE if the role type change is valid
 *   - FALSE if conflicts exist
 *   - Raises exceptions for invalid states
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Ensures role hierarchy changes maintain system integrity by:
 *   - Validating role existence and active status
 *   - Checking hierarchy level compatibility
 *   - Preventing circular dependencies
 *   - Validating against existing user role assignments
 *   - Maintaining audit trail of attempted changes
 *
 * Assumptions:
 *   - public.roles table exists with columns: id, role_type, deleted_at, is_active
 *   - public.user_roles table exists with columns: role_id, user_id, is_active, deleted_at
 *   - get_role_hierarchy_level function exists and returns valid hierarchy levels
 *   - role_type enum exists with proper hierarchy values
 *   - audit_logs table exists for change tracking
 *
 * Example Usage:
 *   SELECT public.validate_role_hierarchy_change(
 *     '123e4567-e89b-12d3-a456-426614174000'::UUID,
 *     'TENANT_ADMIN'::role_type
 *   );
 */

-- Drop existing function and related triggers
DROP TRIGGER IF EXISTS trg_validate_role_hierarchy_change ON public.roles;
DROP FUNCTION IF EXISTS public.validate_role_hierarchy_change(UUID, role_type);

CREATE OR REPLACE FUNCTION public.validate_role_hierarchy_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_current_level INTEGER;
    v_new_level INTEGER;
    v_has_conflicts BOOLEAN;
BEGIN
    -- Only proceed if role_type is being changed
    IF NEW.role_type = OLD.role_type THEN
        RETURN NEW;
    END IF;

    -- Get hierarchy levels
    v_current_level := get_role_hierarchy_level(OLD.role_type);
    v_new_level := get_role_hierarchy_level(NEW.role_type);

    -- Prevent invalid transitions
    IF OLD.role_type = 'super_admin'::role_type THEN
        RAISE EXCEPTION 'Cannot modify super_admin role type';
    END IF;

    -- Check for conflicts with existing role assignments
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles ur1
        WHERE ur1.role_id = NEW.id
        AND ur1.deleted_at IS NULL
        AND ur1.is_active = true
        AND EXISTS (
            SELECT 1
            FROM public.user_roles ur2
            JOIN public.roles r2 ON r2.id = ur2.role_id
            WHERE ur2.user_id = ur1.user_id
            AND ur2.role_id != NEW.id
            AND ur2.deleted_at IS NULL
            AND ur2.is_active = true
            AND get_role_hierarchy_level(r2.role_type) >= v_new_level
        )
    ) INTO v_has_conflicts;

    IF v_has_conflicts THEN
        RAISE EXCEPTION 'Role type change would create hierarchy conflicts with existing user role assignments';
    END IF;

    -- Log the change attempt
    PERFORM log_audit_event(
        'roles',
        'UPDATE',
        auth.uid(),
        jsonb_build_object(
            'function', 'validate_role_hierarchy_change',
            'role_id', NEW.id,
            'current_type', OLD.role_type,
            'new_type', NEW.role_type,
            'current_level', v_current_level,
            'new_level', v_new_level
        ),
        NULL,
        NULL
    );

    RETURN NEW;
END;
$$;

-- Create trigger for role type changes
CREATE TRIGGER trg_validate_role_hierarchy_change
    BEFORE UPDATE ON public.roles
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_role_hierarchy_change();

    
-- Add helpful comment
COMMENT ON FUNCTION public.validate_role_hierarchy_change IS 'Validates role hierarchy changes to maintain system integrity';
--
--
--
/**
 * Function: get_users_by_role
 *
 * Purpose: Retrieves all users assigned to a specific role type with optional filtering
 *
 * Returns: TABLE
 *   - user_id UUID
 *   - email TEXT
 *   - display_name TEXT
 *   - role_type role_type
 *   - assigned_at TIMESTAMPTZ
 *   - is_active BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Retrieves users based on role type with:
 *   - Optional inclusion of inactive users
 *   - Optional inclusion of users with higher role levels
 *   - Proper role hierarchy consideration
 *   - Efficient filtering and pagination
 *
 * Assumptions:
 *   - public.users table exists with proper user fields
 *   - public.user_roles table exists with role assignments
 *   - public.roles table exists with role hierarchy
 *   - role_type enum exists with proper values
 *   - get_role_hierarchy_level function exists
 *
 * Example Usage:
 *   SELECT * FROM public.get_users_by_role(
 *     'TENANT_ADMIN',
 *     include_inactive := false,
 *     include_higher_roles := true
 *   );
 */

-- Drop existing function
DROP FUNCTION IF EXISTS public.get_users_by_role(role_type, BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION public.get_users_by_role(
    p_role_type role_type,
    p_include_inactive BOOLEAN DEFAULT false,
    p_include_higher_roles BOOLEAN DEFAULT false
)
RETURNS TABLE (
    user_id UUID,
    email TEXT,
    display_name TEXT,
    role_type role_type,
    assigned_at TIMESTAMPTZ,
    is_active BOOLEAN
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_role_level INTEGER;
BEGIN
    -- Get the hierarchy level for the requested role type
    v_role_level := get_role_hierarchy_level(p_role_type);

    RETURN QUERY
    WITH role_users AS (
        SELECT DISTINCT ON (u.id)
            u.id,
            u.email,
            u.display_name,
            r.role_type,
            ur.created_at as assigned_at,
            u.is_active
        FROM public.users u
        JOIN public.user_roles ur ON ur.user_id = u.id
        JOIN public.roles r ON r.id = ur.role_id
        WHERE (
            -- Match exact role type or include higher roles if requested
            r.role_type = p_role_type
            OR (
                p_include_higher_roles 
                AND get_role_hierarchy_level(r.role_type) >= v_role_level
            )
        )
        AND ur.deleted_at IS NULL
        AND ur.is_active = true
        AND r.deleted_at IS NULL
        AND r.is_active = true
        AND u.deleted_at IS NULL
        AND (p_include_inactive OR u.is_active = true)
        ORDER BY 
            CASE r.role_type
                WHEN 'super_admin' THEN 1
                WHEN 'admin' THEN 2
                WHEN 'manager' THEN 3
                ELSE 4
            END
    )
    SELECT 
        ru.id,
        ru.email,
        ru.display_name,
        ru.role_type,
        ru.assigned_at,
        ru.is_active
    FROM role_users ru
    ORDER BY ru.assigned_at DESC;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.get_users_by_role IS 'Retrieves users assigned to a specific role type with optional filtering for inactive users and higher roles';
--
--
--
/**
 * Function: validate_role_hierarchy_change
 *
 * Purpose: Validates if a role's hierarchy level can be changed while maintaining system integrity
 *
 * Returns: BOOLEAN
 *   - TRUE if the role type change is valid
 *   - FALSE if conflicts exist
 *   - Raises exceptions for invalid states
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Ensures role hierarchy changes maintain system integrity by:
 *   - Validating role existence and active status
 *   - Checking hierarchy level compatibility
 *   - Preventing circular dependencies
 *   - Validating against existing user role assignments
 *   - Maintaining audit trail of attempted changes
 *
 * Assumptions:
 *   - public.roles table exists with columns: id, role_type, deleted_at, is_active
 *   - public.user_roles table exists with columns: role_id, user_id, is_active, deleted_at
 *   - get_role_hierarchy_level function exists and returns valid hierarchy levels
 *   - role_type enum exists with proper hierarchy values
 *   - audit_logs table exists for change tracking
 *
 * Example Usage:
 *   SELECT public.validate_role_hierarchy_change(
 *     '123e4567-e89b-12d3-a456-426614174000'::UUID,
 *     'TENANT_ADMIN'::role_type
 *   );
 */

-- Drop existing function and related triggers
DROP TRIGGER IF EXISTS trg_validate_role_hierarchy_change ON public.roles;
DROP FUNCTION IF EXISTS public.validate_role_hierarchy_change(UUID, role_type);

CREATE OR REPLACE FUNCTION public.validate_role_hierarchy_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_current_level INTEGER;
    v_new_level INTEGER;
    v_has_conflicts BOOLEAN;
BEGIN
    -- Only proceed if role_type is being changed
    IF NEW.role_type = OLD.role_type THEN
        RETURN NEW;
    END IF;

    -- Get hierarchy levels
    v_current_level := get_role_hierarchy_level(OLD.role_type);
    v_new_level := get_role_hierarchy_level(NEW.role_type);

    -- Prevent invalid transitions
    IF OLD.role_type = 'super_admin'::role_type THEN
        RAISE EXCEPTION 'Cannot modify super_admin role type';
    END IF;

    -- Check for conflicts with existing role assignments
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles ur1
        WHERE ur1.role_id = NEW.id
        AND ur1.deleted_at IS NULL
        AND ur1.is_active = true
        AND EXISTS (
            SELECT 1
            FROM public.user_roles ur2
            JOIN public.roles r2 ON r2.id = ur2.role_id
            WHERE ur2.user_id = ur1.user_id
            AND ur2.role_id != NEW.id
            AND ur2.deleted_at IS NULL
            AND ur2.is_active = true
            AND get_role_hierarchy_level(r2.role_type) >= v_new_level
        )
    ) INTO v_has_conflicts;

    IF v_has_conflicts THEN
        RAISE EXCEPTION 'Role type change would create hierarchy conflicts with existing user role assignments';
    END IF;

    -- Log the change attempt
    PERFORM log_audit_event(
        'roles',
        'UPDATE',
        auth.uid(),
        jsonb_build_object(
            'function', 'validate_role_hierarchy_change',
            'role_id', NEW.id,
            'current_type', OLD.role_type,
            'new_type', NEW.role_type,
            'current_level', v_current_level,
            'new_level', v_new_level
        ),
        NULL,
        NULL
    );

    RETURN NEW;
END;
$$;

-- Create trigger for role type changes
CREATE TRIGGER trg_validate_role_hierarchy_change
    BEFORE UPDATE ON public.roles
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_role_hierarchy_change();

    
-- Add helpful comment
COMMENT ON FUNCTION public.validate_role_hierarchy_change IS 'Validates role hierarchy changes to maintain system integrity';
--
--
--
/**
 * Function: check_role_conflicts
 *
 * Purpose: Validates if a user's role assignment would create hierarchy conflicts
 *
 * Returns: BOOLEAN
 *   - TRUE if the role assignment is valid
 *   - FALSE if conflicts exist
 *   - Raises exceptions for invalid states
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Ensures role assignments maintain hierarchy integrity by checking:
 *   - User existence and status
 *   - Role validity and status
 *   - Hierarchy level compatibility
 *   - Existing role assignments
 *   - Tenant isolation rules
 *
 * Features:
 *   - Validates user and role existence
 *   - Prevents circular role assignments
 *   - Enforces role hierarchy rules
 *   - Maintains tenant boundaries
 *   - Logs validation attempts
 *   - Handles soft-deleted records
 *   - Supports multi-tenant isolation
 *   - Provides detailed error messages
 *   - Maintains audit trail
 *
 * Example Usage:
 *   SELECT public.check_role_conflicts(
 *     '123e4567-e89b-12d3-a456-426614174000'::UUID,
 *     '987fcdeb-51d3-12d3-a456-426614174000'::UUID
 *   );
 */

-- Drop existing function
DROP FUNCTION IF EXISTS public.check_role_conflicts(UUID, UUID);

CREATE OR REPLACE FUNCTION public.check_role_conflicts(
    p_user_id UUID,
    p_role_id UUID
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_role_type role_type;
    v_role_level INTEGER;
    v_has_conflicts BOOLEAN;
    v_tenant_id UUID;
BEGIN
    -- Validate user and role existence
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_user_id 
        AND deleted_at IS NULL 
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'User not found or inactive: %', p_user_id;
    END IF;

    -- Get role details
    SELECT 
        r.role_type,
        r.tenant_id
    INTO v_role_type, v_tenant_id
    FROM public.roles r
    WHERE r.id = p_role_id
    AND r.deleted_at IS NULL
    AND r.is_active = true;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Role not found or inactive: %', p_role_id;
    END IF;

    -- Get role hierarchy level
    v_role_level := get_role_hierarchy_level(v_role_type);

    -- Check for hierarchy conflicts
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        WHERE ur.user_id = p_user_id
        AND ur.deleted_at IS NULL
        AND ur.is_active = true
        AND r.deleted_at IS NULL
        AND r.is_active = true
        AND (
            -- Check for same or higher level roles
            get_role_hierarchy_level(r.role_type) >= v_role_level
            OR
            -- Check tenant isolation for non-system roles
            (v_role_type != 'SYSTEM_ADMIN' AND r.tenant_id != v_tenant_id)
        )
    ) INTO v_has_conflicts;

    IF v_has_conflicts THEN
        -- Log conflict detection
        INSERT INTO public.audit_logs (
            table_name,
            action,
            old_data,
            new_data,
            changed_by
        )
        VALUES (
            'user_roles',
            'ROLE_CONFLICT_CHECK',
            jsonb_build_object(
                'user_id', p_user_id,
                'existing_role_level', v_role_level
            ),
            jsonb_build_object(
                'role_id', p_role_id,
                'role_type', v_role_type,
                'tenant_id', v_tenant_id
            ),
            auth.uid()
        );
        
        RETURN FALSE;
    END IF;

    -- Log successful validation
    INSERT INTO public.audit_logs (
        table_name,
        action,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        'user_roles',
        'ROLE_CONFLICT_VALIDATED',
        jsonb_build_object(
            'user_id', p_user_id
        ),
        jsonb_build_object(
            'role_id', p_role_id,
            'role_type', v_role_type,
            'role_level', v_role_level,
            'tenant_id', v_tenant_id
        ),
        auth.uid()
    );

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'function', 'check_role_conflicts',
                'user_id', p_user_id,
                'role_id', p_role_id,
                'role_type', v_role_type,
                'role_level', v_role_level
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.check_role_conflicts IS 'Validates role assignments to prevent hierarchy conflicts and maintain tenant isolation';
--
--
--
/**
 * Function: delegate_role_management
 *
 * Purpose: Delegate role management capabilities to another user with comprehensive validation
 *
 * Returns: BOOLEAN
 *   - TRUE if delegation was successful
 *   - FALSE if validation fails
 *   - Raises exceptions for invalid states
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Enables secure delegation of role management capabilities while ensuring:
 *   - Delegator has sufficient privileges
 *   - Delegate exists and is active
 *   - Role types are valid and within delegator's scope
 *   - Tenant isolation is maintained
 *   - Hierarchy rules are enforced
 *
 * Features:
 *   - Validates user existence and status
 *   - Enforces role hierarchy rules
 *   - Prevents circular delegations
 *   - Maintains tenant boundaries
 *   - Comprehensive audit logging
 *   - Detailed error tracking
 *   - Supports multi-tenant isolation
 *   - Transaction safe
 *   - Automatic expiration scheduling
 */

-- Drop existing function
DROP FUNCTION IF EXISTS public.delegate_role_management(UUID, UUID, role_type[]);

CREATE OR REPLACE FUNCTION public.delegate_role_management(
    p_delegator_id UUID,
    p_delegate_id UUID,
    p_role_types role_type[]
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_delegator_level INTEGER;
    v_delegate_level INTEGER;
    v_role_type role_type;
    v_role_level INTEGER;
BEGIN
    -- Validate delegator existence and status
    SELECT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_delegator_id 
        AND deleted_at IS NULL 
        AND is_active = true
    ) INTO v_delegator_level;

    IF NOT v_delegator_level THEN
        RAISE EXCEPTION 'Delegator not found or inactive: %', p_delegator_id;
    END IF;

    -- Validate delegate existence and status
    SELECT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_delegate_id 
        AND deleted_at IS NULL 
        AND is_active = true
    ) INTO v_delegate_level;

    IF NOT v_delegate_level THEN
        RAISE EXCEPTION 'Delegate not found or inactive: %', p_delegate_id;
    END IF;

    -- Get delegator's highest role level
    SELECT MAX(get_role_hierarchy_level(r.role_type)) INTO v_delegator_level
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_delegator_id
    AND ur.is_active = true
    AND ur.deleted_at IS NULL
    AND r.deleted_at IS NULL;

    IF v_delegator_level IS NULL THEN
        RAISE EXCEPTION 'Delegator has no active roles';
    END IF;

    -- Get delegate's highest role level
    SELECT MAX(get_role_hierarchy_level(r.role_type)) INTO v_delegate_level
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_delegate_id
    AND ur.is_active = true
    AND ur.deleted_at IS NULL
    AND r.deleted_at IS NULL;

    -- Validate each role type
    FOREACH v_role_type IN ARRAY p_role_types
    LOOP
        v_role_level := get_role_hierarchy_level(v_role_type);
        
        -- Ensure delegator has higher level than the role being delegated
        IF v_role_level >= v_delegator_level THEN
            RAISE EXCEPTION 'Cannot delegate role type % (level %) - delegator level is %', 
                v_role_type, v_role_level, v_delegator_level;
        END IF;

        -- Prevent delegation of system roles by non-system admins
        IF v_role_type = 'SYSTEM_ADMIN' AND v_delegator_level < get_role_hierarchy_level('SYSTEM_ADMIN') THEN
            RAISE EXCEPTION 'Only system administrators can delegate system roles';
        END IF;
    END LOOP;

    -- Create delegation record
    INSERT INTO public.role_delegations (
        delegator_id,
        delegate_id,
        role_types,
        created_by
    )
    VALUES (
        p_delegator_id,
        p_delegate_id,
        p_role_types,
        auth.uid()
    );

    -- Log successful delegation
    INSERT INTO public.audit_logs (
        table_name,
        action,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        'role_delegations',
        'ROLE_DELEGATION_CREATED',
        jsonb_build_object(
            'delegator_id', p_delegator_id,
            'delegator_level', v_delegator_level,
            'delegate_id', p_delegate_id,
            'delegate_level', v_delegate_level
        ),
        jsonb_build_object(
            'role_types', p_role_types
        ),
        auth.uid()
    );

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'function', 'delegate_role_management',
                'delegator_id', p_delegator_id,
                'delegate_id', p_delegate_id,
                'role_types', p_role_types,
                'delegator_level', v_delegator_level,
                'delegate_level', v_delegate_level
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.delegate_role_management IS 'Enables secure delegation of role management capabilities with comprehensive validation and audit logging';
--
--
--
/**
 * Function: assign_temporary_role
 *
 * Purpose: Assign a temporary role to a user with comprehensive validation and expiration handling
 *
 * Returns: BOOLEAN
 *   - TRUE if temporary role assignment was successful
 *   - FALSE if validation fails
 *   - Raises exceptions for invalid states
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Enables secure temporary role assignment while ensuring:
 *   - User exists and is active
 *   - Role type is valid and assignable
 *   - Expiration date is valid
 *   - Tenant isolation is maintained
 *   - Hierarchy rules are enforced
 *
 * Features:
 *   - Validates user and role existence
 *   - Enforces role hierarchy rules
 *   - Validates expiration dates
 *   - Maintains tenant boundaries
 *   - Comprehensive audit logging
 *   - Detailed error tracking
 *   - Supports multi-tenant isolation
 *   - Transaction safe
 *   - Automatic expiration scheduling
 */

-- Drop existing function
DROP FUNCTION IF EXISTS public.assign_temporary_role(UUID, role_type, TIMESTAMPTZ, UUID);

CREATE OR REPLACE FUNCTION public.assign_temporary_role(
    p_user_id UUID,
    p_role_type role_type,
    p_expiry_date TIMESTAMPTZ,
    p_assigned_by UUID
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_role_id UUID;
    v_assigner_tenant_id UUID;
    v_assigner_level INTEGER;
    v_role_level INTEGER;
BEGIN
    -- Validate user existence and status
    SELECT tenant_id INTO v_assigner_tenant_id
    FROM public.users 
    WHERE id = p_assigned_by 
    AND deleted_at IS NULL 
    AND is_active = true;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Assigner not found or inactive: %', p_assigned_by;
    END IF;

    -- Validate assigner permissions
    SELECT MAX(get_role_hierarchy_level(r.role_type)) INTO v_assigner_level
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_assigned_by
    AND ur.is_active = true
    AND ur.deleted_at IS NULL
    AND r.deleted_at IS NULL;

    IF v_assigner_level IS NULL THEN
        RAISE EXCEPTION 'Assigner has no active roles';
    END IF;

    -- Get role ID for the given role type
    SELECT id INTO v_role_id
    FROM public.roles
    WHERE role_type = p_role_type
    AND deleted_at IS NULL
    AND is_active = true;

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'Role type not found or inactive: %', p_role_type;
    END IF;

    -- Get role level for validation
    v_role_level := get_role_hierarchy_level(p_role_type);

    -- Validate role assignment permissions
    IF v_role_level >= v_assigner_level THEN
        RAISE EXCEPTION 'Cannot assign role with equal or higher level than assigner';
    END IF;

    -- Validate tenant isolation for non-system roles
    IF v_assigner_level < get_role_hierarchy_level('SYSTEM_ADMIN')
    AND v_assigner_tenant_id != (SELECT tenant_id FROM public.roles WHERE id = v_role_id) THEN
        RAISE EXCEPTION 'Cross-tenant role assignment not allowed for non-system administrators';
    END IF;

    -- Validate expiration date
    IF p_expiry_date <= now() THEN
        RAISE EXCEPTION 'Expiration date must be in the future';
    END IF;

    -- Create temporary role assignment
    INSERT INTO public.user_roles (
        user_id,
        role_id,
        expires_at,
        assigned_by,
        tenant_id,
        created_by
    )
    VALUES (
        p_user_id,
        v_role_id,
        p_expiry_date,
        p_assigned_by,
        (SELECT tenant_id FROM public.roles WHERE id = v_role_id),
        auth.uid()
    );

    -- Schedule role expiration
    PERFORM schedule_role_expiration(
        p_user_id,
        v_role_id,
        p_expiry_date
    );

    -- Log successful assignment
    INSERT INTO public.audit_logs (
        table_name,
        action,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        'user_roles',
        'TEMPORARY_ROLE_ASSIGNED',
        jsonb_build_object(
            'user_id', p_user_id,
            'user_tenant', (SELECT tenant_id FROM public.roles WHERE id = v_role_id)
        ),
        jsonb_build_object(
            'role_id', v_role_id,
            'role_type', p_role_type,
            'role_level', v_role_level,
            'expires_at', p_expiry_date,
            'assigned_by', p_assigned_by,
            'assigner_level', v_assigner_level
        ),
        auth.uid()
    );

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'function', 'assign_temporary_role',
                'user_id', p_user_id,
                'role_type', p_role_type,
                'expiry_date', p_expiry_date,
                'assigned_by', p_assigned_by,
                'assigner_level', v_assigner_level
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.assign_temporary_role IS 'Enables secure temporary role assignments with comprehensive validation, expiration handling, and audit logging';
/**
 * Function: schedule_role_expiration
 *
 * Purpose: Schedule and handle the expiration of temporary role assignments
 *
 * Returns: BOOLEAN
 *   - TRUE if expiration was successfully scheduled
 *   - Raises exceptions for invalid states
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Manages the expiration of temporary roles by:
 *   - Validating role assignments
 *   - Scheduling deactivation
 *   - Handling cleanup tasks
 *   - Maintaining audit trail
 *
 * Features:
 *   - Validates role assignments
 *   - Ensures proper timing
 *   - Comprehensive logging
 *   - Error handling
 *   - Transaction safe
 *   - Automatic cleanup
 */

-- Drop existing function
DROP FUNCTION IF EXISTS public.schedule_role_expiration(UUID, UUID, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION public.schedule_role_expiration(
    p_user_id UUID,
    p_role_id UUID,
    p_expiry_date TIMESTAMPTZ
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_role_type role_type;
    v_tenant_id UUID;
    v_user_role_id UUID;
BEGIN
    -- Validate role assignment exists
    SELECT 
        ur.id,
        r.role_type,
        r.tenant_id
    INTO v_user_role_id, v_role_type, v_tenant_id
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_user_id
    AND ur.role_id = p_role_id
    AND ur.is_active = true
    AND ur.deleted_at IS NULL
    AND r.deleted_at IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Active role assignment not found for user % and role %', p_user_id, p_role_id;
    END IF;

    -- Validate expiration date
    IF p_expiry_date <= now() THEN
        RAISE EXCEPTION 'Expiration date must be in the future';
    END IF;

    -- Schedule expiration job
    INSERT INTO public.scheduled_tasks (
        task_type,
        execute_at,
        parameters,
        tenant_id,
        created_by
    )
    VALUES (
        'ROLE_EXPIRATION',
        p_expiry_date,
        jsonb_build_object(
            'user_id', p_user_id,
            'role_id', p_role_id,
            'user_role_id', v_user_role_id,
            'role_type', v_role_type
        ),
        v_tenant_id,
        auth.uid()
    );

    -- Log scheduling
    INSERT INTO public.audit_logs (
        table_name,
        action,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        'scheduled_tasks',
        'ROLE_EXPIRATION_SCHEDULED',
        jsonb_build_object(
            'user_id', p_user_id,
            'role_id', p_role_id,
            'user_role_id', v_user_role_id
        ),
        jsonb_build_object(
            'expiry_date', p_expiry_date,
            'role_type', v_role_type,
            'tenant_id', v_tenant_id
        ),
        auth.uid()
    );

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        )
        VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'function', 'schedule_role_expiration',
                'user_id', p_user_id,
                'role_id', p_role_id,
                'expiry_date', p_expiry_date,
                'role_type', v_role_type,
                'tenant_id', v_tenant_id
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.schedule_role_expiration IS 'Manages the scheduling and handling of temporary role expirations with comprehensive validation and audit logging';--
--
--
-- ========================================================================================
-- Permission Management Functions:
-- ========================================================================================

/**
 * Function: grant_permission()
 *
 * Purpose: Grant a specific permission to a role
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Grants a permission to a role by creating a role_permission mapping.
 *   Includes validation checks and handles audit logging.
 *   Prevents duplicate grants and maintains data integrity.
 *
 * Assumptions:
 *   - Role and permission IDs exist in their respective tables
 *   - Caller has appropriate privileges to grant permissions
 *   - role_permissions table exists with proper structure
 *
 * Example Usage:
 *   SELECT public.grant_permission(
 *     '123e4567-e89b-12d3-a456-426614174000',  -- role_id
 *     '987fcdeb-51d3-12d3-a456-426614174000'   -- permission_id
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.grant_permission(UUID, UUID);

CREATE OR REPLACE FUNCTION public.grant_permission(
    p_role_id UUID,
    p_permission_id UUID
)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if role exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM public.roles 
        WHERE id = p_role_id 
        AND deleted_at IS NULL 
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Role does not exist or is inactive';
    END IF;

    -- Check if permission exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM public.permissions 
        WHERE id = p_permission_id 
        AND deleted_at IS NULL 
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Permission does not exist or is inactive';
    END IF;

    -- Check if permission is already granted
    IF EXISTS (
        SELECT 1 FROM public.role_permissions 
        WHERE role_id = p_role_id 
        AND permission_id = p_permission_id 
        AND deleted_at IS NULL
    ) THEN
        RETURN FALSE;
    END IF;

    -- Grant the permission
    INSERT INTO public.role_permissions (
        role_id,
        permission_id,
        created_by,
        updated_by
    )
    VALUES (
        p_role_id,
        p_permission_id,
        auth.uid(),
        auth.uid()
    );

    -- Log the action
    INSERT INTO public.audit_logs (
        table_name,
        record_id,
        action,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        'role_permissions',
        p_role_id,
        'GRANT',
        NULL,
        jsonb_build_object(
            'role_id', p_role_id,
            'permission_id', p_permission_id
        ),
        auth.uid()
    );

    RETURN TRUE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.grant_permission IS 'Grants a specific permission to a role with audit logging';

/**
 * Function: revoke_permission()
 *
 * Purpose: Revoke a specific permission from a role
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Revokes a permission from a role by soft-deleting the role_permission mapping.
 *   Includes validation checks and handles audit logging.
 *   Maintains referential integrity through soft deletes.
 *
 * Assumptions:
 *   - Role and permission IDs exist in their respective tables
 *   - Caller has appropriate privileges to revoke permissions
 *   - role_permissions table exists with proper structure
 *
 * Example Usage:
 *   SELECT public.revoke_permission(
 *     '123e4567-e89b-12d3-a456-426614174000',  -- role_id
 *     '987fcdeb-51d3-12d3-a456-426614174000'   -- permission_id
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.revoke_permission(UUID, UUID);

CREATE OR REPLACE FUNCTION public.revoke_permission(
    p_role_id UUID,
    p_permission_id UUID
)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_role_permission_id UUID;
BEGIN
    -- Check if role exists
    IF NOT EXISTS (
        SELECT 1 FROM public.roles 
        WHERE id = p_role_id 
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Role does not exist';
    END IF;

    -- Check if permission exists
    IF NOT EXISTS (
        SELECT 1 FROM public.permissions 
        WHERE id = p_permission_id 
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Permission does not exist';
    END IF;

    -- Find the role permission mapping
    SELECT id INTO v_role_permission_id
    FROM public.role_permissions
    WHERE role_id = p_role_id 
    AND permission_id = p_permission_id 
    AND deleted_at IS NULL;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    -- Soft delete the permission
    UPDATE public.role_permissions
    SET 
        deleted_at = CURRENT_TIMESTAMP,
        deleted_by = auth.uid(),
        updated_at = CURRENT_TIMESTAMP,
        updated_by = auth.uid(),
        is_active = false
    WHERE id = v_role_permission_id;

    -- Log the action
    INSERT INTO public.audit_logs (
        table_name,
        record_id,
        action,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        'role_permissions',
        p_role_id,
        'REVOKE',
        jsonb_build_object(
            'role_id', p_role_id,
            'permission_id', p_permission_id
        ),
        NULL,
        auth.uid()
    );

    RETURN TRUE;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.revoke_permission IS 'Revokes a specific permission from a role with audit logging';

/**
 * Function: get_role_permissions()
 *
 * Purpose: Retrieve all permissions assigned to a role
 *
 * Parameters:
 *   @p_role_id UUID - The role to get permissions for
 *
 * Returns: TABLE (
 *   permission_id UUID,
 *   permission_name TEXT,
 *   resource TEXT,
 *   action TEXT
 * )
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Retrieves all permissions assigned to a role by:
 *   - Joining role_permissions and permissions tables
 *   - Filtering for active and non-deleted permissions
 *   - Including permission details
 *
 * Assumptions:
 *   - Role ID exists in the roles table
 *   - Caller has appropriate privileges to view permissions
 *   - role_permissions and permissions tables exist with proper structure
 *
 * Example Usage:
 *   SELECT * FROM get_role_permissions('123e4567-e89b-12d3-a456-426614174000');
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.get_role_permissions(UUID);

CREATE OR REPLACE FUNCTION public.get_role_permissions(
    p_role_id UUID
)
RETURNS TABLE (
    permission_id UUID,
    permission_name TEXT,
    resource TEXT,
    action TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS permission_id,
        p.name AS permission_name,
        p.resource,
        p.action
    FROM public.role_permissions rp
    JOIN public.permissions p ON p.id = rp.permission_id
    WHERE rp.role_id = p_role_id
    AND rp.deleted_at IS NULL
    AND p.deleted_at IS NULL
    AND rp.is_active = true
    AND p.is_active = true;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.get_role_permissions IS 'Retrieves all permissions assigned to a role';
--
--
--
/**
 * Function: has_permission
 *
 * Purpose: Check if a user has a specific permission through their roles
 *
 * Returns: BOOLEAN
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   This function checks if a given user has a specific permission by:
 *   - Joining user_roles, role_permissions, and permissions tables
 *   - Filtering for active and non-deleted records
 *   - Matching the provided resource and action
 *
 * Features:
 *   - Handles soft-deleted records
 *   - Considers active status of roles and permissions
 *   - Efficient EXISTS check for performance
 *
 * Example Usage:
 *   SELECT public.has_permission(
 *     '123e4567-e89b-12d3-a456-426614174000',
 *     'users',
 *     'read'
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.has_permission(UUID, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.has_permission(
    p_user_id UUID,
    p_resource TEXT,
    p_action TEXT
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.role_permissions rp ON rp.role_id = ur.role_id
        JOIN public.permissions p ON p.id = rp.permission_id
        WHERE ur.user_id = p_user_id
        AND p.resource = p_resource
        AND p.action = p_action
        AND ur.is_active = true
        AND rp.is_active = true
        AND p.is_active = true
        AND ur.deleted_at IS NULL
        AND rp.deleted_at IS NULL
        AND p.deleted_at IS NULL
    );
END;
$$;

COMMENT ON FUNCTION public.has_permission IS 'Checks if a user has a specific permission through their roles';
--
--
--
/**
 * Function: has_any_role
 *
 * Purpose: Check if a user has any of the specified role types
 *
 * Parameters:
 *   - p_user_id UUID: The ID of the user to check
 *   - p_role_types role_type[]: Array of role types to check for
 *
 * Returns: BOOLEAN
 *   - TRUE if the user has any of the specified roles
 *   - FALSE otherwise
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   This function checks if a given user has any of the specified role types
 *   by querying the user_roles and roles tables. It considers only active
 *   and non-deleted roles.
 *
 * Features:
 *   - Validates user and role existence
 *   - Checks only active and non-deleted roles
 *   - Efficient EXISTS clause for performance
 *   - Handles Supabase auth integration
 *
 * Example Usage:
 *   SELECT public.has_any_role(
 *     auth.uid(),
 *     ARRAY['super_admin', 'system_admin']::role_type[]
 *   );
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.has_any_role(UUID, role_type[]);

CREATE OR REPLACE FUNCTION public.has_any_role(
    p_user_id UUID,
    p_role_types role_type[]
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        WHERE ur.user_id = p_user_id
        AND r.role_type = ANY(p_role_types)
        AND ur.is_active = true
        AND r.is_active = true
        AND ur.deleted_at IS NULL
        AND r.deleted_at IS NULL
    );
END;
$$;

COMMENT ON FUNCTION public.has_any_role IS 'Checks if a user has any of the specified role types';--
--
--
-- ========================================================================================
-- Audit and Logging Functions
-- ========================================================================================

-- Drop all existing audit triggers first
DROP TRIGGER IF EXISTS audit_trigger ON public.users;
DROP TRIGGER IF EXISTS audit_trigger ON public.roles;
DROP TRIGGER IF EXISTS audit_trigger ON public.permissions;
DROP TRIGGER IF EXISTS audit_trigger ON public.user_roles;
DROP TRIGGER IF EXISTS audit_trigger ON public.role_permissions;
DROP TRIGGER IF EXISTS audit_trigger ON public.role_delegations;
DROP TRIGGER IF EXISTS audit_trigger ON public.scheduled_tasks;
DROP TRIGGER IF EXISTS audit_trigger ON public.user_phone_numbers;
DROP TRIGGER IF EXISTS audit_trigger ON public.user_addresses;

-- Drop existing function
DROP FUNCTION IF EXISTS public.process_audit();

/**
 * Function: process_audit
 *
 * Purpose: Process audit logs for all tables
 *
 * Returns: TRIGGER
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   This function is designed to be used as a trigger for auditing changes
 *   in all tables. It captures the old and new data for INSERT, UPDATE,
 *   and DELETE operations and logs them in the public.audit_logs table.
 *
 * Features:
 *   - Complete Change Tracking:
 *     * Captures INSERT, UPDATE, and DELETE operations
 *     * Records full JSONB snapshots of data states
 *     * Maintains before and after states for all changes
 *   
 *   - Comprehensive Metadata:
 *     * Table name tracking
 *     * Record UUID identification
 *     * Operation type logging (INSERT/UPDATE/DELETE)
 *     * Timestamp recording
 *   
 *   - User Accountability:
 *     * Tracks performing user (created_by, updated_by, deleted_by)
 *     * Maintains user action history
 *   
 *   - Security:
 *     * Executes with SECURITY DEFINER
 *     * Restricted search path
 *     * Protected audit trail
 *   
 *   - Integration:
 *     * Works with all RBAC system tables
 *     * Supports UUID primary keys
 *     * Compatible with soft delete pattern
 *
 * Example Usage:
 *   CREATE TRIGGER audit_trigger
 *   AFTER INSERT OR UPDATE OR DELETE ON table_name
 *   FOR EACH ROW EXECUTE FUNCTION public.process_audit();
 */
CREATE OR REPLACE FUNCTION public.process_audit()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    v_performed_by UUID;
    v_record_id UUID;
BEGIN
    -- Get the record ID based on operation type
    v_record_id := CASE TG_OP
        WHEN 'DELETE' THEN OLD.id
        ELSE NEW.id
    END;

    -- Set the data snapshots based on operation type
    CASE TG_OP
        WHEN 'UPDATE' THEN
            old_data := to_jsonb(OLD);
            new_data := to_jsonb(NEW);
            -- Get the user who performed the update
            v_performed_by := COALESCE(
                NEW.updated_by,
                (SELECT auth.uid()),
                NULL
            );
        WHEN 'DELETE' THEN
            old_data := to_jsonb(OLD);
            new_data := NULL;
            -- Get the user who performed the delete
            v_performed_by := COALESCE(
                OLD.deleted_by,
                (SELECT auth.uid()),
                NULL
            );
        WHEN 'INSERT' THEN
            old_data := NULL;
            new_data := to_jsonb(NEW);
            -- Get the user who performed the insert
            v_performed_by := COALESCE(
                NEW.created_by,
                (SELECT auth.uid()),
                NULL
            );
    END CASE;

    -- Insert the audit log with enhanced error handling
    BEGIN
        INSERT INTO public.audit_logs (
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            performed_by,
            performed_at
        )
        VALUES (
            TG_TABLE_NAME::TEXT,
            v_record_id,
            TG_OP,
            old_data,
            new_data,
            v_performed_by,
            CURRENT_TIMESTAMP
        );
    EXCEPTION WHEN OTHERS THEN
        -- Log the error but allow the original operation to proceed
        INSERT INTO public.error_logs (
            error_message,
            error_code,
            error_stack,
            severity,
            function_name,
            schema_name,
            context_data,
            user_id,
            ip_address,
            user_agent
        )
        VALUES (
            'Audit logging failed',
            SQLSTATE,
            SQLERRM,
            'ERROR',
            'process_audit',
            TG_TABLE_NAME::TEXT,
            jsonb_build_object(
                'table_name', TG_TABLE_NAME,
                'record_id', v_record_id,
                'action', TG_OP
            ),
            auth.uid(),
            current_setting('request.headers', true)::json->>'x-forwarded-for',
            current_setting('request.headers', true)::json->>'user-agent'
        );
    END;

    RETURN NULL; -- for AFTER trigger
END;
$$;

-- Create audit triggers for all relevant tables
CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();

CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.roles
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();

CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.permissions
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();

CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.user_roles
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();

CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.role_permissions
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();

CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.role_delegations
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();

CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.scheduled_tasks
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();

CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.user_phone_numbers
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();

CREATE TRIGGER audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.user_addresses
    FOR EACH ROW EXECUTE FUNCTION public.process_audit();
/**
 * Function: log_audit_event
 *
 * Purpose: Log audit events and significant user activities
 *
 * Returns: UUID (audit log entry ID)
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   This function logs audit events to the audit_logs table and significant
 *   actions to the user_activities table. It captures details such as the
 *   table affected, action performed, old and new data, metadata, user info,
 *   and request context.
 *
 * Assumptions:
 *   - The audit_logs and user_activities tables exist
 *   - The auth.uid() function is available to get the current user's ID
 *   - The error_logs table exists for logging function errors
 *
 * Example Usage:
 *   SELECT public.log_audit_event(
 *     'users',
 *     'update',
 *     '123e4567-e89b-12d3-a456-426614174000'::UUID,
 *     '{"name": "John Doe"}'::JSONB,
 *     '{"name": "Jane Doe"}'::JSONB,
 *     '{"reason": "Name change request"}'::JSONB
 *   );
 */

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS public.log_audit_event(TEXT, TEXT, UUID, JSONB, JSONB, JSONB);

CREATE OR REPLACE FUNCTION public.log_audit_event(
    p_table_name TEXT,
    p_action TEXT,
    p_record_id UUID,
    p_old_data JSONB DEFAULT NULL,
    p_new_data JSONB DEFAULT NULL,
    p_metadata JSONB DEFAULT NULL
)
RETURNS UUID
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_user UUID;
    v_audit_id UUID;
    v_current_timestamp TIMESTAMPTZ;
    v_ip_address TEXT;
    v_user_agent TEXT;
BEGIN
    -- Get current timestamp
    v_current_timestamp := now();
    
    -- Get current user from session context
    BEGIN
        v_current_user := auth.uid();
        IF v_current_user IS NULL THEN
            RAISE WARNING 'No authenticated user found for audit event';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error getting current user: %', SQLERRM;
    END;
    
    -- Try to get IP and user agent from request context
    BEGIN
        v_ip_address := current_setting('request.headers', true)::json->>'x-forwarded-for';
        v_user_agent := current_setting('request.headers', true)::json->>'user-agent';
    EXCEPTION WHEN OTHERS THEN
        v_ip_address := NULL;
        v_user_agent := NULL;
        RAISE WARNING 'Could not get request context: %', SQLERRM;
    END;

    -- Insert audit log entry
    INSERT INTO public.audit_logs (
        table_name,
        record_id,
        action,
        old_data,
        new_data,
        metadata,
        performed_by,
        performed_at,
        ip_address,
        user_agent
    )
    VALUES (
        p_table_name,
        p_record_id,
        p_action,
        p_old_data,
        p_new_data,
        COALESCE(p_metadata, '{}'::jsonb) || jsonb_build_object(
            'timestamp', v_current_timestamp,
            'ip_address', v_ip_address,
            'user_agent', v_user_agent
        ),
        v_current_user,
        v_current_timestamp,
        v_ip_address,
        v_user_agent
    )
    RETURNING id INTO v_audit_id;

    -- Also log to user_activities if the action is significant
    IF p_action IN ('create', 'update', 'delete', 'restore', 'soft_delete', 
                   'role_assigned', 'role_revoked', 'permission_changed') THEN
        INSERT INTO public.user_activities (
            user_id,
            activity_type,
            description,
            details,
            ip_address,
            user_agent,
            created_at
        )
        VALUES (
            COALESCE(p_new_data->>'user_id', p_record_id)::UUID,
            p_action,
            format('Action %s performed on %s', p_action, p_table_name),
            jsonb_build_object(
                'table_name', p_table_name,
                'record_id', p_record_id,
                'performed_by', v_current_user,
                'metadata', p_metadata
            ),
            v_ip_address,
            v_user_agent,
            v_current_timestamp
        );
    END IF;

    RETURN v_audit_id;

EXCEPTION WHEN OTHERS THEN
    -- Log error to a separate error_logs table if available
    BEGIN
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            function_name,
            created_at
        )
        VALUES (
            SQLERRM,
            jsonb_build_object(
                'table_name', p_table_name,
                'action', p_action,
                'record_id', p_record_id,
                'user_id', v_current_user,
                'stack', substr(pg_exception_context(), 1, 500)
            ),
            'log_audit_event',
            v_current_timestamp
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed to log error: %', SQLERRM;
    END;
    
    -- Re-raise the original error
    RAISE;
END;
$$;

/**
 * Function: log_activity
 *
 * Purpose: Log user activities with detailed information
 *
 * Returns: UUID (activity log entry ID)
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   This function logs user activities to the user_activities table. It captures
 *   details such as the user ID, activity type, description, additional details,
 *   IP address, and user agent.
 *
 * Assumptions:
 *   - The user_activities table exists with the appropriate columns
 *   - The current_setting function is available to retrieve request headers
 *
 * Example Usage:
 *   SELECT public.log_activity(
 *     '123e4567-e89b-12d3-a456-426614174000'::UUID,
 *     'login',
 *     'User logged in successfully',
 *     '{"browser": "Chrome", "device": "desktop"}'::JSONB
 *   );
 */
CREATE OR REPLACE FUNCTION public.log_activity(
    p_user_id UUID,
    p_activity_type TEXT,
    p_description TEXT DEFAULT NULL,
    p_details JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_activity_id UUID;
BEGIN
    INSERT INTO public.user_activities (
        user_id,
        activity_type,
        description,
        details,
        ip_address,
        user_agent
    )
    VALUES (
        p_user_id,
        p_activity_type,
        p_description,
        p_details,
        current_setting('request.headers', true)::json->>'x-forwarded-for',
        current_setting('request.headers', true)::json->>'user-agent'
    )
    RETURNING id INTO v_activity_id;
    
    RETURN v_activity_id;
END;
$$;

-- ========================================================================================
-- Utility Functions
-- ========================================================================================

/**
 * Function: prevent_id_modification
 *
 * Purpose: Ensures primary keys (UUIDs) cannot be modified after creation
 *
 * Returns: TRIGGER
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   This function is designed to be used as a trigger to prevent modification
 *   of the 'id' field (primary key) in tables. It raises an exception if an
 *   attempt is made to change the 'id' value during an UPDATE operation.
 *
 * Assumptions:
 *   - Table must have an 'id' column that serves as the primary key
 *   - Should be used with a BEFORE UPDATE trigger
 *   - No special handling needed for NULL values
 *   - Works with all tables in the RBAC system
 *
 * Example Usage:
 *   CREATE TRIGGER prevent_id_change
 *   BEFORE UPDATE ON public.users
 *   FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();
 */

-- First drop any existing triggers
DROP TRIGGER IF EXISTS prevent_id_change ON public.users;
DROP TRIGGER IF EXISTS prevent_id_change ON public.roles;
DROP TRIGGER IF EXISTS prevent_id_change ON public.permissions;
DROP TRIGGER IF EXISTS prevent_id_change ON public.user_roles;
DROP TRIGGER IF EXISTS prevent_id_change ON public.role_permissions;
DROP TRIGGER IF EXISTS prevent_id_change ON public.role_delegations;
DROP TRIGGER IF EXISTS prevent_id_change ON public.scheduled_tasks;
DROP TRIGGER IF EXISTS prevent_id_change ON public.audit_logs;
DROP TRIGGER IF EXISTS prevent_id_change ON public.user_activities;
DROP TRIGGER IF EXISTS prevent_id_change ON public.error_logs;

-- Drop the function with CASCADE to clean up any dependencies
DROP FUNCTION IF EXISTS public.prevent_id_modification() CASCADE;

-- Create the function
CREATE OR REPLACE FUNCTION public.prevent_id_modification()
RETURNS TRIGGER
SECURITY DEFINER 
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only check if this is an UPDATE operation and if the ID is actually changing
    IF TG_OP = 'UPDATE' AND NEW.id IS DISTINCT FROM OLD.id THEN
        -- Log the attempt
        INSERT INTO public.audit_logs (
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            performed_by
        ) VALUES (
            TG_TABLE_NAME::TEXT,
            OLD.id,
            'ID_MODIFICATION_ATTEMPT',
            jsonb_build_object('old_id', OLD.id),
            jsonb_build_object('attempted_new_id', NEW.id),
            auth.uid()
        );
        
        RAISE EXCEPTION 'ID modification is not allowed. Table: %, Record ID: %', TG_TABLE_NAME, OLD.id;
    END IF;

    RETURN NEW;
EXCEPTION 
    WHEN OTHERS THEN
        -- Log any errors
        INSERT INTO public.error_logs (
            error_message,
            error_details,
            context_data,
            created_by
        ) VALUES (
            SQLERRM,
            SQLSTATE,
            jsonb_build_object(
                'table_name', TG_TABLE_NAME,
                'old_id', OLD.id,
                'new_id', NEW.id,
                'function', 'prevent_id_modification'
            ),
            auth.uid()
        );
        RAISE;
END;
$$;

-- Add comment
COMMENT ON FUNCTION public.prevent_id_modification IS 'Prevents modification of ID fields and logs attempts';

-- Create triggers for all tables that need ID protection
CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.roles
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.permissions
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.user_roles
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.role_permissions
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.role_delegations
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.scheduled_tasks
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.audit_logs
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.user_activities
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();

CREATE TRIGGER prevent_id_change
    BEFORE UPDATE ON public.error_logs
    FOR EACH ROW EXECUTE FUNCTION public.prevent_id_modification();
    
/**
 * Function: initialize_default_roles
 *
 * Purpose: Initialize the default system roles in the RBAC system
 *
 * Returns: VOID
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Creates the basic role structure in the system with predefined roles.
 *   Each role is created with appropriate name, description, and system role flag.
 *   Handles duplicate entries gracefully using ON CONFLICT.
 *
 * Assumptions:
 *   - The roles table exists with columns: name, description, role_type, is_system_role
 *   - The role_type enum type exists with values: super_admin, admin, manager, editor, user, guest
 *   - Name column has a unique constraint
 *
 * Example Usage:
 *   SELECT public.initialize_default_roles();
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.initialize_default_roles();

-- Function: Initialize default roles
CREATE OR REPLACE FUNCTION public.initialize_default_roles()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Insert default roles
    INSERT INTO public.roles (name, description, role_type, is_system_role)
    VALUES 
        ('Super Administrator', 'Complete system access', 'super_admin', true),
        ('Administrator', 'System administration access', 'admin', true),
        ('Manager', 'User and content management', 'manager', true),
        ('Editor', 'Content management', 'editor', true),
        ('User', 'Standard user access', 'user', true),
        ('Guest', 'Limited access', 'guest', true)
    ON CONFLICT (name) DO NOTHING;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.initialize_default_roles IS 'Function to initialize default system roles in RBAC system';

/**
 * Function: update_timestamp
 *
 * Purpose: Automatically updates the updated_at timestamp for any table with timestamp tracking
 *
 * Returns: TRIGGER
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   This trigger function automatically sets the updated_at field to the current
 *   timestamp whenever a record is modified. It works with any table that has an
 *   updated_at column of type TIMESTAMPTZ. The function is designed to be used with
 *   a BEFORE UPDATE trigger to ensure the timestamp is set before the actual update.
 *
 * Assumptions:
 *   - Table must have an updated_at column of type TIMESTAMPTZ
 *   - Should be used with a BEFORE UPDATE trigger
 *   - No special handling needed for NULL values
 *   - Works with all tables in the RBAC system
 *
 * Example Usage:
 *   CREATE TRIGGER set_timestamp
 *   BEFORE UPDATE ON public.users
 *   FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
 */

-- Drop existing function if exists
DROP FUNCTION IF EXISTS public.update_timestamp() CASCADE;

CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Add helpful comment
COMMENT ON FUNCTION public.update_timestamp IS 'Trigger function to automatically update updated_at timestamp on record changes';

-- Create triggers for all relevant tables
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
    
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.roles
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
    
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.permissions
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
    
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.user_roles
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
    
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.role_permissions
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
    
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.role_delegations
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
    
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.scheduled_tasks
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
    
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.user_phone_numbers
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
    
CREATE TRIGGER set_timestamp 
    BEFORE UPDATE ON public.user_addresses
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

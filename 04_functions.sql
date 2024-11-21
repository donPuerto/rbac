-- =====================================================================================
-- FUNCTIONS
-- =====================================================================================
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
 *    - assign_role_to_user(p_user_id UUID, p_role_type role_type) - Assign role
 *    - remove_role_from_user(p_user_id UUID, p_role_type role_type) - Remove role
 *    - get_user_roles(p_user_id UUID) - Get user's roles
 *    - handle_role_soft_delete() - Handle role deletion
 *
 * 3. Permission Management Functions
 *    - grant_permission(p_role_id UUID, p_permission_id UUID) - Grant permission
 *    - revoke_permission(p_role_id UUID, p_permission_id UUID) - Revoke permission
 *    - get_role_permissions(p_role_id UUID) - Get role's permissions
 *
 * 4. Audit and Logging Functions
 *    - log_audit_event() - Log audit events
 *    - log_activity() - Log user activities
 *    - process_audit() - Process audit logs
 *
 * 5. Utility Functions
 *    - prevent_id_modification() - Prevent ID changes
 *    - update_timestamp() - Update timestamp trigger
 *    - initialize_default_roles() - Initialize system roles
 *
 * Note: Each function includes comprehensive error handling, audit logging,
 * and follows security best practices with SECURITY DEFINER and proper schema settings.
 */

-- ========================================================================================
--
-- User Management Functions
--
-- ========================================================================================


-- ========================================================================================
-- 1. Core User Functions:
-- ========================================================================================

/**
 * Function: handle_new_user()
 * 
 * Purpose: Trigger function for new user creation with duplicate checks
 * 
 * Description:
 *   Handles the creation of new users with validation:
 *   - Checks for duplicate email in users table
 *   - Checks for duplicate phone in user_phone_numbers table (if provided)
 *   - Creates user record with metadata
 *   - Creates phone record if provided
 *   - Creates audit log entry
 *
 * Trigger: AFTER INSERT ON auth.users
 * Returns: TRIGGER
 * Security: SECURITY DEFINER
 */
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_phone TEXT;
    v_country_code TEXT;
BEGIN
    -- Check for duplicate email
    IF EXISTS (
        SELECT 1 FROM public.users 
        WHERE email = NEW.email 
        AND id != NEW.id
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Email address already exists: %', NEW.email;
    END IF;

    -- Get phone details from metadata if provided
    v_phone := NEW.raw_user_meta_data->>'phone';
    v_country_code := COALESCE(NEW.raw_user_meta_data->>'country_code', '+1');

    -- Check for duplicate phone if provided
    IF v_phone IS NOT NULL THEN
        IF EXISTS (
            SELECT 1 FROM public.user_phone_numbers
            WHERE phone_number = v_phone
            AND deleted_at IS NULL
        ) THEN
            RAISE EXCEPTION 'Phone number already exists: %', v_phone;
        END IF;
    END IF;

    -- Create user record
    INSERT INTO public.users (
        id,
        email,
        first_name,
        last_name,
        raw_user_meta_data,
        created_by,
        status,
        is_active
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'first_name', 'Unknown'),
        COALESCE(NEW.raw_user_meta_data->>'last_name', 'User'),
        NEW.raw_user_meta_data,
        NEW.id,
        'active',
        TRUE
    );

    -- Create phone record if phone number provided
    IF v_phone IS NOT NULL THEN
        INSERT INTO public.user_phone_numbers (
            user_id,
            phone_number,
            phone_type,
            is_primary,
            country_code,
            created_by
        ) VALUES (
            NEW.id,
            v_phone,
            COALESCE(NEW.raw_user_meta_data->>'phone_type', 'mobile'),
            TRUE, -- First phone number is primary
            v_country_code,
            NEW.id
        );
    END IF;

    -- Log the new user creation
    PERFORM log_audit_event(
        'users',
        NEW.id,
        'create',
        NULL,
        jsonb_build_object(
            'email', NEW.email,
            'first_name', COALESCE(NEW.raw_user_meta_data->>'first_name', 'Unknown'),
            'last_name', COALESCE(NEW.raw_user_meta_data->>'last_name', 'User'),
            'phone', v_phone,
            'country_code', v_country_code
        )
    );

    RETURN NEW;
END;
$$;
--
--
--
/**
 * Function: is_user_active()
 * 
 * Purpose: Checks if a user account is active and not deleted
 * 
 * Parameters:
 *   - p_user_id UUID: The ID of the user to check
 * 
 * Returns: BOOLEAN
 *   - TRUE if user exists, is active, and not deleted
 *   - FALSE otherwise
 *
 * Security: SECURITY DEFINER
 * Stability: STABLE
 *
 * Description:
 *   Performs a comprehensive check of user status by verifying:
 *   - User exists in the database
 *   - User is not soft deleted (deleted_at IS NULL)
 *   - User is marked as active (is_active = TRUE)
 *   - User status is 'active'
 *
 * Example Usage:
 *   SELECT is_user_active('123e4567-e89b-12d3-a456-426614174000');
 */
CREATE OR REPLACE FUNCTION public.is_user_active(
    p_user_id UUID
)
RETURNS BOOLEAN
STABLE
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM users u
        WHERE u.id = p_user_id 
        AND u.is_active = true 
        AND u.status = 'active'
        AND u.deleted_at IS NULL
    );
END;
$$;
--
--
--
/*
* Function: soft_delete_user()
*
Purpose: 
  Performs a soft delete on a user record by:
  - Marking the user as inactive
  - Setting deletion timestamp and user
  - Creating audit logs
  The function includes validations and error handling to ensure proper deletion.

Parameters:
  p_user_id UUID - The ID of the user to soft delete

Returns:
  BOOLEAN - true if deletion successful, false if user not found or error occurs

Example Usage:
-- Soft delete a specific user
SELECT public.soft_delete_user('123e4567-e89b-12d3-a456-426614174000');

-- Use in a transaction
BEGIN;
  -- Attempt to soft delete
  IF public.soft_delete_user(user_id) THEN
    -- Perform additional cleanup if needed
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
END;

Notes:
  - Requires authenticated user context (auth.uid())
  - Creates audit log entry
  - Does not physically delete the record
*/
CREATE OR REPLACE FUNCTION public.soft_delete_user(
    p_user_id UUID
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_user UUID;
    v_rows_affected INTEGER;
BEGIN
    -- Get current user ID from session
    BEGIN
        v_current_user := auth.uid();
        IF v_current_user IS NULL THEN
            RAISE EXCEPTION 'No authenticated user found';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to get current user: %', SQLERRM;
    END;
    
    -- Check if user exists and is not already deleted
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE id = p_user_id 
        AND deleted_at IS NULL
    ) THEN
        RAISE NOTICE 'User not found or already deleted';
        RETURN false;
    END IF;

    -- Perform soft delete
    UPDATE public.users
    SET 
        deleted_at = CURRENT_TIMESTAMP,
        deleted_by = v_current_user,
        updated_at = CURRENT_TIMESTAMP,
        updated_by = v_current_user,
        is_active = false
    WHERE id = p_user_id
    AND deleted_at IS NULL
    RETURNING 1 INTO v_rows_affected;

    -- Verify update was successful
    IF v_rows_affected = 0 THEN
        RAISE EXCEPTION 'Failed to update user';
    END IF;

    -- Log the audit event
    BEGIN
        PERFORM log_audit_event(
            'users',
            'soft_delete',
            p_user_id,
            NULL,
            jsonb_build_object('deleted_by', v_current_user)
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed to log audit event: %', SQLERRM;
        -- Continue execution even if logging fails
    END;

    RETURN true;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error in soft_delete_user: %', SQLERRM;
    RETURN false;
END;
$$;
--
--
--
/*
* Function: restore_deleted_user()
*
Purpose: 
  Restores a previously soft-deleted user account by:
  - Clearing deletion markers
  - Reactivating the account
  - Logging the restoration in audit trail
  
Parameters:
  p_user_id UUID - The ID of the soft-deleted user to restore

Returns:
  BOOLEAN - true if restoration successful, false if user not found or not deleted

Example Usage:
-- Restore a soft-deleted user
SELECT public.restore_deleted_user('123e4567-e89b-12d3-a456-426614174000');

-- Use in conditional logic
IF public.restore_deleted_user(user_id) THEN
    -- Handle successful restoration
ELSE
    -- Handle failed restoration
END IF;

Notes:
  - Requires authenticated user context (auth.uid())
  - Only works on soft-deleted users
  - Creates audit log entry for the restoration
*/
CREATE OR REPLACE FUNCTION public.restore_deleted_user(
    p_user_id UUID
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_user UUID;
BEGIN
    -- Get current user ID from session
    v_current_user := auth.uid();
    
    -- Check if user exists and is deleted
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE id = p_user_id 
        AND deleted_at IS NOT NULL
    ) THEN
        RETURN false;
    END IF;

    -- Restore user
    UPDATE public.users
    SET 
        deleted_at = NULL,
        deleted_by = NULL,
        updated_at = CURRENT_TIMESTAMP,
        updated_by = v_current_user,
        is_active = true
    WHERE id = p_user_id;

    -- Log the restoration
    PERFORM log_audit_event(
        'users',
        p_user_id,
        'restore',
        NULL,
        jsonb_build_object('restored_by', v_current_user)
    );

    RETURN true;
END;
$$;
--
--
--
/*
* Function: restore_deleted_user()
*
Purpose: 
  Restores a previously soft-deleted user account by:
  - Clearing deletion markers
  - Reactivating the account
  - Logging the restoration in audit trail
  
Parameters:
  p_user_id UUID - The ID of the soft-deleted user to restore
  p_restored_by UUID - The ID of the user performing the restoration
  p_reason TEXT - Optional reason for restoration

Returns:
  BOOLEAN - true if restoration successful, false if user not found or not deleted

Example Usage:
-- Restore a soft-deleted user
SELECT public.restore_deleted_user('123e4567-e89b-12d3-a456-426614174000', '987fcdeb-51a2-4bc3-9876-543210987654', 'Account restored upon user request');

-- Use in conditional logic
IF public.restore_deleted_user(user_id, restored_by, reason) THEN
    -- Handle successful restoration
ELSE
    -- Handle failed restoration
END IF;

Notes:
  - Requires authenticated user context (auth.uid())
  - Only works on soft-deleted users
  - Creates audit log entry for the restoration
*/
CREATE OR REPLACE FUNCTION public.restore_deleted_user(
    p_user_id UUID,
    p_restored_by UUID,
    p_reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
BEGIN
    -- Check if user exists and is deleted
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = p_user_id 
        AND deleted_at IS NOT NULL
    ) THEN
        RETURN FALSE;
    END IF;

    -- Capture old data for audit
    SELECT jsonb_build_object(
        'email', email,
        'status', status,
        'is_active', is_active,
        'deleted_at', deleted_at,
        'deleted_by', deleted_by,
        'updated_at', updated_at,
        'updated_by', updated_by
    )
    INTO v_old_data
    FROM public.users
    WHERE id = p_user_id;

    -- Restore the user
    UPDATE public.users
    SET deleted_at = NULL,
        deleted_by = NULL,
        is_active = TRUE,
        status = 'active',
        updated_at = CURRENT_TIMESTAMP,
        updated_by = p_restored_by
    WHERE id = p_user_id
    AND deleted_at IS NOT NULL
    RETURNING jsonb_build_object(
        'email', email,
        'status', status,
        'is_active', is_active,
        'deleted_at', deleted_at,
        'deleted_by', deleted_by,
        'updated_at', updated_at,
        'updated_by', updated_by
    ) INTO v_new_data;

    -- If user was found and restored
    IF FOUND THEN
        -- Log the activity
        PERFORM log_activity(
            p_restored_by,
            'user_restored',
            COALESCE(p_reason, 'User account restored'),
            jsonb_build_object(
                'user_id', p_user_id,
                'restored_by', p_restored_by,
                'reason', p_reason,
                'restored_at', CURRENT_TIMESTAMP
            )
        );

        -- Create audit log
        PERFORM log_audit_event(
            'users',
            p_user_id,
            'restore',
            v_old_data,
            v_new_data,
            p_restored_by
        );

        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$;
--
--
--
/**
 * Function: get_user_profile()
 * 
 * Purpose: Get complete user profile including roles, phone numbers, and addresses
 * 
 * Parameters:
 *   - p_user_id UUID: The ID of the user to get profile for
 *
 * Returns: JSONB
 *   - Complete user profile including:
 *     * Basic user information
 *     * Assigned roles
 *     * Phone numbers
 *     * Addresses
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Retrieves a comprehensive user profile by:
 *   - Getting basic user information
 *   - Including all active roles
 *   - Including all active phone numbers
 *   - Including all active addresses
 *   - Excluding soft-deleted records
 *
 * Example Usage:
 *   SELECT get_user_profile('123e4567-e89b-12d3-a456-426614174000');
 */
CREATE OR REPLACE FUNCTION public.get_user_profile(p_user_id UUID)
RETURNS JSONB
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile JSONB;
BEGIN
    SELECT jsonb_build_object(
        'user', jsonb_build_object(
            'id', u.id,
            'email', u.email,
            'first_name', u.first_name,
            'last_name', u.last_name,
            'display_name', u.display_name,
            'status', u.status,
            'is_active', u.is_active,
            'created_at', u.created_at
        ),
        'roles', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'role_id', r.id,
                'name', r.name,
                'role_type', r.role_type
            ))
            FROM user_roles ur
            JOIN roles r ON r.id = ur.role_id
            WHERE ur.user_id = u.id
            AND ur.deleted_at IS NULL
        ), '[]'::jsonb),
        'phones', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'phone_number', p.phone_number,
                'phone_type', p.phone_type,
                'is_primary', p.is_primary,
                'country_code', p.country_code
            ))
            FROM user_phone_numbers p
            WHERE p.user_id = u.id
            AND p.deleted_at IS NULL
        ), '[]'::jsonb),
        'addresses', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'address_type', a.address_type,
                'street_address', a.street_address,
                'city', a.city,
                'state_province', a.state_province,
                'country', a.country,
                'is_primary', a.is_primary
            ))
            FROM user_addresses a
            WHERE a.user_id = u.id
            AND a.deleted_at IS NULL
        ), '[]'::jsonb)
    ) INTO v_profile
    FROM users u
    WHERE u.id = p_user_id
    AND u.deleted_at IS NULL;

    RETURN v_profile;
END;
$$;
--
--
--
/**
 * Function: update_user_status()
 *
 * Purpose: Update user status with comprehensive audit logging
 * 
 * Parameters:
 *   - p_user_id UUID: The ID of the user to update
 *   - p_status TEXT: New status to set
 *   - p_updated_by UUID: ID of the user making the change
 *
 * Returns: BOOLEAN
 *   - TRUE if status was updated
 *   - FALSE if user not found or already deleted
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Updates user status with proper tracking by:
 *   - Validating user exists
 *   - Updating status
 *   - Creating audit log with old and new status
 *   - Tracking who made the change
 *
 * Example Usage:
 *   SELECT update_user_status(
 *     '123e4567-e89b-12d3-a456-426614174000',
 *     'inactive',
 *     '987fcdeb-51a2-4bc3-9876-543210987654'
 *   );
 */
CREATE OR REPLACE FUNCTION public.update_user_status(
    p_user_id UUID,
    p_status TEXT,
    p_updated_by UUID
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_status TEXT;
BEGIN
    -- Get current status for audit
    SELECT status INTO v_old_status
    FROM users
    WHERE id = p_user_id;

    -- Update status
    UPDATE users
    SET 
        status = p_status,
        updated_at = CURRENT_TIMESTAMP,
        updated_by = p_updated_by
    WHERE id = p_user_id
    AND deleted_at IS NULL;

    -- Log the change
    PERFORM log_audit_event(
        'users',
        p_user_id,
        'status_update',
        jsonb_build_object('status', v_old_status),
        jsonb_build_object('status', p_status),
        p_updated_by
    );

    RETURN FOUND;
END;
$$;
--
--
--
/*
 * Function: search_users
 * 
 * Purpose: Search and filter users with pagination
 * 
 * Parameters:
 *   - p_search TEXT: Search term for email, first_name, last_name
 *   - p_status TEXT[]: Array of status values to filter by
 *   - p_role_types role_type[]: Array of role types to filter by
 *   - p_limit INTEGER: Maximum number of results (default 10)
 *   - p_offset INTEGER: Number of results to skip (default 0)
 *
 * Returns: TABLE
 *   - total_count BIGINT: Total number of matching records
 *   - users JSONB: Array of user records with roles
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Performs flexible user search by:
 *   - Applying text search on multiple fields
 *   - Filtering by status and role types
 *   - Including role information
 *   - Supporting pagination
 *   - Excluding soft-deleted records
 *
 * Example Usage:
 *   SELECT * FROM search_users(
 *     p_search => 'john',
 *     p_status => ARRAY['active', 'pending'],
 *     p_role_types => ARRAY['user', 'admin']::role_type[],
 *     p_limit => 20,
 *     p_offset => 0
 *   );
*/
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
BEGIN
    RETURN QUERY
    WITH filtered_users AS (
        SELECT DISTINCT u.*
        FROM users u
        LEFT JOIN user_roles ur ON ur.user_id = u.id AND ur.deleted_at IS NULL
        LEFT JOIN roles r ON r.id = ur.role_id AND r.deleted_at IS NULL
        WHERE u.deleted_at IS NULL
        AND (
            p_search IS NULL 
            OR u.email ILIKE '%' || p_search || '%'
            OR u.first_name ILIKE '%' || p_search || '%'
            OR u.last_name ILIKE '%' || p_search || '%'
        )
        AND (p_status IS NULL OR u.status = ANY(p_status))
        AND (p_role_types IS NULL OR r.role_type = ANY(p_role_types))
    )
    SELECT 
        (SELECT COUNT(*) FROM filtered_users)::BIGINT,
        COALESCE(jsonb_agg(jsonb_build_object(
            'id', u.id,
            'email', u.email,
            'first_name', u.first_name,
            'last_name', u.last_name,
            'status', u.status,
            'created_at', u.created_at,
            'roles', COALESCE((
                SELECT jsonb_agg(DISTINCT r.name)
                FROM user_roles ur
                JOIN roles r ON r.id = ur.role_id
                WHERE ur.user_id = u.id
                AND ur.deleted_at IS NULL
            ), '[]'::jsonb)
        )), '[]'::jsonb)
    FROM (
        SELECT * FROM filtered_users
        ORDER BY created_at DESC
        LIMIT p_limit
        OFFSET p_offset
    ) u;
END;
$$;
--
--
--
/**
 * Function: validate_user_access
 * 
 * Purpose: Check if user has access to specific resource/action
 * 
 * Parameters:
 *   - p_user_id UUID: The ID of the user to check
 *   - p_resource TEXT: Resource to check access for
 *   - p_action TEXT: Action to check permission for
 *
 * Returns: BOOLEAN
 *   - TRUE if user has access
 *   - FALSE if user does not have access
 *
 * Security: SECURITY DEFINER
 *
 * Description:
 *   Validates user access rights by:
 *   - Checking user is active
 *   - Verifying role assignments
 *   - Checking permission grants
 *   - Considering soft-deleted records
 *
 * Example Usage:
 *   SELECT validate_user_access(
 *     '123e4567-e89b-12d3-a456-426614174000',
 *     'documents',
 *     'read'
 *   );
 */
CREATE OR REPLACE FUNCTION public.validate_user_access(
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
        FROM users u
        JOIN user_roles ur ON ur.user_id = u.id
        JOIN roles r ON r.id = ur.role_id
        JOIN role_permissions rp ON rp.role_id = r.id
        JOIN permissions p ON p.id = rp.permission_id
        WHERE u.id = p_user_id
        AND u.is_active = true
        AND u.deleted_at IS NULL
        AND ur.deleted_at IS NULL
        AND r.deleted_at IS NULL
        AND p.resource = p_resource
        AND p.action = p_action
    );
END;
$$;
-- ========================================================================================
-- Role Management Functions
-- ========================================================================================

-- ========================================================================================
-- 1. Core Role Functions:
-- ========================================================================================


-- =====================================================================================
-- Function: get_role_hierarchy_level
-- Purpose: Helper function to convert role_type to numeric hierarchy level
-- Parameters:
--   - p_role_type: The role type to get hierarchy level for
-- Returns: Integer representing the hierarchy level (1-7, higher = more privileges)
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.get_role_hierarchy_level(
    p_role_type role_type
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN CASE p_role_type
        WHEN 'super_admin' THEN 7
        WHEN 'admin' THEN 6
        WHEN 'manager' THEN 5
        WHEN 'moderator' THEN 4
        WHEN 'editor' THEN 3
        WHEN 'user' THEN 2
        WHEN 'guest' THEN 1
        ELSE 0
    END;
END;
$$;
--
--
--
-- =====================================================================================
-- Function: manage_user_role
-- Purpose: Unified function to assign or revoke roles with hierarchy validation
-- Parameters:
--   - p_user_id: The target user to manage role for
--   - p_role_type: The role type to assign/revoke
--   - p_managed_by: The user performing the action
--   - p_action: 'assign' or 'revoke'
-- Returns: boolean indicating success/failure
-- Note: This replaces assign_role_to_user, assign_user_role, and revoke_user_role
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.manage_user_role(
    p_user_id UUID,
    p_role_type role_type,
    p_managed_by UUID,
    p_action TEXT DEFAULT 'assign'
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_id UUID;
    v_manager_role_level INTEGER;
    v_target_role_level INTEGER;
    v_manager_highest_role role_type;
    v_current_timestamp TIMESTAMPTZ := now();
BEGIN
    -- Validate parameters
    IF p_action NOT IN ('assign', 'revoke') THEN
        RAISE EXCEPTION 'Invalid action. Must be either ''assign'' or ''revoke''';
    END IF;

    -- Validate user existence
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'Target user does not exist or is deleted';
    END IF;

    -- Get manager's highest role
    SELECT r.role_type INTO v_manager_highest_role
    FROM user_roles ur
    JOIN roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_managed_by
    AND ur.deleted_at IS NULL
    AND ur.is_active = true
    ORDER BY get_role_hierarchy_level(r.role_type) DESC
    LIMIT 1;

    -- Validate manager's role
    IF v_manager_highest_role IS NULL THEN
        RAISE EXCEPTION 'Manager has no active roles';
    END IF;

    -- Get hierarchy levels
    v_manager_role_level := get_role_hierarchy_level(v_manager_highest_role);
    v_target_role_level := get_role_hierarchy_level(p_role_type);

    -- Check if manager has sufficient privileges
    IF v_manager_role_level <= v_target_role_level THEN
        RAISE EXCEPTION 'Insufficient privileges. Your role level: %, Target role level: %', 
            v_manager_role_level, v_target_role_level;
    END IF;

    -- Get role ID
    SELECT id INTO v_role_id
    FROM public.roles
    WHERE role_type = p_role_type
    AND deleted_at IS NULL;

    -- Check if role exists
    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'Role % does not exist', p_role_type;
    END IF;

    -- Handle role management based on action
    IF p_action = 'assign' THEN
        INSERT INTO public.user_roles (
            user_id,
            role_id,
            assigned_by,
            assigned_at,
            created_by,
            created_at,
            is_active
        )
        VALUES (
            p_user_id,
            v_role_id,
            p_managed_by,
            v_current_timestamp,
            p_managed_by,
            v_current_timestamp,
            true
        )
        ON CONFLICT (user_id, role_id, deleted_at) 
        DO UPDATE SET
            updated_at = v_current_timestamp,
            updated_by = p_managed_by,
            is_active = true,
            deleted_at = NULL,
            deleted_by = NULL;
    ELSE
        UPDATE public.user_roles
        SET 
            deleted_at = v_current_timestamp,
            deleted_by = p_managed_by,
            updated_at = v_current_timestamp,
            updated_by = p_managed_by,
            is_active = false
        WHERE user_id = p_user_id
        AND role_id = v_role_id
        AND deleted_at IS NULL;
    END IF;

    -- Log in audit_logs
    INSERT INTO audit_logs (
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
        p_user_id,
        p_action || '_role',
        NULL,
        jsonb_build_object(
            'role_type', p_role_type,
            'managed_by', p_managed_by,
            'action', p_action
        ),
        p_managed_by,
        v_current_timestamp
    );

    -- Log in user_activities
    INSERT INTO user_activities (
        user_id,
        activity_type,
        description,
        details
    )
    VALUES (
        p_user_id,
        p_action || '_role',
        format('Role %s %s by %s', p_role_type, p_action, p_managed_by),
        jsonb_build_object(
            'role_type', p_role_type,
            'managed_by', p_managed_by,
            'action', p_action
        )
    );

    RETURN true;

EXCEPTION WHEN OTHERS THEN
    -- Log error in user_activities
    INSERT INTO user_activities (
        user_id,
        activity_type,
        description,
        details
    )
    VALUES (
        p_managed_by,
        'role_management_error',
        format('Error %s role %s: %s', p_action, p_role_type, SQLERRM),
        jsonb_build_object(
            'error', SQLERRM,
            'role_type', p_role_type,
            'target_user', p_user_id
        )
    );
    RETURN false;
END;
$$;
--
--
--
-- =====================================================================================
-- Function: check_user_role
-- Purpose: Check if a user has a specific role or higher role
-- Parameters:
--   - p_user_id: The user to check
--   - p_role_type: The role type to check for
--   - p_check_higher_roles: Whether to include higher roles in check
-- Returns: boolean indicating if user has role
-- Note: This replaces user_has_role
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.check_user_role(
    p_user_id UUID,
    p_role_type role_type,
    p_check_higher_roles BOOLEAN DEFAULT true
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        WHERE ur.user_id = p_user_id
        AND ur.deleted_at IS NULL
        AND r.deleted_at IS NULL
        AND ur.is_active = true
        AND r.is_active = true
        AND (
            CASE WHEN p_check_higher_roles THEN
                get_role_hierarchy_level(r.role_type) >= get_role_hierarchy_level(p_role_type)
            ELSE
                r.role_type = p_role_type
            END
        )
    );
END;
$$;
--
--
--
-- =====================================================================================
-- Function: get_user_roles
-- Purpose: Get all active roles for a user
-- Parameters:
--   - p_user_id: The user to get roles for
-- Returns: Table of role information
-- =====================================================================================
CREATE OR REPLACE FUNCTION public.get_user_roles(
    p_user_id UUID
)
RETURNS TABLE (
    role_type role_type,
    role_name TEXT,
    assigned_at TIMESTAMPTZ,
    assigned_by UUID,
    hierarchy_level INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.role_type,
        r.name,
        ur.assigned_at,
        ur.assigned_by,
        get_role_hierarchy_level(r.role_type)
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_user_id
    AND ur.deleted_at IS NULL
    AND ur.is_active = true
    AND r.deleted_at IS NULL
    AND r.is_active = true
    ORDER BY get_role_hierarchy_level(r.role_type) DESC;
END;
$$;
--
--
--
-- Function: Handle changes to user roles
-- Purpose: Manages role assignments and maintains audit trail
CREATE OR REPLACE FUNCTION public.handle_user_role_change()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_role_name TEXT;
BEGIN
    -- Get role name for logging
    SELECT name INTO v_role_name
    FROM public.roles
    WHERE id = NEW.role_id;

    -- Log role change activity
    PERFORM log_activity(
        NEW.user_id,
        CASE 
            WHEN TG_OP = 'INSERT' THEN 'role_assigned'
            WHEN TG_OP = 'UPDATE' AND NEW.is_active = false THEN 'role_deactivated'
            ELSE 'role_updated'
        END,
        format('User role %s %s', v_role_name, 
            CASE 
                WHEN TG_OP = 'INSERT' THEN 'assigned'
                WHEN TG_OP = 'UPDATE' AND NEW.is_active = false THEN 'deactivated'
                ELSE 'updated'
            END
        ),
        jsonb_build_object(
            'role_id', NEW.role_id,
            'role_name', v_role_name,
            'assigned_by', NEW.assigned_by
        )
    );

    RETURN NEW;
END;
$$;
--
--
--
-- Function: Handle role soft delete
-- Purpose: Manages the soft deletion of roles and related cleanup
CREATE OR REPLACE FUNCTION public.handle_role_soft_delete()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- Deactivate all user assignments for this role
    UPDATE public.user_roles
    SET 
        is_active = false,
        updated_at = now(),
        updated_by = NEW.deleted_by,
        deleted_at = NEW.deleted_at,
        deleted_by = NEW.deleted_by
    WHERE role_id = NEW.id
    AND deleted_at IS NULL;

    -- Deactivate all permission assignments for this role
    UPDATE public.role_permissions
    SET 
        is_active = false,
        updated_at = now(),
        updated_by = NEW.deleted_by,
        deleted_at = NEW.deleted_at,
        deleted_by = NEW.deleted_by
    WHERE role_id = NEW.id
    AND deleted_at IS NULL;

    -- Log the soft delete
    PERFORM log_activity(
        NEW.deleted_by,
        'role_deleted',
        format('Role %s soft deleted', NEW.name),
        jsonb_build_object(
            'role_name', NEW.name,
            'deleted_by', NEW.deleted_by,
            'deleted_at', NEW.deleted_at
        )
    );

    RETURN NEW;
END;
$$;
--
--
--
-- ========================================================================================
-- 2. Role Check Functions:
-- ========================================================================================
/*
Function: check_role_type
-- Purpose: Unified function to check if a user has a specific role or higher role level
-- Usage Examples:
--   SELECT check_role_type('admin');                            -- Check if current user is admin or higher
--   SELECT check_role_type('manager', user_id);                 -- Check if specific user is manager or higher
--   SELECT check_role_type('editor', user_id, false);          -- Check if user is exactly an editor
--   SELECT check_role_type(NULL, user_id);                     -- Check if user has any active role

COMMENT ON FUNCTION public.check_role_type IS 
'Unified function to check user role types with hierarchy support.
Parameters:
- p_role_type: The role type to check (NULL to check for any role)
- p_user_id: The user to check (defaults to current user)
- p_include_higher_roles: Whether to include higher roles in hierarchy
Returns: Boolean indicating if user has the requested role or higher

Examples:
SELECT check_role_type(''admin'');                    -- Check if current user is admin or higher
SELECT check_role_type(''manager'', user_id);         -- Check if specific user is manager or higher
SELECT check_role_type(''editor'', user_id, false);   -- Check if user is exactly an editor
SELECT check_role_type(NULL, user_id); 
*/
CREATE OR REPLACE FUNCTION public.check_role_type(
    p_role_type role_type DEFAULT NULL,          -- Role to check (NULL to check for any role)
    p_user_id UUID DEFAULT NULL,                 -- User to check (defaults to current user)
    p_include_higher_roles BOOLEAN DEFAULT true  -- Whether to include higher roles in hierarchy
)
RETURNS BOOLEAN
STABLE
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id UUID;
    v_requested_level INTEGER;
BEGIN
    -- Determine which user to check
    v_user_id := COALESCE(p_user_id, auth.uid());
    
    -- If no user ID available, return false
    IF v_user_id IS NULL THEN
        RETURN false;
    END IF;

    -- If no specific role type requested, check for any active role
    IF p_role_type IS NULL THEN
        RETURN EXISTS (
            SELECT 1
            FROM public.user_roles ur
            JOIN public.roles r ON r.id = ur.role_id
            WHERE ur.user_id = v_user_id
            AND ur.deleted_at IS NULL
            AND r.deleted_at IS NULL
            AND ur.is_active = true
            AND r.is_active = true
        );
    END IF;

    -- Get the hierarchy level of the requested role
    v_requested_level := get_role_hierarchy_level(p_role_type);

    -- Check for the role, considering hierarchy if requested
    RETURN EXISTS (
        SELECT 1
        FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        WHERE ur.user_id = v_user_id
        AND ur.deleted_at IS NULL
        AND r.deleted_at IS NULL
        AND ur.is_active = true
        AND r.is_active = true
        AND (
            CASE 
                WHEN p_include_higher_roles THEN
                    get_role_hierarchy_level(r.role_type) >= v_requested_level
                ELSE
                    r.role_type = p_role_type
            END
        )
    );
END;
$$;
--
--
--
--
-- Insert here
--
--
---
-- ========================================================================================
-- Audit and Logging Functions
-- ========================================================================================
-- ========================================================================================
-- 1. Audit Functions:
-- ========================================================================================
-- Function: Process audit for all tables
CREATE OR REPLACE FUNCTION public.process_audit()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        old_data := to_jsonb(OLD);
        new_data := to_jsonb(NEW);
    ELSIF (TG_OP = 'DELETE') THEN
        old_data := to_jsonb(OLD);
        new_data := NULL;
    ELSIF (TG_OP = 'INSERT') THEN
        old_data := NULL;
        new_data := to_jsonb(NEW);
    END IF;

    INSERT INTO public.audit_logs (
        table_name,
        record_id,
        action,
        old_data,
        new_data,
        performed_by
    )
    VALUES (
        TG_TABLE_NAME::TEXT,
        CASE 
            WHEN TG_OP = 'DELETE' THEN OLD.id
            ELSE NEW.id
        END,
        TG_OP,
        old_data,
        new_data,
        CASE 
            WHEN TG_OP = 'UPDATE' THEN NEW.updated_by
            WHEN TG_OP = 'DELETE' THEN NEW.deleted_by
            ELSE NEW.created_by
        END
    );

    RETURN NULL;
END;
$$;
--
--
--
-- Function: Prevent ID modification
-- Purpose: Ensures primary keys (UUIDs) cannot be modified after creation
CREATE OR REPLACE FUNCTION public.prevent_id_modification()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.id != OLD.id THEN
        RAISE EXCEPTION 'Modifying the id field is not allowed';
    END IF;
    RETURN NEW;
END;
$$;
--
--
--
-- Add helpful comment
/*
COMMENT ON FUNCTION public.log_audit_event IS 
'Logs audit events with comprehensive metadata and context.
Parameters:
- p_table_name: The name of the table being audited
- p_action: The type of action (create, update, delete, etc.)
- p_record_id: UUID of the record being audited
- p_old_data: Previous state of the record (for updates/deletes)
- p_new_data: New state of the record (for creates/updates)
- p_metadata: Additional contextual information
Returns: UUID of the created audit log entry

-- Example usage:

-- Log a create event
SELECT log_audit_event(
    'users',
    'create',
    '123e4567-e89b-12d3-a456-426614174000',
    NULL,
    jsonb_build_object('email', 'user@example.com', 'name', 'John Doe'),
    jsonb_build_object('source', 'registration')
);

-- Log an update event
SELECT log_audit_event(
    'users',
    'update',
    '123e4567-e89b-12d3-a456-426614174000',
    jsonb_build_object('email', 'old@example.com'),
    jsonb_build_object('email', 'new@example.com'),
    jsonb_build_object('reason', 'user_request')
);
*/
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
--
--
--
/*
Function: manage_user_role
Purpose: Comprehensive function for assigning and revoking user roles with hierarchy validation
Usage Examples:
  SELECT manage_user_role(user_id, 'editor', admin_id, 'assign');  -- Assign editor role
  SELECT manage_user_role(user_id, 'editor', admin_id, 'revoke');  -- Revoke editor role

COMMENT ON FUNCTION public.manage_user_role IS 
'Comprehensive function for managing user roles with hierarchy validation.
Parameters:
- p_user_id: Target user to manage role for
- p_role_type: Role type to assign/revoke
- p_managed_by: User performing the action
- p_action: Action to perform (''assign'' or ''revoke'')
Returns: Boolean indicating success/failure

Examples:
SELECT manage_user_role(user_id, ''editor'', admin_id, ''assign'');  -- Assign editor role
SELECT manage_user_role(user_id, ''editor'', admin_id, ''revoke'');  -- Revoke editor role
*/
CREATE OR REPLACE FUNCTION public.manage_user_role(
    p_user_id UUID,                -- Target user to manage role for
    p_role_type role_type,         -- Role type to assign/revoke
    p_managed_by UUID,             -- User performing the action
    p_action TEXT DEFAULT 'assign' -- Action to perform ('assign' or 'revoke')
)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_role_id UUID;
    v_manager_role_level INTEGER;
    v_target_role_level INTEGER;
    v_manager_highest_role role_type;
    v_current_timestamp TIMESTAMPTZ := now();
BEGIN
    -- Validate parameters
    IF p_action NOT IN ('assign', 'revoke') THEN
        RAISE EXCEPTION 'Invalid action. Must be either ''assign'' or ''revoke''';
    END IF;

    -- Validate user existence
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'Target user does not exist or is deleted';
    END IF;

    -- Get manager's highest role
    SELECT r.role_type INTO v_manager_highest_role
    FROM user_roles ur
    JOIN roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_managed_by
    AND ur.deleted_at IS NULL
    AND ur.is_active = true
    ORDER BY get_role_hierarchy_level(r.role_type) DESC
    LIMIT 1;

    -- Validate manager's role
    IF v_manager_highest_role IS NULL THEN
        RAISE EXCEPTION 'Manager has no active roles';
    END IF;

    -- Get hierarchy levels
    v_manager_role_level := get_role_hierarchy_level(v_manager_highest_role);
    v_target_role_level := get_role_hierarchy_level(p_role_type);

    -- Check if manager has sufficient privileges
    IF v_manager_role_level <= v_target_role_level THEN
        RAISE EXCEPTION 'Insufficient privileges to manage this role level';
    END IF;

    -- Get role ID
    SELECT id INTO v_role_id
    FROM public.roles
    WHERE role_type = p_role_type
    AND deleted_at IS NULL;

    -- Check if role exists
    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'Role % does not exist', p_role_type;
    END IF;

    -- Handle role management based on action
    IF p_action = 'assign' THEN
        INSERT INTO public.user_roles (
            user_id,
            role_id,
            assigned_by,
            assigned_at,
            created_by,
            created_at,
            is_active
        )
        VALUES (
            p_user_id,
            v_role_id,
            p_managed_by,
            v_current_timestamp,
            p_managed_by,
            v_current_timestamp,
            true
        )
        ON CONFLICT (user_id, role_id, deleted_at) 
        DO UPDATE SET
            updated_at = v_current_timestamp,
            updated_by = p_managed_by,
            is_active = true,
            deleted_at = NULL,
            deleted_by = NULL;
    ELSE
        UPDATE public.user_roles
        SET 
            deleted_at = v_current_timestamp,
            deleted_by = p_managed_by,
            updated_at = v_current_timestamp,
            updated_by = p_managed_by,
            is_active = false
        WHERE user_id = p_user_id
        AND role_id = v_role_id
        AND deleted_at IS NULL;
    END IF;

    -- Log action
    PERFORM log_audit_event(
        'user_roles',
        p_action || '_role',
        p_user_id,
        NULL,
        jsonb_build_object(
            'role_type', p_role_type,
            'managed_by', p_managed_by,
            'action', p_action
        )
    );

    RETURN true;

EXCEPTION WHEN OTHERS THEN
    -- Log error and return false
    PERFORM log_audit_event(
        'user_roles',
        'role_management_error',
        p_user_id,
        NULL,
        jsonb_build_object(
            'error', SQLERRM,
            'role_type', p_role_type,
            'action', p_action
        )
    );
    RETURN false;
END;
$$;
--
--
--
/*
Function: manage_super_admin
Purpose: Specialized function for managing super admin role with additional safety checks
Usage Examples:
  SELECT manage_super_admin(user_id, 'grant');   -- Grant super admin privileges
  SELECT manage_super_admin(user_id, 'revoke');  -- Revoke super admin privileges

COMMENT ON FUNCTION public.manage_super_admin IS 
'Specialized function for managing super admin role with additional safety checks.
Parameters:
- p_user_id: Target user for super admin management
- p_action: Action to perform (''grant'' or ''revoke'')
Returns: Boolean indicating success/failure

Features:
- Prevents removal of last super admin
- Requires super admin privileges to use
- Maintains audit trail
- Includes safety checks

Examples:
SELECT manage_super_admin(user_id, ''grant'');   -- Grant super admin privileges
SELECT manage_super_admin(user_id, ''revoke'');  -- Revoke super admin privileges';
*/
CREATE OR REPLACE FUNCTION public.manage_super_admin(
    p_user_id UUID,    -- Target user for super admin management
    p_action TEXT      -- Action to perform ('grant' or 'revoke')
)
RETURNS BOOLEAN
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_user UUID;
    v_role_id UUID;
    v_current_timestamp TIMESTAMPTZ := now();
BEGIN
    -- Input validation
    IF p_action NOT IN ('grant', 'revoke') THEN
        RAISE EXCEPTION 'Invalid action. Must be either ''grant'' or ''revoke''';
    END IF;

    -- Get current user
    v_current_user := auth.uid();
    IF v_current_user IS NULL THEN
        RAISE EXCEPTION 'No authenticated user found';
    END IF;

    -- Check if current user is super admin
    IF NOT check_role_type('super_admin'::role_type) THEN
        RAISE EXCEPTION 'Only super admins can manage super admin roles';
    END IF;

    -- Get super_admin role ID
    SELECT id INTO v_role_id
    FROM public.roles
    WHERE role_type = 'super_admin'
    AND deleted_at IS NULL
    AND is_active = true;

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'Super admin role not found in system';
    END IF;

    -- Prevent revoking last super admin
    IF p_action = 'revoke' AND (
        SELECT COUNT(*) = 1
        FROM public.user_roles ur
        JOIN public.roles r ON r.id = ur.role_id
        WHERE r.role_type = 'super_admin'
        AND ur.deleted_at IS NULL
        AND ur.is_active = true
    ) THEN
        RAISE EXCEPTION 'Cannot revoke last super admin';
    END IF;

    -- Perform the requested action
    IF p_action = 'grant' THEN
        INSERT INTO public.user_roles (
            user_id,
            role_id,
            assigned_by,
            assigned_at,
            created_by,
            created_at,
            is_active
        )
        VALUES (
            p_user_id,
            v_role_id,
            v_current_user,
            v_current_timestamp,
            v_current_user,
            v_current_timestamp,
            true
        )
        ON CONFLICT (user_id, role_id, deleted_at)
        DO UPDATE SET
            is_active = true,
            deleted_at = NULL,
            deleted_by = NULL,
            updated_at = v_current_timestamp,
            updated_by = v_current_user;
    ELSE
        UPDATE public.user_roles
        SET 
            is_active = false,
            deleted_at = v_current_timestamp,
            deleted_by = v_current_user,
            updated_at = v_current_timestamp,
            updated_by = v_current_user
        WHERE user_id = p_user_id
        AND role_id = v_role_id
        AND deleted_at IS NULL;
    END IF;

    -- Log the action
    PERFORM log_audit_event(
        'user_roles',
        'super_admin_' || p_action,
        p_user_id,
        NULL,
        jsonb_build_object(
            'performed_by', v_current_user,
            'action', p_action
        )
    );

    RETURN true;

EXCEPTION WHEN OTHERS THEN
    -- Log error and return false
    PERFORM log_audit_event(
        'user_roles',
        'super_admin_error',
        p_user_id,
        NULL,
        jsonb_build_object(
            'error', SQLERRM,
            'action', p_action
        )
    );
    RETURN false;
END;
$$;
--
--
--
-- ========================================================================================
-- 2. Activity Logging:
-- ========================================================================================
-- Function: Log user activity
CREATE OR REPLACE FUNCTION public.log_activity(
    p_user_id UUID,
    p_activity_type TEXT,
    p_description TEXT DEFAULT NULL,
    p_details JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
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
--
--
--
-- ========================================================================================
-- Permission Functions:
-- ========================================================================================
-- Function: Get user permissions
CREATE OR REPLACE FUNCTION public.get_user_permissions(
    p_user_id UUID
)
RETURNS TABLE (
    permission_name TEXT,
    resource TEXT,
    action TEXT
)
STABLE
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        p.name as permission_name,
        p.resource,
        p.action
    FROM public.permissions p
    JOIN public.role_permissions rp ON rp.permission_id = p.id
    JOIN public.roles r ON r.id = rp.role_id
    JOIN public.user_roles ur ON ur.role_id = r.id
    WHERE ur.user_id = p_user_id
    AND p.deleted_at IS NULL
    AND rp.deleted_at IS NULL
    AND r.deleted_at IS NULL
    AND ur.deleted_at IS NULL
    AND p.is_active = true
    AND r.is_active = true
    AND ur.is_active = true;
END;
$$;
--
--
--
-- ========================================================================================
-- Utility Functions
-- ========================================================================================

-- Function: Update timestamp
-- Purpose: Automatically updates the updated_at timestamp on record changes
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

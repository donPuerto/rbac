-- ========================================================================================
-- FUNCTIONS
-- ========================================================================================


-- ========================================================================================
-- User Management Functions
-- ========================================================================================

-- ========================================================================================
/*
 1. Core User Functions:
    * handle_new_user() - Trigger function for new user creation
    * is_user_active(p_user_id UUID) - Check user active status
    * soft_delete_user(p_user_id UUID) - Soft delete user
    * restore_deleted_user(p_user_id UUID) - Restore soft-deleted user
    * handle_user_soft_delete() - Trigger function for user soft deletion
    * user_exists(p_user_id UUID, p_include_deleted BOOLEAN DEFAULT false) - Check user existence with detailed status 
*/
-- ========================================================================================
/*
Purpose: 
  Trigger function that handles the creation of new users in the system:
  - Creates user record with provided data
  - Assigns default user role automatically
  - Records audit logs and user activity
  - Validates basic data (email format, required fields)

Example Usage:

1. Create trigger:
CREATE TRIGGER handle_new_user_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

2. Function is automatically called when inserting new user:
INSERT INTO auth.users (
    email,
    raw_user_meta_data
) VALUES (
    'john.doe@example.com',
    '{
        "first_name": "John",
        "last_name": "Doe",
        "preferred_language": "en",
        "timezone": "UTC"
    }'
);
*/
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    default_role_id UUID;
    v_current_timestamp TIMESTAMPTZ := now();
    v_user_data JSONB;
BEGIN
    -- Validate email format
    IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format';
    END IF;

    -- Prepare user data
    v_user_data := jsonb_build_object(
        'email', LOWER(NEW.email),
        'first_name', TRIM(COALESCE(NEW.raw_user_meta_data->>'first_name', '')),
        'last_name', TRIM(COALESCE(NEW.raw_user_meta_data->>'last_name', '')),
        'display_name', TRIM(COALESCE(NEW.raw_user_meta_data->>'display_name', 
            NEW.raw_user_meta_data->>'first_name' || ' ' || NEW.raw_user_meta_data->>'last_name')),
        'status', 'active',
        'preferred_language', COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'en'),
        'timezone', COALESCE(NEW.raw_user_meta_data->>'timezone', 'UTC'),
        'notification_preferences', '{"email": true, "sms": false}',
        'is_active', true,
        'created_at', v_current_timestamp,
        'created_by', NEW.id
    );

    -- Insert into public.users with basic info
    INSERT INTO public.users (
        id, 
        email,
        first_name,
        last_name,
        display_name,
        status,
        preferred_language,
        timezone,
        notification_preferences,
        is_active,
        created_at,
        created_by,
        updated_at,
        updated_by    
    )
    VALUES (
        NEW.id, 
        v_user_data->>'email',
        v_user_data->>'first_name',
        v_user_data->>'last_name',
        v_user_data->>'display_name',
        v_user_data->>'status',
        v_user_data->>'preferred_language',
        v_user_data->>'timezone',
        (v_user_data->>'notification_preferences')::jsonb,
        (v_user_data->>'is_active')::boolean,
        v_current_timestamp,
        NEW.id,
        v_current_timestamp,
        NEW.id        
    );

    -- Log user creation with comprehensive data
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
        'users',
        NEW.id,
        'user_created',
        NULL,
        v_user_data,
        NEW.id,
        v_current_timestamp
    );
    
    -- Get default role id (user role)
    SELECT id INTO default_role_id 
    FROM public.roles 
    WHERE role_type = 'user'
    AND deleted_at IS NULL
    AND is_active = true;
    
    -- Assign default role with schema-matched fields
    IF default_role_id IS NOT NULL THEN
        INSERT INTO public.user_roles (
            user_id,
            role_id,
            assigned_by,
            assigned_at,
            is_active,
            created_at,
            created_by,
            updated_at,
            updated_by
        )
        VALUES (
            NEW.id,
            default_role_id,
            NEW.id,
            v_current_timestamp,
            true,
            v_current_timestamp,
            NEW.id,
            v_current_timestamp,
            NEW.id
        );
            
        -- Log role assignment with comprehensive data
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
            NEW.id,
            'role_assigned',
            NULL,
            jsonb_build_object(
                'user_id', NEW.id,
                'role_id', default_role_id,
                'role_type', 'user',
                'auto_assigned', true,
                'assigned_at', v_current_timestamp,
                'assigned_by', NEW.id,
                'is_active', true
            ),
            NEW.id,
            v_current_timestamp
        );
    END IF;

    -- User activity log
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
        NEW.id,
        'account_created',
        'New user account created',
        v_user_data || jsonb_build_object(
            'role_assigned', default_role_id IS NOT NULL,
            'role_id', default_role_id
        ),
        current_setting('request.headers', true)::json->>'x-forwarded-for',
        current_setting('request.headers', true)::json->>'user-agent',
        v_current_timestamp
    );
    
    RETURN NEW;
END;
$$;
--
--
--
/*
Purpose: 
  Check if a user is active by validating multiple conditions:
  - User exists
  - User is marked as active
  - User status is 'active'
  - User has not been deleted

Parameters:
  p_user_id UUID - The ID of the user to check

Returns:
  BOOLEAN - true if user is active, false otherwise

Example Usage:
-- Check if specific user is active
SELECT public.is_user_active('123e4567-e89b-12d3-a456-426614174000');

-- Use in a query to filter active users
SELECT * 
FROM some_table 
WHERE public.is_user_active(user_id);

-- Use in conditional logic
IF public.is_user_active(user_id) THEN
    -- Perform action for active user
END IF;
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
        'restore',
        p_user_id,
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
Purpose:
  Trigger function that handles the cascading soft deletion of user-related records:
  - Deactivates user roles
  - Marks phone numbers as inactive
  - Marks addresses as inactive
  - Creates activity log entry
  This ensures all related user data is consistently marked as deleted.

Trigger Usage:
  AFTER UPDATE ON users
  Triggered when a user is soft deleted (deleted_at is set)

Parameters (via NEW):
  Trigger function using NEW record values:
  - NEW.id: User ID being deleted
  - NEW.deleted_at: Deletion timestamp
  - NEW.deleted_by: ID of user performing deletion

Example Usage:
-- Create the trigger
CREATE TRIGGER handle_user_soft_delete_trigger
AFTER UPDATE OF deleted_at ON public.users
FOR EACH ROW
WHEN (OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL)
EXECUTE FUNCTION public.handle_user_soft_delete();
*/
CREATE OR REPLACE FUNCTION public.handle_user_soft_delete()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- Deactivate all user roles
    UPDATE public.user_roles
    SET 
        is_active = false,
        updated_at = now(),
        updated_by = NEW.deleted_by,
        deleted_at = NEW.deleted_at,
        deleted_by = NEW.deleted_by
    WHERE user_id = NEW.id
    AND deleted_at IS NULL;

    -- Mark all phone numbers as inactive
    UPDATE public.user_phone_numbers
    SET 
        is_active = false,
        updated_at = now(),
        updated_by = NEW.deleted_by,
        deleted_at = NEW.deleted_at,
        deleted_by = NEW.deleted_by
    WHERE user_id = NEW.id
    AND deleted_at IS NULL;

    -- Mark all addresses as inactive
    UPDATE public.user_addresses
    SET 
        is_active = false,
        updated_at = now(),
        updated_by = NEW.deleted_by,
        deleted_at = NEW.deleted_at,
        deleted_by = NEW.deleted_by
    WHERE user_id = NEW.id
    AND deleted_at IS NULL;

    -- Log the soft delete
    PERFORM log_activity(
        NEW.id,
        'user_deleted',
        'User account soft deleted',
        jsonb_build_object(
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
-- 2. User Profile Functions:
-- ========================================================================================

-- Function: Handle phone number changes
CREATE OR REPLACE FUNCTION public.handle_user_phone_number()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_timestamp TIMESTAMPTZ := now();
BEGIN
    -- Validate phone_type
    IF NEW.phone_type NOT IN ('mobile', 'home', 'work', 'other') THEN
        RAISE EXCEPTION 'Invalid phone type: must be mobile, home, work, or other';
    END IF;

    -- Normalize phone number (remove all non-numeric chars except +)
    NEW.phone_number := regexp_replace(NEW.phone_number, '[^0-9+]', '', 'g');
    
    -- Validate phone number format (basic validation)
    IF NEW.phone_number !~ '^\+?[0-9]{10,15}$' THEN
        RAISE EXCEPTION 'Invalid phone number format';
    END IF;

    -- Check unique constraint
    IF EXISTS (
        SELECT 1
        FROM public.user_phone_numbers
        WHERE user_id = NEW.user_id
        AND phone_number = NEW.phone_number
        AND id != COALESCE(NEW.id, uuid_nil())
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Phone number already exists for this user';
    END IF;

    -- Handle primary phone logic
    IF NEW.is_primary THEN
        UPDATE public.user_phone_numbers
        SET 
            is_primary = false,
            updated_at = v_current_timestamp,
            updated_by = NEW.updated_by,
            version = version + 1
        WHERE 
            user_id = NEW.user_id 
            AND id != COALESCE(NEW.id, uuid_nil())
            AND deleted_at IS NULL;
            
        -- Log change in activity log
        INSERT INTO public.user_activities (
            user_id,
            activity_type,
            description,
            details,
            ip_address,
            user_agent
        )
        VALUES (
            NEW.user_id,
            'primary_phone_changed',
            'Primary phone number updated',
            jsonb_build_object(
                'phone_number', NEW.phone_number,
                'phone_type', NEW.phone_type,
                'country_code', NEW.country_code,
                'is_verified', NEW.is_verified
            ),
            current_setting('request.headers', true)::json->>'x-forwarded-for',
            current_setting('request.headers', true)::json->>'user-agent'
        );
    END IF;

    -- Increment version
    NEW.version := COALESCE(OLD.version, 0) + 1;
    
    RETURN NEW;
END;
$$;
--
--
--
-- Function: handle_user_address
CREATE OR REPLACE FUNCTION public.handle_user_address()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_timestamp TIMESTAMPTZ := now();
BEGIN
    -- Validate address_type
    IF NEW.address_type NOT IN ('home', 'work', 'billing', 'shipping', 'other') THEN
        RAISE EXCEPTION 'Invalid address type: must be home, work, billing, shipping, or other';
    END IF;
    
    -- Basic validation
    IF TRIM(NEW.street_address) = '' THEN
        RAISE EXCEPTION 'Street address cannot be empty';
    END IF;
    
    IF TRIM(NEW.city) = '' THEN
        RAISE EXCEPTION 'City cannot be empty';
    END IF;
    
    IF TRIM(NEW.postal_code) = '' THEN
        RAISE EXCEPTION 'Postal code cannot be empty';
    END IF;

    -- Normalize data
    NEW.street_address := TRIM(NEW.street_address);
    NEW.apartment_unit := TRIM(NEW.apartment_unit);
    NEW.city := TRIM(NEW.city);
    NEW.state_province := TRIM(NEW.state_province);
    NEW.postal_code := TRIM(NEW.postal_code);
    NEW.country := UPPER(TRIM(NEW.country));

    -- Check unique constraint
    IF EXISTS (
        SELECT 1
        FROM public.user_addresses
        WHERE user_id = NEW.user_id
        AND address_type = NEW.address_type
        AND street_address = NEW.street_address
        AND COALESCE(apartment_unit, '') = COALESCE(NEW.apartment_unit, '')
        AND id != COALESCE(NEW.id, uuid_nil())
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'This address already exists for the user';
    END IF;

    -- Handle primary address logic
    IF NEW.is_primary THEN
        UPDATE public.user_addresses
        SET 
            is_primary = false,
            updated_at = v_current_timestamp,
            updated_by = NEW.updated_by,
            version = version + 1
        WHERE 
            user_id = NEW.user_id 
            AND address_type = NEW.address_type
            AND id != COALESCE(NEW.id, uuid_nil())
            AND deleted_at IS NULL;
            
        -- Log in user_activities
        INSERT INTO public.user_activities (
            user_id,
            activity_type,
            description,
            details,
            ip_address,
            user_agent
        )
        VALUES (
            NEW.user_id,
            'primary_address_changed',
            format('Primary %s address updated', NEW.address_type),
            jsonb_build_object(
                'address_type', NEW.address_type,
                'city', NEW.city,
                'state_province', NEW.state_province,
                'country', NEW.country,
                'is_verified', NEW.is_verified
            ),
            current_setting('request.headers', true)::json->>'x-forwarded-for',
            current_setting('request.headers', true)::json->>'user-agent'
        );
    END IF;

    -- Increment version
    NEW.version := COALESCE(OLD.version, 0) + 1;
    
    RETURN NEW;
END;
$$;
--
--
--
-- ========================================================================================
-- Role Management Functions
-- ========================================================================================

-- ========================================================================================
-- 1. Core Role Functions:
-- ========================================================================================
-- Function: Initialize default roles
CREATE OR REPLACE FUNCTION public.initialize_default_roles()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
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
--
--
--
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
        AND ur.is_active = true
        AND r.deleted_at IS NULL
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
Returns: UUID of the created audit log entry';

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
        v_ip_address := current_setting('app.request_ip', true);
        v_user_agent := current_setting('app.request_user_agent', true);
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
SELECT manage_user_role(user_id, ''editor'', admin_id, ''revoke'');  -- Revoke editor role';

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
        current_setting('app.request_ip', true),
        current_setting('app.request_user_agent', true)
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



-- ========================================================================================
-- FOR CHECKING HERE
-- ========================================================================================


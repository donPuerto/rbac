-- =====================================================================================
-- Database Cleanup Script
-- =====================================================================================
-- Description: Drops all objects in the correct order to avoid dependency issues
-- =====================================================================================

-- Step 1: Drop Policies (in reverse order)
DROP POLICY IF EXISTS "Users can view their own addresses" ON public.entity_addresses;
DROP POLICY IF EXISTS "Admins have full address access" ON public.entity_addresses;
DROP POLICY IF EXISTS "Users can view their own phones" ON public.entity_phones;
DROP POLICY IF EXISTS "Admins have full phone access" ON public.entity_phones;
DROP POLICY IF EXISTS "Users can view their own emails" ON public.entity_emails;
DROP POLICY IF EXISTS "Admins have full email access" ON public.entity_emails;
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can soft delete own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins have full access" ON public.profiles;
DROP POLICY IF EXISTS "No deletion - use soft delete instead" ON public.profiles;

-- Step 2: Drop Triggers
DROP TRIGGER IF EXISTS set_timestamp_entity_addresses ON public.entity_addresses CASCADE;
DROP TRIGGER IF EXISTS handle_entity_addresses_soft_delete ON public.entity_addresses CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_entity_phones ON public.entity_phones CASCADE;
DROP TRIGGER IF EXISTS handle_entity_phones_soft_delete ON public.entity_phones CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_entity_emails ON public.entity_emails CASCADE;
DROP TRIGGER IF EXISTS handle_entity_emails_soft_delete ON public.entity_emails CASCADE;
DROP TRIGGER IF EXISTS set_timestamp_profiles ON public.profiles CASCADE;
DROP TRIGGER IF EXISTS handle_profile_soft_delete ON public.profiles CASCADE;

-- Step 3: Drop Functions
DROP FUNCTION IF EXISTS public.handle_profile_deletion();
DROP FUNCTION IF EXISTS public.update_timestamp();

-- Step 4: Drop Tables (in correct order)
DROP TABLE IF EXISTS public.entity_addresses CASCADE;
DROP TABLE IF EXISTS public.entity_phones CASCADE;
DROP TABLE IF EXISTS public.entity_emails CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Step 5: Drop Types
DROP TYPE IF EXISTS public.status_type;
DROP TYPE IF EXISTS public.entity_type;
DROP TYPE IF EXISTS public.phone_type;
DROP TYPE IF EXISTS public.gender_type;

-- Step 6: Drop Extensions (if any)
-- DROP EXTENSION IF EXISTS "uuid-ossp";

-- Revoke all permissions
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authenticated;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM service_role;

-- =====================================================================================
-- Types and Extensions
-- =====================================================================================
-- Description: Creates all custom types and enables required extensions
-- =====================================================================================

-- Create ENUMs
CREATE TYPE public.status_type AS ENUM ('active', 'inactive', 'pending', 'archived');
CREATE TYPE public.entity_type AS ENUM ('user', 'lead', 'contact', 'opportunity');
CREATE TYPE public.phone_type AS ENUM ('mobile', 'landline', 'fax', 'voip', 'other');
CREATE TYPE public.gender_type AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');

-- Enable Extensions (if needed)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

COMMENT ON TYPE public.status_type IS 'Status types for various entities';
COMMENT ON TYPE public.entity_type IS 'Types of entities in the CRM system';
COMMENT ON TYPE public.phone_type IS 'Types of phone numbers';
COMMENT ON TYPE public.gender_type IS 'Gender options for profiles';

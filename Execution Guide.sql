-- =====================================================================================
-- RBAC System Execution Order
-- =====================================================================================
-- Description: Controls the order of SQL script execution for the RBAC system
-- Version: 1.0
-- Last Updated: 2024
-- =====================================================================================

-- Execution Order:
-- 1. Drop all policies first (from 00_drop_policies.sql)
-- 2. Drop and recreate enums (01_enum.sql)
-- 3. Drop and recreate tables (02_tables.sql)
-- 4. Drop and recreate functions (03_functions.sql)
-- 5. Load initial data (04_initial_data.sql)
-- 6. Create RLS policies (05_rls_policies.sql)
-- 7. Grant permissions (06_grant_permissions.sql)
-- 8. Create indexes (07_indexes.sql)

-- Start with clean slate - drop everything in reverse order
\i 00_drop_policies.sql
\i 01_enum.sql
\i 02_tables.sql
\i 03_functions.sql
\i 04_initial_data.sql
\i 05_rls_policies.sql
\i 06_grant_permissions.sql
\i 07_indexes.sql

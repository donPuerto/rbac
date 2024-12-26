# Database Setup Order

This document outlines the correct order of operations for setting up the database schema. Following this order ensures that dependencies are created in the correct sequence and prevents reference errors.

## Setup Sequence

### 1. Drop Everything (in reverse order)
- **Policies** - Drop all RLS policies first
- **Triggers** - Remove triggers before functions
- **Functions** - Drop functions after their dependent triggers
- **Tables** - Drop tables after removing their dependencies
- **Types** - Drop custom types last

### 2. Create Types and Extensions
- **ENUMs** - Create enumerated types
- **Custom Types** - Set up any custom composite types
- **Extensions** - Enable required PostgreSQL extensions

### 3. Create Base Tables
1. First create independent tables:
   - `profiles` (since other tables depend on it)
2. Then create dependent tables:
   - `entity_emails`
   - `entity_phones`
   - `entity_addresses`

### 4. Create Functions
- Create all functions before any triggers that use them
- Location: `functions.sql`
- Examples:
  - `update_timestamp()`
  - `handle_profile_deletion()`

### 5. Create Basic Indexes
- Create performance-related indexes
- Focus on commonly queried columns
- Consider partial indexes for specific conditions

### 6. Add Constraints
1. **Foreign Keys**
   - Add references between tables
   - Ensure referential integrity
2. **Check Constraints**
   - Add data validation rules
   - Enforce business logic
3. **Unique Constraints**
   - Create unique indexes
   - Add partial unique constraints where needed

### 7. Create Triggers
- Location: `triggers.sql`
- Ensure all referenced functions exist
- Examples:
  - Timestamp update triggers
  - Soft delete handlers

### 8. Enable RLS and Create Policies
1. **Enable RLS**
   - Activate row level security on tables
2. **Create Policies**
   - Location: `policies.sql`
   - Define access rules per table
   - Set up user-specific filters

### 9. Grant Permissions
- Grant appropriate permissions to roles:
  - `authenticated`
  - `service_role`
  - Any custom roles

### 10. Insert Seed Data
1. **Reference Data**
   - Insert lookup table data
   - Add system-required records
2. **Test Data** (if needed)
   - Add sample data for testing
   - Include representative test cases

## File Execution Order

```sql
1. Run drops (01_cleanup.sql)
2. Run types and extensions (02_types.sql)
3. Run base tables (03_tables.sql)
4. Run functions (04_functions.sql)
5. Run indexes and constraints (05_indexes.sql, 06_constraints.sql)
6. Run triggers (07_triggers.sql)
7. Run RLS and policies (08_policies.sql)
8. Run grants (09_grant_permissions.sql)
9. Run seed data (10_seed_data.sql)
```

## Important Notes

1. Always run scripts in the specified order
2. Verify each step completes successfully before proceeding
3. Check for any error messages between steps
4. Ensure all dependencies exist before creating objects that reference them
5. Consider using transactions for related operations

## Troubleshooting

If you encounter errors:
1. Check that all referenced objects exist
2. Verify the execution order
3. Look for circular dependencies
4. Ensure all required extensions are enabled
5. Verify role permissions

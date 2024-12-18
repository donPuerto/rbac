# Supabase RBAC System

A comprehensive Role-Based Access Control (RBAC) system implemented for Supabase, providing fine-grained access control with hierarchical roles, delegated administration, and audit logging.

## Features

### 1. User Management
- Complete user profile management
- Soft deletion support
- Status tracking (active, inactive, suspended, pending)
- Contact information management (phone numbers, addresses)
- Profile customization (avatar, preferences, timezone)

### 2. Role Management
- Hierarchical role structure
- Role inheritance
- Temporary role assignments
- Role delegation capabilities
- Conflict prevention
- Role expiration scheduling

### 3. Permission Management
- Fine-grained permission control
- Resource-action based permissions
- Permission inheritance through roles
- System vs custom permissions
- Permission validation

### 4. Security Features
- Row Level Security (RLS) policies
- Secure function execution (SECURITY DEFINER)
- Soft deletion across all entities
- Input validation and sanitization
- Comprehensive error handling

### 5. Audit and Monitoring
- Detailed audit logging
- User activity tracking
- Change history
- Role assignment history
- Error logging

### 6. Administrative Features
- Delegated administration
- Role hierarchy management
- User status management
- Batch operations support
- System initialization utilities

## Database Structure

### Core Tables
1. `users` - Core user information and profile data
2. `roles` - System role definitions
3. `permissions` - Available system permissions
4. `user_roles` - User-role assignments
5. `role_permissions` - Role-permission mappings
6. `role_delegations` - Role management delegations

### Supporting Tables
1. `user_phone_numbers` - User contact information
2. `user_addresses` - User physical addresses
3. `audit_logs` - System change tracking
4. `user_activities` - User behavior tracking
5. `scheduled_tasks` - Task scheduling for role expiration

## Key Functions

### User Management
- `handle_new_user()` - New user creation handler
- `soft_delete_user()` - User soft deletion
- `restore_deleted_user()` - User restoration
- `get_user_profile()` - Profile retrieval
- `update_user_status()` - Status management

### Role Management
- `manage_user_role()` - Role assignment/revocation
- `check_user_role()` - Role validation
- `get_role_hierarchy_level()` - Hierarchy management
- `assign_temporary_role()` - Temporary role assignment
- `delegate_role_management()` - Role delegation

### Permission Management
- `grant_permission()` - Permission granting
- `revoke_permission()` - Permission revocation
- `validate_user_access()` - Access validation
- `get_role_permissions()` - Permission retrieval

## Performance Optimization

### Indexes
- User lookup optimization
- Role hierarchy traversal
- Permission checking
- Audit trail querying
- Temporal role management
- Search functionality

## Security Considerations

1. Row Level Security (RLS)
   - Record-level access control
   - Multi-tenant isolation
   - Data visibility rules

2. Function Security
   - SECURITY DEFINER functions
   - Input validation
   - Error handling
   - Audit logging

3. Data Protection
   - Soft deletion
   - Version tracking
   - Change history
   - Error logging

## Getting Started

1. Execute the SQL files in the following order:
   ```sql
   01_extensions.sql  -- Required PostgreSQL extensions
   02_tables.sql      -- Core table definitions
   03_functions.sql   -- System functions
   04_initial_data.sql -- Default data
   05_rls_policies.sql -- Security policies
   06_grant_permissions.sql -- Default permissions
   07_indexes.sql     -- Performance optimization
   ```

2. Initialize the system:
   ```sql
   SELECT initialize_default_roles();
   ```

## Best Practices

1. Always use provided functions for:
   - User management
   - Role assignments
   - Permission grants
   - Status updates

2. Implement proper error handling
3. Monitor audit logs
4. Regularly review role assignments
5. Maintain role hierarchy integrity

## Contributing

Please follow these guidelines when contributing:
1. Maintain existing code structure
2. Add comprehensive comments
3. Include appropriate indexes
4. Implement proper error handling
5. Add audit logging for new functions
6. Update documentation

## License

MIT License - See LICENSE file for details
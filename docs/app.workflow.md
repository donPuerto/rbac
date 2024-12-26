# Application Workflow Documentation

## User Registration and Onboarding Flow

### 1. Initial Signup (Supabase Auth)
- User provides email and password
- Supabase creates record in `auth.users`
- Triggers `on_auth_user_created` trigger

### 2. Profile Creation (`handle_new_user()`)
- Generates initial username and handle from email
- Creates minimal profile record with:
  - Generated handle and username
  - Basic display name
  - Verification status from email
  - Metadata (source, signup IP)
- Creates primary email record in `entity_emails`:
  - Marks as primary
  - Sets verification status
  - Links to user entity

### 3. Onboarding Initialization (`handle_new_user_onboarding()`)
1. Creates onboarding record with defined steps:
   ```json
   {
       "steps": {
           "profile_setup": {"status": "pending", "required": true},
           "email_verification": {"status": "pending", "required": true},
           "preferences": {"status": "pending", "required": true},
           "security_setup": {"status": "pending", "required": true},
           "welcome_tour": {"status": "pending", "required": false}
       }
   }
   ```
2. Creates default user preferences record
3. Creates default security settings record

### 4. Onboarding Process Flow

#### 4.1 Profile Setup (Required)
- Complete profile information:
  - Full name
  - Bio/Tagline
  - Profile picture
  - Additional contact info
- System updates progress via `update_user_onboarding_progress()`

#### 4.2 Email Verification (Required)
- Verify primary email
- Add additional emails if needed
- System tracks verification status

#### 4.3 Preferences Setup (Required)
- Set language and timezone
- Configure notification preferences
- Set UI preferences
- Set privacy preferences

#### 4.4 Security Setup (Required)
- Set up 2FA (optional)
- Configure security notifications
- Set session preferences
- Review security settings

#### 4.5 Welcome Tour (Optional)
- Introduction to key features
- Platform navigation guide
- Getting started tips

### 5. Progress Tracking (`update_user_onboarding_progress()`)
- Tracks completion of each step
- Updates `onboarding_data` JSON
- Calculates completion percentage
- Automatically advances to next pending step
- Marks onboarding as completed when all required steps are done

### 6. Completion States

#### 6.1 Step States
- `pending`: Not started
- `in_progress`: Currently active
- `completed`: Successfully finished
- `skipped`: Optional step bypassed

#### 6.2 Overall Progress
- Percentage calculation based on required steps
- Completion marked only when all required steps done
- Timestamp recorded for completion

### 7. Data Management

#### 7.1 Profile Data
- Minimal initial data
- Progressive completion during onboarding
- Verification states tracked

#### 7.2 Contact Information
- Primary email from signup
- Additional emails optional
- Phone and address optional
- Each contact type supports multiple entries

#### 7.3 Security Settings
- Basic settings created at signup
- 2FA configuration optional
- Session management preferences
- Security notification settings

## Technical Implementation Notes

### Database Tables
- `auth.users`: Supabase authentication
- `public.profiles`: User profile information
- `public.entity_emails`: Email management
- `public.entity_phones`: Phone number management
- `public.entity_addresses`: Address management
- `public.user_preferences`: User settings and preferences
- `public.security_settings`: Security configurations
- `public.onboarding_progress`: Onboarding state tracking

### Functions and Triggers
- `handle_new_user()`: Initial user setup
- `handle_new_user_onboarding()`: Onboarding initialization
- `update_user_onboarding_progress()`: Progress tracking
- `verify_user_email()`: Email verification handling
- `update_profile_completion()`: Profile completion calculation

### Security Considerations
- Row Level Security (RLS) policies on all tables
- Email verification required for sensitive operations
- Progressive security enhancement during onboarding
- Audit logging for security-related changes

### Performance Optimizations
- Indexed lookup fields
- Materialized completion calculations
- Efficient JSON operations for progress tracking
- Optimized query patterns for common operations

-- Suggested indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON public.user_roles (user_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON public.user_roles (role_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_roles_role_type ON public.roles (role_type) WHERE deleted_at IS NULL;

-- Add necessary indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_roles_expiry 
ON public.user_roles (expires_at) 
WHERE expires_at IS NOT NULL AND is_active = true;

CREATE INDEX IF NOT EXISTS idx_role_delegations_delegate 
ON public.role_delegations (delegate_id) 
WHERE deleted_at IS NULL;

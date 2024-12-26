    -- In the table definition:
    CONSTRAINT unique_active_email UNIQUE(email, deleted_at),
    CONSTRAINT unique_primary_email UNIQUE(entity_id, entity_type, is_primary),

    -- After the table creation:
CREATE UNIQUE INDEX idx_unique_primary_email 
    ON public.entity_emails (entity_id, entity_type, is_primary)
    WHERE is_primary = true AND deleted_at IS NULL;

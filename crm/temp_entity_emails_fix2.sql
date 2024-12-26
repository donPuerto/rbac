    CONSTRAINT unique_primary_email UNIQUE(entity_id, entity_type, is_primary) WHERE is_primary = true AND deleted_at IS NULL,

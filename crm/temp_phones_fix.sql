    -- In table definition:
    CONSTRAINT unique_active_phone UNIQUE(phone_number, deleted_at),
    CONSTRAINT unique_primary_phone_base UNIQUE(entity_id, entity_type, is_primary),
    
    -- After table creation (with the other indexes):
CREATE UNIQUE INDEX ON public.entity_phones (entity_id, entity_type, is_primary)
    WHERE is_primary = true AND deleted_at IS NULL;

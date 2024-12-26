    -- In table definition:
    CONSTRAINT unique_primary_address_base UNIQUE(entity_id, entity_type, is_primary),
    
    -- After table creation (with the other indexes):
CREATE UNIQUE INDEX ON public.entity_addresses (entity_id, entity_type, is_primary)
    WHERE is_primary = true AND deleted_at IS NULL;

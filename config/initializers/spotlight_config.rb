Spotlight::Engine.config.thumbnail_field = :thumbnail_ssim
Spotlight::Engine.config.default_browse_index_view_type = :list
Spotlight::Resources::Iiif::Engine.config.metadata_class = -> { ManifestMetadata }
Spotlight::Resources::Iiif::Engine.config.iiif_manifest_field = :content_metadata_iiif_manifest_field_ssi

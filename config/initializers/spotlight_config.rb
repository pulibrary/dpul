Spotlight::Engine.config.thumbnail_field = :thumbnail_ssim
Spotlight::Engine.config.document_presenter_class = RTLPresenter
Spotlight::Engine.config.default_browse_index_view_type = :list
Spotlight::Resources::Iiif::Engine.config.metadata_class = -> { ManifestMetadata }

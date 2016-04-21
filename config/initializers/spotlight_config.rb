Spotlight::Engine.config.thumbnail_field = :thumbnail_ssim
Spotlight::Engine.config.document_presenter_class = RTLPresenter
Spotlight::Resources::Iiif::Engine.config.metadata_class = -> { ManifestMetadata }

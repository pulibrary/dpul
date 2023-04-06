# frozen_string_literal: true

Spotlight::Engine.config.thumbnail_field = :thumbnail_ssim
Spotlight::Engine.config.default_browse_index_view_type = :list
Spotlight::Engine.config.upload_fields = []
Spotlight::Engine.config.iiif_metadata_class = -> { ManifestMetadata }
Spotlight::Engine.config.iiif_manifest_field = :content_metadata_iiif_manifest_field_ssi
Spotlight::Engine.config.iiif_title_fields = "full_title_tesim"
Spotlight::Engine.config.sir_trevor_widgets = %w[
  Heading Text List Quote Iframe Video Oembed Rule UploadedItems Browse
  FeaturedPages SolrDocuments SolrDocumentsCarousel SolrDocumentsEmbed
  SolrDocumentsFeatures SolrDocumentsGrid SearchResults RecentItems
]
Spotlight::Engine.config.default_autocomplete_params = { qf: "id^1000 full_title_tesim^100 id_ng full_title_ng", fl: "id full_title_tesim thumbnail_ssim content_metadata_iiif_manifest_field_ssi full_image_url_ssm" }

class IIIFResource < Spotlight::Resources::IiifHarvester
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
  after_destroy :cleanup_solr
  before_save :set_noid

  class InvalidIIIFManifestError < TypeError; end

  def iiif_manifests
    @iiif_manifests ||= validate_iiif_manifest_collections!
  end

  def validate_iiif_manifest_collections!
    iiif_manifests = ::IiifService.parse(url)

    # Check for valid metadata
    iiif_manifests.to_a.each do |iiif_manifest|
      iiif_manifest.with_exhibit(exhibit)

      next unless iiif_manifest.as_json.key?("manifest") &&
                  iiif_manifest.as_json["manifest"].key?("data") &&
                  iiif_manifest.as_json["manifest"]["data"].key?("metadata")

      collection_metadata = iiif_manifest.as_json["manifest"]["data"]["metadata"].select { |metadata| metadata["label"] == "Collections" }
      invalid_collection_metadata = collection_metadata.select { |metadata| metadata["value"].first.is_a?(Hash) }
      raise(InvalidIIIFManifestError, "Invalid Collection metadata found in the IIIF Manifest: #{url}") unless invalid_collection_metadata.empty?
    end

    @iiif_manifests = iiif_manifests
  end

  def cleanup_solr
    solr.delete_by_id(document_ids, params: { softCommit: true })
  end

  def noid
    data["noid"]
  end

  def save_and_index_now(*args)
    save(*args)
    Spotlight::ReindexJob.perform_now(self)
  end

  private

    def set_noid
      data["noid"] = iiif_manifests.first.noid
    end

    def solr
      Blacklight.default_index.connection
    end

    def document_ids
      document_builder.documents_to_index.to_a.map { |y| y[:id] }
    end

    def write_to_index(batch)
      documents = documents_that_have_ids(batch)
      return unless write? && documents.present?

      blacklight_solr.update data: documents.to_json,
                             headers: { 'Content-Type' => 'application/json' }
    rescue RSolr::Error::Http => rsolr_error
      Rails.logger.error "Failed to update Solr for the following documents: #{document_ids.join(', ')}"
      raise rsolr_error
    end

    # Override hard commit after indexing every document, for performance.
    def commit; end
end

# frozen_string_literal: true

class IIIFResource < Spotlight::Resources::IiifHarvester
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
  after_destroy :cleanup_solr
  before_save :set_noid

  class InvalidIIIFManifestError < TypeError; end
  class IndexingError < StandardError; end

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

  # This is overridden because Spotlight calls it in multiple places to query
  # for the manifest and it needs our auth token. This will not persist the auth
  # token to the database, but will only append it on read.
  def url
    AuthorizedUrl.new(url: super).to_s
  end

  # We have to override both save_and_index and save_and_index_now instead of
  # just reindex because they call `save && reindex`, and sometimes there's
  # nothing new to save so it returns false - yet we still want it to remove
  # hidden solr records.
  def save_and_index(*args)
    remove_hidden_solr_records
    super
  end

  def save_and_index_now(*args)
    save(*args)
    remove_hidden_solr_records
    Spotlight::ReindexJob.perform_now(self)
  end

  def reindex(*args)
    return if exhibit.nil?
    super
  end

  private

    # Hidden solr records are records for resources in Figgy which have been
    # given a status such as "Takedown" or "Private". We don't want to delete the
    # resource so we can keep the hidden fields that might have been set up in
    # DPUL, but we also don't want them to show up in search results.
    def remove_hidden_solr_records
      return if iiif_manifests.to_a.present?
      doc = SolrDocument.find(noid, exhibit: exhibit)
      solr.delete_by_id(doc.id, params: { softCommit: true })
    rescue Blacklight::Exceptions::RecordNotFound
      Rails.logger.debug "No solr record for #{noid} to delete."
    end

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
    rescue RSolr::Error::Http
      error_message = "Failed to update Solr for the following documents: #{document_ids.join(', ')}"
      Rails.logger.error error_message
      raise IndexingError, error_message
    end

    # Override hard commit after indexing every document, for performance.
    def commit; end
end

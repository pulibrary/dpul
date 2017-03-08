class IIIFResource < Spotlight::Resources::IiifHarvester
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
  after_destroy :cleanup_solr
  before_save :set_noid

  def iiif_manifests
    @iiif_manifests ||= IiifService.parse(url)
  end

  def cleanup_solr
    solr.delete_by_id(document_ids, params: { softCommit: true })
  end

  def noid
    data["noid"]
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
end

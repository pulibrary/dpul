class IIIFResource < Spotlight::Resources::IiifHarvester
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
  after_destroy :cleanup_solr

  def iiif_manifests
    @iiif_manifests ||= IiifService.parse(url)
  end

  def cleanup_solr
    solr.delete_by_id(document_ids, params: { softCommit: true })
  end

  private

    def solr
      Blacklight.default_index.connection
    end

    def document_ids
      document_builder.documents_to_index.to_a.map { |y| y[:id] }
    end
end

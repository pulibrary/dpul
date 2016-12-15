class IIIFResource < Spotlight::Resources::IiifHarvester
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'

  def iiif_manifests
    @iiif_manifests ||= IiifService.parse(url)
  end
end

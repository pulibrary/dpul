class IIIFResource < Spotlight::Resources::IiifHarvester
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'

  def initialize(manifest_url: nil, exhibit: nil)
    super()
    self.url = manifest_url
    self.exhibit_id = exhibit.id if exhibit
  end
end

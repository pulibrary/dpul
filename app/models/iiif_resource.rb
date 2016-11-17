class IIIFResource < Spotlight::Resources::IiifHarvester
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
end

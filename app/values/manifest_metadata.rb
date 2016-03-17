class ManifestMetadata < Spotlight::Resources::IiifManifest::Metadata
  def metadata_hash
    Hash[super.map do |key, values|
      values = Array.wrap(values)
      values.map! do |value|
        if value["@value"]
          value["@value"]
        else
          value
        end
      end
      [key, values]
    end]
  end
end

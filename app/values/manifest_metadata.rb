class ManifestMetadata < Spotlight::Resources::IiifManifest::Metadata
  def jsonld_url
    @manifest["see_also"]["@id"] if @manifest["see_also"]
  end

  def jsonld_response
    Faraday.get(jsonld_url).body if jsonld_url
  rescue Faraday::Error::ConnectionFailed, Faraday::TimeoutError => e
    Rails.logger.warn("HTTP GET for #{url} failed with #{e}")
  end

  def jsonld_metadata
    @jsonld_metadata ||= JSON.parse(jsonld_response)
  rescue JSON::ParserError, TypeError
    @jsonld_metadata = nil
  end

  def jsonld_delete_keys
    %w(@context @id)
  end

  def jsonld_metadata_hash
    jsonld_metadata.delete_if { |k, _v| jsonld_delete_keys.include?(k) }
                   .transform_keys { |k| k.to_s.humanize }
  end

  def process_values(input_hash)
    Hash[input_hash.map do |key, values|
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

  def metadata_hash
    if jsonld_metadata
      process_values(jsonld_metadata_hash)
    else
      process_values(super)
    end
  end
end

class ManifestMetadata < Spotlight::Resources::IiifManifest::Metadata
  def jsonld_url
    return unless @manifest["see_also"]
    json_ld_see_also = Array.wrap(@manifest["see_also"]).find { |v| v["format"] == "application/ld+json" }
    return unless json_ld_see_also
    json_ld_see_also["@id"]
  end

  def jsonld_response
    return unless jsonld_url
    response = Faraday.get(jsonld_url)
    raise Faraday::Error::ConnectionFailed, response.status unless response.status == 200
    response.body
  rescue Faraday::Error::ConnectionFailed, Faraday::TimeoutError => e
    Rails.logger.warn("HTTP GET for #{jsonld_url} failed with #{e}")
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

  class Value
    attr_reader :key, :values
    def initialize(key, values)
      @key = key
      @values = Array.wrap(values)
    end

    def to_pair
      [new_key, new_values]
    end

    def new_key
      if key == 'Memberof'
        'Collections'
      else
        key
      end
    end

    def new_values
      values.map do |value|
        if value["@value"]
          value["@value"]
        elsif key == 'Language'
          ISO_639.find_by_code(value).try(:english_name) || value
        elsif key == 'Memberof'
          value['title']
        elsif value["@id"]
          value["@id"]
        else
          value
        end
      end
    end
  end
  def process_values(input_hash)
    h = Hash[input_hash.map do |key, values|
      Value.new(key, values).to_pair
    end]
    range_labels(h)
    h
  end

  def metadata_hash
    if jsonld_metadata
      process_values(jsonld_metadata_hash)
    else
      process_values(super)
    end
  end

  private

    def range_labels(h)
      values = []
      (@manifest['structures'] || []).each do |s|
        (s['ranges'] || []).each do |r|
          values << r['label']
        end
      end
      h['Range label'] = values unless values.empty?
    end
end

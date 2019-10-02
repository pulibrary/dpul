# frozen_string_literal: true

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
      values.map { |value| transform_value(value) }
    end

    def transform_value(value)
      ["@value", "pref_label"].each { |prop| return value[prop] if value[prop] }
      return language_name(value) if key == 'Language'
      return value['title'] if key == 'Memberof'
      return value["@id"] if value["@id"]
      value
    end

    def language_name(value)
      ISO_639.find_by_code(value).try(:english_name) || value
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

  # Do not import manifest's description/etc if there's JSON-LD to pull metadata
  # from.
  def manifest_fields
    return [] if jsonld_metadata
    super
  end

  private

    def range_labels(h)
      values = []
      (@manifest['structures'] || []).each do |s|
        values << s['label']
      end
      h['Range label'] = values unless values.empty?
    end
end

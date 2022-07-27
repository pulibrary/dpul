# frozen_string_literal: true

class ManifestMetadata < Spotlight::Resources::IiifManifest::Metadata
  def jsonld_url
    # IIIF 3 manifests will have it in seeAlso, it's in see_also for
    # IIIF::Presentation manifests.
    see_also = @manifest["see_also"] || @manifest["seeAlso"]
    return unless see_also

    json_ld_see_also = Array.wrap(see_also).find { |v| v["format"] == "application/ld+json" }
    return unless json_ld_see_also

    AuthorizedUrl.new(url: json_ld_see_also["@id"]).to_s
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
    %w[@context @id @type]
  end

  def jsonld_metadata_hash
    jsonld_metadata.delete_if { |k, _v| jsonld_delete_keys.include?(k) }
                   .transform_keys { |k| k.to_s.humanize }
  end

  class Value
    KEY_MAP = {
      "Memberof" => "Collections",
      "Link to catalog" => "View in catalog",
      "Link to finding aid" => "View in finding aid",
      "Electronic locations" => "Available online"
    }.freeze

    attr_reader :key, :values
    def initialize(key, values)
      @key = key
      @values = Array.wrap(values)
    end

    def to_pair
      [new_key, new_values]
    end

    def new_key
      return key unless KEY_MAP.key?(key)

      KEY_MAP[key]
    end

    def new_values
      values.map { |value| transform_value(value) }
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def transform_value(value)
      ["@value", "pref_label", "skos:prefLabel"].each { |prop| return value[prop] if value[prop] }
      return electronic_location_link(value) if key == 'Electronic locations'
      return language_name(value) if key == 'Language'
      return value['title'] if key == 'Memberof'
      return value["@id"] if value["@id"]
      return link_to_catalog(value) if key == "Link to catalog" || key == "Link to finding aid"
      return actors(value) if key == "Actor"
      return value.downcase if key.casecmp("keywords").zero?

      value
    end
    # rubocop:enable Metrics/PerceivedComplexity

    # string and rdf literal values will have been transformed by the general
    # clause; only grouping values should get here
    def actors(value)
      return value unless value["grouping"]

      value["grouping"].map { |h| h["@value"] }.join(", ")
    end

    def link_to_catalog(value)
      "<a href='#{value}'>#{value}</a>"
    end

    def electronic_location_link(value)
      return value unless value.is_a?(Hash)

      "<a href='#{value['@id']}'>#{value['label']}</a>"
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

  # Override label method so it returns multiple values
  # We need to have multiple titles for multi-volume works
  #
  # See upstream code at
  # https://github.com/projectblacklight/spotlight/blob/v2.13.0/app/models/spotlight/resources/iiif_manifest.rb#L187-L191
  def label
    return unless manifest.try(:label)

    Array(json_ld_value(manifest.label)).map { |v| html_sanitize(v) }
  end

  private

    def range_labels(hsh)
      values = []
      (@manifest['structures'] || []).each do |s|
        values << s['label']
      end
      hsh['Range label'] = values unless values.empty?
    end
end

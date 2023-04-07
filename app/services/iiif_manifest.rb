# frozen_string_literal: true

class IiifManifest < ::Spotlight::Resources::IiifManifest
  def to_solr(exhibit: nil)
    return {} unless url && manifest
    @exhibit ||= exhibit
    add_noid
    # this is called in super, but idempotent so safe to call here also; we need the metadata
    solr_hash.merge!(manifest_metadata)
    add_sort_title
    add_sort_date
    add_sort_author
    add_full_text
    add_timestamps
    super
  end

  def add_noid
    solr_hash["access_identifier_ssim"] = [noid]
  end

  # created_at/updated_at are stashed by exclude_system_metadata! so that CustomFields
  # do not get created for them, but there's access to those values for
  # indexing.
  def add_timestamps
    solr_hash["system_created_at_dtsi"] = Array(excluded_metadata["System created at"]).first
    solr_hash["system_updated_at_dtsi"] = Array(excluded_metadata["System updated at"]).first
  end

  def add_sort_title
    # Once we upgrade we should probably use this json_ld_value?
    # solr_hash['sort_title_ssi'] = Array.wrap(json_ld_value(manifest.label)).first
    solr_hash['sort_title_ssi'] = Array.wrap(manifest.label).first
  end

  def add_sort_date
    solr_hash['sort_date_ssi'] = Array.wrap(solr_hash['readonly_date_ssim']).first || Array.wrap(solr_hash['readonly_date-created_ssim']).first
  end

  def add_sort_author
    solr_hash['sort_author_ssi'] = Array.wrap(solr_hash['readonly_author_ssim']).first
  end

  def full_image_url
    return super unless manifest['thumbnail'] && manifest['thumbnail']['service'] && manifest['thumbnail']['service']['@id']

    "#{manifest['thumbnail']['service']['@id']}/full/!800,800/0/default.jpg"
  end

  # Override resources method to handle multi-volume work manifests
  # See: https://github.com/projectblacklight/spotlight/blob/v3.2.0/app/models/spotlight/resources/iiif_manifest.rb#L137
  def resources
    if manifest.is_a? IIIF::Presentation::Collection
      @resources ||= manifest.manifests.flat_map do |m|
        authorized_url = AuthorizedUrl.new(url: m['@id']).to_s
        IiifService.parse(authorized_url).first.resources
      end
    else
      super
    end
  end

  def compound_id
    Digest::MD5.hexdigest("#{exhibit.id}-#{noid}")
  end

  def ark_url
    first_rendering = Array.wrap(manifest["rendering"]).first
    return unless first_rendering && first_rendering["@id"]

    first_rendering["@id"]
  end

  def noid
    if ark_url
      /.*\/(.*)/.match(ark_url)[1]
    else
      /.*\/(.*)\/manifest/.match(url)[1]
    end
  end

  def add_metadata
    solr_hash.merge!(manifest_metadata)
    sidecar.data = sidecar.data.reject do |k, _v|
      k.to_s.start_with?("readonly")
    end
    sidecar.update(data: sidecar.data.merge(manifest_metadata))
  end

  def exclude_system_metadata!(metadata)
    excluded_metadata_keys.each do |excluded_key|
      excluded_metadata[excluded_key] = metadata.delete(excluded_key)
    end
  end

  def excluded_metadata
    @excluded_metadata ||= {}
  end

  def excluded_metadata_keys
    [
      "System created at",
      "System updated at"
    ]
  end

  def manifest_metadata
    @manifest_metadata ||=
      begin
        metadata = metadata_class.new(manifest).to_solr
        return {} if metadata.blank?

        metadata = default_metadata(metadata).merge(metadata)
        exclude_system_metadata!(metadata)
        create_sidecars_for(*metadata.keys)

        metadata.each_with_object({}) do |(key, value), hash|
          next unless (field = exhibit_custom_fields[key])

          field = BothFields.new(field)
          hash[field.field] = value
          hash[field.alternate_field] = value
        end
      end
  end

  # When importing a IIIF Resource the first time, create an "Override Title" field.
  def default_metadata(metadata)
    return {} if metadata["Title"].blank? || sidecar.data["override-title_ssim"].present?

    {
      "Override Title" => nil
    }
  end

  # { "Override Title" => nil, "Title" => "Awesome Title", "Date" => "date" }
  def create_sidecars_for(*keys)
    missing_keys(keys).each do |k|
      readonly = k != "Override Title"
      field = exhibit.custom_fields.create! label: k, readonly_field: readonly, field_type: "vocab"
      field.update(configuration: field.configuration.merge("if" => false)) if disabled_fields.include?(k)
    end
    @exhibit_custom_fields = nil
  end

  # Compare to the slug instead of the label in case the label has been modified
  # by the user in the blacklight configuration. Without this you'll end up with
  # proliferation of duplicate Spotlight::CustomFields.
  def missing_keys(keys)
    custom_field_slugs = exhibit.custom_fields.pluck(:slug)
    keys.reject do |key|
      custom_field_slugs.include?(key.parameterize)
    end
  end

  def disabled_fields
    [
      "Override Title",
      "Title"
    ]
  end

  def add_full_text
    return if manifest["sequences"].blank?

    text = manifest["sequences"]
           .flat_map { |x| x["canvases"] }.compact
           .flat_map { |x| x["rendering"] }.compact
           .select { |x| x["format"] == "text/plain" }
           .map { |x| x["@id"] }.compact
    return if text.empty?

    manifest_id = manifest["@id"].match(/.*\/(.*)\/manifest/)[1]
    text = Array(FiggyGraphql.get_ocr_content_for_id(id: manifest_id)).map { |x| x.to_s.dup.force_encoding('UTF-8') }
    solr_hash["full_text_tesim"] = text
  end
end

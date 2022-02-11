# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument
  include Spotlight::SolrDocument
  include Spotlight::SolrDocument::AtomicUpdates

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  class << self
    def find(id, params = {})
      solr_response = index.find(id, params)
      solr_response.documents.first
    end
  end

  def fetch(key, *default)
    Array.wrap(super).map(&:html_safe)
  end

  def to_param
    first("access_identifier_ssim") || id
  end

  # Overridden so that saving doesn't empty out readonly fields.
  def update(current_exhibit, new_attributes)
    attributes = new_attributes.stringify_keys

    custom_data = attributes.delete('sidecar')
    tags = attributes.delete('exhibit_tag_list')
    resource_attributes = attributes.delete('uploaded_resource')
    # This part was added
    if custom_data
      sidecar = sidecar(current_exhibit)
      custom_data["data"] = sidecar.data.merge(custom_data["data"])
      sidecar.update(custom_data)
    end
    # End additions

    # Note: this causes a save
    current_exhibit.tag(sidecar(current_exhibit), with: tags, on: :tags) if tags

    update_exhibit_resource(resource_attributes) if uploaded_resource?
  end

  # Retrieve the IIIF manifest URL from the configured field
  # @return [String]
  def manifest
    values = fetch(Spotlight::Engine.config.iiif_manifest_field, nil)
    values.first
  end

  # @param field [String]
  def title_or_override_title(field)
    override_title = fetch(override_title_field, []).select(&:present?)
    # Replicate heading functionality in presenter. Return override title,
    # title, or ID in that order.
    override_title.presence || fetch(field, []).select(&:present?).presence || id
  end

  def override_title_field
    [exhibit_prefix, "override-title_ssim"].select(&:present?).join("_")
  end

  # Use the public key to figure out the exhibit prefix for this document.
  # @example
  #   document.keys # => ["exhibit_test_public_bsi"]
  #   document.exhibit_prefix # => "exhibit_test"
  def exhibit_prefix
    public_key = keys.map(&:to_s).find { |key| key.end_with?("public_bsi") } || ""
    public_key.gsub("_public_bsi", "")
  end
end

require 'iiif/presentation'
require 'open-uri'

class IIIFResource < Spotlight::Resource
  # If a manifest_url if provided, it is retrieved, parsed and indexed
  def initialize(manifest_url: nil)
    super()
    self.url = manifest_url
  end

  def title_field
    :"#{solr_fields.prefix}spotlight_title#{solr_fields.string_suffix}"
  end

  def field_name(name)
    (name + solr_fields.string_suffix).to_sym
  end

  def manifest
    return {} if url.blank?
    @manifest ||= ::IIIF::Service.parse(open(url).read)
  end

  def to_solr
    solr_doc = super

    solr_doc[title_field] = manifest['label']
    solr_doc[field_name('thumbnail')] = manifest['thumbnail']['@id'] if manifest['thumbnail']
    manifest['metadata'].each do |h|
      solr_doc[field_name(h['label'].parameterize('_'))] = h['value'].map { |v| v["@value"] }
    end

    solr_doc
  end

  def solr_fields
    Spotlight::Engine.config.solr_fields
  end
end

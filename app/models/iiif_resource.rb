require 'iiif/presentation'
require 'open-uri'
require 'open_uri_redirections'

class IIIFResource < Spotlight::Resource
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'

  # If a manifest_url if provided, it is retrieved, parsed and indexed
  def initialize(manifest_url: nil, exhibit: nil)
    super()
    self.url = manifest_url
    self.exhibit_id = exhibit.id if exhibit
  end

  def title_field
    :"#{solr_fields.prefix}full_title#{solr_fields.string_suffix}"
  end

  def field_name(name)
    (name + solr_fields.string_suffix).to_sym
  end

  def manifest
    return {} if url.blank?
    @manifest ||= ::IIIF::Service.parse(open(url, allow_redirections: :safe).read)
  end

  def to_solr
    super.tap do |solr_doc|
      solr_doc['id'] = id
      solr_doc[title_field] = manifest['label']
      solr_doc['manifest_url_ssm'] = [url]
      if manifest['thumbnail']
        solr_doc[field_name('thumbnail')] = manifest['thumbnail']['@id']
        solr_doc['content_metadata_image_iiif_info_ssm'] = manifest['thumbnail']['@id'].sub(/full.*/, 'info.json')
      end
      manifest['metadata'].each do |h|
        solr_doc[field_name(h['label'].parameterize('_'))] = Array.wrap(h['value']).map { |v| v["@value"] || v }
      end
      solr_doc.merge! sidecar.to_solr
    end
  end

  def solr_fields
    Spotlight::Engine.config.solr_fields
  end

  def sidecar
    @sidecar ||= document_model.new(id: id).sidecar(exhibit)
  end
end

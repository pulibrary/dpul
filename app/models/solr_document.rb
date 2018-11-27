# -*- encoding : utf-8 -*-
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
end

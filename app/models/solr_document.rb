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

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  def display_fields
    @display_fields ||= to_h.select do |x|
      !x.start_with?("spotlight_") &&
      !reserved_fields.include?(x) &&
      !x.end_with?("bsi")
    end
  end

  private

    def reserved_fields
      [
        "full_title_ssim",
        "id",
        "_version_",
        "timestamp",
        "manifest_url_ssm"
      ]
    end
end

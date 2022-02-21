# frozen_string_literal: true

class BulkLabeler
  def self.run(exhibit:, id:, title:, description: nil)
    r = IIIFResource.where(exhibit_id: exhibit.id).select { |x| x.noid == id }.first
    return if r.blank?

    sidecar = r.solr_document_sidecars.select { |sc| sc.data["readonly_collections_ssim"] }.first
    sidecar.data["override-title_ssim"] = title
    sidecar.data["curation-note_tesim"] = { "data": [{ "type" => "text", "data" => { "text" => description, "format" => "html" } }] }.to_json if description
    sidecar.save!
    r.reindex
  end
end

# frozen_string_literal: true
class FriendlyIdRepository < Blacklight::Solr::Repository
  ##
  # Find a single solr document result (by id) using the document configuration
  # @param [String] id document's unique key value
  # @param [Hash] params additional solr query parameters
  def find(id, params = {})
    if params[:exhibit]
      super(Digest::MD5.hexdigest("#{params[:exhibit].id}-#{id}"), params.except(:exhibit))
    else
      first_id = search(q: "access_identifier_ssim:#{id}", rows: 1, fl: "id")["response"]["docs"].first
      if first_id && first_id["id"]
        super(first_id["id"], params)
      else
        super(id, params)
      end
    end
  end
end

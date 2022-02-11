# frozen_string_literal: true

# We use the standard solr repository but need to add our special noid logic
class FriendlyIdRepository < Blacklight::Solr::Repository
  delegate :current_exhibit, to: :blacklight_config

  # Ensure we get the document associated with the correct exhibit
  # Two resources may have the same ARK, so we can't find the correct document
  # using the ARK alone
  # it's set in
  # https://github.com/pulibrary/dpul/blob/e23bc2c5d014394a9ed9ff5ac5e64443c74b3ad5/app/services/iiif_manifest.rb#L59-L61
  # @param [String] id document's unique key value
  # @param [Hash] params additional solr query parameters
  def find(id, params = {})
    if current_exhibit
      super(Digest::MD5.hexdigest("#{current_exhibit.id}-#{id}"), params)
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

# frozen_string_literal: true

# pulled and pared down from spotlight
# https://github.com/projectblacklight/spotlight/blob/b4608610ed0405f1d8ed4d6c9c17a02b06b9bcf6/spec/support/stub_iiif_response.rb
require 'fixtures/iiif_responses'
module StubIiifResponse
  def stub_iiif_response_for_url(url, response)
    allow(IiifService).to receive(:iiif_response).with(url).and_return(response)
  end

  def stub_default_collection
    allow_any_instance_of(Spotlight::Resources::IiifHarvester).to receive_messages(url_is_iiif?: true)

    stub_iiif_response_for_url('uri://for-manifest1/manifest', test_manifest1)
  end
end

RSpec.configure do |config|
  config.include IiifResponses
  config.include StubIiifResponse
end

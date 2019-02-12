module StubbedManifestsHelper
  def stub_manifest(url:, fixture:)
    stub_request(:head, url)
      .to_return(status: 200, body: "", headers: { 'content-type' => 'application/ld+json' })
    stub_request(:get, url)
      .to_return(status: 200, body: File.read(Rails.root.join("spec", "fixtures", "manifests", fixture)), headers: { 'content-type' => 'application/ld+json' })
  end

  def stub_metadata(id:)
    stub_request(:get, "https://figgy.princeton.edu/catalog/#{id}.jsonld")
      .to_return(status: 200, body: File.read(Rails.root.join("spec", "fixtures", "metadata", "#{id}.json")), headers: { 'content-type' => 'application/ld+json' })
  end

  def stub_file_set_text(id:, text:)
    stub_request(:get, "https://figgy.princeton.edu/concern/file_sets/#{id}/text")
      .to_return(status: 200, body: text, headers: { 'content-type' => 'text/plain' })
  end
end
RSpec.configure do |config|
  config.include StubbedManifestsHelper
end

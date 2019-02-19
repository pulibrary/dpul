module StubbedManifestsHelper
  def stub_manifest(url:, fixture:)
    stub_request(:head, url)
      .to_return(status: 200, body: "", headers: { 'content-type' => 'application/ld+json' })
    stub_request(:get, url)
      .to_return(status: 200, body: File.read(Rails.root.join("spec", "fixtures", "manifests", fixture)), headers: { 'content-type' => 'application/ld+json' })
  end

  def stub_metadata(id:, status: 200)
    stub_request(:get, "https://figgy.princeton.edu/catalog/#{id}.jsonld")
      .to_return(status: status, body: File.read(Rails.root.join("spec", "fixtures", "metadata", "#{id}.json")), headers: { 'content-type' => 'application/ld+json' })
  end

  def stub_ocr_content(id:, text:)
    allow(FiggyGraphql).to receive(:get_ocr_content_for_id).with(id: id).and_return([text])
  end

  def stub_collections(fixture:)
    stub_request(:get, "https://hydra-dev.princeton.edu/iiif/collections")
      .to_return(status: 200, body: File.read(Rails.root.join("spec", "fixtures", "manifests", fixture)), headers: { 'content-type' => 'application/ld+json' })
  end
end
RSpec.configure do |config|
  config.include StubbedManifestsHelper
end

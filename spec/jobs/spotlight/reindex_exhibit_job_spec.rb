# frozen_string_literal: true

require 'rails_helper'

describe Spotlight::ReindexExhibitJob do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:url1) { 'http://example.com/1/manifest' }
  let(:manifest) { object_double(CollectionManifest.new, manifests: [{ "@id" => url1 }]) }

  before do
    allow(Spotlight::ReindexJob).to receive(:perform_later)
    allow(CollectionManifest).to receive(:find_by_slug).and_return(manifest)
  end

  it 'runs the index job inline' do
    described_class.perform_now(exhibit)

    expect(Spotlight::ReindexJob).to have_received(:perform_later).once
  end
end

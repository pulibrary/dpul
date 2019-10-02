# frozen_string_literal: true

require 'rails_helper'

describe ExhibitProxy do
  subject(:exhibit_proxy) { described_class.new(exhibit) }

  let(:exhibit) { instance_double(Spotlight::Exhibit) }
  let(:collection_manifest) { double }

  before do
    allow(exhibit).to receive(:slug).and_return('test-exhibit')
    allow(collection_manifest).to receive(:manifests).and_return([{ '@id' => 'uri://to-manifest1' }])
    allow(CollectionManifest).to receive(:find_by_slug).and_return(collection_manifest)
  end

  describe '#document_builder' do
    it 'constructs a DummyDocumentBuilder using the members in the Manifest' do
      expect(exhibit_proxy.document_builder).to be_a ExhibitProxy::DummyDocumentBuilder
      expect(exhibit_proxy.document_builder.members).to eq ['uri://to-manifest1']
      expect(exhibit_proxy.document_builder.documents_to_index).to eq ['uri://to-manifest1']
    end
  end
end

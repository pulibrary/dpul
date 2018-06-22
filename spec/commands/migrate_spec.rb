require 'rails_helper'
require Rails.root.join("lib", "commands", "migrate")

describe Migrate do
  before do
    WebMock.disable!
  end

  describe "exhibit_thumbnails" do
    subject(:command) { described_class.new }

    let(:document) do
      {
        "id" => "353205342bc9eb6a2330447a58ffadb2",
        "readonly_references_ssim" => [
          "{\"https://catalog.princeton.edu/catalog/5557079#view\":[\"Digital content below\"],\"iiif_manifest_paths\":{\"http://arks.princeton.edu/ark:/88435/bg257f113\":\"https://figgy.princeton.edu/concern/scanned_resources/d917e0d6-2894-4d1e-939b-93fdc0796c96/manifest\"}}"
        ],
        "access_identifier_ssim" => [
          "bg257f113"
        ]
      }
    end
    let(:exhibit_thumbnail) { instance_double(Spotlight::ExhibitThumbnail) }
    let(:exhibit_thumbnails) { [exhibit_thumbnail] }
    let(:response) { instance_double(Faraday::Response) }
    let(:manifest) do
      {
        sequences: [
          {
            "@type" => "sc:Sequence",
            "@id" => "https://figgy.princeton.edu/concern/scanned_resources/fbc2d7b3-164b-4458-b2c3-9007c2ed08a5/manifest/sequence/normal",
            canvases: [
              {
                "@type" => "sc:Canvas",
                "@id" => "https://figgy.princeton.edu/concern/scanned_resources/fbc2d7b3-164b-4458-b2c3-9007c2ed08a5/manifest/canvas/ac8a822f-60db-4c97-a79e-2ed1b3676072",
                label: "front cover",
                local_identifier: "bg257f113",
                rendering: [
                  {
                    "@id" => "https://figgy.princeton.edu/downloads/ac8a822f-60db-4c97-a79e-2ed1b3676072/file/d22f7d15-30ca-4f9c-88c3-987e54981840",
                    label: "Download the original file",
                    format: "image/tiff"
                  }
                ],
                width: "4502",
                height: "7200",
                images: [
                  {
                    "@type" => "oa:Annotation",
                    motivation: "sc:painting",
                    resource: {
                      "@type" => "dctypes:Image",
                      "@id" => {
                        id: "ac8a822f-60db-4c97-a79e-2ed1b3676072"
                      },
                      height: "7200",
                      width: "4502",
                      format: "image/jpeg",
                      service: {
                        "@context": "http://iiif.io/api/image/2/context.json",
                        "@id" => "https://libimages1.princeton.edu/loris/figgy_prod/3f%2F26%2F5b%2F3f265b23fbce4298b251d84c19439396%2Fintermediate_file.jp2",
                        profile: "http://iiif.io/api/image/2/level2.json"
                      }
                    },
                    on: "https://figgy.princeton.edu/concern/scanned_resources/fbc2d7b3-164b-4458-b2c3-9007c2ed08a5/manifest/canvas/ac8a822f-60db-4c97-a79e-2ed1b3676072"
                  }
                ]
              }
            ]
          }
        ]
      }
    end

    before do
      allow(response).to receive(:body).and_return(manifest.to_json)

      allow(exhibit_thumbnail).to receive(:document).and_return(document)
      allow(exhibit_thumbnail).to receive(:iiif_manifest_url=)
      allow(exhibit_thumbnail).to receive(:iiif_canvas_id=)
      allow(exhibit_thumbnail).to receive(:iiif_tilesource=)
      allow(exhibit_thumbnail).to receive(:save)
      allow(Spotlight::ExhibitThumbnail).to receive(:all).and_return(exhibit_thumbnails)
    end

    it "migrates the Spotlight::ExhibitThumbnail IIIF Manifests" do
      allow(response).to receive(:success?).and_return(true)
      allow(Faraday).to receive(:get).and_return(response)

      command.exhibit_thumbnails

      expect(exhibit_thumbnail).to have_received(:iiif_manifest_url=).with("https://figgy.princeton.edu/concern/scanned_resources/d917e0d6-2894-4d1e-939b-93fdc0796c96/manifest")
      expect(exhibit_thumbnail).to have_received(:iiif_canvas_id=).with("https://figgy.princeton.edu/concern/scanned_resources/fbc2d7b3-164b-4458-b2c3-9007c2ed08a5/manifest/canvas/ac8a822f-60db-4c97-a79e-2ed1b3676072")
      expect(exhibit_thumbnail).to have_received(:iiif_tilesource=).with("https://libimages1.princeton.edu/loris/figgy_prod/3f%2F26%2F5b%2F3f265b23fbce4298b251d84c19439396%2Fintermediate_file.jp2")

      expect(exhibit_thumbnail).to have_received(:save)
    end

    context "when the request for the IIIF Manifest results in a server-side error" do
      let(:logger) { instance_double(ActiveSupport::Logger) }

      before do
        allow(logger).to receive(:debug)
        allow(logger).to receive(:warn)
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it "does not migrate the Spotlight::ExhibitThumbnail and logs a warning" do
        allow(response).to receive(:success?).and_return(false)
        allow(Faraday).to receive(:get).and_return(response)

        command.exhibit_thumbnails

        expect(exhibit_thumbnail).not_to have_received(:save)
        expect(logger).to have_received(:warn).with("Failed to get https://figgy.princeton.edu/concern/scanned_resources/d917e0d6-2894-4d1e-939b-93fdc0796c96/manifest")
      end
    end

    context "when the request for the IIIF Manifest fails" do
      let(:logger) { instance_double(ActiveSupport::Logger) }

      before do
        allow(Faraday).to receive(:get).and_raise(Faraday::Error::ConnectionFailed.new("Connection failure"))
        allow(logger).to receive(:debug)
        allow(logger).to receive(:warn)
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it "does not migrate the Spotlight::ExhibitThumbnail and logs a warning" do
        command.exhibit_thumbnails

        expect(exhibit_thumbnail).not_to have_received(:save)
        expect(logger).to have_received(:warn).with("Failed to get https://figgy.princeton.edu/concern/scanned_resources/d917e0d6-2894-4d1e-939b-93fdc0796c96/manifest: Connection failure")
      end
    end

    context "when saving the Spotlight::ExhibitThumbnail fails" do
      let(:logger) { instance_double(ActiveSupport::Logger) }

      before do
        allow(response).to receive(:success?).and_return(true)
        allow(Faraday).to receive(:get).and_return(response)

        allow(logger).to receive(:debug)
        allow(logger).to receive(:warn)
        allow(Rails).to receive(:logger).and_return(logger)

        allow(exhibit_thumbnail).to receive(:iiif_manifest_url).and_return("https://figgy.princeton.edu/concern/scanned_resources/d917e0d6-2894-4d1e-939b-93fdc0796c96/manifest")
      end

      it "logs a warning" do
        allow(exhibit_thumbnail).to receive(:save).and_raise(ActiveRecord::RecordInvalid)
        command.exhibit_thumbnails

        expect(logger).to have_received(:warn).with("Failed to update ExhibitThumbnail for https://figgy.princeton.edu/concern/scanned_resources/d917e0d6-2894-4d1e-939b-93fdc0796c96/manifest: Record invalid")
      end
    end
  end

  after do
    WebMock.enable!
  end
end

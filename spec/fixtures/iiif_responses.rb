# frozen_string_literal: true

# pulled and pared down from spotlight
# https://github.com/projectblacklight/spotlight/blob/b4608610ed0405f1d8ed4d6c9c17a02b06b9bcf6/spec/fixtures/iiif_responses.rb
module IiifResponses
  def test_manifest1
    {
      "@id": "uri://for-manifest1/manifest",
      "@type": "sc:Manifest",
      "label": "Test Manifest 1",
      "attribution": "Attribution Data",
      "description": "A test IIIF manifest",
      "license": "http://www.example.org/license.html",
      "metadata": [
        {
          "label": "Author",
          "value": "John Doe"
        },
        {
          "label": "Author",
          "value": "Jane Doe"
        },
        {
          "label": "Another Field",
          "value": "Some data"
        },
        {
          "label": "Date",
          "value": "1929"
        }
      ],
      "thumbnail": {
        "@id": "uri://to-thumbnail",
        "service": {
          "@context": "http://iiif.io/api/image/2/context.json",
          "@id": "uri://to-thumbnail"
        }
      },
      "sequences": [
        {
          "@type": "sc:Sequence",
          "canvases": [
            {
              "@type": "sc:Canvas",
              "images": [
                {
                  "@type": "oa:Annotation",
                  "resource": {
                    "@type": "dcterms:Image",
                    "@id": "uri://full-image",
                    "service": {
                      "@id": "uri://to-image-service"
                    }
                  }
                }
              ]
            }
          ]
        }
      ],
      "structures": [
        {
          "@type": "sc:Range",
          "label": "range label value",
          "ranges": []
        }
      ]
    }.to_json
  end

  def test_manifest_see_also
    values = JSON.parse(test_manifest1)
    value = [
      {
        "@id": "http://for-manifest1.jsonld",
        "format": "application/ld+json"
      },
      {
        "@id": "uri://for-manifest1.xml",
        "format": "text/xml"
      }
    ]

    values["see_also"] = value
    values.to_json
  end

  def test_manifest_mvw
    {
      "@id": "uri://for-manifest_mvw/manifest",
      "@type": "sc:Collection",
      "label": "Test Manifest MVW",
      "attribution": "Attribution Data",
      "description": "A test IIIF MVW manifest",
      "license": "http://www.example.org/license.html",
      "metadata": [
        {
          "label": "Author",
          "value": "John Doe"
        },
        {
          "label": "Author",
          "value": "Jane Doe"
        },
        {
          "label": "Another Field",
          "value": "Some data"
        },
        {
          "label": "Date",
          "value": "1929"
        }
      ],
      "thumbnail": {
        "@id": "uri://to-thumbnail"
      },
      "manifests": [
        {
          "@context": "http://iiif.io/api/presentation/2/context.json",
          "@type": "sc:Manifest",
          "@id": "uri://for-manifest1/manifest",
          "label": [
            "01"
          ]
        }
      ]
    }.to_json
  end
end

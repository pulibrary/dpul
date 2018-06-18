# pulled and pared down from spotlight
# https://github.com/projectblacklight/spotlight/blob/b4608610ed0405f1d8ed4d6c9c17a02b06b9bcf6/spec/fixtures/iiif_responses.rb
module IiifResponses
  def test_manifest1
    {
      "@id": 'uri://for-manifest1/manifest',
      "@type": 'sc:Manifest',
      "label": 'Test Manifest 1',
      "attribution": 'Attribution Data',
      "description": 'A test IIIF manifest',
      "license": 'http://www.example.org/license.html',
      "metadata": [
        {
          "label": 'Author',
          "value": 'John Doe'
        },
        {
          "label": 'Author',
          "value": 'Jane Doe'
        },
        {
          "label": 'Another Field',
          "value": 'Some data'
        },
        {
          "label": 'Date',
          "value": '1929'
        }
      ],
      "thumbnail": {
        "@id": 'uri://to-thumbnail'
      },
      "sequences": [
        {
          "@type": 'sc:Sequence',
          "canvases": [
            {
              "@type": 'sc:Canvas',
              "images": [
                {
                  "@type": 'oa:Annotation',
                  "resource": {
                    "@type": 'dcterms:Image',
                    "@id": 'uri://full-image',
                    "service": {
                      "@id": 'uri://to-image-service'
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end

  def test_manifest2
    {
      "@context": "http://iiif.io/api/presentation/2/context.json",
      "@type": "sc:Collection",
      "@id": "uri://for-manifest2/manifest",
      "label": [
        "Test Manifest 2"
      ],
      "viewingHint": "multi-part",
      "metadata": [
        {
          "label": 'Author',
          "value": 'John Doe'
        },
        {
          "label": 'Author',
          "value": 'Jane Doe'
        },
        {
          "label": 'Another Field',
          "value": 'Some data'
        },
        {
          "label": 'Date',
          "value": '1929'
        }
      ],
      "manifests": [
        {
          "@context": "http://iiif.io/api/presentation/2/context.json",
          "@type": "sc:Manifest",
          "@id": "uri://for-manifest2a/manifest",
          "label": [
            "Test Manifest 2a"
          ],
          "thumbnail": {
            "@id": "uri://thumbnail2a"
          }
        },
        {
          "@context": "http://iiif.io/api/presentation/2/context.json",
          "@type": "sc:Manifest",
          "@id": "uri://for-manifest2b/manifest",
          "label": [
            "Test Manifest 2b"
          ],
          "thumbnail": {
            "@id": "uri://thumbnail2b"
          }
        }
      ],
      "license": "http://rightsstatements.org/vocab/NKC/1.0/"
    }.to_json
  end

  def test_manifest3
    {
      "@context": "http://iiif.io/api/presentation/2/context.json",
      "@type": "sc:Collection",
      "@id": "uri://for-manifest2/manifest",
      "label": [
        "Test Manifest 3"
      ],
      "viewingHint": "multi-part",
      "metadata": [
        {
          "label": 'Author',
          "value": 'John Doe'
        },
        {
          "label": 'Author',
          "value": 'Jane Doe'
        },
        {
          "label": 'Another Field',
          "value": 'Some data'
        },
        {
          "label": 'Date',
          "value": '1929'
        }
      ],
      "manifests": [
        {
          "@context": "http://iiif.io/api/presentation/2/context.json",
          "@type": "sc:Manifest",
          "@id": "uri://for-manifest2a/manifest",
          "label": [
            "Test Manifest 3a"
          ]
        },
        {
          "@context": "http://iiif.io/api/presentation/2/context.json",
          "@type": "sc:Manifest",
          "@id": "uri://for-manifest2b/manifest",
          "label": [
            "Test Manifest 3b"
          ],
          "thumbnail": {
            "@id": "uri://thumbnail2b"
          }
        }
      ],
      "license": "http://rightsstatements.org/vocab/NKC/1.0/"
    }.to_json
  end
end

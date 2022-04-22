## Exhibits

Created from Figgy collections and have Resources. They can have custom fields.

TODO: what/why is an exhibit proxy?

## Resources

A Resource is mostly a manifest url. Data is indexed from the manifest into solr. Look at a `IIIFResource` to see a couple other fields. 

The manifest url is indexed in solr as `content_metadata_iiif_manifest_field_ssi`. Two Resources may have the same manifest url. That's because pomegranate saves the resource as a member of its exhibit. So if one figgy resource is in two exhibits, it will be two resources in dpul. Note this is our local implementation; default spotlight does not create multiple resources, but instead uses prefixed solr fields to distinguish between data relevant to different exhibits.

## SolrDocumentSidecar
A record in the DB that stores exhibit-specific data about the resource in the form of a hash of solr fields / values in an attribute called `data`. The keys in this data attribute are prefixed with the exhibit name as it's actually saved into the index. It stores any metadata field it's configured to display on that exhibit -- some that come from figgy and some custom fields.

TODO:
* How do fields from figgy end up in a sidecar as opposed to the resource itself?

## Resource IDs

1. Database id. These are sequential and are indexed in solr as `spotlight_resource_id_ssim`.
1. Solr document id. These are opaque, assigned by solr, and used as the document_id for saved bookmarks.
1. Access id aka noid. These are used for dpul urls and are based on arks. These are indexed as `access_identifier_ssim`

## Finding a Database id when you have the dpul url

add `/raw` to the end of the dpul url and look for the field `spotlight_resource_id_ssim`

## Helpful snippets for poking around in a console

Scenario: Looking at the data objects for an item when what you have is its url

```
config = CatalogController.blacklight_config
repo = FriendlyIdRepository.new(config)
noid = "8049g8406"

# if you know there's just one you can do
# docs = repo.find(noid)["response"]["docs"]
# but if there might be more you need
docs = repo.search(q: "access_identifier_ssim:#{noid}")["response"]["docs"]

resources = docs.map{|doc| Spotlight::Resource.find(doc["spotlight_resource_id_ssim"].first.split("/").last)}

sidecars = resources.map{|r| Spotlight::SolrDocumentSidecar.where(resource_id: r.id)} 

## get to a solr document from a resource:
iiif_resource.document_builder.documents_to_index.first
```
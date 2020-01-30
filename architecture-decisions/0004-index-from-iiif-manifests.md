# 4. Indexing from IIIF Manifests

Date: Archaeological

## Status

Accepted

## Context

Objects in Pomegranate need to get their metadata from Figgy, where they are
administered. Spotlight ships with a IIIF-based indexer. Figgy already produces
IIIF manifests to support viewing the objects. However the metadata bucket
doesn't contain rich enough metadata for pomegranate use cases.

Figgy (plum, at the time) didn't have an API at the time this decision was made. Manifests were the
only way to get data out. Today Figgy has a graphql API.

## Decision

We will use the IIIF Manifests to pull data from Figgy into Pomegranate. The
Manifest gives us the manifest url (used for presenting a viewer), the thumbnail
iiif image url, and the jsonld metadata location (via seeAlso).

## Consequences

* We have to do multiple queries for each index action.

* Efficiency of synchronization is bound to the efficiency of generating
  manifests

* Access authorization must be negotiated via headers, where an API might be more
  straightforward.

# 7. Indexing resources with non-public visibility

Date: Archaeological

## Status

Accepted

## Context

Figgy resources may have any of the following visibilities:
- Open (public)
- Princeton (netid)
- On Campus (ip)
- Reading Room
- Private

For each of these we need a policy regarding whether it will be indexed in DPUL.

We used to index only public / complete items. But to support the music reserves
collection we need pages that would have a viewer for logged-in institutional
users only.

## Decision

Resources with the following visibilities should index into DPUL:
- Open (public)
- Princeton (netid)
- On Campus (ip)

This is implemented with a token authentication mechanism in `iiif_resource#def
url`

## Consequences

* Users will see metadata for resources they may not be able to access.
* Users with access will be able to search everything they can view.
* There's no support in DPUL for private or reading room material.

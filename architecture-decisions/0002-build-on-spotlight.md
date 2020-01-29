# 2. Build on Spotlight

Date: Archaeological

## Status

Accepted

## Context

PUDL has [collection landing
pages](http://pudl.princeton.edu/collections/pudl0058) because it's a digital collections site which
staff pushed content into. PUDL required all items be in a single collection,
and couldn't provide good search-across. Figgy is a staff back-end, so we need some sort of
application to provide that functionality.

Curators also had a history of either requesting or creating ad-hoc websites to showcase
their material or accompany on-site exhibits. We wanted instead to provide a CMS for
them to create those experiences based on material they curate which wouldn't
create metadata silos and increased maintenance.

Further, curators often had different use cases about how metadata should
display in different contexts. For example, items with the same title in the catalog may need to be differentiated in an exhibit. It was important that certain fields display a certain
way, but be cataloged according to best practices.

Spotlight is an exhibit building platform that provides controlled CMS
functionality and is built on Blacklight similar to our new catalog. It allows
for local overrides of fields.

## Decision

We will use Spotlight to fulfill both the requirements of a Collection Landing
Page as well as exhibits. Curators of collections will generate the collection
pages. Staff who wish to generate exhibits will be able to manage membership in
Figgy but have the tools to create those exhibits in Pomegranate.

## Consequences

* There's a maintenance burden on these pages for Curators.
* Different curators may display fields in different ways, leading to a less
uniform experience than PUDL.
* Most metadata can be managed centrally in the ILS/Figgy/EADs.
* Metadata can still be created which only lives in Pomegranate. This metadata
is less preserved and should be losable.
* The use cases of a Digital Collections site may conflict with the use cases of
exhibit generation.

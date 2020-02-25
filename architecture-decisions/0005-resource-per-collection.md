# 5. Create a IIIFResource for each Collection that a resource is a member of

Date: Archaeological

## Status

Accepted

## Context

We needed to be able to display a resource in more than one collection, because
in Figgy a resource can be a member of multiple collections.

At the time of this decision, one IIIFResource could only be a member of one Exhibit.

## Decision

We create one IIIFResource per Collection of which it is a member.

We map each IIIFResource to one SolrDocument.

## Consequences

* 'Search Across' requires a complicated grouping mechanism (in solr) in order
  to keep a resource from appearing multiple times.

* It's easy to delete a collection and all its resources. It's easy to delete a
  resource if it's no longer in a given collection.

* The resource that appears in 'Search Across' displays metadata as shown in the
  exhibit it happened to pull the resource from. This may be be specialized to
  the exhibit, and different from the canonical data as stored in figgy.

* If spotlight introduces the ability to have one resource in multiple exhibits
  we may have a different implementation than is in core (this happened).

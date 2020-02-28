# 6. Label "Exhibits" as "Collections"

Date: Archaeological

## Status

Accepted

## Context

Spotlight uses the term "Exhibits" because its primary use case is generating
multiple exhibit sites. However, as per
[ADR #2](./0002-build-on-spotlight.md) we want to use it as landing pages for
collections.

The term "Collection" was used everywhere else, including PUDL, so we decided to
use that instead. Originally reported in
[#89](https://github.com/pulibrary/pomegranate/issues/89).

## Decision

* Use "Collection" in the UI everywhere "Exhibit" is mentioned in Spotlight.

## Consequences

* The UI says "Collection," but the code says "Exhibit," which is potentially
  confusing to developers.

* A couple of views will have to be overridden, which complicates the upgrade
  path. See [#90](https://github.com/pulibrary/pomegranate/pull/90/files)

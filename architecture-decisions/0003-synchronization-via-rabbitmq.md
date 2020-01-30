# 3. Synchronization via RabbitMQ

Date: Archaeological

## Status

Accepted

## Context

We want Pomegranate to be a separate application from Figgy, but need some way
for Figgy to tell Pomegranate about new resources so that when something is
marked Complete in Figgy or taken down that it's reflected in Pomegranate.

## Decision

Figgy will send create/update/delete messages to a fanout RabbitMQ Exchange.
Pomegranate will register a durable queue which listens to that exchange and
process messages using [Sneakers](https://github.com/jondot/sneakers).

The message will contain the following information:
 * Collection slugs the object is a member of
 * Manifest URL of the object
 * change event (create / update / delete)

## Consequences

* If Sneakers workers stop processing, then new documents don't make it in to
Pomegranate and we have to perform a reindex.

* We have to monitor the status of our queues to make sure things are working.

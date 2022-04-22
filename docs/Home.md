Collected tips about navigating and using the DPUL codebase and infrastructure.

* [Navigating DPUL Objects](https://github.com/pulibrary/pomegranate/wiki/Navigating-DPUL-Objects)
* [Indexing Metadata from Figgy](https://github.com/pulibrary/pomegranate/wiki/Indexing-metadata-from-Figgy)
* [RabbitMQ / Sneakers](https://github.com/pulibrary/pomegranate/wiki/RabbitMQ---Sneakers)


## Indexing collections in your development environment

Explicit commits have been removed from the codebase in order to rely on autocommit configuration in solr. Once you've indexed a collection you may not see the changes right away. You commit the index manually with:

`Blacklight.default_index.connection.commit`
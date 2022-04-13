Although we index from manifests, the metadata itself comes from figgy's jsonld endpoints. We've configured Pomegranate to use a custom metadata class:

https://github.com/pulibrary/pomegranate/blob/54c75d617bc9d296d40211f1e20074b7534f9aaf/config/initializers/spotlight_config.rb#L6

`ManifestMetadata` pulls everything out of the jsonld and allows for special handling of individual values through `Value#transform_value`. 
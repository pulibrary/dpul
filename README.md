# Pomegranate

A [Spotlight](https://github.com/sul-dlss/spotlight) application for Princeton University Library.

### Setup

```sh
git clone git@github.com:pulibrary/pomegranate.git
cd pomegranate
bundle install
rake jetty:unzip
rake jetty:configure_solr
rake jetty:start
```

After setup, run Pomegranate locally with `rails s`.

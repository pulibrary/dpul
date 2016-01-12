# Pomegranate

[![Circle CI](https://circleci.com/gh/pulibrary/pomegranate.svg?style=svg)](https://circleci.com/gh/pulibrary/pomegranate)
[![Stories in Ready](https://badge.waffle.io/pulibrary/pomegranate.png?label=ready&title=Ready)](https://waffle.io/pulibrary/pomegranate)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)

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

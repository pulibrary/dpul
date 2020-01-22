# Pomegranate

[![Circle CI](https://circleci.com/gh/pulibrary/pomegranate.svg?style=svg)](https://circleci.com/gh/pulibrary/pomegranate)
[![Coverage Status](https://coveralls.io/repos/github/pulibrary/pomegranate/badge.svg?branch=master)](https://coveralls.io/github/pulibrary/pomegranate?branch=master)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)

A [Spotlight](https://github.com/sul-dlss/spotlight) application for Princeton University Library.

## Dependencies

* Ruby
* Nodejs
* Java (to run Solr server)
* (Postgres (for OSX dev systems, install via homebrew)
* Redis (install via homebrew and run via `homebrew services`)


## Setup

```sh
git clone git@github.com:pulibrary/pomegranate.git
cd pomegranate
bundle install
yarn install
bundle exec rake db:create
bundle exec rake db:migrate
```

After setup, run Pomegranate locally either with

`bundle exec foreman start`

to run everything at once, or, in separate terminal windows run each command
listed in `Procfile`

### Importing Data:

1. Log in once via CAS
2. Run `rake pomegranate:site_admin`
3. Click "Create a New Collection"
4. Select a small collection and hit "Save"
  - To find a small collection: go to Figgy, submit a blank search, open the facet collection and click 'more', and page to the low-count collections 
5. Either wait for a solr commit or manually commit in the rails console with
   `Blacklight.default_index.connection.commit`

### Running Tests

```sh
bundle exec rake pomegranate:test
bundle exec rspec
```

### Auto-update from [Figgy](https://github.com/pulibrary/figgy)

Figgy announces events to a durable RabbitMQ fanout exchange. In order to use them, do the
following:

1. Configure the `events` settings in `config/config.yml`
2. Run `WORKERS=FiggyEventHandler rake sneakers:run`

This will subscribe to the events and update the pomegranate records when they're
created, updated, or deleted.

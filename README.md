# DPUL

[![Circle CI](https://circleci.com/gh/pulibrary/dpul.svg?style=svg)](https://circleci.com/gh/pulibrary/dpul)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)
![Coverage Status](https://img.shields.io/badge/coverage-100%25-green.svg)

A [Spotlight](https://github.com/sul-dlss/spotlight) application for Princeton University Library,
formerly known as Pomegranate, but renamed to the offical brand: Digital PUL.

## Dependencies

* Ruby
* Nodejs
* Java (to run Solr server)
* (Postgres (for OSX dev systems, install via homebrew)
* Redis (install via homebrew and run via `homebrew services`)


## Initial Setup

```sh
git clone git@github.com:pulibrary/dpul.git
cd dpul
bundle install
yarn install
```

Remember you'll need to run `bundle install` and `yarn install` on an ongoing basis as dependencies are updated.

## Setup server

### Lando

Lando will automatically set up docker images for Solr and Postgres which match
the versions we use in Production. The ports will not collide with any other
projects you're using Solr/Postgres for, and you can easily clean up with `lando
destroy` or turn off all services with `lando poweroff`.

1. Install Lando DMG from <https://github.com/lando/lando/releases>
1. `rake servers:start`

1. For test:
   - In a separate terminal: `bundle exec rspec`
1. For development:
   - In a separate terminal: `foreman start`
     - Or run services separately as shown in <https://github.com/pulibrary/dpul/blob/main/Procfile>
   - Access DPUL at <http://localhost:3000/>

### Importing Data:

1. Log in once via CAS
2. Run `rake dpul:site_admin`
3. Click "Create a New Collection"
4. Select a small collection and hit "Save"
  - To find a small collection: go to Figgy, submit a blank search, open the facet collection and click 'more', and page to the low-count collections
5. Either wait for a solr commit or manually commit in the rails console with
   `Blacklight.default_index.connection.commit`

### Running Tests

```sh
bundle exec rspec
```

### Auto-update from [Figgy](https://github.com/pulibrary/figgy)

Figgy announces events to a durable RabbitMQ fanout exchange. In order to use them, do the
following:

1. Configure the `events` settings in `config/config.yml`
2. Run `WORKERS=FiggyEventHandler rake sneakers:run`

This will subscribe to the events and update the DPUL records when they're
created, updated, or deleted.

## Replicate database and solr index from production to staging

1. SSH to the staging machine as the system user
1. Stop nginx
1. As deploy user, `cd /opt/dpul/currnt`
1. Run the rake task `DATE=2021-09-23 bundle exec rake dpul:replicate:prod`
   * Note you can't use any date after 9/23 until #1023 is resolved
1. Start nginx back up

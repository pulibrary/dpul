# Pomegranate

[![Circle CI](https://circleci.com/gh/pulibrary/pomegranate.svg?style=svg)](https://circleci.com/gh/pulibrary/pomegranate)
[![Stories in Ready](https://badge.waffle.io/pulibrary/pomegranate.png?label=ready&title=Ready)](https://waffle.io/pulibrary/pomegranate)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=plastic)](./LICENSE)

A [Spotlight](https://github.com/sul-dlss/spotlight) application for Princeton University Library.

## Setup

```sh
git clone git@github.com:pulibrary/pomegranate.git
cd pomegranate
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
```

To create an initial user account and exhibit, use the Spotlight rake tasks:

```sh
rake spotlight:initialize
rake spotlight:exhibit
```

After setup, run Pomegranate locally with `rails s`.

## Auto-update from [Plum](https://github.com/pulibrary/plum)

Plum announces events to a durable RabbitMQ fanout exchange. In order to use them, do the
following:

1. Configure the `events` settings in `config/config.yml`
2. Run `WORKERS=PlumEventHandler rake sneakers:run`

This will subscribe to the plum events and update the pomegranate records when they're
created, updated, or deleted.

## Development Setup

### Test

```sh
bundle exec rake pomegranate:test
bundle exec rspec spec
```

### Development Server

#### Setting up server:

```sh
bundle exec rake pomegranate:development
bundle exec rails s
```

#### Importing Data:

1. Log in once via CAS
2. Run `rake pomegranate:site_admin`
3. Click "Create a New Collection"
4. Select a small collection and hit "Save" (Recommend `ABC Books`)
5. Wait for import (this will take a while since it's happening in foreground on dev)

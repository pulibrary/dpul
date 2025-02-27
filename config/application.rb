# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'
require 'open-uri'
require_relative 'lando_env'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pomegranate
  class Application < Rails::Application
    config.action_mailer.default_url_options = { host: "localhost:3000", from: "noreply@example.com" }

    # Use custom error pages
    config.exceptions_app = routes

    config.autoloader = :zeitwerk
    # Keep using secrets.yml so we can pull secret key base from ENV.
    # Pulled from
    # https://island94.org/2024/11/keep-your-secrets-yml-in-rails-7-2
    config.secrets = config_for(:secrets)
    config.secret_key_base = config.secrets[:secret_key_base]

    delegate :secrets, to: :config

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.autoload_paths += %W(#{Rails.root}/app/workers)
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, Hash, HashWithIndifferentAccess, IIIF::OrderedHash]
  end
end

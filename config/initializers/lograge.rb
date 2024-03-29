# frozen_string_literal: true
Rails.application.configure do
  # Implements fix described in https://github.com/roidrage/lograge/issues/92
  class ActionDispatch::Http::UploadedFile
    def as_json(_options = nil)
      %w[headers].index_with do |attr|
        send(attr).force_encoding('utf-8')
      end
    end
  end
  # Lograge config
  config.lograge.enabled = true

  # We are asking here to log in RAW (which are actually ruby hashes). The Ruby logging is going to take care of the JSON formatting.
  config.lograge.formatter = Lograge::Formatters::Logstash.new

  # This is is useful if you want to log query parameters
  config.lograge.custom_options = lambda do |event|
    { ddsource: ["ruby"],
      params: event.payload[:params].reject { |k| %w[controller action format].include? k } }
  end
end

# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  class CanCan::ModelAdapters::StiNormalizer
    def self.normalize(*args); end
  end
end

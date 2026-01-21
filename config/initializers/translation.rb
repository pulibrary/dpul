# frozen_string_literal: true

Rails.application.config.to_prepare do
  require "i18n/backend/active_record"

  Translation = I18n::Backend::ActiveRecord::Translation

  # Guard to prevent errors when running rake db:create
  # Important when running replicate:prod cap task
  def database_exist?
    return true if ActiveRecord::Base.connection
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
    false
  end

  if database_exist? && Translation.table_exists?
    ##
    # Sets up the new Spotlight Translation backend, backed by ActiveRecord. To
    # turn on the ActiveRecord backend, uncomment the following lines.

    # I18n.backend = I18n::Backend::ActiveRecord.new
    I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
    Translation.send(:include, Spotlight::CustomTranslationExtension)
    I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
    I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

    # I18n.backend = I18n::Backend::Chain.new(I18n.backend, I18n::Backend::Simple.new)
  end
rescue ActiveRecord::DatabaseConnectionError, ActiveRecord::NoDatabaseError
  # when using rake to start servers, there's no db yet
  Rails.logger.debug("Database error")
end

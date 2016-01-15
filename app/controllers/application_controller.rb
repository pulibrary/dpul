class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller

  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def guest_username_authentication_key(key)
    key &&= nil unless key.to_s.match(/^guest/)
    return key if key
    "guest_" + guest_user_unique_suffix
  end
end

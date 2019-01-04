class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller

  before_action :set_paper_trail_whodunnit

  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Use custom error pages
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Blacklight::Exceptions::RecordNotFound, with: :not_found

  def not_found
    render "pages/not_found", status: 404
  end

  def guest_username_authentication_key(key)
    key &&= nil unless key.to_s =~ /^guest/
    return key if key
    "guest_" + guest_user_unique_suffix
  end

  def create_guest_user(key = nil)
    User.new do |g|
      g.username = guest_username_authentication_key(key)
      g.email = guest_email_authentication_key(key)
      g.guest = true if g.respond_to? :guest
      g.skip_confirmation! if g.respond_to?(:skip_confirmation!)
      g.save(validate: false)
    end
  end
end

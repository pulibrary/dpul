# frozen_string_literal: true

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
  rescue_from ActionView::MissingTemplate, with: :not_found

  def not_found
    respond_to do |format|
      format.html { render "pages/not_found", status: 404 }
      format.all { head 404 }
    end
  end

  def current_exhibit
    super
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def guest_username_authentication_key(key)
    key &&= nil unless key.to_s.match?(/^guest/)
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

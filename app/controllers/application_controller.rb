# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Blacklight::Controller
  include Spotlight::Controller
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Spotlight::Concerns::ApplicationController

  before_action :set_paper_trail_whodunnit

  layout 'spotlight/spotlight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Use custom error pages
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Blacklight::Exceptions::RecordNotFound, with: :not_found
  rescue_from ActionView::MissingTemplate, with: :not_found
  rescue_from Riiif::ImageNotFoundError, with: :not_found

  def not_found
    # Error on exhibit when resource is requested on a nonexistent exhibit
    if params[:id] && params[:exhibit_id] && @exhibit.nil?
      redirect_to "/#{params[:exhibit_id]}"
    else
      respond_to do |format|
        format.html { render "pages/not_found", status: :not_found }
        format.all { head :not_found }
      end
    end
  end

  # This override keeps various layout templates from erroring when they check
  # whether there's an exhibit selected
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

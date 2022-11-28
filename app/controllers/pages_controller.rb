# frozen_string_literal: true

class PagesController < ApplicationController
  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { message: "Internal Server Error" }, status: :internal_server_error }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { message: "Not Found" }, status: :not_found }
    end
  end

  def robots
    respond_to :text
    expires_in 6.hours, public: true
  end

  def viewers
    respond_to :html
  end
end

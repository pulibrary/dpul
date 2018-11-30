class PagesController < ApplicationController
  def internal_server_error
    respond_to do |format|
      format.html { render status: 500 }
      format.json { render json: { message: "Internal Server Error" }, status: 500 }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.json { render json: { message: "Not Found" }, status: 404 }
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

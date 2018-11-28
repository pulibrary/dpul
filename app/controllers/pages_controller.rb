class PagesController < ApplicationController
  def robots
    respond_to :text
    expires_in 6.hours, public: true
  end

  def viewers
    respond_to :html
  end
end

require 'rails_helper'

RSpec.describe PagesController do
  describe "robots" do
    it "renders robot.text" do
      get :robots, params: { format: :text }
      expect(response).to render_template "pages/robots"
    end
  end

  describe "viewers" do
    it "renders viewers page" do
      get :viewers, params: { format: :html }
      expect(response).to render_template "pages/viewers"
    end
  end
end

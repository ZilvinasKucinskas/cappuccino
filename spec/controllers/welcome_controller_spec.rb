require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  render_views

  describe "GET #index" do
    it "returns http success" do
      process :index, method: :get
      expect(response).to have_http_status(:success)
    end
  end
end

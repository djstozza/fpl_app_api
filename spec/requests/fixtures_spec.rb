require 'rails_helper'

RSpec.describe "Fixtures", type: :request do
  describe "GET /fixtures" do
    it "works! (now write some real specs)" do
      get fixtures_path
      expect(response).to have_http_status(200)
    end
  end
end

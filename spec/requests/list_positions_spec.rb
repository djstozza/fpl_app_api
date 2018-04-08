require 'rails_helper'

RSpec.describe "ListPositions", type: :request do
  describe "GET /list_positions" do
    it "works! (now write some real specs)" do
      get list_positions_path
      expect(response).to have_http_status(200)
    end
  end
end

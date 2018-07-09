require 'rails_helper'

RSpec.describe "Positions", type: :request do
  describe "GET /api/v1/positions" do
    it "is valid" do
      get api_v1_positions_path

      expect(response).to have_http_status(200)

      expected = Position.pluck_to_hash(:id, :singular_name_short, :singular_name, :plural_name, :plural_name_short)
      expect(response.body).to eq(expected.to_json)
    end
  end
end

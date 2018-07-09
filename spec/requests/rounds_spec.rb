require 'rails_helper'

RSpec.describe "Rounds", type: :request do
  describe "GET /api/v1/rounds" do
    it "is valid" do
      FactoryBot.create(:round)
      get api_v1_rounds_path

      expect(response).to have_http_status(200)
      expect(response.body).to eq(RoundDecorator.new(nil).rounds_hash.to_json)
    end
  end
end

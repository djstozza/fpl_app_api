require 'rails_helper'

RSpec.describe "Round", type: :request do
  describe "GET /api/v1/rounds" do
    it "is valid with no round id" do
      round = FactoryBot.create(:round, is_current: true)
      FactoryBot.create(:fixture, round: round)
      get api_v1_round_index_path

      expected = { round: round, fixtures: round.decorate.fixture_hash }

      expect(response).to have_http_status(200)
      expect(response.body).to eq(expected.to_json)
    end

    it "is valid with a round id" do
      round = FactoryBot.create(:round)
      FactoryBot.create(:fixture, round: round)
      get api_v1_round_index_path(round_id: round)

      expected = { round: round, fixtures: round.decorate.fixture_hash }

      expect(response).to have_http_status(200)
      expect(response.body).to eq(expected.to_json)
    end

    it 'responds with 404 when not found' do
      round = FactoryBot.create(:round)
      get api_v1_round_index_path(round_id: round.id + 1)

      expect(response).to have_http_status(404)
    end
  end
end

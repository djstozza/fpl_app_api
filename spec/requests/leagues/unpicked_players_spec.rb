require 'rails_helper'

RSpec.describe "UnpickedPlayers", type: :request do
  describe "index" do
    it "is valid" do
      FactoryBot.create(:round)
      league = FactoryBot.create(:league)

      get api_v1_league_unpicked_players_path(league_id: league.id)

      expect(response).to have_http_status(200)
      expect(response.body).to eq({ unpicked_players: league.decorate.unpicked_players }.to_json)
    end
  end
end

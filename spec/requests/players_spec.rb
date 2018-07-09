require 'rails_helper'

RSpec.describe "Players", type: :request do
  describe "GET /api/v1/players" do
    it "is valid" do
      FactoryBot.create(:player)
      get api_v1_players_path

      expect(response).to have_http_status(200)
      expect(response.body).to eq(PlayerDecorator.new(Player.all).players_hash.to_json)
    end
  end

  describe "GET api/v1/player" do
    it "is valid" do
      player = FactoryBot.create(:player)
      get api_v1_player_path(id: player.id)

      expect(response).to have_http_status(200)

      expected = {
        player: player,
        team: player.team,
        position: player.position
      }.to_json

      expect(response.body).to eq(expected)
    end

    it 'responds with 404 when not found' do
      player = FactoryBot.create(:player)
      get api_v1_player_path(id: player.id + 1)

      expect(response).to have_http_status(404)
    end
  end
end

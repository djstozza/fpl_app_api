require 'rails_helper'

RSpec.describe "Teams", type: :request do
  describe "GET /api/v1/teams" do
    it "is valid" do
      FactoryBot.create(:team)
      get api_v1_teams_path

      expect(response).to have_http_status(200)
      expect(response.body).to eq(TeamDecorator.new(nil).teams_hash.to_json)
    end
  end

  describe "GET api/v1/team" do
    it "is valid" do
      team = FactoryBot.create(:team)

      FactoryBot.create(:player, team: team)
      FactoryBot.create(:fixture, home_team: team)

      get api_v1_team_path(id: team.id)

      expect(response).to have_http_status(200)

      expected = {
        team: team,
        fixtures: team.decorate.fixture_hash,
        players: PlayerDecorator.new(team.players).players_hash,
      }.to_json

      expect(response.body).to eq(expected)
    end

    it 'responds with 404 when not found' do
      team = FactoryBot.create(:team)
      get api_v1_team_path(id: team.id + 1)

      expect(response).to have_http_status(404)
    end
  end
end

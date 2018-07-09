require 'rails_helper'

RSpec.describe "FplTeams", type: :request do
  describe "GET /api/v1/fpl_teams" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      FactoryBot.create(:fpl_team, user: user)

      get api_v1_fpl_teams_path, headers: auth_headers

      expect(response).to have_http_status(200)

      fpl_teams = UserDecorator.new(user).fpl_teams_arr

      expect(response.body).to eq({ fpl_teams: fpl_teams }.to_json)
    end

    it "responds with 401 if not logged in" do
      get api_v1_fpl_teams_path

      expect(response).to have_http_status(401)
    end
  end

  describe "GET /api/v1/fpl_team" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token
      fpl_team = FactoryBot.create(:fpl_team)
      get api_v1_fpl_team_path(id: fpl_team.id), headers: auth_headers

      expect(response).to have_http_status(200)

      fpl_team_hash = ::FplTeams::Hash.run(fpl_team: fpl_team, user: user).result
      expect(response.body).to eq(fpl_team_hash.to_json)
    end

    it "responds with 401 if not logged in" do
      fpl_team = FactoryBot.create(:fpl_team)
      get api_v1_fpl_team_path(id: fpl_team.id)

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token
      fpl_team = FactoryBot.create(:fpl_team)
      get api_v1_fpl_team_path(id: (fpl_team.id + 1)), headers: auth_headers

      expect(response).to have_http_status(404)
    end

    it "responds with 422 if show_trade_groups is true and user != fpl_team.user" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token
      fpl_team = FactoryBot.create(:fpl_team)
      FactoryBot.create(:fpl_team_list, fpl_team: fpl_team)

      get api_v1_fpl_team_path(id: fpl_team.id, show_trade_groups: true), headers: auth_headers

      expect(response).to have_http_status(422)
    end

    describe "PUT /api/v1/fpl_team" do
      it "is valid" do
        user = FactoryBot.create(:user)
        auth_headers = user.create_new_auth_token
        fpl_team = FactoryBot.create(:fpl_team, user: user)

        put api_v1_fpl_team_path(id: fpl_team.id), headers: auth_headers

        expect(response).to have_http_status(200)

        expected = ::FplTeams::Hash.run(fpl_team: fpl_team, user: user).result.merge(
          success: 'Fpl team successfully updated.',
        ).to_json

        expect(JSON.parse(response.body)).to include(JSON.parse(expected))
      end

      it "responds with 401 if not logged in" do
        fpl_team = FactoryBot.create(:fpl_team)
        put api_v1_fpl_team_path(id: fpl_team.id)

        expect(response).to have_http_status(401)
      end

      it "responds with 422 if show_trade_groups is true and user != fpl_team.user" do
        user = FactoryBot.create(:user)
        auth_headers = user.create_new_auth_token
        fpl_team = FactoryBot.create(:fpl_team)

        put api_v1_fpl_team_path(id: fpl_team.id), headers: auth_headers

        expect(response).to have_http_status(422)
      end

      it "responds with 404 when not found" do
        user = FactoryBot.create(:user)
        auth_headers = user.create_new_auth_token
        fpl_team = FactoryBot.create(:fpl_team)
        put api_v1_fpl_team_path(id: (fpl_team.id + 1)), headers: auth_headers

        expect(response).to have_http_status(404)
      end
    end
  end
end

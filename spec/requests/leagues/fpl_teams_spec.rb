require 'rails_helper'

RSpec.describe "FplTeams", type: :request do
  describe "index" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league)
      FactoryBot.create(:fpl_team, league: league)

      get api_v1_league_fpl_teams_path(league_id: league.id), headers: auth_headers

      expect(response).to have_http_status(200)

      expect(response.body).to eq({ fpl_teams: league.fpl_teams }.to_json)
    end
  end

  describe "update" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league, status: 'create_draft', commissioner: user)

      fpl_team_1 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 1)
      fpl_team_2 = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 2)

      put api_v1_league_fpl_team_path(
        league_id: league.id,
        fpl_team_id: fpl_team_1.id,
        draft_pick_number: fpl_team_2.draft_pick_number
      ), headers: auth_headers

      response_hash = {
        league: league,
        current_user: user,
        fpl_teams: league.decorate.fpl_teams_arr,
        commissioner: user,
      }

      expect(response).to have_http_status(200)
      expect(response.body).to eq(response_hash.to_json)
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league)

      fpl_team = FactoryBot.create(:fpl_team, league: league, draft_pick_number: 1)

      params = {
        league_id: league.id,
        fpl_team_id: fpl_team.id,
        draft_pick_number: fpl_team.draft_pick_number + 1,
      }

      put api_v1_league_fpl_team_path(params), headers: auth_headers

      outcome = ::Leagues::UpdateDraftPickNumberOrder.run(params.merge(user: user))

      response_hash = {
        league: league,
        current_user: user,
        fpl_teams: league.decorate.fpl_teams_arr,
        commissioner: league.commissioner,
      }
      response_hash[:error] = outcome.errors

      expect(response).to have_http_status(422)
      expect(response.body).to eq(response_hash.to_json)
    end
  end
end

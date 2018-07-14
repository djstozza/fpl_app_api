require 'rails_helper'

RSpec.describe "GenerateFplTeamDraftPickNumbers" do
  describe "update" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league, status: 'generate_draft_picks', commissioner: user)

      ::League::MIN_FPL_TEAM_QUOTA.times { FactoryBot.create(:fpl_team, league: league, draft_pick_number: nil) }

      put api_v1_league_generate_fpl_team_draft_pick_numbers_path(league_id: league.id), headers: auth_headers

      expect(response).to have_http_status(200)

      response_hash = {
        league: league.reload,
        current_user: user,
        fpl_teams: league.decorate.fpl_teams_arr,
        commissioner: user,
      }

      expect(JSON.parse(response.body)).to eq(JSON.parse(response_hash.to_json))
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league)
      FactoryBot.create(:fpl_team, league: league)

      params = { league_id: league.id }

      put api_v1_league_generate_fpl_team_draft_pick_numbers_path(params), headers: auth_headers

      expect(response).to have_http_status(422)

      outcome = ::Leagues::GenerateFplTeamDraftPickNumbers.run(params.merge(user: user))

      response_hash = {
        league: league.reload,
        current_user: user,
        fpl_teams: league.decorate.fpl_teams_arr,
        commissioner: league.commissioner,
      }

      response_hash[:error] = outcome.errors

      expect(response.body).to eq(response_hash.to_json)
    end
  end
end

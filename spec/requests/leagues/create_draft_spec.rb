require 'rails_helper'

RSpec.describe "CreateDraft", type: :request do
  describe "create" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league, status: 'create_draft', commissioner: user)

      ::League::MIN_FPL_TEAM_QUOTA.times { FactoryBot.create(:fpl_team, league: league) }

      post api_v1_league_create_draft_path(league_id: league.id), headers: auth_headers

      expect(response).to have_http_status(200)

      response_hash = {
        league: {
          commissioner_id: user.id,
          status: 'draft',
          id: league.id,
          name: league.name,
          code: league.code,
          created_at: league.created_at,
          updated_at: league.reload.updated_at,
        },
        current_user: user,
        fpl_teams: league.decorate.fpl_teams_arr,
        commissioner: user,
      }

      expect(response.body).to eq(response_hash.to_json)
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league)

      ::League::MIN_FPL_TEAM_QUOTA.times { FactoryBot.create(:fpl_team, league: league) }

      post api_v1_league_create_draft_path(league_id: league.id), headers: auth_headers

      expect(response).to have_http_status(422)

      response_hash = {
        league: league,
        current_user: user,
        fpl_teams: league.decorate.fpl_teams_arr,
        commissioner: league.commissioner,
      }

      outcome = ::Leagues::CreateDraft.run(league: league, user: user)
      expect(outcome).not_to be_valid

      response_hash[:error] = outcome.errors

      expect(response.body).to eq(response_hash.to_json)
    end
  end
end

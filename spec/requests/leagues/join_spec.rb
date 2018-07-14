require 'rails_helper'

RSpec.describe "Join", type: :request do
  describe "create" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league, status: 'generate_draft_picks')

      fpl_team_name = 'foo'

      params = {
        name: league.name,
        code: league.code,
        fpl_team_name: fpl_team_name,
      }

      post api_v1_join_path(league: params), headers: auth_headers

      expect(response).to have_http_status(200)

      expected = {
        league: league,
        current_user: user,
        commissioner: league.commissioner,
        fpl_teams: league.decorate.fpl_teams_arr,
        success: 'League successfully joined.',
      }

      expect(response.body).to eq(expected.to_json)
    end

    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      fpl_team = FactoryBot.create(:fpl_team)

      params = {
        name: '',
        code: '',
        fpl_team_name: fpl_team.name,
      }

      post api_v1_join_path(league: params), headers: auth_headers

      expect(response).to have_http_status(422)

      form = ::Leagues::JoinLeagueForm.run(params.merge(user: user))
      expect(form).not_to be_valid

      expected = { error: form.errors }

      expect(response.body).to eq(expected.to_json)
    end
  end
end

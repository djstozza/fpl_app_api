require 'rails_helper'
RSpec.describe "PassMiniDraftPicks", type: :request do
  describe "create" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, mini_draft: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      post api_v1_league_pass_mini_draft_picks_path(
        league_id: league.id,
        fpl_team_list_id: fpl_team_list.id,
      ), headers: auth_headers

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['success']).to eq('You have successfully passed')
    end

    it "responds with 401 if not logged in" do
      league = FactoryBot.create(:league)
      post api_v1_league_pass_mini_draft_picks_path(league_id: league.id)

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token
      league = FactoryBot.create(:league)
      post api_v1_league_pass_mini_draft_picks_path(league_id: league.id + 1), headers: auth_headers

      expect(response).to have_http_status(404)
    end
  end
end

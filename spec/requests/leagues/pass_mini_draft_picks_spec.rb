require 'rails_helper'
RSpec.describe "PassMiniDraftPicks", type: :request do
  describe "create" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, mini_draft: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      expect_to_delay_run(
        MiniDraftPicks::Broadcast,
        with: {
          league: league,
          fpl_team_list: fpl_team_list,
          user: user,
          passed: true,
        },
      )

      post api_v1_league_pass_mini_draft_picks_path(
        league_id: league.id,
        fpl_team_list_id: fpl_team_list.id,
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      expected = MiniDraftPicks::Hash.run(league: league, fpl_team_list: fpl_team_list, user: user).result
      expected[:current_mini_draft_pick_user] = user
      expected[:success] = 'You have successfully passed'

      expect(response.body).to eq(expected.to_json)
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

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      expect_to_not_run_delayed(MiniDraftPicks::Broadcast)

      params = {
        league_id: league.id,
        fpl_team_list_id: fpl_team_list.id,
      }

      post api_v1_league_pass_mini_draft_picks_path(params), headers: auth_headers

      expect(response).to have_http_status(422)

      outcome = MiniDraftPicks::Pass.run(params.merge(user: user))
      expect(outcome).not_to be_valid

      expected = outcome.mini_draft_pick_hash
      expected[:current_mini_draft_pick_user] = user
      expected[:error] = outcome.errors

      expect(response.body).to eq(expected.to_json)
    end
  end
end

require 'rails_helper'

RSpec.describe "DraftPicks", type: :request do
  describe "index" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      FactoryBot.create(:round, is_current: true)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team)

      expected = MiniDraftPicks::Hash.run(
        league: league,
        fpl_team_list: fpl_team_list,
        user: user,
      ).result.to_json

      get api_v1_league_mini_draft_picks_path(
        league_id: league.id,
        fpl_team_list_id: fpl_team_list.id,
      ), headers: auth_headers

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to eq(JSON.parse(expected))
    end

    it "responds with 401 if not logged in" do
      league = FactoryBot.create(:league)
      get api_v1_league_mini_draft_picks_path(league_id: league.id)

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token
      league = FactoryBot.create(:league)
      get api_v1_league_mini_draft_picks_path(league_id: league.id + 1), headers: auth_headers

      expect(response).to have_http_status(404)
    end
  end

  describe "update" do
    it "is valid when drafting a player" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, mini_draft: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      player = FactoryBot.create(:player)

      fpl_team.players << list_position.player

      post api_v1_league_mini_draft_picks_path(
        league_id: league.id,
        list_position_id: list_position.id,
        fpl_team_list_id: fpl_team_list.id,
        in_player_id: player.id
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      expect(JSON.parse(response.body)['success']).to eq(
        "You have successfully traded out #{list_position.player.decorate.name} for " \
          "#{player.decorate.name} in the mini draft.",
      )
    end
  end
end

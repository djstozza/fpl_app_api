require 'rails_helper'

RSpec.describe "Trades", type: :request do
  describe "create" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, mini_draft: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      out_player = list_position.player
      in_player = FactoryBot.create(:player)

      fpl_team.players << out_player

      post api_v1_trades_path(list_position_id: list_position.id, in_player_id: in_player.id), headers: auth_headers

      expected = FplTeamLists::Hash.run(
        fpl_team_list: fpl_team_list,
        user: user,
        show_list_positions: true,
        show_waiver_picks: true,
        user_owns_fpl_team: true,
      ).result

      expected[:success] = "Trade successful - Out: #{out_player.decorate.name} In: #{in_player.decorate.name}"
      expected[:unpicked_players] = league.decorate.unpicked_players

      expect(response).to have_http_status(200)
      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      player = FactoryBot.create(:player)

      fpl_team.players << list_position.player

      params = { list_position_id: list_position.id, player_id: player.id }

      post api_v1_trades_path(params), headers: auth_headers

      expect(response).to have_http_status(422)

      outcome = ::FplTeamLists::ProcessTrade.run(params.merge(user: user))

      expected = outcome.fpl_team_list_hash
      expected[:error] = outcome.errors

      expect(response.body).to eq(expected.to_json)
    end
  end
end

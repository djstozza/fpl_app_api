require 'rails_helper'

RSpec.describe "TradeablePlayers" do
  describe "index" do
    it "is valid - no inter_team_trade_group" do
      round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)
      league = FactoryBot.create(:league)

      fpl_team_1 = FactoryBot.create(:fpl_team, league: league)
      fpl_team_list_1 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_1, round: round)
      list_position_1 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list_1)

      fpl_team_1.players << list_position_1.player

      fpl_team_2 = FactoryBot.create(:fpl_team, league: league)
      fpl_team_list_2 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_2, round: round)
      list_position_2 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list_2)
      fpl_team_2.players << list_position_2.player

      get api_v1_fpl_team_list_tradeable_players_path(fpl_team_list_id: fpl_team_list_1.id)

      expect(response).to have_http_status(200)

      fpl_team_list_hash = ::FplTeamLists::Hash.new(fpl_team_list: fpl_team_list_1)

      expected = {
        out_players: fpl_team_list_hash.tradeable_players,
        in_players: fpl_team_list_hash.all_in_players_tradeable,
      }

      expect(response.body).to eq(expected.to_json)
    end

    it "is valid - inter_team_trade_group" do
      round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)
      league = FactoryBot.create(:league)

      fpl_team_1 = FactoryBot.create(:fpl_team, league: league)
      fpl_team_list_1 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_1, round: round)
      list_position_1 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list_1)

      fpl_team_1.players << list_position_1.player

      fpl_team_2 = FactoryBot.create(:fpl_team, league: league)
      fpl_team_list_2 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_2, round: round)
      list_position_2 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list_2)
      fpl_team_2.players << list_position_2.player

      inter_team_trade_group = FactoryBot.create(
        :inter_team_trade_group,
        out_fpl_team_list: fpl_team_list_1,
        in_fpl_team_list: fpl_team_list_2,
        league: league,
        round: round,
      )

      FactoryBot.create(
        :inter_team_trade,
        inter_team_trade_group: inter_team_trade_group,
        out_player: list_position_1.player,
        in_player: list_position_2.player,
      )

      list_position_3 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list_2)
      fpl_team_2.players << list_position_3.player

      params = {
        fpl_team_list_id: fpl_team_list_1.id,
        inter_team_trade_group_id: inter_team_trade_group.id,
      }

      get api_v1_fpl_team_list_tradeable_players_path(params)

      expect(response).to have_http_status(200)

      out_fpl_team_list_hash = ::FplTeamLists::Hash.new(params)
      in_fpl_team_list_hash = ::FplTeamLists::Hash.new(fpl_team_list: fpl_team_list_2)

      expected = {
        out_players: out_fpl_team_list_hash.tradeable_players(player_ids: inter_team_trade_group.out_player_ids),
        in_players: in_fpl_team_list_hash.tradeable_players(player_ids: inter_team_trade_group.in_player_ids),
      }

      expect(response.body).to eq(expected.to_json)
    end
  end
end

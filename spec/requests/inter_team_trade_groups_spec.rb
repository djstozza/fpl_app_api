require 'rails_helper'

RSpec.describe "InterTeamTradeGroups", type: :request do
  describe "create" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)

      league = FactoryBot.create(:league)
      out_fpl_team = FactoryBot.create(:fpl_team, league: league, user: user)
      out_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: out_fpl_team, round: round)

      out_list_position = FactoryBot.create(:list_position, fpl_team_list: out_fpl_team_list)
      out_fpl_team.players << out_list_position.player

      in_fpl_team = FactoryBot.create(:fpl_team, league: league)
      in_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: in_fpl_team)

      in_list_position = FactoryBot.create(:list_position, fpl_team_list: in_fpl_team_list)
      in_fpl_team.players << in_list_position.player

      post api_v1_inter_team_trade_groups_path(
        fpl_team_id: out_fpl_team.id,
        fpl_team_list_id: out_fpl_team_list.id,
        out_list_position_id: out_list_position.id,
        in_list_position_id: in_list_position.id,
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      expected = FplTeamLists::Hash.run(
        fpl_team_list: out_fpl_team_list,
        user: user,
        show_trade_groups: true,
        user_owns_fpl_team: true,
      ).result

      expected[:success] =
        "Successfully created a pending trade - Fpl Team: #{in_fpl_team.name}, " \
          "Out: #{out_list_position.player.decorate.name} In: #{in_list_position.player.decorate.name}."

      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: false)

      league = FactoryBot.create(:league)
      out_fpl_team = FactoryBot.create(:fpl_team, league: league, user: user)
      out_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: out_fpl_team, round: round)

      out_list_position = FactoryBot.create(:list_position, fpl_team_list: out_fpl_team_list)
      out_fpl_team.players << out_list_position.player

      in_fpl_team = FactoryBot.create(:fpl_team, league: league)
      in_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: in_fpl_team)

      in_list_position = FactoryBot.create(:list_position, fpl_team_list: in_fpl_team_list)
      in_fpl_team.players << in_list_position.player

      params = {
        fpl_team_id: out_fpl_team.id,
        fpl_team_list_id: out_fpl_team_list.id,
        out_list_position_id: out_list_position.id,
        in_list_position_id: in_list_position.id,
      }

      post api_v1_inter_team_trade_groups_path(params), headers: auth_headers

      outcome = InterTeamTradeGroups::Create.run(params.merge(user: user))

      expected = outcome.fpl_team_list_hash.merge(error: outcome.errors)

      expect(response).to have_http_status(422)
      expect(response.body).to eq(expected.to_json)
    end
  end

  describe "update" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)
      league = FactoryBot.create(:league)

      out_fpl_team = FactoryBot.create(:fpl_team, league: league, user: user)
      out_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: out_fpl_team, round: round)
      out_list_position = FactoryBot.create(:list_position, fpl_team_list: out_fpl_team_list)

      in_fpl_team = FactoryBot.create(:fpl_team, league: league)
      in_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: in_fpl_team)
      in_list_position = FactoryBot.create(:list_position, fpl_team_list: in_fpl_team_list)

      out_fpl_team.players << out_list_position.player
      in_fpl_team.players << in_list_position.player

      inter_team_trade_group = FactoryBot.create(
        :inter_team_trade_group,
        out_fpl_team_list: out_fpl_team_list,
        in_fpl_team_list: in_fpl_team_list,
        league: league,
        round: round,
      )

      FactoryBot.create(
        :inter_team_trade,
        inter_team_trade_group: inter_team_trade_group,
        out_player: out_list_position.player,
        in_player: in_list_position.player,
      )

      put api_v1_inter_team_trade_group_path(
        fpl_team_list_id: out_fpl_team_list.id,
        inter_team_trade_group_id: inter_team_trade_group.id,
        trade_action: 'submit',
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      expected = FplTeamLists::Hash.run(
        fpl_team_list: out_fpl_team_list,
        user: user,
        show_trade_groups: true,
        user_owns_fpl_team: true,
      ).result

      expected[:success] = 'This trade proposal has successfully submitted'
      expect(response.body).to eq(expected.to_json)
    end


    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: false)
      league = FactoryBot.create(:league)

      out_fpl_team = FactoryBot.create(:fpl_team, league: league, user: user)
      out_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: out_fpl_team, round: round)
      out_list_position = FactoryBot.create(:list_position, fpl_team_list: out_fpl_team_list)

      in_fpl_team = FactoryBot.create(:fpl_team, league: league)
      in_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: in_fpl_team)
      in_list_position = FactoryBot.create(:list_position, fpl_team_list: in_fpl_team_list)

      out_fpl_team.players << out_list_position.player
      in_fpl_team.players << in_list_position.player

      inter_team_trade_group = FactoryBot.create(
        :inter_team_trade_group,
        out_fpl_team_list: out_fpl_team_list,
        in_fpl_team_list: in_fpl_team_list,
        league: league,
        round: round,
      )

      FactoryBot.create(
        :inter_team_trade,
        inter_team_trade_group: inter_team_trade_group,
        out_player: out_list_position.player,
        in_player: in_list_position.player,
      )

      params = {
        fpl_team_list_id: out_fpl_team_list.id,
        inter_team_trade_group_id: inter_team_trade_group.id,
        trade_action: 'submit',
      }

      put api_v1_inter_team_trade_group_path(params), headers: auth_headers

      expect(response).to have_http_status(422)

      outcome = InterTeamTradeGroups::Submit.run(params.merge(user: user))

      expected = FplTeamLists::Hash.run(
        fpl_team_list: out_fpl_team_list,
        user: user,
        show_trade_groups: true,
        user_owns_fpl_team: true,
      ).result

      expected[:error] = outcome.errors
      expect(response.body).to eq(expected.to_json)
    end
  end
end

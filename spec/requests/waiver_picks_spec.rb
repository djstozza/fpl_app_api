require 'rails_helper'

RSpec.describe "WaiverPicks", type: :request do
  describe "create" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      first_round = FactoryBot.build_stubbed(:round)
      expect(Round).to receive(:first).and_return(first_round).at_least(1)

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      player = FactoryBot.create(:player)

      fpl_team.players << list_position.player

      post api_v1_fpl_team_list_waiver_picks_path(
        fpl_team_list_id: fpl_team_list.id,
        list_position_id: list_position.id,
        in_player_id: player,
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      waiver_pick = WaiverPick.first

      success = "Waiver pick was successfully created. Pick number: #{waiver_pick.pick_number}, " \
                  "In: #{waiver_pick.in_player.decorate.name}, Out: #{waiver_pick.out_player.decorate.name}"

      expected = FplTeamLists::Hash.run(
        fpl_team_list: fpl_team_list,
        user: user,
        show_waiver_picks: true,
        user_owns_fpl_team: true,
      ).result

      expected[:success] = success

      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 401 if not logged in" do
      user = FactoryBot.create(:user)

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)

      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      player = FactoryBot.create(:player)

      fpl_team.players << list_position.player

      post api_v1_fpl_team_list_waiver_picks_path(
        fpl_team_list_id: fpl_team_list.id,
        list_position_id: list_position.id,
        in_player_id: player,
      )

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)

      league = FactoryBot.create(:league)

      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      player = FactoryBot.create(:player)

      fpl_team.players << list_position.player

      post api_v1_fpl_team_list_waiver_picks_path(
        fpl_team_list_id: fpl_team_list.id + 1,
        list_position_id: list_position.id,
        in_player_id: player,
      ), headers: auth_headers

      expect(response).to have_http_status(404)
    end

    it " responds with a 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round)

      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      player = FactoryBot.create(:player)

      fpl_team.players << list_position.player

      params = {
        fpl_team_list_id: fpl_team_list.id,
        list_position_id: list_position.id,
        in_player_id: player.id,
      }

      post api_v1_fpl_team_list_waiver_picks_path(params), headers: auth_headers

      expect(response).to have_http_status(422)

      outcome = WaiverPicks::Create.run(params.merge(user: user))
      expect(outcome).not_to be_valid

      expected = outcome.fpl_team_list_hash
      expected[:error] = outcome.errors

      expect(response.body).to eq(expected.to_json)
    end
  end

  describe "update" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      first_round = FactoryBot.build_stubbed(:round)
      expect(Round).to receive(:first).and_return(first_round).at_least(1)

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position_1 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      list_position_2 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position_1.player
      fpl_team.players << list_position_2.player

      waiver_pick_1 = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position_1.player,
      )

      waiver_pick_2 = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position_2.player,
      )

      put api_v1_fpl_team_list_waiver_pick_path(
        fpl_team_list_id: fpl_team_list.id,
        waiver_pick_id: waiver_pick_1.id,
        pick_number: waiver_pick_2.pick_number,
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      success = "Waiver picks successfully re-ordered. Pick number: #{waiver_pick_2.pick_number}, In: " \
                  "#{waiver_pick_1.in_player.decorate.name}, Out: #{waiver_pick_1.out_player.decorate.name}"

      expected = FplTeamLists::Hash.run(
        fpl_team_list: fpl_team_list,
        user: user,
        show_waiver_picks: true,
        user_owns_fpl_team: true,
      ).result

      expected[:success] = success

      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 401 if not logged in" do
      user = FactoryBot.create(:user)

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position_1 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      list_position_2 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position_1.player
      fpl_team.players << list_position_2.player

      waiver_pick_1 = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position_1.player,
      )

      waiver_pick_2 = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position_2.player,
      )

      put api_v1_fpl_team_list_waiver_pick_path(
        fpl_team_list_id: fpl_team_list.id,
        waiver_pick_id: waiver_pick_1.id,
        pick_number: waiver_pick_2.pick_number,
      )

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position_1 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)
      list_position_2 = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position_1.player
      fpl_team.players << list_position_2.player

      waiver_pick_1 = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position_1.player,
      )

      waiver_pick_2 = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position_2.player,
      )

      put api_v1_fpl_team_list_waiver_pick_path(
        fpl_team_list_id: fpl_team_list.id + 1,
        waiver_pick_id: waiver_pick_1.id + 1,
        pick_number: waiver_pick_2.pick_number,
      ), headers: auth_headers

      expect(response).to have_http_status(404)
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position.player

      waiver_pick = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position.player,
      )

      params = {
        fpl_team_list_id: fpl_team_list.id,
        waiver_pick_id: waiver_pick.id,
        pick_number: waiver_pick.pick_number + 1,
      }

      put api_v1_fpl_team_list_waiver_pick_path(params), headers: auth_headers

      expect(response).to have_http_status(422)

      outcome = WaiverPicks::UpdateOrder.run(params.merge(user: user))
      expect(outcome).not_to be_valid

      expected = outcome.fpl_team_list_hash
      expected[:error] = outcome.errors

      expect(response.body).to eq(expected.to_json)
    end
  end

  describe "delete" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      first_round = FactoryBot.build_stubbed(:round)
      expect(Round).to receive(:first).and_return(first_round).at_least(1)

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position.player

      waiver_pick = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position.player,
      )

      delete api_v1_fpl_team_list_waiver_pick_path(
        fpl_team_list_id: fpl_team_list.id,
        waiver_pick_id: waiver_pick.id,
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      success = "Waiver pick successfully deleted. Pick number: #{waiver_pick.pick_number}, In: " \
                  "#{waiver_pick.in_player.decorate.name}, Out: #{waiver_pick.out_player.decorate.name}"

      expected = FplTeamLists::Hash.run(
        fpl_team_list: fpl_team_list,
        user: user,
        show_waiver_picks: true,
        user_owns_fpl_team: true,
      ).result

      expected[:success] = success

      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 401 if not logged in" do
      user = FactoryBot.create(:user)

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position.player

      waiver_pick = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position.player,
      )

      put api_v1_fpl_team_list_waiver_pick_path(
        fpl_team_list_id: fpl_team_list.id,
        waiver_pick_id: waiver_pick.id,
      )

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, deadline_time: 2.days.from_now)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position.player

      waiver_pick = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position.player,
      )

      delete api_v1_fpl_team_list_waiver_pick_path(
        fpl_team_list_id: fpl_team_list.id + 1,
        waiver_pick_id: waiver_pick.id + 1,
      ), headers: auth_headers

      expect(response).to have_http_status(404)
    end

    it "responds to 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position = FactoryBot.create(:list_position, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position.player

      waiver_pick = FactoryBot.create(
        :waiver_pick,
        fpl_team_list: fpl_team_list,
        round: round,
        league: league,
        out_player: list_position.player,
      )

      params = {
        fpl_team_list_id: fpl_team_list.id,
        waiver_pick_id: waiver_pick.id,
      }

      delete api_v1_fpl_team_list_waiver_pick_path(params), headers: auth_headers

      expect(response).to have_http_status(422)

      outcome = WaiverPicks::Delete.run(params.merge(user: user))
      expect(outcome).not_to be_valid

      expected = outcome.fpl_team_list_hash
      expected[:error] = outcome.errors

      expect(response.body).to eq(expected.to_json)
    end
  end
end

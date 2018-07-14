require 'rails_helper'

RSpec.describe "ListPositions", type: :request do
  describe "show" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      fpl_team = FactoryBot.create(:fpl_team, user: user)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team)
      list_position = FactoryBot.create(:list_position, :starting, :gkp, fpl_team_list: fpl_team_list)

      FactoryBot.create(:list_position, :sgkp, fpl_team_list: fpl_team_list)

      get api_v1_list_position_path(list_position_id: list_position.id), headers: auth_headers

      expect(response).to have_http_status(200)
      expect(response.body).to eq({ substitute_options: list_position.decorate.substitute_options }.to_json)
    end
  end

  describe "update" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)

      fpl_team = FactoryBot.create(:fpl_team, user: user)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

      list_position_1 = FactoryBot.create(:list_position, :starting, :gkp, fpl_team_list: fpl_team_list)
      list_position_2 = FactoryBot.create(:list_position, :sgkp, fpl_team_list: fpl_team_list)

      fpl_team.players << list_position_1.player
      fpl_team.players << list_position_2.player

      put api_v1_list_position_path(
        list_position_id: list_position_1.id,
        substitute_list_position_id: list_position_2.id,
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      expected = FplTeamLists::Hash.run(
        fpl_team_list: fpl_team_list,
        user: user,
        show_list_positions: true,
        show_waiver_picks: true,
        user_owns_fpl_team: true,
      ).result

      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      fpl_team = FactoryBot.create(:fpl_team, user: user)
      fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team)

      list_position_1 = FactoryBot.create(:list_position, :starting, :gkp, fpl_team_list: fpl_team_list)
      list_position_2 = FactoryBot.create(:list_position, :starting, :fwd, fpl_team_list: fpl_team_list)

      params = {
        list_position_id: list_position_1.id,
        substitute_list_position_id: list_position_2.id,
      }

      put api_v1_list_position_path(params), headers: auth_headers

      outcome = ::FplTeamLists::ProcessSubstitution.run(params.merge(user: user))

      expected = FplTeamLists::Hash.run(
        fpl_team_list: fpl_team_list,
        user: user,
        show_list_positions: true,
        show_waiver_picks: true,
        user_owns_fpl_team: true,
      ).result
      expected[:error] = outcome.errors

      expect(response).to have_http_status(422)
      expect(response.body).to eq(expected.to_json)
    end
  end
end

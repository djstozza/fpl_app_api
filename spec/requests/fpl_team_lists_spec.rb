require 'rails_helper'

RSpec.describe "FplTeamLists", type: :request do
  describe "GET /api/v1/fpl_team_list" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token
      fpl_team_list = FactoryBot.create(:fpl_team_list)
      get api_v1_fpl_team_list_path(id: fpl_team_list.id), headers: auth_headers

      expect(response).to have_http_status(200)

      fpl_team_list_hash = ::FplTeamLists::Hash.run(fpl_team_list: fpl_team_list, user: user).result
      expect(response.body).to eq(fpl_team_list_hash.to_json)
    end

    it "responds with 401 if not logged in" do
      fpl_team_list = FactoryBot.create(:fpl_team_list)
      get api_v1_fpl_team_list_path(id: fpl_team_list.id)

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token
      fpl_team_list = FactoryBot.create(:fpl_team_list)
      get api_v1_fpl_team_list_path(id: (fpl_team_list.id + 1)), headers: auth_headers

      expect(response).to have_http_status(404)
    end
  end
end

require 'rails_helper'

RSpec.describe "FplTeamLists", type: :request do
  describe "GET /fpl_team_lists" do
    it "works! (now write some real specs)" do
      get fpl_team_lists_path
      expect(response).to have_http_status(200)
    end
  end
end

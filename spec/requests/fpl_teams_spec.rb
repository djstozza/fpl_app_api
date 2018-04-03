require 'rails_helper'

RSpec.describe "FplTeams", type: :request do
  describe "GET /fpl_teams" do
    it "works! (now write some real specs)" do
      get fpl_teams_path
      expect(response).to have_http_status(200)
    end
  end
end

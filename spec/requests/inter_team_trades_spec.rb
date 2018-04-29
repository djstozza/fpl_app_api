require 'rails_helper'

RSpec.describe "InterTeamTrades", type: :request do
  describe "GET /inter_team_trades" do
    it "works! (now write some real specs)" do
      get inter_team_trades_path
      expect(response).to have_http_status(200)
    end
  end
end

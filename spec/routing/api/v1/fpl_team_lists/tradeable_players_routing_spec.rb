require "rails_helper"

RSpec.describe Api::V1::FplTeamLists::TradeablePlayersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => base_route).to route_to({
        controller: "api/v1/fpl_team_lists/tradeable_players",
        action: "index",
        fpl_team_list_id: "1",
      })
    end

    it "does not route to #create" do
      expect(:post => base_route).not_to be_routable
    end

    it "does not route to #show" do
      expect(:get => "#{base_route}1").not_to be_routable
    end

    it "does not route to #edit" do
      expect(:get => "#{base_route}1/edit").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(:put => "#{base_route}1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(:patch => "#{base_route}1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "#{base_route}1").not_to be_routable
    end
  end

  private

  def base_route
    "/api/v1/fpl_team_lists/1/tradeable_players/"
  end
end

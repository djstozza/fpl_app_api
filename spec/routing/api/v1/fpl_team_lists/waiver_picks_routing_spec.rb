require "rails_helper"

RSpec.describe Api::V1::FplTeamLists::WaiverPicksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => base_route).not_to be_routable
    end

    it "does not route to #show" do
      expect(:get => "#{base_route}1").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => base_route).to route_to({
        controller: "api/v1/fpl_team_lists/waiver_picks",
        action: "create",
        fpl_team_list_id: "1",
      })
    end

    it "does not route to #edit" do
      expect(:get => "#{base_route}1/edit").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "#{base_route}1").to  route_to({
        controller: "api/v1/fpl_team_lists/waiver_picks",
        action: "update",
        fpl_team_list_id: "1",
        waiver_pick_id: "1",
      })
    end

    it "routes to #update via PATCH" do
      expect(:patch => "#{base_route}1").to  route_to({
        controller: "api/v1/fpl_team_lists/waiver_picks",
        action: "update",
        fpl_team_list_id: "1",
        waiver_pick_id: "1",
      })
    end

    it "routes to #destroy" do
      expect(:delete => "#{base_route}1").to  route_to({
        controller: "api/v1/fpl_team_lists/waiver_picks",
        action: "destroy",
        fpl_team_list_id: "1",
        waiver_pick_id: "1",
      })
    end
  end

  private

  def base_route
    "/api/v1/fpl_team_lists/1/waiver_picks/"
  end
end

require "rails_helper"

RSpec.describe Api::V1::Leagues::MiniDraftPicksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => base_route).to route_to({
        controller: "api/v1/leagues/mini_draft_picks",
        action: "index",
        league_id: "1",
      })
    end

    it "does not route to #show" do
      expect(:get => "#{base_route}1").not_to be_routable
    end


    it "routes to #create" do
      expect(:post => base_route).to route_to({
        controller: "api/v1/leagues/mini_draft_picks",
        action: "create",
        league_id: "1",
      })
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

    it "does not route to #destroy" do
      expect(:delete => "#{base_route}1").not_to be_routable
    end

  end

  private

  def base_route
    "/api/v1/leagues/1/mini_draft_picks"
  end
end

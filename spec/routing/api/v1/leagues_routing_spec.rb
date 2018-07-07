require "rails_helper"

RSpec.describe Api::V1::LeaguesController, type: :routing do
  describe "routing" do
    it "does not route to #index" do
      expect(:get => base_route).not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "#{base_route}1").to route_to({
        controller: "api/v1/leagues",
        action: "show",
        id: "1",
      })
    end

    it "does not route to #create" do
      expect(:post => base_route).to route_to({
        controller: "api/v1/leagues",
        action: "create",
      })
    end

    it "routes to #edit" do
      expect(:get => "#{base_route}1/edit").to route_to({
        controller: "api/v1/leagues",
        action: "edit",
        id: "1",
      })
    end

    it "routes to #update via PUT" do
      expect(:put => "#{base_route}1").to route_to({
        controller: "api/v1/leagues",
        action: "update",
        id: "1",
      })
    end

    it "routes to #update via PATCH" do
      expect(:patch => "#{base_route}1").to route_to({
        controller: "api/v1/leagues",
        action: "update",
        id: "1",
      })
    end

    it "routes to #destroy" do
      expect(:delete => "#{base_route}1").not_to be_routable
    end
  end

  private

  def base_route
    "/api/v1/leagues/"
  end
end

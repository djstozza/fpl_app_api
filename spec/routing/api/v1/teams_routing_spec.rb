require "rails_helper"

RSpec.describe Api::V1::TeamsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => base_route).to route_to({
        controller: "api/v1/teams",
        action: "index",
      })
    end

    it "routes to #show" do
      expect(:get => "#{base_route}1").to route_to({
        controller: "api/v1/teams",
        action: "show",
        id: "1",
      })
    end

    it "does not route to #create" do
      expect(:post => base_route).not_to be_routable
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
    "/api/v1/teams/"
  end
end

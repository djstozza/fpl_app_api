require "rails_helper"

RSpec.describe Api::V1::Leagues::CreateDraftController, type: :routing do
  describe "routing" do
    it "does not route to #index" do
      expect(:get => base_route).not_to be_routable
    end

    it "does not route to #show" do
      expect(:get => "#{base_route}1").not_to be_routable
    end

    it "does not route to #create" do
      expect(:post => base_route).to route_to({
        controller: "api/v1/leagues/create_draft",
        action: "create",
        league_id: "1",
      })
    end

    it "does not route to #edit" do
      expect(:get => "#{base_route}1/edit").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "#{base_route}1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "#{base_route}1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "#{base_route}1").not_to be_routable
    end
  end

  private

  def base_route
    "/api/v1/leagues/1/create_draft/"
  end
end

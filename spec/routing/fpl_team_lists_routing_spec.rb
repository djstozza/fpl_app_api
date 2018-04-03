require "rails_helper"

RSpec.describe FplTeamListsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/fpl_team_lists").to route_to("fpl_team_lists#index")
    end


    it "routes to #show" do
      expect(:get => "/fpl_team_lists/1").to route_to("fpl_team_lists#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/fpl_team_lists").to route_to("fpl_team_lists#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/fpl_team_lists/1").to route_to("fpl_team_lists#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/fpl_team_lists/1").to route_to("fpl_team_lists#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/fpl_team_lists/1").to route_to("fpl_team_lists#destroy", :id => "1")
    end

  end
end

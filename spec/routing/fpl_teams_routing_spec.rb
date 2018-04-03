require "rails_helper"

RSpec.describe FplTeamsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/fpl_teams").to route_to("fpl_teams#index")
    end


    it "routes to #show" do
      expect(:get => "/fpl_teams/1").to route_to("fpl_teams#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/fpl_teams").to route_to("fpl_teams#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/fpl_teams/1").to route_to("fpl_teams#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/fpl_teams/1").to route_to("fpl_teams#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/fpl_teams/1").to route_to("fpl_teams#destroy", :id => "1")
    end

  end
end

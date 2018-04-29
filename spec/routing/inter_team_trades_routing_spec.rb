require "rails_helper"

RSpec.describe InterTeamTradesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/inter_team_trades").to route_to("inter_team_trades#index")
    end


    it "routes to #show" do
      expect(:get => "/inter_team_trades/1").to route_to("inter_team_trades#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/inter_team_trades").to route_to("inter_team_trades#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/inter_team_trades/1").to route_to("inter_team_trades#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/inter_team_trades/1").to route_to("inter_team_trades#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/inter_team_trades/1").to route_to("inter_team_trades#destroy", :id => "1")
    end

  end
end

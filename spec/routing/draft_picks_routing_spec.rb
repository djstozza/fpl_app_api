require "rails_helper"

RSpec.describe DraftPicksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/draft_picks").to route_to("draft_picks#index")
    end


    it "routes to #show" do
      expect(:get => "/draft_picks/1").to route_to("draft_picks#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/draft_picks").to route_to("draft_picks#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/draft_picks/1").to route_to("draft_picks#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/draft_picks/1").to route_to("draft_picks#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/draft_picks/1").to route_to("draft_picks#destroy", :id => "1")
    end

  end
end

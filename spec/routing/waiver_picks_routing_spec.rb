require "rails_helper"

RSpec.describe WaiverPicksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/waiver_picks").to route_to("waiver_picks#index")
    end


    it "routes to #show" do
      expect(:get => "/waiver_picks/1").to route_to("waiver_picks#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/waiver_picks").to route_to("waiver_picks#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/waiver_picks/1").to route_to("waiver_picks#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/waiver_picks/1").to route_to("waiver_picks#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/waiver_picks/1").to route_to("waiver_picks#destroy", :id => "1")
    end

  end
end

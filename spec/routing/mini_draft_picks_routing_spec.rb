require "rails_helper"

RSpec.describe MiniDraftPicksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/mini_draft_picks").to route_to("mini_draft_picks#index")
    end


    it "routes to #show" do
      expect(:get => "/mini_draft_picks/1").to route_to("mini_draft_picks#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/mini_draft_picks").to route_to("mini_draft_picks#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/mini_draft_picks/1").to route_to("mini_draft_picks#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/mini_draft_picks/1").to route_to("mini_draft_picks#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/mini_draft_picks/1").to route_to("mini_draft_picks#destroy", :id => "1")
    end

  end
end

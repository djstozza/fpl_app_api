require "rails_helper"

RSpec.describe FixturesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/fixtures").to route_to("fixtures#index")
    end


    it "routes to #show" do
      expect(:get => "/fixtures/1").to route_to("fixtures#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/fixtures").to route_to("fixtures#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/fixtures/1").to route_to("fixtures#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/fixtures/1").to route_to("fixtures#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/fixtures/1").to route_to("fixtures#destroy", :id => "1")
    end

  end
end

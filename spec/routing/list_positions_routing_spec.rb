require "rails_helper"

RSpec.describe ListPositionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/list_positions").to route_to("list_positions#index")
    end


    it "routes to #show" do
      expect(:get => "/list_positions/1").to route_to("list_positions#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/list_positions").to route_to("list_positions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/list_positions/1").to route_to("list_positions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/list_positions/1").to route_to("list_positions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/list_positions/1").to route_to("list_positions#destroy", :id => "1")
    end

  end
end

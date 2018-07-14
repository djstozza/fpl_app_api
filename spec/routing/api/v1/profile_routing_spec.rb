require "rails_helper"

RSpec.describe Api::V1::ProfileController, type: :routing do
  describe "routing" do
    it "routes to index" do
      expect(get: api_v1_profile_index_path).to be_routable
    end
  end
end

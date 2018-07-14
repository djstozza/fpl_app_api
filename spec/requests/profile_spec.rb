require 'rails_helper'

RSpec.describe "Profile" do
  describe "index" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      get api_v1_profile_index_path, headers: auth_headers

      expect(response).to have_http_status(200)
      expect(response.body).to eq({ current_user: user}.to_json)
    end
  end
end

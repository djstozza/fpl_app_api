require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "sign_up" do
    it "is valid" do
      params = {
        username: 'foo',
        email: 'foo@bar.com',
        password: '12345678',
      }

      post api_v1_user_registration_path(registration: params)

      expect(response).to have_http_status(200)
    end
  end

  describe "update account" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      params = {
        user: {
          username: 'foo',
          email: 'foo@bar.com',
        },
        registration: {
          user: {
            email: user.email,
            username: user.username,
          }
        }
      }

      put api_v1_user_registration_path(params), headers: auth_headers
      expect(response).to have_http_status(200)
    end
  end
end

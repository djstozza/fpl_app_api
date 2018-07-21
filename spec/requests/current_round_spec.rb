require 'rails_helper'

RSpec.describe "CurrentRound", type: :request do
  describe "index" do
    it "is valid" do
      round = FactoryBot.create(:round, is_current: true)
      get api_v1_current_round_index_path

      expected = {
        current_round: round,
        current_round_status: round.status,
        current_round_deadline_time: round.current_deadline_time + 1.second,
      }

      expect(response).to have_http_status(200)
      expect(response.body).to eq(expected.to_json)
    end
  end
end

require 'rails_helper'

RSpec.describe "DraftPicks", type: :request do
  describe "GET /draft_picks" do
    it "works! (now write some real specs)" do
      get draft_picks_path
      expect(response).to have_http_status(200)
    end
  end
end

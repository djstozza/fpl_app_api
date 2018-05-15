require 'rails_helper'

RSpec.describe "MiniDraftPicks", type: :request do
  describe "GET /mini_draft_picks" do
    it "works! (now write some real specs)" do
      get mini_draft_picks_path
      expect(response).to have_http_status(200)
    end
  end
end

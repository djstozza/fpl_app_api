require 'rails_helper'

RSpec.describe "DraftPicks", type: :request do
  describe "index" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      FactoryBot.create(:round)
      league = FactoryBot.create(:league)

      get api_v1_league_draft_picks_path(league_id: league.id), headers: auth_headers

      expect(response).to have_http_status(200)
    end

    it "responds with 401 if not logged in" do
      league = FactoryBot.create(:league)
      get api_v1_league_draft_picks_path(league_id: league.id)

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token
      league = FactoryBot.create(:league)
      get api_v1_league_draft_picks_path(league_id: league.id + 1), headers: auth_headers

      expect(response).to have_http_status(404)
    end
  end

  describe "update" do
    it "is valid when drafting a player" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)
      league = FactoryBot.create(:league, status: 'draft')
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      draft_pick = FactoryBot.create(:draft_pick, league: league, fpl_team: fpl_team)
      player = FactoryBot.create(:player)

      expect_to_run(
        Leagues::Activate,
        with: { league: league },
      )

      expect_to_delay_run(
        DraftPicks::Broadcast,
        with: {
          league: league,
          user: draft_pick.user,
          player: player,
          mini_draft: false,
        },
      )

      put api_v1_league_draft_pick_path(
        league_id: league.id,
        draft_pick_id: draft_pick.id,
        player_id: player.id
      ), headers: auth_headers

      response_hash = league.decorate.draft_response_hash.merge(
        current_user: user,
        success: "You have successfully drafted #{player.decorate.name}.",
      )

      expect(response).to have_http_status(200)
      expect(response.body).to include(response_hash.to_json)
    end

    it "is valid when making a mini draft pick" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)
      league = FactoryBot.create(:league, status: 'draft')
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      draft_pick = FactoryBot.create(:draft_pick, league: league, fpl_team: fpl_team)
      mini_draft = true

      expect_to_run(
        Leagues::Activate,
        with: { league: league },
      )

      expect_to_delay_run(
        DraftPicks::Broadcast,
        with: {
          league: league,
          user: draft_pick.user,
          player: nil,
          mini_draft: mini_draft,
        },
      )

      put api_v1_league_draft_pick_path(
        league_id: league.id,
        draft_pick_id: draft_pick.id,
        mini_draft: mini_draft
      ), headers: auth_headers

      response_hash = league.decorate.draft_response_hash.merge(
        current_user: user,
        success: "You have successfully selected your pick for the mini draft",
      )
      expect(response).to have_http_status(200)
      expect(response.body).to eq(response_hash.to_json)
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      FactoryBot.create(:round)
      league = FactoryBot.create(:league)
      fpl_team = FactoryBot.create(:fpl_team, user: user, league: league)
      draft_pick = FactoryBot.create(:draft_pick, league: league, fpl_team: fpl_team)
      player = FactoryBot.create(:player)

      expect_not_to_run(Leagues::Activate)

      expect_to_not_run_delayed(DraftPicks::Broadcast)

      params = {
        league_id: league.id,
        draft_pick_id: draft_pick.id,
        player_id: player.id,
      }

      put api_v1_league_draft_pick_path(params), headers: auth_headers

      outcome = ::DraftPicks::Update.run(params.merge(user: user))
      expect(outcome).not_to be_valid

      response_hash = league.decorate.draft_response_hash.merge(
        current_user: user,
        error: outcome.errors,
      )
      response_hash[:current_draft_pick_user] = user

      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)).to eq(JSON.parse(response_hash.to_json))
    end
  end
end

require 'rails_helper'

RSpec.describe "Leagues", type: :request do
  describe "show" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league)
      FactoryBot.create(:fpl_team, league: league)

      get api_v1_league_path(id: league.id), headers: auth_headers

      expect(response).to have_http_status(200)

      fpl_teams_arr = league.decorate.fpl_teams_arr

      expected = {
        league: league,
        fpl_teams: fpl_teams_arr,
        current_user: user,
        commissioner: league.commissioner,
      }

      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 401 if not logged in" do
      league = FactoryBot.create(:league)

      get api_v1_league_path(id: league.id)

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league)

      get api_v1_league_path(id: league.id + 1), headers: auth_headers

      expect(response).to have_http_status(404)
    end
  end

  describe "create" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league_name = 'foo'
      fpl_team_name = 'bar'
      code = 'abc123'

      post api_v1_leagues_path(
        league: {
          code: code,
          name: league_name,
          fpl_team_name: fpl_team_name
        },
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      league = League.first
      fpl_team = FplTeam.first

      expect(league.commissioner).to eq(user)
      expect(league.name).to eq(league_name)
      expect(fpl_team.name).to eq(fpl_team_name)
      expect(fpl_team.user).to eq(user)
      expect(fpl_team.league).to eq(league)

      fpl_teams_arr = league.decorate.fpl_teams_arr

      expected = {
        league: league,
        fpl_teams: fpl_teams_arr,
        commissioner: user,
        current_user: user,
      }
      expected[:success] = 'League successfully created.'

      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 401 if not logged in" do
      league_name = 'foo'
      fpl_team_name = 'bar'
      code = 'abc123'

      post api_v1_leagues_path(
        league: {
          code: code,
          name: league_name,
          fpl_team_name: fpl_team_name
        },
      )

      expect(response).to have_http_status(401)
    end

    it "responds with 422 if invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league)

      params = {
        code: 'abc123',
        name: league.name,
        fpl_team_name: 'bar',
      }

      post api_v1_leagues_path(league: params), headers: auth_headers

      expect(response).to have_http_status(422)

      form = ::Leagues::CreateLeagueForm.run(params.merge(user: user))
      expect(form).not_to be_valid

      expected = { error: form.errors }

      expect(response.body).to eq(expected.to_json)
    end
  end

  describe "edit" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league, commissioner: user)

      get edit_api_v1_league_path(id: league.id), headers: auth_headers

      expect(response).to have_http_status(200)

      expected = {
        league: league,
      }

      expect(response.body).to eq(expected.to_json)
    end

    it "responds with 401 if not logged in" do
      league = FactoryBot.create(:league)

      get edit_api_v1_league_path(id: league.id)

      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league = FactoryBot.create(:league)

      get edit_api_v1_league_path(id: league.id + 1), headers: auth_headers

      expect(response).to have_http_status(404)
    end
  end

  describe "update" do
    it "is valid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league_name = 'foo'
      code = 'abc123'
      league = FactoryBot.create(:league, commissioner: user)

      put api_v1_league_path(
        id: league.id,
        league: {
          code: code,
          name: league_name,
        },
      ), headers: auth_headers

      expect(response).to have_http_status(200)

      expected = { league: league.reload }
      expected[:success] = 'League successfully updated.'

      expect(JSON.parse(response.body)).to eq(JSON.parse(expected.to_json))
    end

    it "responds with 401 if not logged in" do
      league_name = 'foo'
      code = 'abc123'

      league = FactoryBot.create(:league)

      put api_v1_league_path(
        id: league.id,
        league: {
          code: code,
          name: league_name,
        },
      )
      expect(response).to have_http_status(401)
    end

    it "responds with 404 when not found" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      league_name = 'foo'
      code = 'abc123'

      league = FactoryBot.create(:league, commissioner: user)

      put api_v1_league_path(
        id: league.id + 1,
        league: {
          code: code,
          name: league_name,
        },
      ), headers: auth_headers

      expect(response).to have_http_status(404)
    end

    it "responds with 422 when invalid" do
      user = FactoryBot.create(:user)
      auth_headers = user.create_new_auth_token

      params = {
        code: 'abc123',
        name: 'foo',
      }

      league = FactoryBot.create(:league)

      put api_v1_league_path(
        id: league.id,
        league: params,
      ), headers: auth_headers

      expect(response).to have_http_status(422)

      form = ::Leagues::UpdateLeagueForm.run(params.merge(league: league, user: user))
      expected = { error: form.errors }

      expect(response.body).to eq(expected.to_json)
    end
  end
end

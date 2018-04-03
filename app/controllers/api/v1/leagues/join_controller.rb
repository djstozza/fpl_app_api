class Api::V1::Leagues::JoinController < ApplicationController
  before_action :authenticate_api_v1_user!

  # POST /join_leagues.json
  def create
    form = Leagues::JoinLeagueForm.run(join_league_params.merge(user: current_api_v1_user))

    if form.valid?
      league = form.result
      render json: {
        league: league,
        current_user: current_api_v1_user,
        commissioner: league.commissioner,
        fpl_teams: league.decorate.fpl_teams_arr,
        success: 'League successfully joined.',
      }
    else
      render json: { error: form.errors }, status: :unprocessable_entity
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def join_league_params
    params.fetch(:league, keys: [:code, :name, :fpl_team_name])
  end
end

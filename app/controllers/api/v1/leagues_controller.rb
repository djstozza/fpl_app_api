class  Api::V1::LeaguesController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_league, only: [:show, :edit, :update]

  def show
    render json: {
      league: @league,
      fpl_teams: @league.decorate.fpl_teams_arr,
      current_user: current_api_v1_user,
      commissioner: @league.commissioner,
    }
  end

  def create
    form = ::Leagues::CreateLeagueForm.run(league_params.merge(user: current_api_v1_user))

    if form.valid?
      league = form.result
      render json: {
        league: league,
        fpl_teams: league.decorate.fpl_teams_arr,
        commissioner: league.commissioner,
        current_user: current_api_v1_user,
        success: 'League successfully created.'
      }
    else
      render json: { error: form.errors }, status: :unprocessable_entity
    end
  end

  def edit
    render json: { league: @league }
  end

  def update
    form = ::Leagues::UpdateLeagueForm.run(league_params.merge(league: @league, user: current_api_v1_user))
    if form.valid?
      render json: { league: form.result, success: 'League successfully updated.' }
    else
      render json: { error: form.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @league.destroy
    respond_with(@league)
  end

  private
  def set_league
    @league = League.find(params[:id])
  end

  def league_params
    params.fetch(:league, keys: [:id, :code, :league_name, :fpl_team_name])
  end
end

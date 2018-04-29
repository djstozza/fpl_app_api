class Api::V1::FplTeamsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_fpl_team, only: [:show, :update, :destroy]

  def index
    fpl_teams = UserDecorator.new(current_api_v1_user).fpl_teams_arr
    render json: { fpl_teams: fpl_teams }
  end

  def show
    render json: {
      fpl_team: @fpl_team,
      current_user: current_api_v1_user,
      user_owns_fpl_team: @fpl_team.user == current_api_v1_user,
      league_status: @fpl_team.league.status
    }
  end

  def update
    outcome = FplTeams::UpdateForm.run(permitted_params.merge(fpl_team: @fpl_team, user: current_api_v1_user))
    fpl_team = outcome.result || outcome.fpl_team
    result_hash = { fpl_team: fpl_team, current_user: current_api_v1_user }
    if outcome.valid?
      result_hash[:success] = 'Fpl team successfully updated.'
      render json: result_hash
    else
      result_hash[:error] = outcome.errors
      render json: result_hash, status: :unprocessable_entity
    end
  end


  private

  def set_fpl_team
    @fpl_team = FplTeam.find(permitted_params[:id])
  end

  def permitted_params
    params.permit(:id, :name)
  end
end

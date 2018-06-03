class Api::V1::ListPositionsController < ApplicationController
  before_action :authenticate_api_v1_user!, only: :update

  def show
    list_position = ListPosition.find(permitted_params[:list_position_id])
    render json: { substitute_options: list_position.decorate.substitute_options }
  end

  def update
    outcome = ::FplTeamLists::ProcessSubstitution.run(permitted_params.merge(user: current_api_v1_user))
    fpl_team_list_hash = outcome.fpl_team_list_hash

    if outcome.valid?
      render json:  fpl_team_list_hash
    else
      render json: fpl_team_list_hash.merge!(error: outcome.errors), status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:list_position_id, :substitute_list_position_id)
  end
end

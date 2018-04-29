class Api::V1::TradesController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    outcome = ::FplTeamLists::ProcessTrade.run(permitted_params.merge(user: current_api_v1_user))
    fpl_team_list = outcome.fpl_team_list.decorate

    if outcome.valid?
      render json: {
        fpl_team_list: fpl_team_list,
        status: fpl_team_list.status,
        list_positions: fpl_team_list.list_position_arr,
        grouped_list_positions: fpl_team_list.grouped_list_position_arr,
        success: "Trade successful - Out: #{outcome.out_player.decorate.name} In: #{outcome.in_player.decorate.name}",
      }
    else
      render json: {
        fpl_team_list: fpl_team_list,
        status: fpl_team_list.status,
        list_positions: fpl_team_list.list_position_arr,
        grouped_list_positions: fpl_team_list.grouped_list_position_arr,
        error: outcome.errors
      }, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:list_position_id, :in_player_id)
  end
end

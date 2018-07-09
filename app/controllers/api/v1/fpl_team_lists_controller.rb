class Api::V1::FplTeamListsController < ApplicationController
  before_action :authenticate_api_v1_user!

  def show
    fpl_team_list = FplTeamList.find(permitted_params[:id])
    render json: ::FplTeamLists::Hash.run(
      permitted_params.merge(
        fpl_team_list: fpl_team_list,
        user: current_api_v1_user,
      )
    ).result
  end

  private

  def permitted_params
    params.permit(:id, :show_waiver_picks, :show_trade_groups, :show_list_positions)
  end
end

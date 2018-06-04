class Api::V1::FplTeamListsController < ApplicationController
  before_action :authenticate_api_v1_user!

  def show
    render json: ::FplTeamLists::Hash.run(permitted_params.merge(user: current_api_v1_user)).result
  end

  private

  def permitted_params
    params.permit(:fpl_team_list_id, :show_waiver_picks, :show_trade_groups, :show_list_positions)
  end
end

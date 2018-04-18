class Api::V1::FplTeamListController < ApplicationController
  # GET /api/v1/round/
  def index
    fpl_team_list =
      if params[:fpl_team_list]
        FplTeamList.find(params[:fpl_team_list_id])
      else
        FplTeamList.find_by(round: Round.current)
      end

    render json: { fpl_team_list: fpl_team_list.decorate.list_position_arr }
  end
end

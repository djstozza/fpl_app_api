class Api::V1::OutPlayersController < ApplicationController
  def index
    fpl_team_list = FplTeamList.find_by(fpl_team_id: params[:fpl_team_id], round: Round.current)&.decorate

    render json: {
      fpl_team_list: fpl_team_list,
      out_players: fpl_team_list&.tradeable_players,
      status: fpl_team_list&.status,
    }
  end
end

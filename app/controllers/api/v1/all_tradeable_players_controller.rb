class Api::V1::AllTradeablePlayersController < ApplicationController
  def index
    fpl_team_list = FplTeamList.find_by(fpl_team_id: params[:fpl_team_id], round: Round.current)&.decorate

    render json: {
      in_players: fpl_team_list&.all_in_players_tradeable,
      tradeable_fpl_teams: fpl_team_list&.tradeable_fpl_teams,
    }
  end
end

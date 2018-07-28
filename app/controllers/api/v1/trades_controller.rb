class Api::V1::TradesController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    outcome = ::FplTeamLists::ProcessTrade.run(permitted_params.merge(user: current_api_v1_user))

    fpl_team_list_hash = outcome.fpl_team_list_hash

    if outcome.valid?
      message = "Trade successful - Out: #{outcome.out_player.decorate.name} In: #{outcome.in_player.decorate.name}"
      render json:  fpl_team_list_hash.merge!(
        success: message,
        unpicked_players: outcome.fpl_team_list.league.decorate.unpicked_players,
      )
    else
      render json: fpl_team_list_hash.merge!(error: outcome.errors), status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:list_position_id, :in_player_id)
  end
end

class Api::V1::FplTeamLists::TradeablePlayersController < ApplicationController
  before_action :set_fpl_team_list
  before_action :set_inter_team_trade_group

  def index
    out_hash = FplTeamLists::Hash.new(permitted_params)

    in_players =
      if @inter_team_trade_group.present?
        in_hash = FplTeamLists::Hash.new(fpl_team_list: @inter_team_trade_group.in_fpl_team_list)
        in_hash.tradeable_players(player_ids: @inter_team_trade_group.in_player_ids)
      else
        out_hash.all_in_players_tradeable
      end

    render json: {
      out_players: out_hash.tradeable_players(player_ids: @inter_team_trade_group&.out_player_ids),
      in_players: in_players,
    }
  end


  private

  def set_fpl_team_list
    @fpl_team_list = FplTeamList.find(permitted_params[:fpl_team_list_id])
  end

  def set_inter_team_trade_group
    @inter_team_trade_group = InterTeamTradeGroup.find_by(id: permitted_params[:inter_team_trade_group_id])
  end

  def permitted_params
    params.permit(:fpl_team_list_id, :inter_team_trade_group_id)
  end
end

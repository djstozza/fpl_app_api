class Api::V1::Leagues::UnpickedPlayersController < ApplicationController
  def index
    league = League.find(params[:league_id])
    render json: { unpicked_players: league.decorate.unpicked_players }
  end
end

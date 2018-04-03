class Api::V1::PlayersController < ApplicationController
  before_action :set_player, only: [:show]

  # GET /api/v1/players
  def index
    render json: PlayerDecorator.new(Player.all).players_hash
  end

  # GET /api/v1/players/1
  def show
    render json: { player: @player, team: @player.team, position: @player.position }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(params[:id])
  end
end

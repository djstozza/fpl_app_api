class Api::V1::PlayersController < ApplicationController
  before_action :set_player, only: [:show]

  # GET /api/v1/players
  def index
    players = params[:team_id] ? Team.find(params[:team_id]).players : Player.all
    render json: PlayerSerializer.new(players).serializable_hash[:data]
  end

  # GET /api/v1/players/1
  def show
    render json: @player
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_player
    @player = Player.find(params[:id])
  end
end

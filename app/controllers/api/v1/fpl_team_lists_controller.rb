class Api::V1::FplTeamListsController < ApplicationController
  before_action :set_fpl_team_list, only: [:show, :update, :destroy]

  respond_to :json

  def index
    fpl_team_list = FplTeamList.find_by(fpl_team_id: permitted_params[:fpl_team_id], round: Round.current)&.decorate
    render json: {
      fpl_team_list: fpl_team_list&.list_position_arr || [],
      grouped_list_positions: fpl_team_list&.grouped_list_position_arr || [],
    }
  end

  def show
    respond_with(@fpl_team_list)
  end

  def create
    @fpl_team_list = FplTeamList.new(fpl_team_list_params)
    @fpl_team_list.save
    respond_with(@fpl_team_list)
  end

  def update
    @fpl_team_list.update(fpl_team_list_params)
    respond_with(@fpl_team_list)
  end

  def destroy
    @fpl_team_list.destroy
    respond_with(@fpl_team_list)
  end

  private
    def set_fpl_team
      @fpl_team_list = FplTeamList.find(permitted_params[:fpl_team_id])
    end

  def permitted_params
    params.permit(:fpl_team_id, :fpl_team_list_id)
  end
end

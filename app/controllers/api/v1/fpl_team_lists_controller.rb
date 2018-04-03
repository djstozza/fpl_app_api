class Api::V1::FplTeamListsController < ApplicationController
  before_action :set_fpl_team_list, only: [:show, :update, :destroy]

  respond_to :json

  def index
    @fpl_team_lists = FplTeamList.all
    respond_with(@fpl_team_lists)
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
    def set_fpl_team_list
      @fpl_team_list = FplTeamList.find(params[:id])
    end

    def fpl_team_list_params
      params[:fpl_team_list]
    end
end

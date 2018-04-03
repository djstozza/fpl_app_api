class Api::V1::FplTeamsController < ApplicationController
  before_action :set_fpl_team, only: [:show, :update, :destroy]

  respond_to :json

  def index
    @fpl_teams = FplTeam.all
    respond_with(@fpl_teams)
  end

  def show
    respond_with(@fpl_team)
  end

  def create
    @fpl_team = FplTeam.new(fpl_team_params)
    @fpl_team.save
    respond_with(@fpl_team)
  end

  def update
    @fpl_team.update(fpl_team_params)
    respond_with(@fpl_team)
  end

  def destroy
    @fpl_team.destroy
    respond_with(@fpl_team)
  end

  private
    def set_fpl_team
      @fpl_team = FplTeam.find(params[:id])
    end

    def fpl_team_params
      params[:fpl_team]
    end
end

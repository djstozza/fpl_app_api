class Api::V1::TeamsController < ApplicationController
  before_action :set_team, only: :show

  # GET /api/v1/teams
  def index
    respond_with TeamDecorator.new(nil).teams_hash
  end

  # GET /api/v1/teams/1
  def show
    respond_with(
      team: @team,
      fixtures: @team.decorate.fixture_hash
    )
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.find(params[:id])
  end
end

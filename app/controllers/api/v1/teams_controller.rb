class Api::V1::TeamsController < ApplicationController
  before_action :set_team, only: :show

  # GET /api/v1/teams
  def index
    respond_with TeamSerializer.new(Team.all.sort).serializable_hash[:data]
  end

  # GET /api/v1/teams/1
  def show
    options = {}
    options[:include] = [:home_fixtures, :away_fixtures]
    team_serializer = TeamSerializer.new(@team, options).serializable_hash

    respond_with(
      team: team_serializer[:data],
      fixtures: @team.decorate.fixture_hash
    )
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.find(params[:id])
  end
end

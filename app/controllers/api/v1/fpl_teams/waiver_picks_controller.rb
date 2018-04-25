class Api::V1::FplTeams::WaiverPicksController < ApplicationController
  def index
    fpl_team_list = FplTeamList.find_by(round: Round.current, fpl_team_id: params[:fpl_team_id])
    render json: { waiver_picks: fpl_team_list&.decorate&.waiver_picks_arr || [] }
  end
end

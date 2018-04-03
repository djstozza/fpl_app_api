class Api::V1::Leagues::FplTeamsController < ApplicationController
  before_action :authenticate_api_v1_user!

  # PUT /leagues/:id/fpl_teams/:fpl_team_id.json
  def update
    outcome = ::Leagues::UpdatePickNumberOrder.run(permitted_params.merge(user: current_api_v1_user))
    league = outcome.result || outcome.league

    response_hash = {
      league: league,
      current_user: current_api_v1_user,
      fpl_teams: league.decorate.fpl_teams_arr,
      commissioner: league.commissioner,
    }

    if outcome.valid?
      render json: response_hash
    else
      response_hash[:error] = outcome.errors
      render json: response_hash, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:league_id, :fpl_team_id, :draft_pick_number)
  end
end

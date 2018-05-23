class Api::V1::Leagues::PassMiniDraftPicksController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    outcome = MiniDraftPicks::Pass.run(permitted_params.merge(user: current_api_v1_user))

    league = outcome.league.decorate
    fpl_team_list = outcome.fpl_team_list.decorate

    response_hash = league.decorate.mini_draft_response_hash.merge(
      fpl_team_list: fpl_team_list,
      list_positions: fpl_team_list.tradeable_players,
      current_user: current_api_v1_user,
    )

    if outcome.valid?
      response_hash[:success] = 'You have successfully passed'
    else
      response_hash[:error] = outcome.errors
    end

    render json: response_hash
  end

  private

  def permitted_params
    params.permit(:league_id, :fpl_team_list_id)
  end
end

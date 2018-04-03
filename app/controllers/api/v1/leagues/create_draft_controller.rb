class Api::V1::Leagues::CreateDraftController < ApplicationController
  before_action :authenticate_api_v1_user!

  # POST /leagues/:league_id/create_draft.json
  def create
    outcome = ::Leagues::CreateDraft.run(permitted_params.merge(user: current_api_v1_user))
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
    params.permit(:league_id)
  end
end

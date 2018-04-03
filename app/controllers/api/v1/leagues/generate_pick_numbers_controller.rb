class Api::V1::Leagues::GeneratePickNumbersController < ApplicationController
  before_action :authenticate_api_v1_user!

  # PUT /leagues/:league_id/generate_pick_numbers.json
  def update
    outcome = ::Leagues::GeneratePickNumbers.run(permitted_params.merge(user: current_api_v1_user))
    league = outcome.result

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

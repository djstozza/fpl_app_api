class Api::V1::Leagues::DraftPicksController < ApplicationController
  before_action :authenticate_api_v1_user!

  def index
    league = League.find(permitted_params[:league_id]).decorate
    response_hash = league.decorate.draft_response_hash
    response_hash[:current_user] = current_api_v1_user

    render json: response_hash
  end

  def update
    outcome = ::DraftPicks::Update.run(permitted_params.merge(user: current_api_v1_user))
    league = outcome.result || outcome.league

    response_hash = league.decorate.draft_response_hash
    response_hash[:current_user] = current_api_v1_user

    if outcome.valid?
      success =
        if outcome.mini_draft
          "You have successfully selected your pick for the mini draft"
        else
          "You have successfully drafted #{outcome.player.decorate.name}."
        end
      response_hash[:success] = success
      render json: response_hash
    else
      response_hash[:error] = outcome.errors
      render json: response_hash, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:league_id, :draft_pick_id, :player_id, :mini_draft)
  end
end

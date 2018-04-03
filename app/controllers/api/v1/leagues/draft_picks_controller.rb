class Api::V1::Leagues::DraftPicksController < ApplicationController
  before_action :authenticate_api_v1_user!, only: :update

  def index
    league = League.find(permitted_params[:league_id])
    league_decorator = league.decorate

    render json: {
      draft_picks: league_decorator.all_draft_picks,
      current_draft_pick: league_decorator.current_draft_pick,
      fpl_team: league_decorator.current_draft_pick.fpl_team,
      unpicked_players: league_decorator.unpicked_players,
    }
  end

  def update
    outcome = ::DraftPicks::Update.run(permitted_params.merge(user: current_api_v1_user))
    league_decorator = outcome.result&.decorate || outcome.league.decorate

    response_hash = {
      draft_picks: league_decorator.all_draft_picks,
      current_draft_pick: league_decorator.current_draft_pick,
      fpl_team: league_decorator.current_draft_pick.fpl_team,
      unpicked_players: league_decorator.unpicked_players,
    }

    if outcome.valid?
      response_hash[:success] = "You have successfully drafted #{outcome.player.decorate.name}."
      render json: response_hash
    else
      response_hash[:error] = outcome.errors
      render json: response_hash
    end
  end

  private

  def permitted_params
    params.permit(:league_id, :draft_pick_id, :player_id)
  end
end

class Api::V1::Leagues::DraftPicksController < ApplicationController
  before_action :authenticate_api_v1_user!, only: :update

  def index
    league = League.find(permitted_params[:league_id])
    league_decorator = league.decorate
    current_draft_pick = league_decorator.current_draft_pick
    fpl_team = current_draft_pick.fpl_team
    fpl_team_decorator = fpl_team&.decorate

    render json: {
      draft_picks: league_decorator.all_draft_picks,
      current_draft_pick: current_draft_pick,
      fpl_team: fpl_team,
      mini_draft_pick: fpl_team.draft_picks.find_by(mini_draft: true).present?,
      unpicked_players: league_decorator.unpicked_players,
      mini_draft_picked: fpl_team_decorator&.mini_draft_picked?,
      all_players_picked: fpl_team_decorator&.all_players_picked?,
    }
  end

  def update
    outcome = ::DraftPicks::Update.run(permitted_params.merge(user: current_api_v1_user))
    league_decorator = outcome.result&.decorate || outcome.league.decorate
    current_draft_pick = league_decorator.current_draft_pick
    fpl_team = current_draft_pick.fpl_team
    fpl_team_decorator = fpl_team&.decorate

    response_hash = {
      draft_picks: league_decorator.all_draft_picks,
      current_draft_pick: current_draft_pick,
      fpl_team: fpl_team,
      unpicked_players: league_decorator.unpicked_players,
      mini_draft_picked: fpl_team_decorator&.mini_draft_picked?,
      all_players_picked: fpl_team_decorator&.all_players_picked?,
    }

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
      render json: response_hash
    end
  end

  private

  def permitted_params
    params.permit(:league_id, :draft_pick_id, :player_id, :mini_draft)
  end
end

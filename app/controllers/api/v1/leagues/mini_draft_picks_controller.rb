class Api::V1::Leagues::MiniDraftPicksController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_league
  before_action :set_fpl_team_list

  def index
    response_hash = @league.mini_draft_response_hash.merge(
      fpl_team_list: @fpl_team_list,
      out_players: @fpl_team_list.tradeable_players,
      current_user: current_api_v1_user,
    )

    render json: response_hash
  end

  def create
    outcome = MiniDraftPicks::Process.run(permitted_params.merge(user: current_api_v1_user))

    response_hash = @league.mini_draft_response_hash.merge(
      fpl_team_list: @fpl_team_list,
      out_players: @fpl_team_list.tradeable_players,
      current_user: current_api_v1_user,
    )

    if outcome.valid?
      response_hash[:success] =
        "You have successfully traded out #{outcome.result.out_player.decorate.name} for " \
          "#{outcome.result.in_player.decorate.name} in the mini draft."
      render json: response_hash
    else
      response_hash[:error] =  outcome.errors
      render json: response_hash, status: :unprocessable_entity
    end
  end


  private

  def set_league
    @league = League.find(permitted_params[:league_id]).decorate
  end

  def set_fpl_team_list
    @fpl_team_list =
      FplTeamList
        .joins(:fpl_team)
        .find_by(
          '(round_id = :round_id AND fpl_teams.league_id = :league_id AND fpl_teams.user_id = :user_id) OR ' \
          'fpl_team_lists.id = :id',
          round_id: Round.current.id,
          league_id: permitted_params[:league_id],
          user_id: current_api_v1_user.id,
          id: permitted_params[:fpl_team_list_id],
        )
        .decorate
  end

  def permitted_params
    params.permit(:league_id, :fpl_team_list_id, :list_position_id, :in_player_id)
  end
end

class Api::V1::Leagues::PassMiniDraftPicksController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    outcome = MiniDraftPicks::Pass.run(permitted_params.merge(user: current_api_v1_user))

    mini_draft_pick_hash = outcome.mini_draft_pick_hash

    if outcome.valid?
      mini_draft_pick_hash[:success] = 'You have successfully passed'
      render json: mini_draft_pick_hash
    else
      mini_draft_pick_hash[:error] = outcome.errors
      render json: mini_draft_pick_hash, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:league_id, :fpl_team_list_id)
  end
end

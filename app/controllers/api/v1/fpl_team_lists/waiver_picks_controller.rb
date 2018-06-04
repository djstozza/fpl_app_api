class Api::V1::FplTeamLists::WaiverPicksController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_fpl_team_list

  def index
    fpl_team_list_hash = FplTeamLists::Hash.run(
      permitted_params.merge(user: current_api_v1_user, show_waiver_picks: true),
    )
    render json: fpl_team_list_hash.result
  end

  def create
    outcome = WaiverPicks::Create.run(permitted_params.merge(user: current_api_v1_user))

    fpl_team_list_hash = outcome.fpl_team_list_hash

    if outcome.valid?
      waiver_pick = outcome.result
      message = "Waiver pick was successfully created. Pick number: #{waiver_pick.pick_number}, " \
               "In: #{waiver_pick.in_player.decorate.name}, Out: #{waiver_pick.out_player.decorate.name}"
      render json: fpl_team_list_hash.merge(success: message)
    else
      render json: fpl_team_list_hash.merge(error: outcome.errors), status: :unprocessable_entity
    end
  end

  def update
    outcome = WaiverPicks::UpdateOrder.run(permitted_params.merge(user: current_api_v1_user))

    fpl_team_list_hash = outcome.fpl_team_list_hash

    if outcome.valid?
      waiver_pick = outcome.result
      message = "Waiver picks successfully re-ordered. Pick number: #{waiver_pick.pick_number}, In: " \
               "#{waiver_pick.in_player.decorate.name}, Out: #{waiver_pick.out_player.decorate.name}"

      render json: fpl_team_list_hash.merge(success: message)
    else
      render json: fpl_team_list_hash.merge(error: outcome.errors), status: :unprocessable_entity
    end
  end

  def destroy
    outcome = WaiverPicks::Delete.run(permitted_params.merge(user: current_api_v1_user))

    fpl_team_list_hash = outcome.fpl_team_list_hash

    if outcome.valid?
      waiver_pick = outcome.waiver_pick
      message = "Waiver pick successfully deleted. Pick number: #{waiver_pick.pick_number}, In: " \
                  "#{waiver_pick.in_player.decorate.name}, Out: #{waiver_pick.out_player.decorate.name}"

      render json: fpl_team_list_hash.merge(success: message)
    else
      render json: fpl_team_list_hash.merge(error: outcome.errors), status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit(:waiver_pick_id, :list_position_id, :fpl_team_list_id, :in_player_id, :pick_number)
  end

  def set_fpl_team_list
    @fpl_team_list = FplTeamList.find(params[:fpl_team_list_id])
  end
end

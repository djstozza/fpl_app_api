class Api::V1::FplTeamLists::WaiverPicksController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_fpl_team_list

  def index
    render json: { waiver_picks: @fpl_team_list.decorate.waiver_picks_arr }
  end

  def create
    outcome = WaiverPicks::Create.run(permitted_params.merge(user: current_api_v1_user))

    if outcome.valid?
      waiver_pick = outcome.result
      render json: {
        waiver_picks: @fpl_team_list.decorate.waiver_picks_arr,
        success: "Waiver pick was successfully created. Pick number: #{waiver_pick.pick_number}, " \
                 "In: #{waiver_pick.in_player.decorate.name}, Out: #{waiver_pick.out_player.decorate.name}",
      }
    else
      render json: {
        waiver_picks: @fpl_team_list.decorate.waiver_picks_arr,
        error: outcome.errors,
      }, status: :unprocessable_entity
    end
  end

  def update
    outcome = WaiverPicks::UpdateOrder.run(permitted_params.merge(user: current_api_v1_user))

    if outcome.valid?
      waiver_pick = outcome.result

      render json: {
        waiver_picks: @fpl_team_list.decorate.waiver_picks_arr,
        success: "Waiver picks successfully re-ordered. Pick number: #{waiver_pick.pick_number}, In: " \
                 "#{waiver_pick.in_player.decorate.name}, Out: #{waiver_pick.out_player.decorate.name}",
      }
    else
      render json: {
        waiver_picks: @fpl_team_list.decorate.waiver_picks_arr,
        error: outcome.errors,
      }, status: :unprocessable_entity
    end
  end

  def destroy
    outcome = WaiverPicks::Delete.run(permitted_params.merge(user: current_api_v1_user))

    if outcome.valid?
      waiver_pick = outcome.waiver_pick

      render json: {
        waiver_picks: @fpl_team_list.decorate.waiver_picks_arr,
        success: "Waiver pick successfully deleted. Pick number: #{waiver_pick.pick_number}, In: " \
                    "#{waiver_pick.in_player.decorate.name}, Out: #{waiver_pick.out_player.decorate.name}",

      }
    else
      render json: {
        waiver_picks: @fpl_team_list.decorate.waiver_picks_arr,
        error: outcome.errors,
      }, status: :unprocessable_entity
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

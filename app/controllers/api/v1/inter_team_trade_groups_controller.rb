class Api::V1::InterTeamTradeGroupsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_fpl_team_list, except: :index

  # POST  /api/v1/inter_team_trade_groups
  # POST  /api/v1/inter_team_trade_groups.json
  def create
    outcome = InterTeamTradeGroups::Create.run(permitted_params.merge(user: current_api_v1_user))

    fpl_team_list_hash = outcome.fpl_team_list_hash

    if outcome.valid?
      render json: fpl_team_list_hash.merge(success: outcome.result.success)
    else
      render json: fpl_team_list_hash.merge(error: outcome.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT  /api/v1/inter_team_trade_groups/1
  # PATCH/PUT  /api/v1/inter_team_trade_groups/1.json
  def update
    outcome = "InterTeamTradeGroups::#{permitted_params[:trade_action].camelize}".constantize.run(
      permitted_params.merge(user: current_api_v1_user)
    )

    fpl_team_list_hash = outcome.fpl_team_list_hash

    if outcome.valid?
      render json: fpl_team_list_hash.merge(success: outcome.result.success)
    else
      render json: fpl_team_list_hash.merge(error: outcome.errors), status: :unprocessable_entity
    end
  end

  private

  def set_fpl_team_list
    @fpl_team_List = FplTeamList.find(permitted_params[:fpl_team_list_id])
  end

  def permitted_params
    params.permit(
      :fpl_team_id,
      :fpl_team_list_id,
      :out_list_position_id,
      :in_list_position_id,
      :inter_team_trade_group_id,
      :inter_team_trade_id,
      :trade_action,
    )
  end
end

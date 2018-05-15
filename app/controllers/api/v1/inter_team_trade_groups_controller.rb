class Api::V1::InterTeamTradeGroupsController < ApplicationController
  before_action :authenticate_api_v1_user!, except: :index
  before_action :set_fpl_team_list, except: :index

  # GET /fpl_teams/1/inter_team_trade_groups
  # GET /fpl_teams/1/inter_team_trade_groups.json
  def index
    fpl_team_list = FplTeamList.find_by(round: Round.current, fpl_team_id: params[:fpl_team_id])
    render json: fpl_team_list.decorate.inter_team_trade_group_hash
  end

  # POST /inter_team_trade_groups
  # POST /inter_team_trade_groups.json
  def create
    outcome = InterTeamTradeGroups::Create.run(permitted_params.merge(user: current_api_v1_user))

    result_hash =  FplTeamList.find(permitted_params[:fpl_team_list_id]).decorate.inter_team_trade_group_hash

    if outcome.valid?
      result_hash[:success] =
        "Successfully created a pending trade - Fpl Team: #{outcome.result.in_fpl_team.name}, " \
          "Out: #{outcome.out_player.decorate.name} In: #{outcome.in_player.decorate.name}."
      render json: result_hash
    else
      result_hash[:error] = outcome.errors
      render json: result_hash, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /inter_team_trade_groups/1
  # PATCH/PUT /inter_team_trade_groups/1.json
  def update
    outcome = "InterTeamTradeGroups::#{permitted_params[:trade_action].camelize}".constantize.run(
      permitted_params.merge(user: current_api_v1_user)
    )

    result_hash = FplTeamList.find(permitted_params[:fpl_team_list_id]).decorate.inter_team_trade_group_hash

    if outcome.valid?
      result_hash[:success] = outcome.result
      render json: result_hash
    else
      result_hash[:error] = outcome.errors
      render json: result_hash,
        status: :unprocessable_entity
    end
  end

  # DELETE /fpl_teams/1/inter_team_trade_groups/1
  # DELETE /fpl_teams/1/inter_team_trade_groups/1.json
  def destroy
    outcome =
      InterTeamTradeGroups::Delete.run(
        inter_team_trade_group: @inter_team_trade_group,
        current_user: current_user
      )

    if outcome.valid?
      render json: trade_group_hash
    else
      render json: trade_group_hash.merge(errors: outcome.errors.full_messages),
        status: :unprocessable_entity
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

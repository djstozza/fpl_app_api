class Api::V1::InterTeamTradeGroupsController < ApplicationController
  before_action :set_inter_team_trade_group, only: [:show, :update, :destroy]

  def index
    @inter_team_trade_groups = InterTeamTradeGroup.all
    respond_with(@inter_team_trade_groups)
  end

  def show
    respond_with(@inter_team_trade_group)
  end

  def create
    @inter_team_trade_group = InterTeamTradeGroup.new(inter_team_trade_group_params)
    @inter_team_trade_group.save
    respond_with(@inter_team_trade_group)
  end

  def update
    @inter_team_trade_group.update(inter_team_trade_group_params)
    respond_with(@inter_team_trade_group)
  end

  def destroy
    @inter_team_trade_group.destroy
    respond_with(@inter_team_trade_group)
  end

  private
    def set_inter_team_trade_group
      @inter_team_trade_group = InterTeamTradeGroup.find(params[:id])
    end

    def inter_team_trade_group_params
      params[:inter_team_trade_group]
    end
end

class Api::V1::InterTeamTradesController < ApplicationController
  before_action :set_inter_team_trade, only: [:show, :update, :destroy]

  def index
    @inter_team_trades = InterTeamTrade.all
    respond_with(@inter_team_trades)
  end

  def show
    respond_with(@inter_team_trade)
  end

  def create
    @inter_team_trade = InterTeamTrade.new(inter_team_trade_params)
    @inter_team_trade.save
    respond_with(@inter_team_trade)
  end

  def update
    @inter_team_trade.update(inter_team_trade_params)
    respond_with(@inter_team_trade)
  end

  def destroy
    @inter_team_trade.destroy
    respond_with(@inter_team_trade)
  end

  private
    def set_inter_team_trade
      @inter_team_trade = InterTeamTrade.find(params[:id])
    end

    def inter_team_trade_params
      params[:inter_team_trade]
    end
end

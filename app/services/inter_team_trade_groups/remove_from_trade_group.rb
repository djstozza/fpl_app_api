class InterTeamTradeGroups::RemoveFromTradeGroup < InterTeamTradeGroups::Base
  object :user, class: User
  object :inter_team_trade_group, class: InterTeamTradeGroup
  object :inter_team_trade, class: InterTeamTrade

  validate :authorised_user_out_fpl_team
  validate :round_is_current
  validate :trade_occurring_in_valid_period
  validate :inter_team_trade_group_pending
  validate :trade_occurring_in_valid_period

  def execute
    trade = inter_team_trade.delete
    errors.merge!(trade.errors)

    inter_team_trade_group.delete if inter_team_trade_group.inter_team_trades.blank?
    errors.merge!(inter_team_trade_group.errors)

    "Out: #{out_player.decorate.name} - In: #{in_player.decorate.name} has been removed from your trade proposal."
  end

  private

  def out_player
    inter_team_trade.out_player
  end

  def in_player
    inter_team_trade.in_player
  end
end

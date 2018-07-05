class InterTeamTradeGroups::RemoveFromTradeGroup < InterTeamTradeGroups::Base
  object :inter_team_trade_group, class: InterTeamTradeGroup
  object :inter_team_trade, class: InterTeamTrade

  delegate :out_player, :in_player, to: :inter_team_trade

  validate :authorised_user_out_fpl_team
  validate :inter_team_trade_group_pending

  def execute
    trade = inter_team_trade.delete
    errors.merge!(trade.errors)

    inter_team_trade_group.delete if inter_team_trade_group.inter_team_trades.blank?
    errors.merge!(inter_team_trade_group.errors)

    OpenStruct.new(
      success: "Out: #{out_player.decorate.name} - In: #{in_player.decorate.name} has been removed from " \
                 "your trade proposal.",
    )
  end

  private

  def inter_team_trade_group_pending
    return if inter_team_trade_group.pending?
    errors.add(:base, 'You cannot remove picks to this trade proposal as it is no longer pending.')
  end
end

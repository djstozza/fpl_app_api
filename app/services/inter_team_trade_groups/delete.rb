class InterTeamTradeGroups::Delete < InterTeamTradeGroups::Base
  object :user, class: User
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_out_fpl_team
  validate :round_is_current
  validate :trade_occurring_in_valid_period
  validate :inter_team_trade_group_unprocessed
  validate :trade_occurring_in_valid_period

  def execute
    inter_team_trade_group.inter_team_trades.delete_all
    inter_team_trade_group.delete
    errors.merge!(inter_team_trade_group.errors)

    'Trade successfully deleted.'
  end
end

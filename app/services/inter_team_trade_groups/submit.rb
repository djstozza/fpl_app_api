class InterTeamTradeGroups::Submit < InterTeamTradeGroups::Base
  object :user, class: User
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_out_fpl_team
  validate :inter_team_trade_group_pending
  validate :trade_occurring_in_valid_period
  validate :no_duplicate_trades

  def execute
    inter_team_trade_group.update(status: 'submitted')
    errors.merge!(inter_team_trade_group.errors)

    'Trade successfully submitted'
  end
end

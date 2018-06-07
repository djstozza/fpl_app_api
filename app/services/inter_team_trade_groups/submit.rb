class InterTeamTradeGroups::Submit < InterTeamTradeGroups::Base
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_out_fpl_team
  validate :inter_team_trade_group_pending
  validate :trade_occurring_in_valid_period
  validate :no_duplicate_trades

  def execute
    inter_team_trade_group.update(status: 'submitted')
    errors.merge!(inter_team_trade_group.errors)

    halt_if_errors!

    FplTeamTradeBroadcastJob.perform_later(
      fpl_team_list: in_fpl_team_list,
      fpl_team: in_fpl_team,
      user: in_fpl_team.user,
      round: round,
      show_trade_groups: true,
    )

    'Trade successfully submitted'
  end
end

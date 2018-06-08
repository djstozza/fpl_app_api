class InterTeamTradeGroups::Delete < InterTeamTradeGroups::Base
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_out_fpl_team
  validate :round_is_current
  validate :trade_occurring_in_valid_period
  validate :inter_team_trade_group_unprocessed
  validate :trade_occurring_in_valid_period

  def execute
    status = inter_team_trade_group.status

    inter_team_trade_group.inter_team_trades.delete_all
    inter_team_trade_group.delete
    errors.merge!(inter_team_trade_group.errors)

    halt_if_errors!

    if status == 'submitted'
      FplTeams::Broadcast.delay.run(
        fpl_team_list: in_fpl_team_list,
        fpl_team: in_fpl_team,
        user: in_fpl_team.user,
        round: round,
        show_trade_groups: true,
      )
    end

    'Trade successfully deleted.'
  end
end

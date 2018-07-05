class InterTeamTradeGroups::Submit < InterTeamTradeGroups::Base
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_out_fpl_team
  validate :inter_team_trade_group_pending
  validate :no_duplicate_trades
  validate :out_players_in_fpl_team
  validate :in_players_in_fpl_team

  def execute
    inter_team_trade_group.assign_attributes(status: 'submitted')
    inter_team_trade_group.save
    errors.merge!(inter_team_trade_group.errors)

    halt_if_errors!

    FplTeams::Broadcast.delay.run(
      fpl_team_list: in_fpl_team_list,
      fpl_team: in_fpl_team,
      user: in_fpl_team.user,
      round: round,
      show_trade_groups: true,
    )

    OpenStruct.new(
      success: 'This trade proposal has successfully submitted',
    )
  end

  private

  def inter_team_trade_group_pending
    return if inter_team_trade_group.pending?
    errors.add(:base, 'You can only submit pending trade proposals.')
  end
end

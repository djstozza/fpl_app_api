class InterTeamTradeGroups::Decline < InterTeamTradeGroups::Base
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_in_fpl_team
  validate :inter_team_trade_group_submitted

  def execute
    inter_team_trade_group.assign_attributes(status: 'declined')
    inter_team_trade_group.save
    errors.merge!(inter_team_trade_group.errors)

    halt_if_errors!

    FplTeams::Broadcast.delay.run(
      fpl_team_list: out_fpl_team_list,
      fpl_team: out_fpl_team,
      user: out_fpl_team.user,
      round: round,
      show_trade_groups: true,
    )

    OpenStruct.new(
      success: "You have successfully declined #{out_fpl_team.user.username}'s trade proposal.",
    )
  end

  private

  def inter_team_trade_group_submitted
    return if inter_team_trade_group.submitted?
    errors.add(:base, "You can only decline submitted trade proposals.")
  end
end

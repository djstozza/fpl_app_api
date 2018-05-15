class InterTeamTradeGroups::Decline < InterTeamTradeGroups::Base
  object :user, class: User
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_in_fpl_team
  validate :inter_team_trade_group_unprocessed
  validate :trade_occurring_in_valid_period

  def execute
    inter_team_trade_group.update(status: 'declined')
    errors.merge!(inter_team_trade_group.errors)
    @success_message = "You have successfully declined #{out_fpl_team.user.username}'s trade proposal."
    inter_team_trade_group
  end
end

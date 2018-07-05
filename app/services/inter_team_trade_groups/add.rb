class InterTeamTradeGroups::Add < InterTeamTradeGroups::Base
  object :inter_team_trade_group, class: InterTeamTradeGroup
  object :out_list_position, class: ListPosition
  object :in_list_position, class: ListPosition

  validate :authorised_user_out_fpl_team
  validate :out_player_in_fpl_team
  validate :in_player_in_fpl_team
  validate :identical_player_and_target_positions
  validate :unique_in_player_in_group
  validate :unique_out_player_in_group
  validate :valid_team_quota_out_fpl_team
  validate :valid_team_quota_in_fpl_team
  validate :inter_team_trade_group_pending

  def execute
    inter_team_trade = InterTeamTrade.new
    inter_team_trade.assign_attributes(
      out_player: out_player,
      in_player: in_player,
      inter_team_trade_group: inter_team_trade_group
    )
    inter_team_trade.save
    errors.merge!(inter_team_trade.errors)

    OpenStruct.new(
      inter_team_trade: inter_team_trade,
      success: "Out: #{out_player.decorate.name} - In: #{in_player.decorate.name} has been added to " \
               "the trade proposal.",
    )
  end

  private

  def inter_team_trade_group_pending
    return if inter_team_trade_group.pending?
    errors.add(:base, 'You cannot add more picks to this trade proposal as it is no longer pending.')
  end
end

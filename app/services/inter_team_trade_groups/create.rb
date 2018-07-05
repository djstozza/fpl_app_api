class InterTeamTradeGroups::Create < InterTeamTradeGroups::Base
  object :out_list_position, class: ListPosition
  object :in_list_position, class: ListPosition

  object :inter_team_trade_group, class: InterTeamTradeGroup, default: -> { InterTeamTradeGroup.new }

  delegate :fpl_team_list, to: :out_list_position, prefix: :out
  delegate :fpl_team_list, to: :in_list_position, prefix: :in

  validate :authorised_user_out_fpl_team
  validate :out_player_in_fpl_team
  validate :in_player_in_fpl_team
  validate :in_fpl_team_in_league
  validate :identical_player_and_target_positions
  validate :valid_team_quota_out_fpl_team
  validate :valid_team_quota_in_fpl_team
  validate :inter_team_trade_group_is_new

  def execute
    inter_team_trade_group.assign_attributes(
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      round: round,
      league: league,
      status: 'pending',
    )
    inter_team_trade_group.save
    errors.merge!(inter_team_trade_group.errors)

    inter_team_trade = InterTeamTrade.new
    inter_team_trade.assign_attributes(
      out_player: out_player,
      in_player: in_player,
      inter_team_trade_group: inter_team_trade_group
    )
    inter_team_trade.save
    errors.merge!(inter_team_trade.errors)

    OpenStruct.new(
      inter_team_trade_group: inter_team_trade_group,
      inter_team_trade: inter_team_trade,
      success: "Successfully created a pending trade - Fpl Team: #{in_fpl_team.name}, " \
                 "Out: #{out_player.decorate.name} In: #{in_player.decorate.name}.",
    )
  end

  private

  def inter_team_trade_group_is_new
    return if inter_team_trade_group.new_record?
    errors.add(:base, "This trade proposal already exists.")
  end
end

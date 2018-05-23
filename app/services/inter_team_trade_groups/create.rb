class InterTeamTradeGroups::Create < InterTeamTradeGroups::Base
  object :user, class: User
  object :out_list_position, class: ListPosition
  object :in_list_position, class: ListPosition

  object :inter_team_trade_group, class: InterTeamTradeGroup, default: -> do
    InterTeamTradeGroup.new(
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      round: round,
      league: league,
      status: 'pending'
    )
  end

  validate :authorised_user_out_fpl_team
  validate :out_player_in_fpl_team
  validate :in_player_in_fpl_team
  validate :in_fpl_team_in_league
  validate :identical_player_and_target_positions
  validate :round_is_current
  validate :trade_occurring_in_valid_period
  validate :valid_team_quota_out_fpl_team
  validate :valid_team_quota_in_fpl_team

  def execute
    inter_team_trade_group.save
    errors.merge!(inter_team_trade_group.errors)

    trade = InterTeamTrade.create(
      out_player: out_player,
      in_player: in_player,
      inter_team_trade_group: inter_team_trade_group
    )
    errors.merge!(trade.errors)

    inter_team_trade_group
  end
end

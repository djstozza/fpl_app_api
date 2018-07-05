class InterTeamTradeGroups::Approve < InterTeamTradeGroups::Base
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_in_fpl_team
  validate :inter_team_trade_group_submitted
  validate :out_players_in_fpl_team
  validate :in_players_in_fpl_team

  def execute
    inter_team_trade_group.update(status: 'approved')
    errors.merge!(inter_team_trade_group.errors)

    in_players = inter_team_trade_group.in_players
    out_players = inter_team_trade_group.out_players

    out_fpl_team.players.delete(out_players)
    in_fpl_team.players.delete(in_players)

    errors.merge!(out_fpl_team.errors)
    errors.merge!(in_fpl_team.errors)

    inter_team_trade_group.inter_team_trades.each do |trade|
      out_list_position = out_fpl_team_list.list_positions.find_by(player: trade.out_player)
      out_list_position.update(player: trade.in_player)
      errors.merge!(out_list_position.errors)

      in_list_position = in_fpl_team_list.list_positions.find_by(player: trade.in_player)
      in_list_position.update(player: trade.out_player)
      errors.merge!(in_list_position.errors)
    end

    out_fpl_team.players << in_players
    in_fpl_team.players << out_players

    errors.merge!(out_fpl_team_list.errors)
    errors.merge!(in_fpl_team_list.errors)

    halt_if_errors!

    FplTeams::Broadcast.delay.run(
      fpl_team_list: out_fpl_team_list,
      fpl_team: out_fpl_team,
      user: out_fpl_team.user,
      round: round,
      show_trade_groups: true,
    )

    OpenStruct.new(
      success: 'You have successfully approved the trade. All players involved have been exchanged.',
    )
  end

  private

  def inter_team_trade_group_submitted
    return if inter_team_trade_group.submitted?
    errors.add(:base, "You can only approve submitted trade proposals.")
  end
end

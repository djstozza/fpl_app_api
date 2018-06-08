class InterTeamTradeGroups::Approve < InterTeamTradeGroups::Base
  object :inter_team_trade_group, class: InterTeamTradeGroup

  validate :authorised_user_in_fpl_team
  validate :inter_team_trade_group_unprocessed
  validate :out_players_in_fpl_team
  validate :in_players_in_fpl_team
  validate :trade_occurring_in_valid_period

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
      out_fpl_team_list.list_positions.find_by(player: trade.out_player).update!(player: trade.in_player)
      in_fpl_team_list.list_positions.find_by(player: trade.in_player).update!(player: trade.out_player)
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

    'You have successfully approved the trade. All players involved have been exchanged.'
  end
end

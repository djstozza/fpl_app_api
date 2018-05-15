class InterTeamTradeGroupDecorator < ApplicationDecorator
  def all_inter_team_trades
    inter_team_trades
      .joins('JOIN players AS in_players ON inter_team_trades.in_player_id = in_players.id')
      .joins('JOIN players AS out_players ON inter_team_trades.out_player_id = out_players.id')
      .joins('JOIN teams AS in_teams ON in_players.team_id = in_teams.id')
      .joins('JOIN teams AS out_teams ON out_players.team_id = out_teams.id')
      .joins('JOIN positions ON out_players.position_id = positions.id')
      .pluck_to_hash(
        :id,
        'in_players.id AS in_player_id',
        'in_players.last_name AS in_player_last_name',
        'in_teams.short_name AS in_team_short_name',
        'out_players.id AS out_player_id',
        'out_players.last_name AS out_player_last_name',
        'out_teams.short_name AS out_team_short_name',
        :singular_name_short
      )
  end
end

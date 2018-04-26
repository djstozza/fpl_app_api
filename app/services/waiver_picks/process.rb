class WaiverPicks::Process < ApplicationInteraction
  object :round, class: Round, default: -> { Round.current }

  def execute
    League.active.each do |league|
      waiver_groups = league.waiver_picks.where(round: round).group_by { |pick| pick.pick_number }
      waiver_groups.sort.each do |_k, v|
        v.sort { |a, b| b.fpl_team_list.fpl_team.rank <=> a.fpl_team_list.fpl_team.rank }.each do |pick|
          out_player = pick.out_player
          in_player = pick.in_player
          fpl_team_list = pick.fpl_team_list
          fpl_team = fpl_team_list.fpl_team

          next if league.players.include?(in_player)
          next if fpl_team.players.include?(in_player)
          next unless fpl_team.players.include?(out_player)
          next if out_player.position != in_player.position

          fpl_team_list.list_positions.find_by(player: out_player).update(player: in_player)
          league.players.delete(out_player)
          league.players << in_player
          fpl_team.players.delete(out_player)
          fpl_team.players << in_player

          pick.update(status: 'approved')
        end
      end

      league.waiver_picks.where(round: round).pending.update_all(status: 'declined')
    end
  end
end

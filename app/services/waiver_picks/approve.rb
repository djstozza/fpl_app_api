class WaiverPicks::Approve < ApplicationInteraction
  object :waiver_pick, class: WaiverPick

  delegate :fpl_team_list, :in_player, :out_player, :fpl_team, :league, :round, to: :waiver_pick

  def execute
    return if Time.now < round.deadline_time - 1.day
    return if league.players.include?(in_player)
    return if fpl_team.players.include?(in_player)
    return unless fpl_team.players.include?(out_player)
    return if out_player.position != in_player.position
    return unless waiver_pick.pending?

    fpl_team_list.list_positions.find_by(player: out_player).update(player: in_player)
    league.players.delete(out_player)
    league.players << in_player
    fpl_team.players.delete(out_player)
    fpl_team.players << in_player

    waiver_pick.update(status: 'approved')
    errors.merge!(waiver_pick.errors)
  end
end

class RecurringScoringJob < ApplicationInteraction
  def execute
    return if Round.last == round && round.finished
    return if Time.now < round.deadline_time + round.deadline_time_game_offset

    League.active.each do |league|
      compose(::Leagues::Score, league: league, round: round)
      compose(::Leagues::Rank, league: league, round: round)
      compose(::Leagues::ProcessNextLineUp, league: league, round: round, next_round: next_round)

      league.fpl_teams.each do |fpl_team|
        compose(
          ::FplTeams::Broadcast,
          fpl_team: fpl_team,
          user: fpl_team.user,
          show_list_positions: true,
          show_waiver_picks: true,
        )
      end
    end
  end

  private

  def round
    Round.find_by(is_current: true)
  end

  def next_round
    Round.find_by(is_next: true)
  end
end

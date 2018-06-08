class Score < ApplicationInteraction
  def execute
    round = Round.find_by(is_current: true)
    next_round = Round.find_by(is_next: true)

    League.active.each do |league|
      ::Leagues::Score.run!(league: league, round: round)
      ::Leagues::Rank.run!(league: league, round: round)

      next if next_round.blank? || !round.data_checked

      league.fpl_teams.each do |fpl_team|
        ::FplTeams::ProcessNextLineUp.run!(fpl_team: fpl_team, current_round: round, next_round: next_round)
      end
    end
  end
end

class Leagues::ProcessNextLineUp < ApplicationInteraction
  object :league, class: League
  object :round, class: Round
  object :next_round, class: Round, default: nil

  delegate :fpl_teams, to: :league

  def execute
    return if next_round.blank? || !round.data_checked

    fpl_teams.each do |fpl_team|
      compose(FplTeams::ProcessNextLineUp, fpl_team: fpl_team, round: round, next_round: next_round)
    end
  end
end

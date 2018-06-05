class Leagues::Score < ActiveInteraction::Base
  object :league, class: League
  object :round, class: Round, default: -> { Round.current }

  def execute
    ActiveRecord::Base.transaction do
      league.fpl_teams.each do |fpl_team|
        FplTeams::Score.run(fpl_team: fpl_team, round: round)
      end
    end
  end
end

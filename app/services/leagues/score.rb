class Leagues::Score < ActiveInteraction::Base
  object :league, class: League
  object :round, class: Round, default: -> { Round.current }

  delegate :fpl_teams, :fpl_team_lists, to: :league

  def execute
    fpl_team_lists.where(round: round).each do |fpl_team_list|
      compose(FplTeamLists::Score, fpl_team_list: fpl_team_list)
    end

    fpl_teams.each { |fpl_team| compose(FplTeams::Score, fpl_team: fpl_team) }
  end
end

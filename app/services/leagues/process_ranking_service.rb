class Leagues::ProcessRankingService < ActiveInteraction::Base
  object :league, class: League
  object :round, class: Round

  def execute
    league.fpl_team_lists.where(round: round).order(total_score: :desc).each_with_index do |fpl_team_list, i|
      fpl_team_list.update(rank: i + 1)
    end
    league.fpl_teams.order(total_score: :desc).each_with_index do |fpl_team, i|
      fpl_team.update(rank: i + 1)
      fpl_team.fpl_team_lists.find_by(round: round).update(overall_rank: fpl_team.rank)
    end
  end
end

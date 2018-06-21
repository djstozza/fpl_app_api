class Leagues::Rank < ActiveInteraction::Base
  object :league, class: League
  object :round, class: Round

  delegate :fpl_teams, :fpl_team_lists, to: :league

  def execute
    fpl_team_lists.each do |fpl_team_list|
      rank = ordered_fpl_team_list_total_scores.index(fpl_team_list.total_score) + 1

      fpl_team_list.assign_attributes(rank: rank)
      fpl_team_list.save
      errors.merge!(fpl_team_list.errors)
    end

    fpl_teams.each do |fpl_team|
      rank = ordered_fpl_team_list_total_scores.index(fpl_team.total_score) + 1

      fpl_team.assign_attributes(rank: rank)
      fpl_team.save
      errors.merge!(fpl_team.errors)

      fpl_team_list = fpl_team.fpl_team_lists.find_by(round: round)
      fpl_team_list.assign_attributes(overall_rank: fpl_team.rank)
      fpl_team_list.save
      errors.merge!(fpl_team_list.errors)
    end
  end

  private

  def ordered_fpl_team_list_total_scores
    fpl_team_lists.where(round: round).order(total_score: :desc).pluck(:total_score)
  end

  def ordered_fpl_team_list_total_scores
    fpl_teams.order(total_score: :desc).pluck(:total_score)
  end
end

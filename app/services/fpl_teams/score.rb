class FplTeams::Score < ApplicationInteraction
  object :fpl_team, class: FplTeam

  delegate :fpl_team_lists, to: :fpl_team

  def execute
    total_score = fpl_team_lists.pluck(:total_score).inject(0) { |sum, x| x.present? ? sum + x : sum }

    fpl_team.assign_attributes(total_score: total_score)
    fpl_team.save
    errors.merge!(fpl_team.errors)
  end
end

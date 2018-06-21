class FplTeams::ProcessNextLineUp < ActiveInteraction::Base
  object :fpl_team, class: FplTeam
  object :round, class: Round
  object :next_round, class: Round, default: nil

  def execute
    return if fpl_team.fpl_team_lists.find_by(round: next_round).present? || next_round.nil? || !round.data_checked

    current_fpl_team_list = fpl_team.fpl_team_lists.find_by(round: round)
    next_fpl_team_list = FplTeamList.create(round: next_round, fpl_team: fpl_team)
    errors.merge!(next_fpl_team_list.errors)

    current_fpl_team_list.list_positions.each do |list_position|
      next_list_position = ListPosition.create(
        fpl_team_list: next_fpl_team_list,
        role: list_position.role,
        player: list_position.player,
        position: list_position.position
      )

      errors.merge!(next_list_position.errors)
    end

    next_fpl_team_list
  end
end

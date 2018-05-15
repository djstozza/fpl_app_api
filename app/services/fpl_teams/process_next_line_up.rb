class FplTeams::ProcessNextLineUp < ActiveInteraction::Base
  object :fpl_team, class: FplTeam
  object :current_round, class: Round
  object :next_round, class: Round

  def execute
    current_fpl_team_list = fpl_team.fpl_team_lists.find_by(round: current_round)
    next_fpl_team_list = FplTeamList.create(round: next_round, fpl_team: fpl_team)
    current_fpl_team_list.list_positions.each do |list_position|
      ListPosition.create(
        fpl_team_list: next_fpl_team_list,
        role: list_position.role,
        player: list_position.player,
        position: list_position.position
      )
    end
  end
end

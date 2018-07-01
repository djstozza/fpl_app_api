class FplTeams::ProcessInitialLineUp < ApplicationInteraction
  object :fpl_team, class: FplTeam

  run_in_transaction!

  def execute
    round = Round.current.present? ? Round.current : Round.first
    fpl_team_list = FplTeamList.create(fpl_team: fpl_team, round: round)

    starting = []
    starting += fpl_team.players.forwards
    starting += fpl_team.players.midfielders.order(ict_index: :desc).first(4)
    starting += fpl_team.players.defenders.order(ict_index: :desc).first(3)
    starting << fpl_team.players.goalkeepers.order(ict_index: :desc).first

    starting.each do |player|
      ListPosition.create(player: player, position: player.position, fpl_team_list: fpl_team_list, role: 'starting')
    end

    left_over_players = fpl_team.players.where.not(id: starting.pluck(:id))

    i = 0
    left_over_players.each do |player|
      if player.position.singular_name == 'Goalkeeper'
        ListPosition.create(
          player: player,
          position: player.position,
          fpl_team_list: fpl_team_list,
          role: 'substitute_gkp',
        )
      else
        i += 1
        ListPosition.create(
          player: player,
          position: player.position,
          fpl_team_list: fpl_team_list,
          role: "substitute_#{i}",
        )
      end
    end

    fpl_team_list
  end
end

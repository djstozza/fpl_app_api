class FplTeams::Broadcast < ApplicationInteraction
  object :fpl_team, class: FplTeam
  object :user, class: User
  object :round, class: Round, default: -> { Round.current }
  object :fpl_team_list, class: FplTeamList, default: -> { set_fpl_team_list }
  boolean :show_waiver_picks, default: false
  boolean :show_trade_groups, default: false
  boolean :show_list_positions, default: false
  string :info, default: nil

  delegate :fpl_team_lists, to: :fpl_team

  def execute
    fpl_team_hash = FplTeams::Hash.run(
      fpl_team: fpl_team,
      user: user,
      round: round,
      fpl_team_list: fpl_team_list,
      show_waiver_picks: show_waiver_picks,
      show_trade_groups: show_trade_groups,
      show_list_positions: show_list_positions,
    ).result

    binding.pry

    ActionCable.server.broadcast("fpl_team_#{fpl_team.id}", fpl_team_hash.merge(info: info))
  end

  private

  def set_fpl_team_list
    fpl_team_lists.find_by(round: round)
  end
end

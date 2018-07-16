class FplTeams::Hash < ApplicationInteraction
  object :fpl_team, class: FplTeam
  object :user, class: User
  object :round, class: Round, default: -> { Round.current }
  object :fpl_team_list, class: FplTeamList, default: -> { set_fpl_team_list }
  boolean :show_waiver_picks, default: false
  boolean :show_trade_groups, default: false
  boolean :show_list_positions, default: false

  delegate :league, :fpl_team_lists, to: :fpl_team

  def execute
    hash
  end

  def hash
    return base_hash unless fpl_team_list

    fpl_team_list_hash = FplTeamLists::Hash.run(
      fpl_team_list: fpl_team_list,
      user: user,
      show_waiver_picks: show_waiver_picks,
      show_trade_groups: show_trade_groups,
      show_list_positions: show_list_positions,
      user_owns_fpl_team: user_owns_fpl_team,
    )
    errors.merge!(fpl_team_list_hash.errors)

    fpl_team_hash =
      if fpl_team_list_hash.valid?
        base_hash.merge(fpl_team_list_hash.result)
      else
        base_hash
      end

    fpl_team_hash
  end

  private

  def base_hash
    {
      fpl_team: fpl_team,
      fpl_team_list: fpl_team_list,
      fpl_team_lists: fpl_team_lists.reload.sort,
      current_user: user,
      user_owns_fpl_team: user_owns_fpl_team,
      league: league,
      league_status: league.status,
    }
  end

  def user_owns_fpl_team
    fpl_team.user == user
  end

  def set_fpl_team_list
    fpl_team_lists.find_by(round: round)
  end
end

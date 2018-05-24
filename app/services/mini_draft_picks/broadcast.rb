class MiniDraftPicks::Broadcast < ApplicationInteraction
  object :league, class: League
  object :fpl_team_list, class: FplTeamList
  object :user, class: User
  object :out_player, class: Player, default: nil
  object :in_player, class: Player, default: nil
  boolean :passed, default: false

  def execute
    response_hash = league.decorate.mini_draft_response_hash.merge(
      fpl_team_list: fpl_team_list,
      list_positions: fpl_team_list.decorate.tradeable_players,
      info: info,
    )

    ActionCable.server.broadcast("league_#{league.id}_mini_draft_picks", response_hash)
  end

  private

  def info
    return if league_decorator.consecutive_passes

    if passed
      "#{user.username} has passed."
    else
      "#{user.username} has just drafted #{in_player.decorate.name} for #{out_player.decorate.name}."
    end
  end

  def league_decorator
    league.decorate
  end
end

class MiniDraftPicks::Broadcast < ApplicationInteraction
  object :league, class: League
  object :fpl_team_list, class: FplTeamList
  object :user, class: User
  object :out_player, class: Player, default: nil
  object :in_player, class: Player, default: nil
  boolean :passed, default: false

  def execute
    return if mini_draft_pick_hash[:consecutive_passes]

    ActionCable.server.broadcast("league_#{league.id}_mini_draft_picks", mini_draft_pick_hash.merge!(info: info))
  end

  private

  def info
    if passed
      "#{user.username} has passed."
    else
      "#{user.username} has just drafted #{in_player.decorate.name} for #{out_player.decorate.name}."
    end
  end

  def mini_draft_pick_hash
    MiniDraftPicks::Hash.run(league: league).result
  end
end

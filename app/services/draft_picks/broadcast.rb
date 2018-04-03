class DraftPicks::Broadcast < ApplicationInteraction
  object :league, class: League
  object :user, class: User
  object :player, class: Player

  def execute
    league_decorator = league.decorate
    ActionCable.server.broadcast("league_#{league.id}_draft_picks", {
      draft_picks: league_decorator.all_draft_picks,
      current_draft_pick: league_decorator.current_draft_pick,
      unpicked_players: league_decorator.unpicked_players,
      info: "#{user.username} has just drafted #{player.decorate.name}."
    })
  end
end

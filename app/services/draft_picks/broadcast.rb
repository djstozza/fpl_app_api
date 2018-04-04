class DraftPicks::Broadcast < ApplicationInteraction
  object :league, class: League
  object :user, class: User
  boolean :mini_draft
  object :player, class: Player, default: nil

  def execute
    league_decorator = league.decorate
    current_draft_pick = league_decorator.current_draft_pick
    fpl_team = current_draft_pick.fpl_team
    fpl_team_decorator = fpl_team&.decorate

    ActionCable.server.broadcast("league_#{league.id}_draft_picks", {
      draft_picks: league_decorator.all_draft_picks,
      current_draft_pick: current_draft_pick,
      unpicked_players: league_decorator.unpicked_players,
      fpl_team: fpl_team,
      mini_draft_picked: fpl_team_decorator&.mini_draft_picked?,
      all_players_picked: fpl_team_decorator&.all_players_picked?,
      info: info,
    })
  end

  private

  def info
    if mini_draft
      "#{user.username} has made a mini draft position pick."
    else
      "#{user.username} has just drafted #{player.decorate.name}."
    end
  end
end

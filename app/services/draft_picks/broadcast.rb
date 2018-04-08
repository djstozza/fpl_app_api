class DraftPicks::Broadcast < ApplicationInteraction
  object :league, class: League
  object :user, class: User
  boolean :mini_draft
  object :player, class: Player, default: nil

  def execute
    response_hash = league.decorate.draft_response_hash
    response_hash[:info] = info

    ActionCable.server.broadcast("league_#{league.id}_draft_picks", response_hash)
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

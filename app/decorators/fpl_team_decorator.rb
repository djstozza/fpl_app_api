class FplTeamDecorator < ApplicationDecorator
  def mini_draft_picked?
    draft_picks.find_by(mini_draft: true).present?
  end

  def all_players_picked?
    draft_picks.where.not(player: nil).count == FplTeam::QUOTAS[:players]
  end
end

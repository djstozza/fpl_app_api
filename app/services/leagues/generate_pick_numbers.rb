class Leagues::GeneratePickNumbers < ApplicationInteraction
  object :league, class: League
  object :user, class: User
  validate :user_is_commissioner
  validate :min_fpl_team_quota

  run_in_transaction!

  def execute
    shuffled_fpl_teams = league.fpl_teams.shuffle
    shuffled_fpl_teams.each do |fpl_team|
      fpl_team.update(draft_pick_number: (shuffled_fpl_teams.index(fpl_team) + 1))
    end

    league.update(status: 'create_draft')
    league
  end

  private

  def user_is_commissioner
    return if league.commissioner = user
    errors.add(:base, 'You are not authorised to edit this league.')
  end

  def min_fpl_team_quota
    return if league.fpl_teams.count >= League::MIN_FPL_TEAM_QUOTA
    errors.add(:base, "There must be #{League::MIN_FPL_TEAM_QUOTA} teams present for the draft to occcur.")
  end
end

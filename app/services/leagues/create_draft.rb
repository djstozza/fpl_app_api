class Leagues::CreateDraft < ApplicationInteraction
  object :league, class: League
  object :user, class: User

  # 15 player picks per team & 1 mini draft pick
  PICKS_PER_TEAM = 16

  validate :user_is_commissioner
  validate :league_status
  validate :min_fpl_team_quota

  run_in_transaction!

  def execute
    (1..total_picks).each do |i|
      draft_pick = DraftPick.new(pick_number: i, league: league, fpl_team: fpl_team(i))
      draft_pick.save
      errors.merge!(draft_pick.errors)
    end

    league.update(status: 'draft')
    errors.merge!(league.errors)

    league
  end

  private

  def fpl_teams
    league.fpl_teams.order(:draft_pick_number)
  end

  def fpl_team_count
    fpl_teams.count
  end

  def total_picks
    fpl_teams.count * PICKS_PER_TEAM
  end

  def fpl_team_index(i)
    divider = i % (2 * fpl_team_count)
    divider == 0 ? divider : divider - 1
  end

  def fpl_team(i)
    fpl_team_index = fpl_team_index(i)
    if fpl_team_index < fpl_team_count
      fpl_teams[fpl_team_index % fpl_team_count]
    else
      fpl_teams.reverse[fpl_team_index % fpl_team_count]
    end
  end

  def user_is_commissioner
    return if league.commissioner == user
    errors.add(:base, 'You are not authorised to edit this league.')
  end

  def league_status
    return if league.status == 'create_draft'
    errors.add(:base, 'You cannot initiate the draft at this time.')
  end

  def min_fpl_team_quota
    return if fpl_team_count >= League::MIN_FPL_TEAM_QUOTA
    errors.add(:base, "There must be at least #{League::MIN_FPL_TEAM_QUOTA} teams present for the draft to occcur.")
  end
end

class Leagues::GenerateFplTeamDraftPickNumbers < ApplicationInteraction
  object :league, class: League
  object :user, class: User

  delegate :fpl_teams, to: :league

  validate :user_is_commissioner
  validate :min_fpl_team_quota
  validate :league_status

  run_in_transaction!

  def execute
    shuffled_fpl_teams.each do |fpl_team|
      fpl_team.assign_attributes(draft_pick_number: (shuffled_fpl_teams.index(fpl_team) + 1))
      fpl_team.save
      errors.merge!(fpl_team.errors)
    end

    halt_if_errors!

    league.assign_attributes(status: 'create_draft')
    league.save
    errors.merge!(league.errors)

    league
  end

  private

  def shuffled_fpl_teams
    @shuffled_fpl_teams ||= fpl_teams.shuffle
  end

  def user_is_commissioner
    return if league.commissioner == user
    errors.add(:base, 'You are not authorised to edit this league.')
  end

  def league_status
    return if league.status == 'generate_draft_picks'
    errors.add(:base, 'You cannot generate draft pick numbers at this time.')
  end

  def min_fpl_team_quota
    return if fpl_teams.count >= League::MIN_FPL_TEAM_QUOTA
    errors.add(:base, "There must be at least #{League::MIN_FPL_TEAM_QUOTA} teams present for the draft to occcur.")
  end
end

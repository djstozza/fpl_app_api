class Leagues::UpdateDraftPickNumberOrder < ApplicationInteraction
  object :league, class: League
  object :fpl_team, class: FplTeam
  object :user, class: User
  integer :draft_pick_number

  delegate :fpl_teams, to: :league

  validate :user_is_commissioner
  validate :league_status
  validate :valid_draft_pick_number
  validate :fpl_team_in_league

  run_in_transaction!

  def execute
    old_draft_pick_number = fpl_team.draft_pick_number
    fpl_team.update(draft_pick_number: nil)

    if old_draft_pick_number > draft_pick_number
      fpl_teams.where(
        'draft_pick_number >= :new_pick_number AND draft_pick_number <= :old_pick_number',
        new_pick_number: draft_pick_number,
        old_pick_number: old_draft_pick_number,
      ).order(draft_pick_number: :desc).each do |fpl_team|
        fpl_team.update(draft_pick_number: fpl_team.draft_pick_number + 1)
        errors.merge!(fpl_team.errors)
      end
    elsif old_draft_pick_number <= draft_pick_number
      fpl_teams.where(
        'draft_pick_number <= :new_pick_number AND draft_pick_number >= :old_pick_number',
        new_pick_number: draft_pick_number,
        old_pick_number: old_draft_pick_number
      ).order(:draft_pick_number).each do |fpl_team|
        fpl_team.update(draft_pick_number: fpl_team.draft_pick_number - 1)
        errors.merge!(fpl_team.errors)
      end
    end

    fpl_team.update(draft_pick_number: draft_pick_number)
    errors.merge!(fpl_team.errors)

    league
  end

  private

  def user_is_commissioner
    return if league.commissioner == user
    errors.add(:base, 'You are not authorised to edit this league.')
  end

  def league_status
    return if league.status == 'create_draft'
    errors.add(:base, 'You cannot make any more changes to the draft pick order.')
  end

  def valid_draft_pick_number
    return if fpl_teams.pluck(:draft_pick_number).include?(draft_pick_number)
    errors.add(:base, 'Draft pick number is invalid.')
  end

  def fpl_team_in_league
    return if fpl_teams.include?(fpl_team)
    errors.add(:base, 'You can only update draft pick numbers for fpl teams that are part of your league.')
  end
end

class Leagues::UpdatePickNumberOrder < ApplicationInteraction
  object :league, class: League
  object :fpl_team, class: FplTeam
  object :user, class: User
  integer :draft_pick_number

  validate :user_is_commissioner
  validate :league_status

  run_in_transaction!

  def execute
    fpl_teams = league.fpl_teams.order(:draft_pick_number)
    old_draft_pick_number = fpl_team.draft_pick_number
    fpl_team.update(draft_pick_number: nil)

    if old_draft_pick_number > draft_pick_number
      fpl_teams.where(
        'draft_pick_number >= :new_pick_number AND draft_pick_number <= :old_pick_number',
        new_pick_number: draft_pick_number,
        old_pick_number: old_draft_pick_number,
      ).each do |team|
        team.update(draft_pick_number: team.draft_pick_number + 1)
      end

      fpl_team.update(draft_pick_number: draft_pick_number)
    elsif old_draft_pick_number < draft_pick_number
      fpl_teams.where(
        'draft_pick_number <= :new_pick_number AND draft_pick_number >= :old_pick_number',
        new_pick_number: draft_pick_number,
        old_pick_number: old_draft_pick_number
      ).each do |team|
        team.update(draft_pick_number: team.draft_pick_number - 1)
      end
    end

    fpl_team.update(draft_pick_number: draft_pick_number)
    league
  end

  private

  def user_is_commissioner
    return if league.commissioner = user
    errors.add(:base, 'You are not authorised to edit this league.')
  end

  def league_status
    return if league.status == 'create_draft'
    errors.add(:base, 'You cannot make any more changes to the draft pick order.')
  end
end

class Leagues::CreateDraft < ApplicationInteraction
  object :league, class: League
  object :user, class: User

  # 15 player picks per team & 1 mini draft pick
  PICKS_PER_TEAM = 16

  validate :user_is_commissioner
  validate :league_status

  run_in_transaction!

  def execute
    fpl_teams = league.fpl_teams.order(:draft_pick_number)
    fpl_team_count = fpl_teams.count
    total_picks = fpl_teams.count * PICKS_PER_TEAM

    (1..total_picks).each do |i|
      divider = i % (2 * fpl_team_count)
      index = divider == 0 ? divider : divider - 1

      fpl_team =
        if index < fpl_team_count
          fpl_teams[index % fpl_team_count]
        else
          fpl_teams.reverse[index % fpl_team_count]
        end

      draft_pick = DraftPick.create(pick_number: i, league: league, fpl_team: fpl_team)

      errors.merge!(draft_pick.errors)
    end

    league.update(status: 'draft')
    league
  end

  def user_is_commissioner
    return if league.commissioner = user
    errors.add(:base, 'You are not authorised to edit this league.')
  end

  def league_status
    return if league.status == 'create_draft'
    errors.add(:base, 'You cannot initiate the draft at this time.')
  end
end

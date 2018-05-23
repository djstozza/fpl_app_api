class MiniDraftPicks::Pass < ApplicationInteraction
  object :league, class: League
  object :user, class: User
  object :fpl_team_list, class: FplTeamList

  validate :round_is_current
  validate :fpl_team_turn
  validate :authorised_user

  def execute
    outcome = MiniDraftPick.create(
      fpl_team: fpl_team,
      round: round,
      league: league,
      season: league_decorator.season,
      pick_number: league_decorator.next_mini_draft_pick_number,
      passed: true
    )
    errors.merge!(outcome.errors) if outcome.errors.any?

    MiniDraftPickBroadcastJob.perform_later(league,fpl_team_list, user, nil, nil, true)

    if league_decorator.consecutive_passes
      self.class.run(
        league: league,
        fpl_team_list_id: league_decorator.current_mini_draft_pick.fpl_team.fpl_team_lists.find_by(round: round).id,
        user: league_decorator.current_mini_draft_pick.fpl_team.user
      )
    end
  end

  private

  def fpl_team
    fpl_team_list.fpl_team
  end

  def round
    fpl_team_list.round
  end

  def round_is_current
    return if round == Round.current
    errors.add(:base, "You can only make changes to your squad's line up for the upcoming round.")
  end

  def mini_draft_pick_round
    return if round.mini_draft
    errors.add(:base, 'Mini draft picks cannot be performed at this time')
  end

  def mini_draft_pick_occurring_in_valid_period
    if Time.now > round.deadline_time
      errors.add(:base, 'The deadline time for making mini draft picks has passed.')
    end
  end

  def fpl_team_turn
    return if league_decorator.next_fpl_team == fpl_team
    errors.add(:base, 'You pass out of turn.')
  end

  def authorised_user
    return if fpl_team.user == user
    errors.add(:base, 'You are not authorised to make changes to this team.')
  end

  def league_decorator
    league.decorate
  end

  def season
    league_decorator.season
  end

  def fpl_team
    fpl_team_list.fpl_team
  end
end

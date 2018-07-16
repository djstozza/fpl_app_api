class MiniDraftPicks::Pass < ApplicationInteraction
  object :league, class: League
  object :user, class: User
  object :fpl_team_list, class: FplTeamList

  delegate :fpl_team, to: :fpl_team_list
  delegate :round, to: :fpl_team_list

  validate :round_is_current
  validate :fpl_team_turn
  validate :authorised_user
  validate :mini_draft_pick_occurring_in_valid_period
  validate :mini_draft_pick_round

  def execute
    mini_draft_pick = MiniDraftPick.create(
      fpl_team: fpl_team,
      round: round,
      league: league,
      season: season,
      pick_number: mini_draft_pick_hash[:next_mini_draft_pick_number],
      passed: true
    )
    errors.merge!(mini_draft_pick.errors) if mini_draft_pick.errors.any?

    halt_if_errors!

    if mini_draft_pick_hash[:consecutive_passes]
      self.class.delay.run(
        league: league,
        fpl_team_list: current_mini_draft_pick.fpl_team.reload.fpl_team_lists.find_by(round: round),
        user: current_mini_draft_pick.fpl_team.user
      )
    else
      MiniDraftPicks::Broadcast.delay.run(league: league, fpl_team_list: fpl_team_list, user: user, passed: true)
    end

    mini_draft_pick
  end

  def mini_draft_pick_hash
    MiniDraftPicks::Hash.run(league: league, fpl_team_list: fpl_team_list, user: user).result
  end

  private

  def current_mini_draft_pick
    mini_draft_pick_hash[:current_mini_draft_pick]
  end

  def round_is_current
    return if round == Round.current
    errors.add(:base, "You can only make changes to your squad's line up for the upcoming round.")
  end

  def mini_draft_pick_round
    return if round.mini_draft
    errors.add(:base, 'Mini draft picks cannot be performed at this time.')
  end

  def mini_draft_pick_occurring_in_valid_period
    if Time.now > round.deadline_time - 1.day
      errors.add(:base, 'The deadline time for making mini draft picks has passed.')
    end
  end

  def fpl_team_turn
    return if mini_draft_pick_hash[:next_fpl_team] == fpl_team
    errors.add(:base, 'You cannot pass out of turn.')
  end

  def authorised_user
    return if fpl_team.user == user
    errors.add(:base, 'You are not authorised to make changes to this team.')
  end

  def season
    mini_draft_pick_hash[:season]
  end
end

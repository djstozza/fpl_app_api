class WaiverPicks::Base < ApplicationInteraction
  object :user, class: User
  object :fpl_team_list, class: FplTeamList

  delegate :round, :fpl_team, :waiver_picks, to: :fpl_team_list
  delegate :league, to: :fpl_team

  validate :authorised_user
  validate :round_is_current
  validate :not_first_round
  validate :valid_time_period

  run_in_transaction!

  def fpl_team_list_hash
    FplTeamLists::Hash.run(
      fpl_team_list: fpl_team_list,
      user: user,
      show_waiver_picks: true,
      user_owns_fpl_team: fpl_team.user == user,
    ).result
  end

  private

  def authorised_user
    return if fpl_team.user == user
    errors.add(:base, 'You are not authorised to make changes to this team.')
  end

  def round_is_current
    return if round == Round.current
    errors.add(:base, "You can only make changes to your squad's line up for the upcoming round.")
  end

  def not_first_round
    return if round != Round.first
    errors.add(:base, 'There are no waiver picks during the first round.')
  end

  def valid_time_period
    if Time.now > round.deadline_time - 1.day
      errors.add(:base, 'The waiver pick deadline for this round has passed.')
    end
  end
end

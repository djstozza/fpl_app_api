class WaiverPicks::Base < ApplicationInteraction
  object :user, class: User
  object :fpl_team_list, class: FplTeamList

  object :round, class: Round, default: -> { fpl_team_list.round }
  object :fpl_team, class: FplTeam, default: -> { fpl_team_list.fpl_team }
  array :waiver_picks, default: -> { fpl_team_list.waiver_picks }
  object :league, class: League, default: -> { fpl_team.league }

  validate :authorised_user
  validate :round_is_current
  validate :not_first_round
  validate :valid_time_period

  run_in_transaction!

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

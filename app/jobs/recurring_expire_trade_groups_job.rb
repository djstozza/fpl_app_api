class RecurringExpireTradeGroupsJob < ApplicationInteraction
  def execute
    round = Round.current

    return if Time.now.utc.to_date != round.deadline_time.to_date
    return if InterTeamTradeGroup.where(round: round, status: ['submitted', 'pending']).blank?

    ::InterTeamTradeGroups::Expire.delay(wait_until: round.deadline_time).run
  end
end

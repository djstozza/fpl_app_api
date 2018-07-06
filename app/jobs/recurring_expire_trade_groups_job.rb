class RecurringExpireTradeGroupsJob < ApplicationInteraction
  def execute
    round = Round.current
    return if Time.now.utc.to_date != round.deadline_time.to_date
    return if InterTeamTradeGroup.where(round: round).pending.blank?

    ::InterTeamTradeGroups::Expire.delay(wait_until: deadline_time).run
  end
end

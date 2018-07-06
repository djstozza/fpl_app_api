class InterTeamTradeGroups::Expire < ApplicationInteraction
  def execute
    round = Round.current
    return if Time.now < round.deadline_time

    InterTeamTradeGroup.where(status: ['pending', 'submitted'], round: round).update_all(status: 'expired')
  end
end

class InterTeamTradeGroups::Expire < ApplicationInteraction
  def execute
    InterTeamTradeGroup.where(status: ['pending', 'submitted']).update_all(status: 'expired')
  end
end

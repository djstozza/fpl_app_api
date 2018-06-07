class FplTeamTradeBroadcastJob < ApplicationJob
  queue_as :default

  def perform(params)
    FplTeams::Broadcast.run!(params)
  end
end

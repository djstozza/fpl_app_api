class DraftPickBroadcastJob < ApplicationJob
  queue_as :default

  def perform(league, user, player)
    DraftPicks::Broadcast.run(league: league, user: user, player: player)
  end
end

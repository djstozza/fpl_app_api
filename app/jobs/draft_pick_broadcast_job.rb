class DraftPickBroadcastJob < ApplicationJob
  queue_as :default

  def perform(league, user, player, mini_draft)
    DraftPicks::Broadcast.run(league: league, user: user, player: player, mini_draft: mini_draft)
  end
end

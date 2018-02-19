require 'sidekiq'
require 'sidekiq-scheduler'

class RecurringBroadcastCurrentRoundWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform
    Rounds::BroadcastCurrentRound.run!
  end
end

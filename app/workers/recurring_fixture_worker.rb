require 'sidekiq'
require 'sidekiq-scheduler'

class RecurringFixtureWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform
    Fixtures::Populate.run!
    Rounds::BroadcastCurrentRound.run!
  end
end

require 'sidekiq'
require 'sidekiq-scheduler'

class RecurringPlayerWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform
    Players::Populate.run!
  end
end

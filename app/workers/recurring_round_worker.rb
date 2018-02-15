require 'sidekiq'
require 'sidekiq-scheduler'

class RecurringRoundWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform
    Rounds::Populate.run!
  end
end

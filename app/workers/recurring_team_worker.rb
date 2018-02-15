require 'sidekiq'
require 'sidekiq-scheduler'

class RecurringTeamWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform
    Teams::Populate.run!
  end
end

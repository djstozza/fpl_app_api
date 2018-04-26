require 'sidekiq'

class ProcessWaiverPicksWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform
    WaiverPicks::Process.run!
  end
end

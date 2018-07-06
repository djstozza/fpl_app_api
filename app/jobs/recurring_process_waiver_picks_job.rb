class RecurringProcessWaiverPicksJob < ApplicationInteraction
  def execute
    round = Round.current
    waiver_cutoff = round.deadline_time - 1.day

    return if Time.now.utc.to_date != waiver_cutoff.to_date
    return if WaiverPick.where(round: round, status: 'pending').blank?

    ::WaiverPicks::Process.delay(wait_until: waiver_cutoff).run
  end
end

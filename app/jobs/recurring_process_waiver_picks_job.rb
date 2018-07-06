class RecurringProcessWaiverPicksJob < ApplicationInteraction
  def execute
    round = Round.current
    return if WaiverPick.pending.where(round: round).empty?
    waiver_cutoff = round.deadline_time - 1.day

    return if Time.now.utc.to_date != waiver_cutoff.to_date
    ::WaiverPicks::Process.delay(wait_until: waiver_cutoff).run
  end
end

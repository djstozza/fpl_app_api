class WaiverPicks::Delete < WaiverPicks::Base
  object :waiver_pick, class: WaiverPick

  validate :pending_waiver_pick
  validate :fpl_team_list_waiver_pick

  def execute
    waiver_picks.where('pick_number > ?', waiver_pick.pick_number).each do |waiver_pick|
      waiver_pick.update(pick_number: waiver_pick.pick_number - 1)
      errors.merge!(waiver_pick.errors)
    end

    waiver_pick.destroy
  end

  private

  def pending_waiver_pick
    return if waiver_pick.pending?
    errors.add(:base, 'You can only delete pending waiver picks.')
  end

  def fpl_team_list_waiver_pick
    return if fpl_team_list.waiver_picks.include?(waiver_pick)
    errors.add(:base, 'This waiver pick does not belong to your team.')
  end
end

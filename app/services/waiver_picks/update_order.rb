class WaiverPicks::UpdateOrder < WaiverPicks::Base
  object :waiver_pick, class: WaiverPick

  integer :pick_number

  validate :fpl_team_list_waiver_pick
  validate :pending_waiver_pick
  validate :valid_pick_number
  validate :change_in_pick_number

  def execute
    if waiver_pick.pick_number > pick_number
      waiver_picks.where(
        'pick_number >= :new_pick_number AND pick_number <= :old_pick_number',
        new_pick_number: pick_number,
        old_pick_number: waiver_pick.pick_number,
      ).each do |pick|
        pick.update(pick_number: pick.pick_number + 1)
        errors.merge!(pick.errors)
      end
    elsif waiver_pick.pick_number < pick_number
      waiver_picks.where(
        'pick_number <= :new_pick_number AND pick_number >= :old_pick_number',
        new_pick_number: pick_number,
        old_pick_number: waiver_pick.pick_number,
      ).each do |pick|
        pick.update(pick_number: pick.pick_number - 1)
        errors.merge!(pick.errors)
      end
    end

    waiver_pick.update(pick_number: pick_number)
    errors.merge!(waiver_pick.errors)

    waiver_pick
  end

  private

  def fpl_team_list_waiver_pick
    return if waiver_picks.include?(waiver_pick)
    errors.add(:base, 'This waiver pick does not belong to your team.')
  end

  def pending_waiver_pick
    return if waiver_pick.pending?
    errors.add(:base, 'You can only edit pending waiver picks.')
  end

  def valid_pick_number
    return if waiver_picks.map { |pick| pick.pick_number }.include?(pick_number)
    errors.add(:base, 'Pick number is invalid.')
  end

  def change_in_pick_number
    return if waiver_pick.pick_number != pick_number
    errors.add(:base, 'No change in pick number.')
  end
end

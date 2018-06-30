class WaiverPicks::Process < ApplicationInteraction
  object :round, class: Round, default: -> { Round.current }

  def execute
    return if Time.now < round.deadline_time - 1.day
    League.active.each do |league|
      waiver_groups(league).each do |_k, waiver_group|
        waiver_group_sorted_by_fpl_team(waiver_group).each do |waiver_pick|
          compose(WaiverPicks::Approve, waiver_pick: waiver_pick)
        end
      end

      league.waiver_picks.where(round: round).pending.update_all(status: 'declined')
    end
  end

  private

  def waiver_groups(league)
    league.waiver_picks.where(round: round).group_by { |pick| pick.pick_number }.sort
  end

  def waiver_group_sorted_by_fpl_team(waiver_group)
    waiver_group.sort do |a, b|
      b.fpl_team.rank <=> a.fpl_team.rank
    end
  end
end

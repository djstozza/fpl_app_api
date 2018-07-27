class WaiverPicks::Process < ApplicationInteraction
  object :round, class: Round, default: -> { Round.current }

  def execute
    return if Time.now < round.deadline_time - 1.day
    League.active.each do |league|
      pick_number_arr = league.waiver_picks.where(round: round).pluck(:pick_number).uniq
      pick_number_arr.each do |pick_number|
        waiver_group(league, pick_number).each { |waiver_pick| compose(WaiverPicks::Approve, waiver_pick: waiver_pick) }
      end

      league.waiver_picks.where(round: round).pending.update_all(status: 'declined')
    end
  end

  private

  def waiver_group(league, pick_number)
    league.waiver_picks
      .pending
      .joins(:fpl_team_list)
      .joins('JOIN fpl_teams ON fpl_team_lists.fpl_team_id = fpl_teams.id')
      .where(round: round, pick_number: pick_number)
      .order('fpl_team_lists.overall_rank DESC, fpl_team_lists.rank DESC, fpl_teams.mini_draft_pick_number ASC')
  end
end

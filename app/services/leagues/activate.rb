class Leagues::Activate < ApplicationInteraction
  object :league, class: League

  delegate :draft_picks, :fpl_teams, to: :league

  run_in_transaction!

  def execute
    return unless league.draft?
    return if draft_picks.where(player: nil, mini_draft: false).any?
    mini_draft_arr = draft_picks.where(mini_draft: true).order(:pick_number).pluck(:fpl_team_id)

    fpl_teams.each do |fpl_team|
      compose(::FplTeams::ProcessInitialLineUp, fpl_team: fpl_team)
      fpl_team.update(mini_draft_pick_number: (mini_draft_arr.index(fpl_team.id) + 1))
    end

    league.update(status: 'active')
    errors.merge!(league.errors)

    league
  end
end

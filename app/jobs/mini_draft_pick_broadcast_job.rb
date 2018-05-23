class MiniDraftPickBroadcastJob < ApplicationJob
  queue_as :default

  def perform(league, fpl_team_list, user, out_player, in_player, passed)
    MiniDraftPicks::Broadcast.run!(
      league: league,
      fpl_team_list: fpl_team_list,
      user: user,
      out_player: out_player,
      in_player: in_player,
      passed: passed,
    )
  end
end

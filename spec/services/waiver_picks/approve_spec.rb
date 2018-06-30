require 'rails_helper'

RSpec.describe WaiverPicks::Approve do
  it 'approves the waiver_pick' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)

    league = FactoryBot.create(:league, status: 'active')

    fpl_team = FactoryBot.create(:fpl_team, league: league, rank: 1)
    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
    list_position = FactoryBot.create(:list_position, :fwd, fpl_team_list: fpl_team_list)

    league.players << list_position.player
    fpl_team.players << list_position.player

    waiver_pick = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list,
      out_player: list_position.player,
    )

    described_class.run(waiver_pick: waiver_pick)

    expect(waiver_pick.approved?).to be_truthy
    expect(fpl_team.players).to contain_exactly(waiver_pick.in_player)
    expect(league.players).to contain_exactly(waiver_pick.in_player)
    expect(fpl_team_list.players).to contain_exactly(waiver_pick.in_player)
    expect(list_position.reload.player).to eq(waiver_pick.in_player)
  end
end

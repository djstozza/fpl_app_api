require 'rails_helper'

RSpec.describe WaiverPicks::Process do
  it 'processes the waiver picks' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)

    league = FactoryBot.create(:league, status: 'active')

    in_player_1 = FactoryBot.create(:player, :fwd)
    in_player_2 = FactoryBot.create(:player, :fwd)
    in_player_3 = FactoryBot.create(:player, :fwd)

    out_player_1 = FactoryBot.create(:player, :fwd)
    out_player_2 = FactoryBot.create(:player, :fwd)
    out_player_3 = FactoryBot.create(:player, :fwd)

    fpl_team_1 = FactoryBot.create(:fpl_team, league: league, rank: 1)
    fpl_team_list_1 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_1, round: round)
    list_position_1 = FactoryBot.create(:list_position, :fwd, player: out_player_1, fpl_team_list: fpl_team_list_1)
    fpl_team_1.players << out_player_1

    fpl_team_2 = FactoryBot.create(:fpl_team, league: league, rank: 2)
    fpl_team_list_2 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_2, round: round)
    list_position_2 = FactoryBot.create(:list_position, :fwd, player: out_player_2, fpl_team_list: fpl_team_list_2)
    fpl_team_2.players << out_player_2

    fpl_team_3 = FactoryBot.create(:fpl_team, league: league, rank: 3)
    fpl_team_list_3 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_3, round: round)
    list_position_3 = FactoryBot.create(:list_position, :fwd, player: out_player_3, fpl_team_list: fpl_team_list_3)
    fpl_team_3.players << out_player_3

    league.players += [out_player_1, out_player_2, out_player_3]

    waiver_pick_1 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_1,
      out_player: out_player_1,
      in_player: in_player_1,
      pick_number: 1,
    )

    waiver_pick_2 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_2,
      out_player: out_player_2,
      in_player: in_player_1,
      pick_number: 1,
    )

    waiver_pick_3 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_3,
      out_player: out_player_3,
      in_player: in_player_1,
      pick_number: 1,
    )

    waiver_pick_4 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_1,
      out_player: out_player_1,
      in_player: in_player_2,
      pick_number: 2,
    )

    waiver_pick_5 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_2,
      out_player: out_player_2,
      in_player: in_player_3,
      pick_number: 2,
    )

    waiver_pick_6 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_2,
      out_player: out_player_2,
      in_player: in_player_2,
      pick_number: 3,
    )

    described_class.run!

    # waiver_pick_1, waiver_pick_2 and waiver_pick_3 all have a pick_number of 1
    # waiver_pick_3 is processed first because fpl_team_3 has the lowest rank (3) - gets approved
    # waiver_pick_2 is processed next because fpl_team_2 has the next highest rank (2)
    #   - gets declined because in_player_1 was already incorporated into fpl_team_3 when waiver_pick_3 was approved
    # waiver_pick_1 is processed next because fpl_team_1 hash the highest rank (1)
    #   - gets declined because in_player_1 was already incorporated into fpl_team_3 when waiver_pick_3 was approved
    expect(waiver_pick_1.reload.declined?).to be_truthy
    expect(waiver_pick_2.reload.declined?).to be_truthy
    expect(waiver_pick_3.reload.approved?).to be_truthy

    # waiver_pick_4 and waiver_pick_5 both have a pick_number of 2
    # waiver_pick_5 gets processed first because fpl_team_2 rank > fpl_team_1 rank - gets approved
    # waiver_pick_4 also gets approved
    expect(waiver_pick_4.reload.approved?).to be_truthy
    expect(waiver_pick_5.reload.approved?).to be_truthy

    # waiver_pick_6 has a pick_number of 3
    # waiver_pick_6 gets declined because in_player_2 was already incorporated into fpl_team_1 when waiver_pick_4
    #   was approved
    expect(waiver_pick_6.reload.declined?).to be_truthy

    expect(fpl_team_1.players.reload).to contain_exactly(in_player_2)
    expect(fpl_team_list_1.players.reload).to contain_exactly(in_player_2)
    expect(list_position_1.reload.player).to eq(in_player_2)

    expect(fpl_team_2.players.reload).to contain_exactly(in_player_3)
    expect(fpl_team_list_2.players.reload).to contain_exactly(in_player_3)
    expect(list_position_2.reload.player).to eq(in_player_3)

    expect(fpl_team_3.players.reload).to contain_exactly(in_player_1)
    expect(fpl_team_list_3.players.reload).to contain_exactly(in_player_1)
    expect(list_position_3.reload.player).to eq(in_player_1)

    expect(league.players.reload).to contain_exactly(in_player_1, in_player_2, in_player_3)
  end

  it 'does not process waiver picks prior to the waiver_pick cut_off time' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now + 1.minute)

    league = FactoryBot.create(:league, status: 'active')

    fpl_team = FactoryBot.create(:fpl_team, league: league, rank: 1)
    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
    list_position = FactoryBot.create(:list_position, :fwd, fpl_team_list: fpl_team_list)

    fpl_team.players << list_position.player
    league.players << list_position.player

    FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list,
      out_player: list_position.player,
    )

    expect_not_to_run(WaiverPicks::Approve)

    described_class.run!
  end
end

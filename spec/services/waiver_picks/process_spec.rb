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
    out_player_4 = FactoryBot.create(:player, :fwd)
    out_player_5 = FactoryBot.create(:player, :fwd)

    fpl_team_1 = FactoryBot.create(:fpl_team, league: league, rank: 1, mini_draft_pick_number: 5)
    fpl_team_list_1 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_1, round: round, rank: 1, overall_rank: 1)
    FactoryBot.create(:list_position, :fwd, player: out_player_1, fpl_team_list: fpl_team_list_1)
    fpl_team_1.players << out_player_1

    fpl_team_2 = FactoryBot.create(:fpl_team, league: league, rank: 2, mini_draft_pick_number: 4)
    fpl_team_list_2 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_2, round: round, rank: 2, overall_rank: 2)
    FactoryBot.create(:list_position, :fwd, player: out_player_2, fpl_team_list: fpl_team_list_2)
    fpl_team_2.players << out_player_2

    fpl_team_3 = FactoryBot.create(:fpl_team, league: league, rank: 2, mini_draft_pick_number: 3)
    fpl_team_list_3 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_3, round: round, rank: 3, overall_rank: 2)
    list_position_3 = FactoryBot.create(:list_position, :fwd, player: out_player_3, fpl_team_list: fpl_team_list_3)
    fpl_team_3.players << out_player_3

    fpl_team_4 = FactoryBot.create(:fpl_team, league: league, rank: 2, mini_draft_pick_number: 2)
    fpl_team_list_4 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_4, round: round, rank: 3, overall_rank: 2)
    list_position_4 = FactoryBot.create(:list_position, :fwd, player: out_player_4, fpl_team_list: fpl_team_list_4)
    fpl_team_4.players << out_player_4

    fpl_team_5 = FactoryBot.create(:fpl_team, league: league, rank: 5, mini_draft_pick_number: 1)
    fpl_team_list_5 = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_5, round: round, rank: 5, overall_rank: 5)
    list_position_5 = FactoryBot.create(:list_position, :fwd, player: out_player_5, fpl_team_list: fpl_team_list_5)
    fpl_team_5.players << out_player_5

    league.players += [out_player_1, out_player_2, out_player_3, out_player_4, out_player_5]

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
      fpl_team_list: fpl_team_list_4,
      out_player: out_player_4,
      in_player: in_player_1,
      pick_number: 1,
    )

    waiver_pick_5 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_5,
      out_player: out_player_5,
      in_player: in_player_1,
      pick_number: 1,
    )

    waiver_pick_6 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_2,
      out_player: out_player_2,
      in_player: in_player_2,
      pick_number: 2,
    )

    waiver_pick_7 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_3,
      out_player: out_player_3,
      in_player: in_player_2,
      pick_number: 2,
    )

    waiver_pick_8 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_4,
      out_player: out_player_4,
      in_player: in_player_2,
      pick_number: 2,
    )

    waiver_pick_9 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_2,
      out_player: out_player_2,
      in_player: in_player_3,
      pick_number: 3,
    )

    waiver_pick_10 = FactoryBot.create(
      :waiver_pick,
      round: round,
      league: league,
      fpl_team_list: fpl_team_list_3,
      out_player: out_player_3,
      in_player: in_player_3,
      pick_number: 3,
    )

    described_class.run!

    # waiver_picks 1-5 have a pick_number of 1 and are trying to trade in in_player_1
    # waiver_pick_5 is processed first because fpl_team_list_5 has the lowest overall rank (5) - gets approved
    # waiver_picks 1-4 are declined since in_player_1 is taken

    # waiver_picks 6-8 have a pick_number of 2 and are trying to trade in in_player_2
    # waiver_pick_8 is processed first:
    # - While fpl_team_listss 2-4 have the same overall rank (2), waiver_pick 6 gets processed last
    #   since fpl_team_list_2 has the highest round rank (2)
    # - While fpl_team_lists 3-4 have the same round rank (3), fpl_team_4 has the higher mini_draft_pick_number (2)
    #   and is therefore processed first - gets approved.
    # waiver_picks 6 and 7 are both declined since in_player_2 is taken

    # waiver_picks 9-10 both have a pick_number of 3 and are trying to trade in in_player_3
    # waiver_pick_10 is processed first since fpl_team_list_3 has a lower round rank (3) - gets approved

    expect(WaiverPick.approved).to contain_exactly(waiver_pick_5.reload, waiver_pick_8.reload, waiver_pick_10.reload)
    expect(WaiverPick.declined).to contain_exactly(
      waiver_pick_1.reload,
      waiver_pick_2.reload,
      waiver_pick_3.reload,
      waiver_pick_4.reload,
      waiver_pick_6.reload,
      waiver_pick_7.reload,
      waiver_pick_9.reload,
    )

    expect(fpl_team_5.players.reload).to contain_exactly(in_player_1)
    expect(fpl_team_list_5.players.reload).to contain_exactly(in_player_1)
    expect(list_position_5.reload.player).to eq(in_player_1)

    expect(fpl_team_4.players.reload).to contain_exactly(in_player_2)
    expect(fpl_team_list_4.players.reload).to contain_exactly(in_player_2)
    expect(list_position_4.reload.player).to eq(in_player_2)

    expect(fpl_team_3.players.reload).to contain_exactly(in_player_3)
    expect(fpl_team_list_3.players.reload).to contain_exactly(in_player_3)
    expect(list_position_3.reload.player).to eq(in_player_3)

    expect(league.reload.players).to contain_exactly(in_player_1, in_player_2, in_player_3, out_player_1, out_player_2)
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

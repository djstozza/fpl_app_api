require 'rails_helper'

RSpec.describe WaiverPicks::Create do
  it 'creates a waiver_pick' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(round).at_least(1)

    current_round = FactoryBot.create(:round, is_current: true, deadline_time: 3.days.from_now)

    fpl_team_list = FactoryBot.create(:fpl_team_list, round: current_round)
    list_position = FactoryBot.create(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.create(:player, :fwd)

    result = described_class.run!(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )

    expect(result.pick_number).to eq(1)
    expect(result.pending?).to be_truthy
    expect(result.in_player).to eq(player)
    expect(result.out_player).to eq(list_position.player)
    expect(result.round).to eq(current_round)
    expect(result.league).to eq(result.fpl_team.league)
  end

  it '#not_first_round' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:first).and_return(round).at_least(1)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :fwd)

    expect(fpl_team_list).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("There are no waiver picks during the first round.")
  end

  it '#round_is_current' do
    round = FactoryBot.build_stubbed(:round, is_current: false, deadline_time: 3.days.from_now)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :fwd)

    expect(fpl_team_list).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only make changes to your squad's line up for the upcoming round.")
  end

  it '#valid_time_period' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :fwd)

    expect(fpl_team_list).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("The waiver pick deadline for this round has passed.")
  end

  it '#authorised_user' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :fwd)

    user = FactoryBot.build_stubbed(:user)

    expect(fpl_team_list).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to make changes to this team.")
  end

  it '#in_player_unpicked' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :fwd)

    expect(fpl_team_list).to receive(:players).and_return([list_position.player]).at_least(1)
    expect(player).to receive(:leagues).and_return([league]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("The player you are trying to trade into your team is owned by another team in your league.")
  end

  it '#same_positions' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :mid)

    expect(fpl_team_list).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You can only trade players that have the same positions.")
  end

  it '#maximum_number_of_players_from_team' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :fwd)

    expect(fpl_team_list).to receive(:players).and_return([
      list_position.player,
      FactoryBot.build_stubbed(:player, team: player.team),
      FactoryBot.build_stubbed(:player, team: player.team),
      FactoryBot.build_stubbed(:player, team: player.team),
    ]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You can't have more than 3 players from the same team (#{player.team.name}).")
  end

  it '#duplicate_waiver_picks' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :fwd)

    waiver_pick = FactoryBot.build_stubbed(
      :waiver_pick,
      league: league,
      round: round,
      fpl_team_list: fpl_team_list,
      in_player: player,
      out_player: list_position.player,
    )

    expect(fpl_team_list).to receive(:players).and_return([list_position.player]).at_least(1)
    expect(fpl_team_list.waiver_picks).to receive(:find_by).and_return(waiver_pick)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )

    expect(outcome.errors.full_messages).to contain_exactly(
      "Duplicate waiver pick - (Pick number: #{waiver_pick.pick_number} " \
      "Out: #{list_position.player.decorate.name} " \
      "In: #{player.decorate.name})."
    )
  end

  it '#out_player_in_fpl_team_list' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 3.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: fpl_team, round: round)

    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)
    player = FactoryBot.build_stubbed(:player, :fwd)

    outcome = described_class.run(
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
      user: fpl_team_list.user,
    )
    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only trade out players that are part of your team.")
  end
end

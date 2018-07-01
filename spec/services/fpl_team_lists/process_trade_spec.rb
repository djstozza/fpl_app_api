require 'rails_helper'

RSpec.describe FplTeamLists::ProcessTrade do
  it 'is valid' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)
    league = FactoryBot.create(:league)
    fpl_team = FactoryBot.create(:fpl_team, league: league)
    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
    list_position = FactoryBot.create(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)

    fpl_team.players << list_position.player
    league.players << list_position.player

    player = FactoryBot.create(:player)

    result = described_class.run!(user: fpl_team_list.user, list_position: list_position, in_player: player)

    expect(result.player).to eq(player)
    expect(fpl_team_list.players).to contain_exactly(player)
    expect(fpl_team.players).to contain_exactly(player)
    expect(league.players).to contain_exactly(player)
  end

  it '#authorised_user' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([list_position.player]).at_least(1)

    player = FactoryBot.build_stubbed(:player)

    user = FactoryBot.build_stubbed(:user)

    outcome = described_class.run(user: user, list_position: list_position, in_player: player)

    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to make changes to this team.")
  end

  it '#in_player_unpicked' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)

    player = FactoryBot.build_stubbed(:player)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([list_position.player]).at_least(1)
    expect(fpl_team_list.league).to receive(:players).and_return([list_position.player, player]).at_least(1)

    outcome = described_class.run(user: fpl_team_list.user, list_position: list_position, in_player: player)

    expect(outcome.errors.full_messages)
      .to contain_exactly("The player you are trying to trade into your team is owned by another team in your league.")
  end

  it '#trade_occurring_in_valid_period - before waiver cutoff' do
    first_round = FactoryBot.build_stubbed(:round, is_current: false, deadline_time: 1.week.ago)
    expect(Round).to receive(:first).and_return(first_round).at_least(1)

    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)

    player = FactoryBot.build_stubbed(:player)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(user: fpl_team_list.user, list_position: list_position, in_player: player)
    expect(outcome.errors.full_messages)
      .to contain_exactly("You cannot trade players until the waiver cutoff time has passed.")
  end

  it '#trade_occurring_in_valid_period - deadline_time passed' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: Time.now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)

    player = FactoryBot.build_stubbed(:player)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(user: fpl_team_list.user, list_position: list_position, in_player: player)
    expect(outcome.errors.full_messages).to contain_exactly("The deadline time for making trades has passed.")
  end

  it '#same_positions' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)

    player = FactoryBot.build_stubbed(:player, :mid)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(user: fpl_team_list.user, list_position: list_position, in_player: player)
    expect(outcome.errors.full_messages).to contain_exactly("You can only trade players that have the same positions.")
  end

  it '#round_is_current' do
    round = FactoryBot.build_stubbed(:round, is_current: false, deadline_time: 1.day.from_now)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)

    player = FactoryBot.build_stubbed(:player)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([list_position.player]).at_least(1)

    outcome = described_class.run(user: fpl_team_list.user, list_position: list_position, in_player: player)
    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only make changes to your squad's line up for the upcoming round.")
  end

  it '#maximum_number_of_players_from_team' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)

    player = FactoryBot.build_stubbed(:player)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([
      list_position.player,
      FactoryBot.build_stubbed(:player, team: player.team),
      FactoryBot.build_stubbed(:player, team: player.team),
      FactoryBot.build_stubbed(:player, team: player.team),
    ]).at_least(1)

    outcome = described_class.run(user: fpl_team_list.user, list_position: list_position, in_player: player)
    expect(outcome.errors.full_messages)
      .to contain_exactly("You can't have more than 3 players from the same team (#{player.team.name}).")
  end
end

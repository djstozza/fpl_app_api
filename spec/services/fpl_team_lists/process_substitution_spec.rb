require 'rails_helper'

RSpec.describe FplTeamLists::ProcessSubstitution do
  it 'is valid' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)
    substitute_list_position = FactoryBot.build_stubbed(:list_position, :fwd, :s1, fpl_team_list: fpl_team_list)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([
      list_position.player, substitute_list_position.player,
    ]).at_least(1)

    expect_any_instance_of(ListPositionDecorator).to receive(:substitute_options).and_return([
      substitute_list_position.player_id
    ])

    expect(list_position).to receive(:save)
    expect(substitute_list_position).to receive(:save)

    described_class.run(
      list_position: list_position,
      substitute_list_position: substitute_list_position,
      user: fpl_team_list.user
    )

    expect(list_position.substitute_1?).to be_truthy
    expect(substitute_list_position.starting?).to be_truthy
  end

  it '#round_is_current' do
    round = FactoryBot.build_stubbed(:round, is_current: false, deadline_time: 7.days.from_now)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)
    substitute_list_position = FactoryBot.build_stubbed(:list_position, :fwd, :s1, fpl_team_list: fpl_team_list)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([
      list_position.player, substitute_list_position.player,
    ]).at_least(1)

    expect_any_instance_of(ListPositionDecorator).to receive(:substitute_options).and_return([
      substitute_list_position.player_id
    ])

    outcome = described_class.run(
      list_position: list_position,
      substitute_list_position: substitute_list_position,
      user: fpl_team_list.user
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only make changes to your squad's line up for the upcoming round.")
  end

  it '#before_deadline_time' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: Time.now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)
    substitute_list_position = FactoryBot.build_stubbed(:list_position, :fwd, :s1, fpl_team_list: fpl_team_list)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([
      list_position.player, substitute_list_position.player,
    ]).at_least(1)

    expect_any_instance_of(ListPositionDecorator).to receive(:substitute_options).and_return([
      substitute_list_position.player_id
    ])

    outcome = described_class.run(
      list_position: list_position,
      substitute_list_position: substitute_list_position,
      user: fpl_team_list.user
    )

    expect(outcome.errors.full_messages).to contain_exactly("The deadline time for making substitutions has passed.")
  end

  it '#authorised_user' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)
    substitute_list_position = FactoryBot.build_stubbed(:list_position, :fwd, :s1, fpl_team_list: fpl_team_list)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([
      list_position.player, substitute_list_position.player,
    ]).at_least(1)


    expect_any_instance_of(ListPositionDecorator).to receive(:substitute_options).and_return([
      substitute_list_position.player_id
    ])

    user = FactoryBot.build_stubbed(:user)

    outcome = described_class.run(
      list_position: list_position,
      substitute_list_position: substitute_list_position,
      user: user
    )

    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to make changes to this team.")
  end

  it '#player_team_presence' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)
    substitute_list_position = FactoryBot.build_stubbed(:list_position, :fwd, :s1, fpl_team_list: fpl_team_list)

    player = FactoryBot.build_stubbed(:player)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([
      player, substitute_list_position.player,
    ]).at_least(1)


    expect_any_instance_of(ListPositionDecorator).to receive(:substitute_options).and_return([
      substitute_list_position.player_id
    ])

    outcome = described_class.run(
      list_position: list_position,
      substitute_list_position: substitute_list_position,
      user: fpl_team_list.user
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("#{list_position.player.decorate.name} isn't part of your team.")
  end

  it '#substitute_player_team_presence' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)
    substitute_list_position = FactoryBot.build_stubbed(:list_position, :fwd, :s1, fpl_team_list: fpl_team_list)

    player = FactoryBot.build_stubbed(:player)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([
      list_position.player, player,
    ]).at_least(1)

    expect_any_instance_of(ListPositionDecorator).to receive(:substitute_options).and_return([
      substitute_list_position.player_id
    ])

    outcome = described_class.run(
      list_position: list_position,
      substitute_list_position: substitute_list_position,
      user: fpl_team_list.user
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("#{substitute_list_position.player.decorate.name} isn't part of your team.")
  end

  it '#valid_starting_line_up' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, round: round)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, :starting, fpl_team_list: fpl_team_list)
    substitute_list_position = FactoryBot.build_stubbed(:list_position, :fwd, :s1, fpl_team_list: fpl_team_list)

    expect(fpl_team_list.fpl_team).to receive(:players).and_return([
      list_position.player, substitute_list_position.player,
    ]).at_least(1)

    expect_any_instance_of(ListPositionDecorator).to receive(:substitute_options).and_return([])

    outcome = described_class.run(
      list_position: list_position,
      substitute_list_position: substitute_list_position,
      user: fpl_team_list.user
    )

    expect(outcome.errors.full_messages).to contain_exactly("Invalid substitution.")
  end
end

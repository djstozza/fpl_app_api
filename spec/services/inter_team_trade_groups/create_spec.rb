require 'rails_helper'

RSpec.describe InterTeamTradeGroups::Create do
  it 'creates an inter_team_trade_group' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([out_player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    expect_any_instance_of(InterTeamTradeGroup).to receive(:save)
    expect_any_instance_of(InterTeamTrade).to receive(:save)

    result = described_class.run!(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position
    )

    expect(result.success).to eq(
      "Successfully created a pending trade - Fpl Team: #{in_fpl_team.name}, Out: #{out_player.decorate.name} " \
        "In: #{in_player.decorate.name}.",
    )

    inter_team_trade_group = result.inter_team_trade_group
    expect(inter_team_trade_group).to be_pending
    expect(inter_team_trade_group.out_fpl_team).to eq(out_fpl_team)
    expect(inter_team_trade_group.in_fpl_team).to eq(in_fpl_team)
    expect(inter_team_trade_group.league).to eq(league)
    expect(inter_team_trade_group.round).to eq(round)

    inter_team_trade = result.inter_team_trade

    expect(inter_team_trade.inter_team_trade_group).to eq(inter_team_trade_group)
    expect(inter_team_trade.out_player).to eq(out_player)
    expect(inter_team_trade.in_player).to eq(in_player)
  end

  it '#round_is_current' do
    round = FactoryBot.build_stubbed(:round, deadline_time: 1.week.from_now)
    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([out_player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only make changes to your squad's line up for the upcoming round.")
  end

  it '#trade_occurring_in_valid_period' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: Time.now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    expect(out_fpl_team).to receive(:players).and_return([out_list_position.player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([in_list_position.player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("The deadline time for making trades this round has passed.")
  end

  it '#authorised_user_out_fpl_team' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([out_player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    user = FactoryBot.build_stubbed(:user)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: user,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to make changes to this team.")
  end

  it '#out_player_in_fpl_team' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    expect(in_fpl_team).to receive(:players).and_return([in_list_position.player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only trade out players that are part of your team.")
  end

  it '#in_player_in_fpl_team' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    expect(out_fpl_team).to receive(:players).and_return([out_list_position.player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You can only propose trades with players that are in that fpl team.")
  end

  it '#identical_player_and_target_positions' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, :mid, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([out_player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You can only trade players that have the same positions.")
  end

  it '#identical_player_and_target_positions' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, :mid, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([out_player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You can only trade players that have the same positions.")
  end

  it '#valid_team_quota_out_fpl_team' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([
      out_player,
      FactoryBot.build_stubbed(:player, team: in_player.team),
      FactoryBot.build_stubbed(:player, team: in_player.team),
      FactoryBot.build_stubbed(:player, team: in_player.team),
    ]).at_least(1)

    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages).to contain_exactly(
      "You can't have more than #{FplTeam::QUOTAS[:team]} players from the same team (#{in_player.team.name}).",
    )
  end

  it '#valid_team_quota_in_fpl_team' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([out_player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([
      in_player,
      FactoryBot.build_stubbed(:player, team: out_player.team),
      FactoryBot.build_stubbed(:player, team: out_player.team),
      FactoryBot.build_stubbed(:player, team: out_player.team),
    ]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages).to contain_exactly(
      "#{in_fpl_team.name} can't have more than #{FplTeam::QUOTAS[:team]} players from the same team " \
      "(#{out_player.team.name})."
    )
  end

  it '#inter_team_trade_group_is_new' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([out_player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    inter_team_trade_group = FactoryBot.build_stubbed(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending'
    )

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages).to contain_exactly("This trade proposal already exists.")
  end

  it '#in_fpl_team_in_league' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    expect(out_fpl_team).to receive(:players).and_return([out_player]).at_least(1)
    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      out_list_position: out_list_position,
      in_list_position: in_list_position,
    )

    expect(outcome.errors.full_messages).to contain_exactly("#{in_fpl_team.name} is not part of your league.")
  end
end

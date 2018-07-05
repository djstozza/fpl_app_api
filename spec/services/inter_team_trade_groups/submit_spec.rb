require 'rails_helper'

RSpec.describe InterTeamTradeGroups::Submit do
  it 'submits the inter_team_trade_group' do
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

    expect(inter_team_trade_group).to receive(:out_players).and_return([out_player]).at_least(1)
    expect(inter_team_trade_group).to receive(:in_players).and_return([in_player]).at_least(1)

    expect_to_delay_run(
      FplTeams::Broadcast,
      with: {
        fpl_team_list: in_fpl_team_list,
        fpl_team: in_fpl_team,
        user: in_fpl_team.user,
        round: round,
        show_trade_groups: true,
      },
    )

    expect(inter_team_trade_group).to receive(:save)

    result = described_class.run!(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
    )

    expect(result.success).to eq("This trade proposal has successfully submitted")
    expect(inter_team_trade_group).to be_submitted
  end

  it '#round_is_current' do
    round = FactoryBot.build_stubbed(:round, is_current: false, deadline_time: 1.week.from_now)

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

    expect(inter_team_trade_group).to receive(:out_players).and_return([out_player]).at_least(1)
    expect(inter_team_trade_group).to receive(:in_players).and_return([in_player]).at_least(1)

    expect_to_not_run_delayed(FplTeams::Broadcast)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
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

    expect(inter_team_trade_group).to receive(:out_players).and_return([out_player]).at_least(1)
    expect(inter_team_trade_group).to receive(:in_players).and_return([in_player]).at_least(1)

    expect_to_not_run_delayed(FplTeams::Broadcast)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
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

    inter_team_trade_group = FactoryBot.build_stubbed(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending'
    )

    expect(inter_team_trade_group).to receive(:out_players).and_return([out_player]).at_least(1)
    expect(inter_team_trade_group).to receive(:in_players).and_return([in_player]).at_least(1)

    user = FactoryBot.build_stubbed(:user)

    expect_to_not_run_delayed(FplTeams::Broadcast)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: user,
      inter_team_trade_group: inter_team_trade_group,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to make changes to this team.")
  end

  it '#inter_team_trade_group_pending' do
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
      status: 'approved'
    )

    expect(inter_team_trade_group).to receive(:out_players).and_return([out_player]).at_least(1)
    expect(inter_team_trade_group).to receive(:in_players).and_return([in_player]).at_least(1)

    expect_to_not_run_delayed(FplTeams::Broadcast)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You can only submit pending trade proposals.")
  end

  it '#no_duplicate_trades' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.create(:league)

    out_fpl_team = FactoryBot.create(:fpl_team, league: league)
    in_fpl_team = FactoryBot.create(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.create(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.create(:list_position, fpl_team_list: in_fpl_team_list)

    out_player = out_list_position.player
    in_player = in_list_position.player

    out_fpl_team.players << out_player
    in_fpl_team.players << in_player

    inter_team_trade_group_1 = FactoryBot.create(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'submitted',
    )

    FactoryBot.create(
      :inter_team_trade,
      out_player: out_player,
      in_player: in_player,
      inter_team_trade_group: inter_team_trade_group_1,
    )

    inter_team_trade_group_2 = FactoryBot.create(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending',
    )

    FactoryBot.create(
      :inter_team_trade,
      out_player: out_player,
      in_player: in_player,
      inter_team_trade_group: inter_team_trade_group_2,
    )

    expect_to_not_run_delayed(FplTeams::Broadcast)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group_2,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You have already proposed this trade.")
  end

  it '#out_players_in_fpl_team' do
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

    expect(in_fpl_team).to receive(:players).and_return([in_player]).at_least(1)

    inter_team_trade_group = FactoryBot.build_stubbed(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending'
    )

    expect(inter_team_trade_group).to receive(:out_players).and_return([out_player]).at_least(1)
    expect(inter_team_trade_group).to receive(:in_players).and_return([in_player]).at_least(1)

    expect_to_not_run_delayed(FplTeams::Broadcast)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("Not all the players in this proposed trade are in the team (#{out_fpl_team.name}).")
  end

  it '#in_players_in_fpl_team' do
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

    inter_team_trade_group = FactoryBot.build_stubbed(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending'
    )

    expect(inter_team_trade_group).to receive(:out_players).and_return([out_player]).at_least(1)
    expect(inter_team_trade_group).to receive(:in_players).and_return([in_player]).at_least(1)

    expect_to_not_run_delayed(FplTeams::Broadcast)

    outcome = described_class.run(
      fpl_team_list: out_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("Not all the players in this proposed trade are in the team (#{in_fpl_team.name}).")
  end
end

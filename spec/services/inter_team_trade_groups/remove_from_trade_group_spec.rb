require 'rails_helper'

RSpec.describe InterTeamTradeGroups::RemoveFromTradeGroup do
  it 'removes inter_team_trades from inter_team_trade_groups' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: 1.day.from_now)

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

    inter_team_trade_group = FactoryBot.create(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending'
    )

    inter_team_trade = FactoryBot.create(
      :inter_team_trade,
      out_player: out_player,
      in_player: in_player,
      inter_team_trade_group: inter_team_trade_group,
    )

    result = described_class.run!(
      fpl_team_list: in_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
      inter_team_trade: inter_team_trade,
    )

    expect(result.success).to eq(
      "Out: #{out_player.decorate.name} - In: #{in_player.decorate.name} has been removed from " \
        "your trade proposal.",
    )
    expect(inter_team_trade_group.inter_team_trades).to be_empty
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

    inter_team_trade_group = FactoryBot.build_stubbed(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending',
    )

    inter_team_trade = FactoryBot.build_stubbed(
      :inter_team_trade,
      out_player: out_list_position.player,
      in_player: in_list_position.player,
      inter_team_trade_group: inter_team_trade_group,
    )

    outcome = described_class.run(
      fpl_team_list: in_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
      inter_team_trade: inter_team_trade,
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

    inter_team_trade_group = FactoryBot.build_stubbed(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending',
    )

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    inter_team_trade = FactoryBot.build_stubbed(
      :inter_team_trade,
      out_player: out_list_position.player,
      in_player: in_list_position.player,
      inter_team_trade_group: inter_team_trade_group,
    )

    outcome = described_class.run(
      fpl_team_list: in_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
      inter_team_trade: inter_team_trade,
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

    inter_team_trade_group = FactoryBot.build_stubbed(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'pending',
    )

    inter_team_trade = FactoryBot.build_stubbed(
      :inter_team_trade,
      out_player: out_list_position.player,
      in_player: in_list_position.player,
      inter_team_trade_group: inter_team_trade_group,
    )

    user = FactoryBot.build_stubbed(:user)

    outcome = described_class.run(
      fpl_team_list: in_fpl_team_list,
      user: user,
      inter_team_trade_group: inter_team_trade_group,
      inter_team_trade: inter_team_trade,
    )

    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to make changes to this team.")
  end

  it '#inter_team_trade_group_unprocessed' do
    round = FactoryBot.build_stubbed(:round, is_current: true, deadline_time: 1.day.from_now)
    expect(Round).to receive(:current).and_return(round)

    league = FactoryBot.build_stubbed(:league)

    out_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    in_fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    out_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: out_fpl_team, round: round)
    in_fpl_team_list = FactoryBot.build_stubbed(:fpl_team_list, fpl_team: in_fpl_team, round: round)

    out_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: out_fpl_team_list)
    in_list_position = FactoryBot.build_stubbed(:list_position, fpl_team_list: in_fpl_team_list)

    inter_team_trade_group = FactoryBot.build_stubbed(
      :inter_team_trade_group,
      league: league,
      out_fpl_team_list: out_fpl_team_list,
      in_fpl_team_list: in_fpl_team_list,
      status: 'approved',
    )

    inter_team_trade = FactoryBot.build_stubbed(
      :inter_team_trade,
      out_player: out_list_position.player,
      in_player: in_list_position.player,
      inter_team_trade_group: inter_team_trade_group,
    )

    outcome = described_class.run(
      fpl_team_list: in_fpl_team_list,
      user: out_fpl_team_list.user,
      inter_team_trade_group: inter_team_trade_group,
      inter_team_trade: inter_team_trade,
    )

    expect(outcome.errors.full_messages)
      .to contain_exactly("You cannot remove picks to this trade proposal as it is no longer pending.")
  end
end

require 'rails_helper'

RSpec.describe MiniDraftPicks::Process do
  it 'creates a mini draft pick' do
    round = FactoryBot.create(:round, mini_draft: true, is_current: true, deadline_time: 2.days.from_now)

    league = FactoryBot.create(:league)
    user = FactoryBot.create(:user)
    player_1 = FactoryBot.create(:player, :fwd)

    fpl_team_1 = FactoryBot.create(:fpl_team, league: league, user: user, mini_draft_pick_number: 1)
    fpl_team_1.players << player_1
    league.players << player_1

    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team_1, round: round)
    list_position = FactoryBot.create(:list_position, :fwd, player: player_1, fpl_team_list: fpl_team_list)

    fpl_team_2 = FactoryBot.create(:fpl_team, league: league, mini_draft_pick_number: 2)

    player_2 = FactoryBot.create(:player)

    expect_to_delay_run(
      MiniDraftPicks::Broadcast,
      with: {
        league: league,
        fpl_team_list: fpl_team_list,
        user: user,
        out_player: player_1,
        in_player: player_2,
      }
    )

    outcome = described_class.run(
      league: league,
      user: user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player_2,
    )

    result = outcome.result

    # Creates the mini draft pick
    expect(result.pick_number).to eq(MiniDraftPick.count)
    expect(result.season).to eq('summer')
    expect(result.in_player).to eq(player_2)
    expect(result.out_player).to eq(player_1)
    expect(result.passed).to be_falsy
    expect(result.fpl_team).to eq(fpl_team_1)

    # Updates the list_position, fpl_team, league
    expect(list_position.player).to eq(player_2)
    expect(fpl_team_list.players).to include(player_2)
    expect(fpl_team_list.players).not_to include(player_1)
    expect(fpl_team_1.players).to include(player_2)
    expect(fpl_team_1.players).not_to include(player_1)
    expect(league.players).to include(player_2)
    expect(league.players).not_to include(player_1)

    # Valid mini draft pick hash
    mini_draft_pick_hash = outcome.mini_draft_pick_hash
    expect(mini_draft_pick_hash[:next_fpl_team]).to eq(fpl_team_2)
    expect(mini_draft_pick_hash[:current_mini_draft_pick_user]).to eq(fpl_team_2.user)
    expect(mini_draft_pick_hash[:mini_draft_picks].pluck(:id)).to include(result.id)

    current_mini_draft_pick = mini_draft_pick_hash[:current_mini_draft_pick]
    expect(current_mini_draft_pick.pick_number).to eq(MiniDraftPick.count + 1)
    expect(current_mini_draft_pick.fpl_team).to eq(fpl_team_2)
  end

  it 'fails if the deadline_time has passed' do
    round = FactoryBot.build_stubbed(
      :round,
      mini_draft: true,
      is_current: true,
      deadline_time: 1.day.from_now
    )
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)

    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :fwd)

    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages).to include("The deadline time for making mini draft picks has passed.")
  end

  it 'fails if the round is not current' do
    round = FactoryBot.build_stubbed(:round, mini_draft: true, is_current: false)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :fwd)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages).to include(
      "You can only make changes to your squad's line up for the upcoming round.",
    )
  end

  it 'fails if the fpl_team_list round is not a mini_draft round' do
    round = FactoryBot.build_stubbed(:round, mini_draft: false, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :fwd)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages).to include("Mini draft picks cannot be performed at this time.")
  end

  it 'fails if the player is owned by another fpl team in the league' do
    round = FactoryBot.build_stubbed(:round, mini_draft: true, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :fwd)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    expect(player).to receive(:leagues).and_return([league])

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages)
      .to include("The player you are trying to trade into your team is owned by another team in your league.")
  end

  it 'fails if the in_player position is not the same as the out_player position' do
    round = FactoryBot.build_stubbed(:round, mini_draft: true, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :mid)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages).to include("You can only trade players that have the same positions.")
  end

  it 'fails if the fpl team has made consecutive passes' do
    round = FactoryBot.build_stubbed(:round, mini_draft: true, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :fwd)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)
    expect_any_instance_of(described_class).to receive(:consecutive_passes).and_return(true)

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages)
      .to include("You have already passed and will not be able to make any more mini draft picks.")
  end

  it 'fails if the fpl team is not the next fpl team' do
    round = FactoryBot.build_stubbed(:round, mini_draft: true, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :fwd)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    allow_any_instance_of(described_class)
      .to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: double(FplTeam) })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages).to include("You cannot pick out of turn.")
  end

  it 'fails if the user does not own the fpl team' do
    round = FactoryBot.build_stubbed(:round, mini_draft: true, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    user = FactoryBot.build_stubbed(:user)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :fwd)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)

    outcome = described_class.run(
      league: league,
      user: user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages).to include("You are not authorised to make changes to this team.")
  end

  it 'fails if the fpl team already has the maximum quota of players from one team' do
    round = FactoryBot.build_stubbed(:round, mini_draft: true, is_current: true, deadline_time: 2.days.from_now)
    expect(Round).to receive(:current).and_return(round).at_least(1)

    league = FactoryBot.build_stubbed(:league)
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    fpl_team_list = FactoryBot.build_stubbed(
      :fpl_team_list,
      fpl_team: fpl_team,
      round: round,
    )

    player = FactoryBot.build_stubbed(:player, :fwd)
    list_position = FactoryBot.build_stubbed(:list_position, :fwd, fpl_team_list: fpl_team_list)

    allow_any_instance_of(described_class).to receive(:mini_draft_pick_hash).and_return({ next_fpl_team: fpl_team })
    allow_any_instance_of(described_class).to receive(:player_in_fpl_team).and_return(true)
    expect(fpl_team).to receive(:players).and_return([
      double(Player, team_id: player.team_id),
      double(Player, team_id: player.team_id),
      double(Player, team_id: player.team_id),
      list_position.player,
    ]).at_least(1)

    outcome = described_class.run(
      league: league,
      user: fpl_team.user,
      fpl_team_list: fpl_team_list,
      list_position: list_position,
      in_player: player,
    )

    expect(outcome.errors.full_messages)
      .to include("You can't have more than 3 players from the same team (#{player.team.name}).")
  end
end

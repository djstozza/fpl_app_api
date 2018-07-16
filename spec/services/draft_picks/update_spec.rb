require 'rails_helper'

RSpec.describe DraftPicks::Update do
  it 'adds a player' do
    league = FactoryBot.create(:league, status: 'draft')
    fpl_team = FactoryBot.create(:fpl_team, league: league)
    draft_pick = FactoryBot.create(:draft_pick, fpl_team: fpl_team, league: league)

    player = FactoryBot.create(:player)

    expect_to_run(
      Leagues::Activate,
      with: { league: league },
    )
    expect_to_delay_run(
      DraftPicks::Broadcast,
      with: {
        league: league,
        user: draft_pick.user,
        player: player,
        mini_draft: false,
      },
    )

    described_class.run!(league: league, draft_pick: draft_pick, user: draft_pick.user, player: player)

    expect(draft_pick.player).to eq(player)
    expect(fpl_team.players).to contain_exactly(player)
    expect(league.players).to contain_exactly(player)
  end

  it 'with a mini draft pick' do
    league = FactoryBot.create(:league, status: 'draft')
    fpl_team = FactoryBot.create(:fpl_team, league: league)
    mini_draft = true
    draft_pick = FactoryBot.create(:draft_pick, fpl_team: fpl_team, league: league)

    expect_to_run(
      Leagues::Activate,
      with: { league: league },
    )
    expect_to_delay_run(
      DraftPicks::Broadcast,
      with: {
        league: league,
        user: draft_pick.user,
        player: nil,
        mini_draft: mini_draft,
      },
    )

    described_class.run!(league: league, draft_pick: draft_pick, user: draft_pick.user, mini_draft: mini_draft)
    expect(draft_pick.mini_draft).to eq(mini_draft)
  end

  it '#authorised_user' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)
    user = FactoryBot.build_stubbed(:user)

    player = FactoryBot.build_stubbed(:player)

    expect(league.decorate).to receive(:current_draft_pick).and_return(draft_pick)

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: user, player: player)
    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to update this draft pick.")
  end

  it '#draft_pick_current' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)

    player = FactoryBot.build_stubbed(:player)

    expect(league.decorate).to receive(:current_draft_pick).and_return(double(DraftPick))

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: fpl_team.user, player: player)
    expect(outcome.errors.full_messages).to contain_exactly("You cannot pick out of turn.")
  end

  it '#player_unpicked - league' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)

    player = FactoryBot.build_stubbed(:player)

    expect(league.decorate).to receive(:current_draft_pick).and_return(draft_pick)
    expect(league).to receive(:players).and_return([player])

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: fpl_team.user, player: player)
    expect(outcome.errors.full_messages)
      .to contain_exactly("#{player.decorate.name} is has already been picked by another fpl team in your league.")
  end

  it '#player_unpicked - fpl_team' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)

    player = FactoryBot.build_stubbed(:player)

    expect(league.decorate).to receive(:current_draft_pick).and_return(draft_pick)
    expect(fpl_team.players).to receive(:include?).and_return(true)

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: fpl_team.user, player: player)
    expect(outcome.errors.full_messages)
      .to contain_exactly("#{player.decorate.name} is already in your fpl team.")
  end

  it '#mini_draft_picked' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)

    expect(fpl_team.decorate).to receive(:mini_draft_picked?).and_return(true)

    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)

    expect(league.decorate).to receive(:current_draft_pick).and_return(draft_pick)

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: fpl_team.user, mini_draft: true)
    expect(outcome.errors.full_messages)
      .to contain_exactly("You have already selected your position in the mini draft.")
  end

  it '#all_players_picked' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)

    expect(fpl_team.decorate).to receive(:all_players_picked?).and_return(true)
    expect(league.decorate).to receive(:current_draft_pick).and_return(draft_pick)

    player = FactoryBot.build_stubbed(:player)

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: fpl_team.user, player: player)
    expect(outcome.errors.full_messages)
      .to contain_exactly("You are only allowed #{FplTeam::QUOTAS[:players]} players in a team.")
  end

  it '#maximum_number_of_players_by_position' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)

    expect(league.decorate).to receive(:current_draft_pick).and_return(draft_pick)

    quota = FplTeam::QUOTAS[:forwards]
    quota.times { fpl_team.players << FactoryBot.create(:player, :fwd) }

    player = FactoryBot.build_stubbed(:player, :fwd)

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: fpl_team.user, player: player)
    expect(outcome.errors.full_messages).to contain_exactly("You can't have more than #{quota} forwards in your team.")
  end

  it '#maximum_number_of_players_from_team' do
    league = FactoryBot.build_stubbed(:league, status: 'draft')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)

    expect(league.decorate).to receive(:current_draft_pick).and_return(draft_pick)

    team = FactoryBot.create(:team)

    quota = FplTeam::QUOTAS[:team]
    quota.times { fpl_team.players << FactoryBot.create(:player, team: team) }

    player = FactoryBot.build_stubbed(:player, :gkp, team: team)

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: fpl_team.user, player: player)
    expect(outcome.errors.full_messages)
      .to contain_exactly("You can't have more than #{quota} players from the same team (#{team.name}).")
  end

  it '#league_status' do
    league = FactoryBot.build_stubbed(:league, status: 'active')
    fpl_team = FactoryBot.build_stubbed(:fpl_team, league: league)
    draft_pick = FactoryBot.build_stubbed(:draft_pick, fpl_team: fpl_team, league: league)

    expect(league.decorate).to receive(:current_draft_pick).and_return(draft_pick)

    player = FactoryBot.build_stubbed(:player)

    outcome = described_class.run(league: league, draft_pick: draft_pick, user: fpl_team.user, player: player)
    expect(outcome.errors.full_messages).to contain_exactly("You cannot draft players at this time.")
  end
end

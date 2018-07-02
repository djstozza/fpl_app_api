require 'rails_helper'

RSpec.describe Leagues::JoinLeagueForm do
  it 'adds a new fpl team to the league' do
    league = FactoryBot.create(:league, status: 'generate_draft_picks')
    user = FactoryBot.create(:user)

    params = {
      name: league.name,
      code: league.code,
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))

    fpl_team = outcome.fpl_team
    expect(fpl_team.name).to eq(params[:fpl_team_name])
    expect(fpl_team.user).to eq(user)
    expect(fpl_team.league).to eq(league)
  end

  it 'requires a name' do
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: '',
      code: 'abc123',
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to include("Name can't be blank")
  end

  it 'requires a code' do
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: 'foo',
      code: '',
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to include("Code can't be blank")
  end

  it 'requires an fpl_team_name' do
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: 'foo',
      code: 'abc123',
      fpl_team_name: '',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to include("Fpl team name can't be blank")
  end

  it '#league_presence - incorrect league name' do
    league = FactoryBot.create(:league, status: 'generate_draft_picks')
    user = FactoryBot.create(:user)

    params = {
      name: league.name + 'a',
      code: league.code,
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages)
      .to contain_exactly("The league name and/or code you have entered is incorrect.")
  end

  it '#league_presence - incorrect league code' do
    league = FactoryBot.create(:league, status: 'generate_draft_picks')
    user = FactoryBot.create(:user)

    params = {
      name: league.name,
      code: league.code + 'a',
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages)
      .to contain_exactly("The league name and/or code you have entered is incorrect.")
  end

  it '#already_joined' do
    league = FactoryBot.create(:league, status: 'generate_draft_picks')
    fpl_team = FactoryBot.create(:fpl_team, league: league)

    params = {
      name: league.name,
      code: league.code,
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: fpl_team.user))
    expect(outcome.errors.full_messages).to contain_exactly("You have already joined this league.")
  end

  it '#fpl_team_name_uniqueness' do
    league = FactoryBot.create(:league, status: 'generate_draft_picks')
    fpl_team = FactoryBot.create(:fpl_team, league: league)
    user = FactoryBot.create(:user)

    params = {
      name: league.name,
      code: league.code,
      fpl_team_name: fpl_team.name,
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to contain_exactly("Fpl team name has already been taken")
  end

  it '#max_fpl_team_quota' do
    league = FactoryBot.build_stubbed(:league)
    user = FactoryBot.build_stubbed(:user)

    fpl_teams = []
    League::MAX_FPL_TEAM_QUOTA.times { fpl_teams << double(FplTeam) }
    allow_any_instance_of(described_class).to receive(:league).and_return(league)
    expect(league).to receive(:fpl_teams).and_return(fpl_teams)

    params = {
      name: league.name,
      code: league.code,
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages)
      .to contain_exactly("The limit on fpl teams for this league has already been reached.")
  end

  it '#inactive_league' do
    league = FactoryBot.build_stubbed(:league, status: 'create_draft')
    user = FactoryBot.build_stubbed(:user)

    allow_any_instance_of(described_class).to receive(:league).and_return(league)

    params = {
      name: league.name,
      code: league.code,
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to contain_exactly("You cannot join an activated league.")
  end
end

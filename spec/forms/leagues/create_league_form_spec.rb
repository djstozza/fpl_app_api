require 'rails_helper'

RSpec.describe Leagues::CreateLeagueForm do
  it 'creates a league with the user as the commissioner as well an fpl team' do
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: 'foo',
      code: 'abc123',
      fpl_team_name: 'bar',
    }

    expect_any_instance_of(League).to receive(:save)
    expect_any_instance_of(FplTeam).to receive(:save)

    outcome = described_class.run(params.merge(user: user))
    result = outcome.result
    expect(result.name).to eq(params[:name])
    expect(result.code).to eq(params[:code])
    expect(result.commissioner).to eq(user)

    fpl_team = outcome.fpl_team
    expect(fpl_team.name).to eq(params[:fpl_team_name])
    expect(fpl_team.league).to eq(result)
    expect(fpl_team.user).to eq(user)
  end

  it 'requires a name' do
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: '',
      code: 'abc123',
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to contain_exactly("Name can't be blank")
  end

  it 'requires a code' do
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: 'foo',
      code: '',
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to contain_exactly("Code can't be blank")
  end

  it 'requires an fpl_team_name' do
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: 'foo',
      code: 'abc123',
      fpl_team_name: '',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to contain_exactly("Fpl team name can't be blank")
  end

  it '#league_name_uniqueness' do
    league = FactoryBot.create(:league)

    user = FactoryBot.build_stubbed(:user)

    params = {
      name: league.name.upcase,
      code: 'abc123',
      fpl_team_name: 'bar',
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to contain_exactly("Name has already been taken")
  end

  it '#fpl_team_name_uniqueness' do
    fpl_team = FactoryBot.create(:fpl_team)

    user = FactoryBot.build_stubbed(:user)

    params = {
      name: 'foo',
      code: 'abc123',
      fpl_team_name: fpl_team.name.upcase,
    }

    outcome = described_class.run(params.merge(user: user))
    expect(outcome.errors.full_messages).to contain_exactly("Fpl team name has already been taken")
  end
end

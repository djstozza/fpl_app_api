require 'rails_helper'

RSpec.describe Leagues::UpdateLeagueForm do
  it 'updates the league' do
    league = FactoryBot.build_stubbed(:league)

    params = {
      name: 'foo bar',
      code: 'abc123',
    }

    expect(league).to receive(:save)

    result = described_class.run!(params.merge(league: league, user: league.commissioner))
    expect(result.name).to eq(params[:name])
    expect(result.code).to eq(params[:code])
  end

  it 'requires a code' do
    league = FactoryBot.build_stubbed(:league)

    params = {
      name: 'foo bar',
      code: '',
    }

    outcome = described_class.run(params.merge(league: league, user: league.commissioner))
    expect(outcome.errors.full_messages).to contain_exactly("Code can't be blank")
  end

  it 'requires a name' do
    league = FactoryBot.build_stubbed(:league)

    params = {
      name: '',
      code: 'abc123',
    }

    outcome = described_class.run(params.merge(league: league, user: league.commissioner))
    expect(outcome.errors.full_messages).to contain_exactly("Name can't be blank")
  end

  it '#league_name_uniqueness' do
    league_1 = FactoryBot.create(:league)

    league_2 = FactoryBot.build_stubbed(:league)
    params = {
      name: league_1.name.upcase,
      code: 'abc123',
    }

    outcome = described_class.run(params.merge(league: league_2, user: league_2.commissioner))
    expect(outcome.errors.full_messages).to contain_exactly("Name has already been taken")
  end

  it '#user_is_commissioner' do
    league = FactoryBot.build_stubbed(:league)
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: 'foo bar',
      code: 'abc123',
    }
    outcome = described_class.run(params.merge(league: league, user: user))
    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to edit this league.")
  end
end

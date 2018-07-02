require 'rails_helper'

RSpec.describe FplTeams::UpdateForm do
  it 'updates the fpl team' do
    fpl_team = FactoryBot.build_stubbed(:fpl_team)

    params = {
      name: 'foo',
    }

    expect(fpl_team).to receive(:save)

    result = described_class.run!(params.merge(fpl_team: fpl_team, user: fpl_team.user))
    expect(result.name).to eq(params[:name])
  end

  it '#fpl_team_name_uniqueness' do
    fpl_team_1 = FactoryBot.create(:fpl_team)

    fpl_team_2 = FactoryBot.build_stubbed(:fpl_team)

    params = {
      name: fpl_team_1.name,
    }

    outcome = described_class.run(params.merge(fpl_team: fpl_team_2, user: fpl_team_2.user))
    expect(outcome.errors.full_messages).to contain_exactly("Name has already been taken")
  end

  it '#user_owns_fpl_team' do
    fpl_team = FactoryBot.build_stubbed(:fpl_team)
    user = FactoryBot.build_stubbed(:user)

    params = {
      name: 'foo',
    }

    outcome = described_class.run(params.merge(fpl_team: fpl_team, user: user))
    expect(outcome.errors.full_messages).to contain_exactly("You are not authorised to edit this fpl team.")
  end

  it 'requires a name' do
    fpl_team = FactoryBot.build_stubbed(:fpl_team)

    params = {
      name: '',
    }

    outcome = described_class.run(params.merge(fpl_team: fpl_team, user: fpl_team.user))
    expect(outcome.errors.full_messages).to contain_exactly("Name can't be blank")
  end
end

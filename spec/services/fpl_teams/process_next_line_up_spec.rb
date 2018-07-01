require 'rails_helper'

RSpec.describe FplTeams::ProcessNextLineUp do
  it 'creates a new fpl_team_list based on the old_fpl_team_list' do
    round = FactoryBot.create(:round, is_current: true, data_checked: true)
    next_round = FactoryBot.create(:round, is_next: true)
    fpl_team = FactoryBot.create(:fpl_team)
    fpl_team_list = FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
    list_position = FactoryBot.create(:list_position, :starting, :fwd, fpl_team_list: fpl_team_list)

    result = described_class.run!(fpl_team: fpl_team, round: round, next_round: next_round)
    expect(result.fpl_team).to eq(fpl_team)
    expect(result.round).to eq(next_round)

    next_list_position = result.list_positions.first
    expect(next_list_position.position).to eq(list_position.position)
    expect(next_list_position.role).to eq(list_position.role)
    expect(next_list_position.player).to eq(list_position.player)
  end

  it 'does not create a new fpl_team_list if one already exists for the next round' do
    round = FactoryBot.create(:round, is_current: true, data_checked: true)
    next_round = FactoryBot.create(:round, is_next: true)
    fpl_team = FactoryBot.create(:fpl_team)

    FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)
    FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: next_round)

    expect { described_class.run!(fpl_team: fpl_team, round: round, next_round: next_round) }
      .not_to change { FplTeamList.count }
  end

  it 'does not create a new fpl_team_list if there is no next round' do
    round = FactoryBot.create(:round, is_current: true, data_checked: true)
    fpl_team = FactoryBot.create(:fpl_team)

    FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

    expect { described_class.run!(fpl_team: fpl_team, round: round, next_round: nil) }
      .not_to change { FplTeamList.count }
  end

  it 'does not create a new fpl_team_list if the current round is not data_checked' do
    round = FactoryBot.create(:round, is_current: true, data_checked: false)
    next_round = FactoryBot.create(:round, is_next: true)
    fpl_team = FactoryBot.create(:fpl_team)

    FactoryBot.create(:fpl_team_list, fpl_team: fpl_team, round: round)

    expect { described_class.run!(fpl_team: fpl_team, round: round, next_round: next_round) }
      .not_to change { FplTeamList.count }
  end
end

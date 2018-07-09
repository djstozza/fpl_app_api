require 'rails_helper'

RSpec.describe FplTeams::ProcessInitialLineUp do
  it 'is valid' do
    round = FactoryBot.create(:round)
    fpl_team = FactoryBot.create(:fpl_team)

    (1..3).each { |i| FactoryBot.create(:player, :fwd, ict_index: i) }
    (1..5).each { |i| FactoryBot.create(:player, :mid, ict_index: i) }
    (1..5).each { |i| FactoryBot.create(:player, :def, ict_index: i) }
    (1..2).each { |i| FactoryBot.create(:player, :gkp, ict_index: i) }

    forward_ids = Player.forwards.ids
    starting_midfielder_ids = Player.midfielders.where.not(ict_index: 1).ids
    starting_defender_ids = Player.defenders.where.not(ict_index: [1, 2]).ids

    fpl_team.players << Player.all

    result = described_class.run!(fpl_team: fpl_team)

    expect(result.round).to eq(round)
    expect(result.fpl_team).to eq(fpl_team)
    expect(result.players).to eq(fpl_team.players)

    # Starting list_positions
    expect(result.list_positions.forwards.starting.pluck(:player_id)).to eq(forward_ids)
    expect(result.list_positions.midfielders.starting.pluck(:player_id)).to eq(starting_midfielder_ids)
    expect(result.list_positions.defenders.starting.pluck(:player_id)).to eq(starting_defender_ids)
    expect(result.list_positions.goalkeepers.starting.pluck(:player_id)).to contain_exactly(Player.goalkeepers.last.id)

    # Substitute list_positions
    expect(result.list_positions.substitute_gkp.pluck(:player_id)).to contain_exactly(Player.goalkeepers.first.id)
    expect(result.list_positions.substitute_1.pluck(:player_id)).to contain_exactly(Player.defenders.first.id)
    expect(result.list_positions.substitute_2.pluck(:player_id)).to contain_exactly(Player.defenders.second.id)
    expect(result.list_positions.substitute_3.pluck(:player_id)).to contain_exactly(Player.midfielders.first.id)
  end
end

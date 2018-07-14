require 'rails_helper'

RSpec.describe LeaguePlayer, type: :model do
  it 'must be unique to a league' do
    league = FactoryBot.create(:league)
    player = FactoryBot.create(:player)

    described_class.create(league: league, player: player)

    league_player = described_class.new(league: league, player: player)

    expect(league_player).not_to be_valid
  end
end

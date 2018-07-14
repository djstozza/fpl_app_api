require 'rails_helper'

RSpec.describe FplTeamPlayer, type: :model do
  it "must be unique to an fpl_team" do
    player = FactoryBot.create(:player)
    fpl_team = FactoryBot.create(:fpl_team)

    described_class.create(player: player, fpl_team: fpl_team)

    fpl_team_player = described_class.new(player: player, fpl_team: fpl_team)
    expect(fpl_team_player).not_to be_valid
  end
end

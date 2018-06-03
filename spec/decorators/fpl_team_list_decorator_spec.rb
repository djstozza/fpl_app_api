require 'rails_helper'

RSpec.describe FplTeamListDecorator, type: :decorator do
  context '#list_positions_arr' do
    it 'creates a valid array of hashes' do
      fpl_team_list = FactoryBot.create(:fpl_team_list)

      fixture = FactoryBot.create(:fixture, round: fpl_team_list.round)

      player = FactoryBot.create(:player)

      list_position = FactoryBot.create(:list_position, player: player)

      player.update(player_fixture_history: {
        round: fpl_team_list.round_id,
        fixture: fixture.id,
        minutes: 90,

      })
    end
  end
end

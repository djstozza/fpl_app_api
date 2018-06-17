require 'rails_helper'

RSpec.describe FplTeamDecorator, type: :decorator do
  context '#mini_draft_picked?' do
    it 'checks whether there has been a mini draft pick' do
      fpl_team = FactoryBot.create(:fpl_team)
      FactoryBot.create(:draft_pick, :mini_draft, fpl_team: fpl_team, league: fpl_team.league)

      expect(fpl_team.decorate.mini_draft_picked?).to be_truthy
    end
  end

  context '#all_players_picked?' do
    it 'checkes whether all the draft picks of the fpl team have been picked' do
      fpl_team = FactoryBot.build_stubbed(:fpl_team)

      FplTeam::QUOTAS[:players].times do
        FactoryBot.build_stubbed(:draft_pick, :picked, fpl_team: fpl_team, league: fpl_team.league)
      end

      expect(fpl_team.decorate.all_players_picked?).to be_truthy
    end
  end
end

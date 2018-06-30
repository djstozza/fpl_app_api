# == Schema Information
#
# Table name: mini_draft_picks
#
#  id            :integer          not null, primary key
#  pick_number   :integer
#  season        :integer
#  passed        :boolean
#  league_id     :integer
#  out_player_id :integer
#  in_player_id  :integer
#  fpl_team_id   :integer
#  round_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe MiniDraftPick, type: :model do
  it 'requires a league, fpl_team, season and pick_number' do
    mini_draft_pick = FactoryBot.build_stubbed(:mini_draft_pick, league: nil)
    expect(mini_draft_pick).not_to be_valid

    mini_draft_pick = FactoryBot.build_stubbed(:mini_draft_pick, pick_number: nil)
    expect(mini_draft_pick).not_to be_valid

    mini_draft_pick = FactoryBot.build_stubbed(:mini_draft_pick, season: nil)
    expect(mini_draft_pick).not_to be_valid

    mini_draft_pick = FactoryBot.build_stubbed(:mini_draft_pick, fpl_team: nil)
    expect(mini_draft_pick).not_to be_valid
  end

  it 'requires the in_player and out_player to be absent if passed' do
    mini_draft_pick = FactoryBot.build_stubbed(:mini_draft_pick, in_player: nil, out_player: nil, passed: true)
    expect(mini_draft_pick).to be_valid

    mini_draft_pick = FactoryBot.build_stubbed(:mini_draft_pick, :picked, passed: true)
    expect(mini_draft_pick).not_to be_valid
  end

  it 'requires an in_player and out_player if not passed' do
    mini_draft_pick = FactoryBot.build_stubbed(:mini_draft_pick, in_player: nil, out_player: nil)
    expect(mini_draft_pick).not_to be_valid
  end

  it 'requires the pick_number to be unique for a season' do
    league = FactoryBot.create(:league)
    mini_draft_pick_1 = FactoryBot.create(:mini_draft_pick, :passed, league: league, season: 'summer')

    mini_draft_pick_2 = FactoryBot.build_stubbed(
      :mini_draft_pick,
      :passed,
      league: league,
      pick_number: mini_draft_pick_1.pick_number,
      season: 'summer'
    )
    expect(mini_draft_pick_2).not_to be_valid

    mini_draft_pick_2 = FactoryBot.build_stubbed(
      :mini_draft_pick,
      :passed,
      league: league,
      pick_number: mini_draft_pick_1.pick_number,
      season: 'winter'
    )
    expect(mini_draft_pick_2).to be_valid
  end

  context '#completed' do
    it 'shows picked and passed mini draft picks as completed' do
      mini_draft_pick_1 = FactoryBot.create(:mini_draft_pick, :picked)
      mini_draft_pick_2 = FactoryBot.create(:mini_draft_pick, :passed)
      mini_draft_pick_3 = MiniDraftPick.new

      expect(MiniDraftPick.completed).to contain_exactly(mini_draft_pick_1, mini_draft_pick_2)
      expect(MiniDraftPick.completed).not_to contain_exactly(mini_draft_pick_3)
    end
  end
end

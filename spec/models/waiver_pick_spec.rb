# == Schema Information
#
# Table name: waiver_picks
#
#  id               :integer          not null, primary key
#  pick_number      :integer
#  status           :integer          default("pending")
#  out_player_id    :integer
#  in_player_id     :integer
#  fpl_team_list_id :integer
#  round_id         :integer
#  league_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe WaiverPick, type: :model do
  it 'requires a round' do
    waiver_pick = FactoryBot.build_stubbed(:waiver_pick, round: nil)
    expect(waiver_pick).not_to be_valid
  end

  it 'requires a league' do
    waiver_pick = FactoryBot.build_stubbed(:waiver_pick, league: nil)
    expect(waiver_pick).not_to be_valid
  end

  it 'requires a fpl_team_list' do
    waiver_pick = FactoryBot.build_stubbed(:waiver_pick, fpl_team_list: nil)
    expect(waiver_pick).not_to be_valid
  end

  it 'requires an in_player' do
    waiver_pick = FactoryBot.build_stubbed(:waiver_pick, in_player: nil)
    expect(waiver_pick).not_to be_valid
  end

  it 'requires an out_player' do
    waiver_pick = FactoryBot.build_stubbed(:waiver_pick, out_player: nil)
    expect(waiver_pick).not_to be_valid
  end

  it 'requires a status' do
    waiver_pick = FactoryBot.build_stubbed(:waiver_pick, status: nil)
    expect(waiver_pick).not_to be_valid
  end

  it 'requires a pick_number' do
    waiver_pick = FactoryBot.build_stubbed(:waiver_pick, pick_number: nil)
    expect(waiver_pick).not_to be_valid
  end

  it 'requires a unique pick_number on create' do
    waiver_pick = FactoryBot.create(:waiver_pick)
    expect {
      FactoryBot.create(
        :waiver_pick,
        pick_number: waiver_pick.pick_number,
        fpl_team_list: waiver_pick.fpl_team_list,
      )
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

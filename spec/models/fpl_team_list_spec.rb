# == Schema Information
#
# Table name: fpl_team_lists
#
#  id           :integer          not null, primary key
#  fpl_team_id  :integer
#  round_id     :integer
#  total_score  :integer
#  rank         :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  overall_rank :integer
#

require 'rails_helper'

RSpec.describe FplTeamList, type: :model do
  it 'requires a round and fpl team' do
    expect(FactoryBot.build(:fpl_team_list, round: nil)).not_to be_valid
    expect(FactoryBot.build(:fpl_team_list, fpl_team: nil)).not_to be_valid
  end

  it 'only allows one fpl team list per round' do
    fpl_team_list = FactoryBot.create(:fpl_team_list)
    expect(FactoryBot.build(:fpl_team_list, fpl_team: fpl_team_list.fpl_team, round: fpl_team_list.round))
      .not_to be_valid
  end
end

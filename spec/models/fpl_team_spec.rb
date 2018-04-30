# == Schema Information
#
# Table name: fpl_teams
#
#  id                     :integer          not null, primary key
#  name                   :string           not null
#  user_id                :integer
#  league_id              :integer
#  total_score            :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  draft_pick_number      :integer
#  mini_draft_pick_number :integer
#  rank                   :integer
#

require 'rails_helper'

RSpec.describe FplTeam, type: :model do
  it 'requires a unique name' do
    fpl_team = FactoryBot.create(:fpl_team)
    expect(FactoryBot.build(:fpl_team, name: fpl_team.name.upcase)).not_to be_valid
  end

  it 'requires a user and a league' do
    expect(FactoryBot.build(:fpl_team, user: nil)).not_to be_valid
    expect(FactoryBot.build(:fpl_team, league: nil)).not_to be_valid
  end

  it 'allows a user to only have one per league' do
    fpl_team = FactoryBot.create(:fpl_team)
    expect(FactoryBot.build(:fpl_team, league: fpl_team.league)).to be_valid
    expect(FactoryBot.build(:fpl_team, user: fpl_team.user)).to be_valid
    expect(FactoryBot.build(:fpl_team, user: fpl_team.user, league: fpl_team.league)).not_to be_valid
  end
end

# == Schema Information
#
# Table name: draft_picks
#
#  id          :integer          not null, primary key
#  pick_number :integer
#  mini_draft  :boolean          default(FALSE)
#  league_id   :integer
#  player_id   :integer
#  fpl_team_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe DraftPick, type: :model do
  it 'does not require a player on create but does on update if there was no mini draft pick' do
    draft_pick = FactoryBot.create(:draft_pick)
    draft_pick.update(player: nil)

    expect(draft_pick).not_to be_valid
  end

  it 'does not require a player to be present if there was a mini draft pick on update' do
    draft_pick = FactoryBot.create(:draft_pick)
    draft_pick.update(mini_draft: true)

    expect(draft_pick).to be_valid
  end

  it 'requires a player to be picked or a mini draft but not both' do
    draft_pick = FactoryBot.create(:draft_pick)
    draft_pick.update(mini_draft: true, player: FactoryBot.create(:player))

    expect(draft_pick).not_to be_valid
  end

  it 'only allows a player to be picked once per league' do
    picked_draft_pick = FactoryBot.create(:draft_pick, :picked)

    draft_pick = FactoryBot.create(:draft_pick, league: picked_draft_pick.league)
    draft_pick.update(player: picked_draft_pick.player)

    expect(draft_pick).not_to be_valid
  end
end

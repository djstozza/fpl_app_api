# == Schema Information
#
# Table name: list_positions
#
#  id               :integer          not null, primary key
#  fpl_team_list_id :integer
#  player_id        :integer
#  position_id      :integer
#  role             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe ListPosition, type: :model do
  # belongs_to :fpl_team_list
  # belongs_to :player
  # belongs_to :position
  # enum role: { starting: 0, substitute_1: 1, substitute_2: 2, substitute_3: 3, substitute_gkp: 4 }
  # validates :fpl_team_list_id, :player_id, :position_id, :role, presence: true
  #
  # scope :forwards, -> { where(position: Position.find_by(singular_name: 'Forward')) }
  # scope :midfielders, -> { where(position: Position.find_by(singular_name: 'Midfielder')) }
  # scope :defenders, -> { where(position: Position.find_by(singular_name: 'Defender')) }
  # scope :goalkeepers, -> { where(position: Position.find_by(singular_name: 'Goalkeeper')) }
  # scope :field_players, -> { where.not(position: Position.find_by(singular_name: 'Goalkeeper')) }
  # scope :substitutes, -> { where.not(role: 'starting').order(:role) }
  it 'requires a position, fpl_team_list, player and role' do
    expect(FactoryBot.build(:list_position, fpl_team_list: nil)).not_to be_valid
    expect(FactoryBot.build(:list_position, player: nil)).not_to be_valid
    expect(FactoryBot.build(:list_position, position: nil)).not_to be_valid
    expect(FactoryBot.build(:list_position, role: nil)).not_to be_valid
  end

  it 'has valid scopes' do
    fwd_pos = Position.find_by(singular_name_short: 'FWD')
    mid_pos = Position.find_by(singular_name_short: 'MID')
    def_pos = Position.find_by(singular_name_short: 'DEF')
    gkp_pos = Position.find_by(singular_name_short: 'GKP')

    starting_fwd = FactoryBot.create(:list_position, position: fwd_pos, role: 'starting')
    starting_mid = FactoryBot.create(:list_position, position: mid_pos, role: 'starting')
    starting_def = FactoryBot.create(:list_position, position: def_pos, role: 'starting')
    starting_gkp = FactoryBot.create(:list_position, position: gkp_pos, role: 'starting')

    sub_fwd = FactoryBot.create(:list_position, position: fwd_pos, role: 'substitute_1')
    sub_mid = FactoryBot.create(:list_position, position: mid_pos, role: 'substitute_2')
    sub_def = FactoryBot.create(:list_position, position: def_pos, role: 'substitute_3')
    sub_gkp = FactoryBot.create(:list_position, position: gkp_pos, role: 'substitute_gkp')

    expect(ListPosition.forwards).to contain_exactly(starting_fwd, sub_fwd)
    expect(ListPosition.midfielders).to contain_exactly(starting_mid, sub_mid)
    expect(ListPosition.defenders).to contain_exactly(starting_def, sub_def)
    expect(ListPosition.goalkeepers).to contain_exactly(starting_gkp, sub_gkp)

    expect(ListPosition.substitutes).to contain_exactly(sub_fwd, sub_mid, sub_def, sub_gkp)
    expect(ListPosition.field_players.starting).to contain_exactly(starting_fwd, starting_mid, starting_def)
  end
end

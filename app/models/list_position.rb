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

class ListPosition < ApplicationRecord
  belongs_to :fpl_team_list
  belongs_to :player
  belongs_to :position
  enum role: { starting: 0, substitute_1: 1, substitute_2: 2, substitute_3: 3, substitute_gkp: 4 }
  validates :fpl_team_list_id, :player_id, :position_id, :role, presence: true

  scope :forwards, -> { where(position: Position.find_by(singular_name: 'Forward')) }
  scope :midfielders, -> { where(position: Position.find_by(singular_name: 'Midfielder')) }
  scope :defenders, -> { where(position: Position.find_by(singular_name: 'Defender')) }
  scope :goalkeepers, -> { where(position: Position.find_by(singular_name: 'Goalkeeper')) }
  scope :field_players, -> { where.not(position: Position.find_by(singular_name: 'Goalkeeper')) }
  scope :substitutes, -> { where.not(role: 'starting').order(:role) }
end

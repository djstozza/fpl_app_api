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

class WaiverPick < ApplicationRecord
  belongs_to :league
  belongs_to :fpl_team_list
  belongs_to :out_player, class_name: Player, foreign_key: :out_player_id
  belongs_to :in_player, class_name: Player, foreign_key: :in_player_id
  belongs_to :round
  validates :status, :pick_number, presence: true
  validates_uniqueness_of :pick_number, scope: :fpl_team_list_id, on: :create
  enum status: { pending: 0, approved: 1, declined: 2 }
end

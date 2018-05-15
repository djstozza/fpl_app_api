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

class FplTeamList < ApplicationRecord
  belongs_to :round
  belongs_to :fpl_team
  has_many :list_positions
  has_many :waiver_picks
  has_many :players, through: :list_positions
  validates_uniqueness_of :round_id, scope: :fpl_team_id
end

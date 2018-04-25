# == Schema Information
#
# Table name: fixtures
#
#  id                     :integer          not null, primary key
#  kickoff_time           :datetime
#  deadline_time          :datetime
#  team_h_difficulty      :integer
#  team_a_difficulty      :integer
#  code                   :integer
#  team_h_score           :integer
#  team_a_score           :integer
#  minutes                :integer
#  started                :boolean
#  finished               :boolean
#  provisional_start_time :boolean
#  finished_provisional   :boolean
#  round_day              :integer
#  stats                  :jsonb
#  round_id               :integer
#  team_h_id              :integer
#  team_a_id              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Fixture < ApplicationRecord
  belongs_to :round
  belongs_to :home_team, class_name: 'Team', foreign_key: :team_h_id
  belongs_to :away_team, class_name: 'Team', foreign_key: :team_a_id

  scope :finished, -> { where(finished: true) }

  validates :code, presence: true, uniqueness: true
end

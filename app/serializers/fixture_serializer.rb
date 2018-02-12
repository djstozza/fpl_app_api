# == Schema Information
#
# Table name: fixtures
#
#  id                     :integer          not null, primary key
#  kickoff_time           :string
#  deadline_time          :string
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

class FixtureSerializer
  include FastJsonapi::ObjectSerializer
  set_type :fixture
  attributes :kickoff_time,
             :team_h_difficulty,
             :code,
             :team_h_score,
             :team_a_score,
             :minutes,
             :started,
             :finished,
             :stats,
             :round_day,
             :round_id
  belongs_to :round
  belongs_to :team_h, class_name: Team, foreign_key: :team_h_id, serializer: :team
  belongs_to :team_a, class_name: Team, foreign_key: :team_a_id, serializer: :team
end

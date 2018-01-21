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
#  round_id               :integer
#  team_h_id              :integer
#  team_a_id              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Fixture < ApplicationRecord
end

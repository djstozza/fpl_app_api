# == Schema Information
#
# Table name: rounds
#
#  id                        :integer          not null, primary key
#  name                      :string
#  deadline_time             :datetime
#  finished                  :boolean
#  data_checked              :boolean
#  deadline_time_epoch       :integer
#  deadline_time_game_offset :integer
#  is_previous               :boolean
#  is_current                :boolean
#  is_next                   :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class RoundSerializer
  include FastJsonapi::ObjectSerializer
  set_type :round
  attributes :name, :deadline_time, :is_previous, :is_current, :is_next, :data_checked
  has_many :fixtures
  cache_options enabled: true, cache_length: 10.minutes
end

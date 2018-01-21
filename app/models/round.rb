# == Schema Information
#
# Table name: rounds
#
#  id                        :integer          not null, primary key
#  name                      :string
#  deadline_time             :string
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

class Round < ApplicationRecord
end

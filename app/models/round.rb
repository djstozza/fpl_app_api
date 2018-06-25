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
#  mini_draft                :boolean
#

class Round < ApplicationRecord
  has_many :fixtures

  validates :name, :deadline_time, presence: true, uniqueness: true

  class << self
    def current
      if where(is_current: true).empty?
        find_by(is_next: true)
      elsif find_by(is_current: true).data_checked
        find_by(is_next: true) || find_by(is_current: true)
      else
        find_by(is_current: true)
      end
    end

    def summer_mini_draft_deadline
      Time.parse("01/09/#{Round.first.deadline_time.year}")
    end

    def winter_mini_draft_deadline
      Time.parse("01/02/#{(Round.first.deadline_time + 1.year).year}")
    end
  end
end

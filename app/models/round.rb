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
  SUMMER_MINI_DRAFT_DEADLINE = Time.parse("01/09/#{Time.now.year}")
  WINTER_MINI_DRAFT_DEALINE = Time.parse("01/02/#{1.year.from_now.year}")

  has_many :fixtures

  validates :name, :deadline_time, presence: true, uniqueness: { case_sensitive: false }

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
  end
end

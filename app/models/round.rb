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

  def status
    if data_checked
      'finished'
    elsif deadline_time + deadline_time_game_offset < Time.now
      'started'
    elsif deadline_time < Time.now && Time.now < deadline_time + deadline_time_game_offset
      'pre_game'
    elsif mini_draft_deadline_time && Time.now < mini_draft_deadline_time
      'mini_draft'
    elsif waiver_deadline_time && Time.now < waiver_deadline_time
      'waiver'
    else
      'trade'
    end
  end

  def waiver_deadline_time
    deadline_time - 1.day if id != Round.first.id
  end

  def mini_draft_deadline_time
    deadline_time - 1.day if mini_draft
  end

  def current_deadline_time
    if status == 'mini_draft'
      mini_draft_deadline_time
    elsif status == 'waiver'
      waiver_deadline_time
    else
      deadline_time
    end
  end

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

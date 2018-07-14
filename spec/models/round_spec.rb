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

require 'rails_helper'

RSpec.describe Round, type: :model do
  describe '#current' do
    it 'returns the #is_next if there is no #is_current' do
      round = FactoryBot.create(:round, is_next: true)

      expect(Round.current).to eq(round)
    end

    it 'returns #is_next if the #is_current is #data_checked' do
      FactoryBot.create(:round, is_current: true, data_checked: true)
      round = FactoryBot.create(:round, is_next: true)

      expect(Round.current).to eq(round)
    end

    it 'returns #is_current if there is no #is_next' do
      round = FactoryBot.create(:round, is_current: true)
      expect(Round.current).to eq(round)
    end
  end
end

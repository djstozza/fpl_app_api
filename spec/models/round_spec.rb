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

  describe '#status' do
    it '#data_checked' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.day.ago, data_checked: true)
      expect(round.status).to eq('finished')
    end

    it '#started' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.day.ago, deadline_time_game_offset: 3600)
      expect(round.status).to eq('started')
    end

    it '#pre_game' do
      round = FactoryBot.build_stubbed(:round, deadline_time: Time.now, deadline_time_game_offset: 3600)
      expect(round.status).to eq('pre_game')
    end

    it '#mini_draft' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 2.days.from_now, mini_draft: true)
      expect(round.status).to eq('mini_draft')
    end

    it '#waiver' do
      first_round = FactoryBot.build_stubbed(:round)
      expect(Round).to receive(:first).and_return(first_round).at_least(1)

      round = FactoryBot.build_stubbed(:round, deadline_time: 2.days.from_now)


      expect(round.status).to eq('waiver')
    end

    it '#trade' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 1.days.from_now)
      expect(Round).to receive(:first).and_return(round).at_least(1)
      expect(round.status).to eq('trade')
    end
  end

  describe '#current_deadline_time' do
    it '#waiver' do
      first_round = FactoryBot.build_stubbed(:round)
      expect(Round).to receive(:first).and_return(first_round).at_least(1)

      round = FactoryBot.build_stubbed(:round, deadline_time: 2.days.from_now)

      expect(round.current_deadline_time).to eq(round.waiver_deadline_time)
    end

    it '#mini_draft' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 2.days.from_now)
      expect(round).to receive(:status).and_return('mini_draft').at_least(1)

      expect(round.current_deadline_time).to eq(round.mini_draft_deadline_time)
    end

    it '#deadline_time' do
      round = FactoryBot.build_stubbed(:round, deadline_time: 2.days.from_now)
      expect(round).to receive(:status).and_return('trade').at_least(1)

      expect(round.current_deadline_time).to eq(round.deadline_time)
    end
  end
end

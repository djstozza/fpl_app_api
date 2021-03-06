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

require 'rails_helper'

RSpec.describe Fixture, type: :model do
  it 'requires a unique code' do
    fixture = FactoryBot.build_stubbed(:fixture, code: nil)
    expect(fixture).not_to be_valid

    fixture_1 = FactoryBot.create(:fixture)
    fixture = FactoryBot.build_stubbed(:fixture, code: fixture_1.code)
    expect(fixture).not_to be_valid
  end
end

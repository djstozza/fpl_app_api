# == Schema Information
#
# Table name: leagues
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  code            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  commissioner_id :integer
#  status          :integer          default("generate_draft_picks")
#

require 'rails_helper'

RSpec.describe League, type: :model do
  it 'requires a unique name' do
    league = FactoryBot.create(:league)
    expect(FactoryBot.build(:league, name: league.name.upcase)).not_to be_valid
  end

  it 'requires a code, a name and a commissioner' do
    expect(FactoryBot.build(:league, code: '')).not_to be_valid
    expect(FactoryBot.build(:league, name: '')).not_to be_valid
    expect(FactoryBot.build(:league, commissioner: nil)).not_to be_valid
  end
end

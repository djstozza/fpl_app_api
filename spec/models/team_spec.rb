# == Schema Information
#
# Table name: teams
#
#  id                    :integer          not null, primary key
#  name                  :string
#  code                  :string
#  short_name            :string
#  strength              :integer
#  position              :integer
#  played                :integer
#  wins                  :integer
#  losses                :integer
#  draws                 :integer
#  clean_sheets          :integer
#  goals_for             :integer
#  goals_against         :integer
#  goal_difference       :integer
#  points                :integer
#  form                  :jsonb
#  current_form          :string
#  link_url              :integer
#  strength_overall_home :integer
#  strength_overall_away :integer
#  strength_attack_home  :integer
#  strength_attack_away  :integer
#  strength_defence_home :integer
#  strength_defence_away :integer
#  team_division         :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'rails_helper'

RSpec.describe Team, type: :model do
  it 'requires a unique code, name and short_name' do
    team = FactoryBot.create(:team)
    expect(FactoryBot.build(:team, name: team.name)).not_to be_valid
    expect(FactoryBot.build(:team, short_name: team.short_name)).not_to be_valid
    expect(FactoryBot.build(:team, code: team.code)).not_to be_valid
  end
end

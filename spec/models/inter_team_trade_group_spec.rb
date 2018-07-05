# == Schema Information
#
# Table name: inter_team_trade_groups
#
#  id                   :integer          not null, primary key
#  out_fpl_team_list_id :integer
#  in_fpl_team_list_id  :integer
#  round_id             :integer
#  league_id            :integer
#  status               :integer          default("pending")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'rails_helper'

RSpec.describe InterTeamTradeGroup, type: :model do
  it 'requires a league' do
    inter_team_trade_group = FactoryBot.build_stubbed(:inter_team_trade_group, league: nil)
    expect(inter_team_trade_group).not_to be_valid
  end

  it 'requires a round' do
    inter_team_trade_group = FactoryBot.build_stubbed(:inter_team_trade_group, round: nil)
    expect(inter_team_trade_group).not_to be_valid
  end

  it 'requires in in_fpl_team_list' do
    inter_team_trade_group = FactoryBot.build_stubbed(:inter_team_trade_group, in_fpl_team_list: nil)
    expect(inter_team_trade_group).not_to be_valid
  end

  it 'requires in out_fpl_team_list' do
    inter_team_trade_group = FactoryBot.build_stubbed(:inter_team_trade_group, out_fpl_team_list: nil)
    expect(inter_team_trade_group).not_to be_valid
  end

  it 'has valid statuses' do
    inter_team_trade_group_1 = FactoryBot.create(:inter_team_trade_group, status: 'pending')
    inter_team_trade_group_2 = FactoryBot.create(:inter_team_trade_group, status: 'submitted')
    inter_team_trade_group_3 = FactoryBot.create(:inter_team_trade_group, status: 'approved')
    inter_team_trade_group_4 = FactoryBot.create(:inter_team_trade_group, status: 'declined')
    inter_team_trade_group_5 = FactoryBot.create(:inter_team_trade_group, status: 'expired')

    expect(InterTeamTradeGroup.pending).to contain_exactly(inter_team_trade_group_1)
    expect(InterTeamTradeGroup.submitted).to contain_exactly(inter_team_trade_group_2)
    expect(InterTeamTradeGroup.approved).to contain_exactly(inter_team_trade_group_3)
    expect(InterTeamTradeGroup.declined).to contain_exactly(inter_team_trade_group_4)
    expect(InterTeamTradeGroup.expired).to contain_exactly(inter_team_trade_group_5)
  end
end

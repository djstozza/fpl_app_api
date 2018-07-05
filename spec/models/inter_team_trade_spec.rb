# == Schema Information
#
# Table name: inter_team_trades
#
#  id                        :integer          not null, primary key
#  inter_team_trade_group_id :integer
#  out_player_id             :integer
#  in_player_id              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe InterTeamTrade, type: :model do
  it 'requires an inter_team_trade_group' do
    inter_team_trade = FactoryBot.build_stubbed(:inter_team_trade, inter_team_trade_group: nil)
    expect(inter_team_trade).not_to be_valid
  end

  it 'requires an in_player' do
    inter_team_trade = FactoryBot.build_stubbed(:inter_team_trade, in_player: nil)
    expect(inter_team_trade).not_to be_valid
  end

  it 'requires an out_player' do
    inter_team_trade = FactoryBot.build_stubbed(:inter_team_trade, out_player: nil)
    expect(inter_team_trade).not_to be_valid
  end

  it 'out_player must be unique per inter_team_trade_group' do
    inter_team_trade_1 = FactoryBot.create(:inter_team_trade)
    inter_team_trade_2 = FactoryBot.build_stubbed(
      :inter_team_trade,
      inter_team_trade_group: inter_team_trade_1.inter_team_trade_group,
      out_player: inter_team_trade_1.out_player,
    )
    expect(inter_team_trade_2).not_to be_valid
  end

  it 'in_player must be unique per inter_team_trade_group' do
    inter_team_trade_1 = FactoryBot.create(:inter_team_trade)
    inter_team_trade_2 = FactoryBot.build_stubbed(
      :inter_team_trade,
      inter_team_trade_group: inter_team_trade_1.inter_team_trade_group,
      in_player: inter_team_trade_1.in_player,
    )
    expect(inter_team_trade_2).not_to be_valid
  end
end

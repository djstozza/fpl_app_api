require 'rails_helper'

RSpec.describe InterTeamTradeGroups::Expire do
  it 'expires all pending and submitted trades' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: Time.now)

    inter_team_trade_group_1 = FactoryBot.create(:inter_team_trade_group, round: round, status: 'approved')
    inter_team_trade_group_2 = FactoryBot.create(:inter_team_trade_group, round: round, status: 'declined')
    inter_team_trade_group_3 = FactoryBot.create(:inter_team_trade_group, round: round, status: 'submitted')
    inter_team_trade_group_4 = FactoryBot.create(:inter_team_trade_group, round: round, status: 'pending')

    described_class.run!

    expect(inter_team_trade_group_1.reload).to be_approved
    expect(inter_team_trade_group_2.reload).to be_declined
    expect(inter_team_trade_group_3.reload).to be_expired
    expect(inter_team_trade_group_4.reload).to be_expired
  end

  it 'does not expire pending and submitted trades if the deadline_time has not passed' do
    round = FactoryBot.create(:round, is_current: true, deadline_time: 1.minute.from_now)

    inter_team_trade_group_1 = FactoryBot.create(:inter_team_trade_group, round: round, status: 'submitted')
    inter_team_trade_group_2 = FactoryBot.create(:inter_team_trade_group, round: round, status: 'pending')

    described_class.run!
    expect(inter_team_trade_group_1.reload).to be_submitted
    expect(inter_team_trade_group_2.reload).to be_pending
  end
end

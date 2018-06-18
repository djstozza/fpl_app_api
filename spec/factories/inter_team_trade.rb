FactoryBot.define do
  factory :inter_team_trade, class: InterTeamTrade do
    association :inter_team_trade_group, factory: :inter_team_trade_group
    association :out_player, factory: :player
    association :in_player, factory: :player
  end
end

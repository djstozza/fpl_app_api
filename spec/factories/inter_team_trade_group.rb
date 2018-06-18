FactoryBot.define do
  factory :inter_team_trade_group, class: InterTeamTradeGroup do
    association :league, factory: :league
    association :round, factory: :round
    association :out_fpl_team_list, factory: :fpl_team_list
    association :in_fpl_team_list, factory: :fpl_team_list
  end
end

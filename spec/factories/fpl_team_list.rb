FactoryBot.define do
  factory :fpl_team_list, class: FplTeamList do
    association :fpl_team, factory: :fpl_team
    association :round, factory: :round
  end
end

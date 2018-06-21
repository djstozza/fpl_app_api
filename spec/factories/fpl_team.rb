FactoryBot.define do
  factory :fpl_team, class: FplTeam do
    sequence :name do |n|
      "Fpl Team Name #{n}"
    end
    association :user, factory: :user
    association :league, factory: :league
    total_score { 50 }
  end
end

FactoryBot.define do
  factory :fixture, class: Fixture do
    code { Faker::Number.unique.number(5) }
    association :round, factory: :round
    association :away_team, factory: :team
    association :home_team, factory: :team
    tean_h_difficulty { 5 }
    team_a_difficulty { 3 }
    kickoff_time { Time.now }
  end
end

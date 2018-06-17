FactoryBot.define do
  factory :fixture, class: Fixture do
    code { Faker::Number.unique.number(5) }
    association :round, factory: :round
    association :away_team, factory: :team
    association :home_team, factory: :team
    team_h_difficulty { Faker::Number.between(1, 5) }
    team_a_difficulty { Faker::Number.between(1, 5) }
    kickoff_time { Time.now }
    started { true }
    finished { true }
  end
end

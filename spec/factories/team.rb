FactoryBot.define do
  factory :team, class: Team do
    sequence :name do |n|
      "Team #{n}"
    end

    sequence :short_name do |n|
      "T#{n}"
    end

    code { Faker::Number.unique.number(5) }
  end
end

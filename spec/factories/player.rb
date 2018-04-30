FactoryBot.define do
  factory :player, class: Player do
    sequence :first_name do |n|
      "first_name #{n}"
    end
    sequence :last_name do |n|
      "last_name #{n}"
    end
    code { Faker::Number.unique.number(5) }
    association :team, factory: :team
    position { Position.find_by(singular_name: 'Forward') }
  end
end

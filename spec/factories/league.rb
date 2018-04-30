FactoryBot.define do
  factory :league, class: League do
    sequence :name do |n|
      "League #{n}"
    end
    code { SecureRandom.hex(6) }
    association :commissioner, factory: :user
  end
end

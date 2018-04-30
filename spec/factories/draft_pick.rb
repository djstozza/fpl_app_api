FactoryBot.define do
  factory :draft_pick, class: DraftPick do
    association :league, factory: :league
    association :fpl_team, factory: :fpl_team

    sequence :pick_number do |n|
      n
    end

    trait :create do
      mini_draft { false }
    end

    trait :picked do
      association :player, factory: :player
    end

    trait :mini_draft do
      mini_draft { true }
    end
  end
end

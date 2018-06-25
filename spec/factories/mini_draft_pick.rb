FactoryBot.define do
  factory :mini_draft_pick, class: MiniDraftPick do
    association :league, factory: :league
    association :fpl_team, factory: :fpl_team
    association :round, factory: :round
    sequence :pick_number do |n|
      n
    end
    season { 'summer' }

    trait :picked do
      association :out_player, factory: :player
      association :in_player, factory: :player
    end

    trait :passed do
      passed true
    end

    trait :summer do
      season { 'summer' }
    end

    trait :winter do
      season { 'winter' }
    end
  end
end

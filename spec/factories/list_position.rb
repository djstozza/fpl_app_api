FactoryBot.define do
  factory :list_position, class: ListPosition do
    association :fpl_team_list, factory: :fpl_team_list
    association :player, factory: :player
    position { Position.find_by(singular_name_short: 'FWD') }
    role { 'starting' }

    trait :fwd do
      association :player, factory: [:player, :fwd]
      position { Position.find_by(singular_name_short: 'FWD') }
    end

    trait :mid do
      association :player, factory: [:player, :mid]
      position { Position.find_by(singular_name_short: 'MID') }
    end

    trait :def do
      association :player, factory: [:player, :def]
      position { Position.find_by(singular_name_short: 'DEF') }
    end

    trait :gkp do
      association :player, factory: [:player, :gkp]
      position { Position.find_by(singular_name_short: 'GKP') }
    end

    trait :starting do
      role { 'starting' }
    end

    trait :s1 do
      role { 'substitute_1' }
    end

    trait :s2 do
      role { 'substitute_2' }
    end

    trait :s3 do
      role { 'substitute_3' }
    end

    trait :sgkp do
      role { 'substitute_gkp' }
      association :player, factory: [:player, :gkp]
      position { Position.find_by(singular_name_short: 'GKP') }
    end
  end
end

FactoryBot.define do
  factory :player, class: Player do
    sequence :first_name do |n|
      "first_name #{n}"
    end

    sequence :last_name do |n|
      "last_name #{n}"
    end

    code { Faker::Number.unique.number(5) }
    status { 'a' }
    association :team, factory: :team
    position { Position.find_by(singular_name: 'Forward') }
    ict_index { 1 }

    trait :fwd do
      position { Position.find_by(singular_name: 'Forward') }
    end

    trait :mid do
      position { Position.find_by(singular_name: 'Midfielder') }
    end

    trait :def do
      position { Position.find_by(singular_name: 'Defender') }
    end

    trait :gkp do
      position { Position.find_by(singular_name: 'Goalkeeper') }
    end

    trait :player_fixture_histories do
      transient do
        player_fixture_histories_arr { [] }
      end

      player_fixture_histories {
        player_fixture_histories_arr.map do |player_fixture_history|
          {
            "round" => player_fixture_history[:round].id,
            "fixture" => player_fixture_history[:fixture].id,
            "total_points" => player_fixture_history[:total_points],
            "kickoff_time" => player_fixture_history[:fixture].kickoff_time.to_s,
            "was_home" => player_fixture_history[:was_home],
            "minutes" => player_fixture_history[:minutes],
            "bps" => player_fixture_history[:bps],
          }
        end
      }
    end
  end
end

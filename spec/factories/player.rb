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
        round nil
        fixture nil
        was_home nil
        minutes nil
        total_points nil
        bps nil
      end

      player_fixture_histories {
        [
          "round" => round.id,
          "fixture" => fixture.id,
          "total_points" => total_points,
          "kickoff_time" => fixture.kickoff_time.to_s,
          "was_home" => was_home,
          "minutes" => minutes,
          "bps" => bps,
        ]
      }

      team { was_home ? fixture.home_team : fixture.away_team }
    end
  end
end

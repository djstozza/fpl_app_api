FactoryBot.define do
  factory :round, class: Round do
    sequence :name do |n|
      "Round #{n}"
    end

    deadline_time { 7.days.from_now }
    deadline_time_game_offset { 3600 }
    data_checked { false }
    is_current { true }
    is_previous { false }
    is_next { false }
    mini_draft { nil }
  end
end

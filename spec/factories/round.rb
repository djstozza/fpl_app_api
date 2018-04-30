FactoryBot.define do
  factory :round, class: Round do
    sequence :name do |n|
      "Round #{n}"
    end

    deadline_time { 7.days.from_now }
    data_checked { false }
    is_current { true }
    is_previous { false }
    is_next { false }
    mini_draft { nil }
  end
end

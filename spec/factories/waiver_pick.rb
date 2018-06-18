FactoryBot.define do
  factory :waiver_pick, class: WaiverPick do
    association :fpl_team_list, factory: :fpl_team_list
    association :round, factory: :round
    association :league, factory: :league
    association :in_player, factory: :player
    association :out_player, factory: :player

    sequence :pick_number do |n|
      n
    end

    status { 'pending' }
  end
end

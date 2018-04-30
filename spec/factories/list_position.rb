FactoryBot.define do
  factory :list_position, class: ListPosition do
    association :fpl_team_list, factory: :fpl_team_list
    association :player, factory: :player
    position { Position.find_by(singular_name_short: 'FWD') }
    role { 'starting' }
  end
end

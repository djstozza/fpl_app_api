desc 'Populate players'

namespace :data_seeding do
  task populate_players: :environment do
    Players::Populate.run!
  end
end

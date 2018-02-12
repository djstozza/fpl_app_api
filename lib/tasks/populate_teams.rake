desc 'Populate teams'

namespace :data_seeding do
  task populate_teams: :environment do
    Teams::Populate.run!
  end
end

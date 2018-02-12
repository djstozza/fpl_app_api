desc 'Populate fixtures'

namespace :data_seeding do
  task populate_fixtures: :environment do
    Fixtures::Populate.run!
  end
end

desc 'Populate fixtures'

namespace :data_seeding do
  task populate_fixtures: :environment do
    Fixtures::Populate.run!
    Team.all.each { |team| Teams::ProcessStats.run!(team: team) }
  end
end

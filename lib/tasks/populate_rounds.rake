desc 'Populate rounds'

namespace :data_seeding do
  task populate_rounds: :environment do
    Rounds::Populate.run!
  end
end

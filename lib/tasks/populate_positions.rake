desc 'Populate positions'

namespace :data_seeding do
  task populate_positions: :environment do
    HTTParty.get('https://fantasy.premierleague.com/drf/bootstrap-static')['element_types'].each do |response|
      position = Position.find_or_create_by(id: response['id'])
      position.update(response)
    end
  end
end

module Support
  module Seeds
    def self.seed
      Position.delete_all

      Position.create_with(
        singular_name: 'Goalkeeper',
        singular_name_short: 'GKP',
        plural_name: 'Goalkeepers',
        plural_name_short: 'GKP'
      ).find_or_create_by(id: 1)

      Position.create_with(
        singular_name: 'Defender',
        singular_name_short: 'DEF',
        plural_name: 'Defenders',
        plural_name_short: 'DEF'
      ).find_or_create_by(id: 2)

      Position.create_with(
        singular_name: 'Midfielder',
        singular_name_short: 'MID',
        plural_name: 'Midfielders',
        plural_name_short: 'MID'
      ).find_or_create_by(id: 3)

      Position.create_with(
        singular_name: 'Forward',
        singular_name_short: 'FWD',
        plural_name: 'Forwards',
        plural_name_short: 'FWD'
      ).find_or_create_by(id: 4)
    end
  end
end

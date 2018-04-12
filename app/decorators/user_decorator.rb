class UserDecorator < ApplicationDecorator
  def fpl_teams_arr
    fpl_teams
      .joins(:league, :user)
      .joins('JOIN users AS commissioners ON leagues.commissioner_id = commissioners.id')
      .pluck_to_hash(
        'fpl_teams.id AS fpl_team_id',
        :name,
        :league_id,
        'leagues.name AS league_name',
        'commissioners.username AS commissioner_username',
        :total_score,
        :rank,
        'users.id = leagues.commissioner_id AS user_is_commissioner',
      ) do |hash|
        hash['league_status'] = League.find(hash['league_id']).status
        hash
      end
  end
end

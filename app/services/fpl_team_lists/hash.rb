class FplTeamLists::Hash < ApplicationInteraction
  object :fpl_team_list, class: FplTeamList
  object :user, class: User
  boolean :show_waiver_picks, default: false
  boolean :show_trade_groups, default: false
  boolean :show_list_positions, default: false
  boolean :user_owns_fpl_team, default: false

  validate :authorised_user, if: :show_trade_groups

  delegate :list_positions, :fpl_team, :round, to: :fpl_team_list

  def execute
    fpl_team_list_hash
  end

  def fpl_team_list_hash
    hash = {}
    hash[:fpl_team_list] = fpl_team_list
    hash[:round_status] = round.status
    hash[:editable] = editable.to_s
    hash[:show_score] = show_score.to_s

    if show_list_positions
      hash[:list_positions] = list_position_arr if show_list_positions
      hash[:grouped_list_positions] = grouped_list_position_arr
    end

    if show_trade_groups && user_owns_fpl_team
      hash[:in_trade_groups] = in_trade_groups
      hash[:out_trade_groups] = out_trade_groups
    end

    hash[:waiver_picks] = waiver_picks_arr if show_waiver_picks && user_owns_fpl_team
    hash
  end

  def user_owns_fpl_team
    fpl_team.user == user
  end

  def tradeable_players(player_ids: [])
    Player
      .order(position_id: :desc, total_points: :desc)
      .joins(:team)
      .joins(:position)
      .joins('JOIN fpl_teams_players ON fpl_teams_players.player_id = players.id')
      .joins('JOIN fpl_teams ON fpl_teams_players.fpl_team_id = fpl_teams.id')
      .joins('JOIN fpl_team_lists ON fpl_team_lists.fpl_team_id = fpl_teams.id')
      .joins(
        'JOIN list_positions ON list_positions.player_id = players.id AND ' \
        'list_positions.fpl_team_list_id = fpl_team_lists.id'
      )
      .where(fpl_team_lists: { id: fpl_team_list.id })
      .where.not(id: player_ids)
      .pluck_to_hash(
        :id,
        'fpl_teams.id AS fpl_team_id',
        'fpl_teams.name AS fpl_team_name',
        'fpl_team_lists.id AS fpl_team_list_id',
        'list_positions.id AS list_position_id',
        :singular_name_short,
        :last_name,
        :status,
        :news,
        :event_points,
        :total_points,
        :short_name
      )
      .uniq
      .map do |hash|
        hash['status'] = status_class_hash[hash['status'].to_sym]
        hash
      end
  end

  def all_in_players_tradeable
    Player
      .order(total_points: :desc)
      .joins(:team)
      .joins(:position)
      .joins('JOIN fpl_teams_players ON fpl_teams_players.player_id = players.id')
      .joins('JOIN fpl_teams ON fpl_teams_players.fpl_team_id = fpl_teams.id')
      .joins('JOIN leagues ON fpl_teams.league_id = leagues.id')
      .joins('JOIN fpl_team_lists ON fpl_team_lists.fpl_team_id = fpl_teams.id')
      .joins('JOIN rounds ON fpl_team_lists.round_id = rounds.id')
      .joins(
        'JOIN list_positions ON list_positions.player_id = players.id AND ' \
        'list_positions.fpl_team_list_id = fpl_team_lists.id'
      )
      .where(leagues: { id: fpl_team.league_id }, fpl_team_lists: { round_id: fpl_team_list.round_id })
      .where.not(fpl_team_lists: { id: fpl_team_list.id })
      .pluck_to_hash(
        :id,
        'fpl_teams.id AS fpl_team_id',
        'fpl_teams.name AS fpl_team_name',
        'fpl_team_lists.id AS fpl_team_list_id',
        'list_positions.id AS list_position_id',
        :singular_name_short,
        :last_name,
        :status,
        :news,
        :event_points,
        :total_points,
        :short_name
      ).map do |hash|
        hash['status'] = status_class_hash[hash['status'].to_sym]
        hash
      end
  end

  private

  def list_position_arr
    list_positions
      .joins(:player, :position, :fpl_team_list)
      .joins('JOIN teams ON teams.id = players.team_id')
      .joins(
        'LEFT JOIN fixtures ON fixtures.round_id = fpl_team_lists.round_id AND ' \
        '(fixtures.team_h_id = teams.id OR fixtures.team_a_id = teams.id)'
      )
      .joins(
        'LEFT JOIN teams AS opponents ON ' \
        '((fixtures.team_h_id = opponents.id AND fixtures.team_a_id = teams.id) OR ' \
        '(fixtures.team_a_id = opponents.id AND fixtures.team_h_id = teams.id))'
      )
      .joins(
        "LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS (players.player_fixture_histories) fixture_history ON " \
        "(fixture_history ->> 'fixture')::INT = fixtures.id AND " \
        "(((fixture_history ->> 'was_home')::BOOLEAN IS TRUE AND fixtures.team_h_id = teams.id) OR " \
        "((fixture_history ->> 'was_home')::BOOLEAN IS FALSE AND fixtures.team_a_id = teams.id))"
      )
      .order(role: :asc, position_id: :desc, player_id: :asc)
      .pluck_to_hash(
        :id,
        :player_id,
        :role,
        :first_name,
        :last_name,
        :position_id,
        :singular_name_short,
        :team_id,
        'teams.short_name AS team_short_name',
        :status,
        :total_points,
        :fpl_team_list_id,
        :team_h_id,
        :team_a_id,
        :event_points,
        :started,
        :finished,
        :finished_provisional,
        :news,
        'fixtures.id AS fixture_id',
        'fpl_team_lists.round_id AS round_id',
        'opponents.short_name AS opponent_short_name',
        'opponents.id AS opponent_id',
        :team_h_difficulty,
        :team_a_difficulty,
        "(fixture_history ->> 'minutes')::INT AS minutes",
        "(fixture_history ->> 'total_points')::INT AS fixture_points",
        "(fixture_history ->> 'was_home')::BOOLEAN AS home",
        "(fixtures.stats -> 'bps') AS bps",
      )
      .each_with_index.map do |hash, i|
        hash['i'] = i
        fixture_hash_attributes(hash) if hash['fixture_id']

        hash['fixture'] = hash['fixture_id'] ? "#{hash['opponent_short_name']} (#{hash['leg']})" : 'BYE'

        hash['role'] = hash['role'].gsub(/tarting|ubstitute_/, '').upcase

        hash['status'] = status_class_hash[hash['status'].to_sym]

        hash
      end
  end

  def fixture_hash_attributes(hash)
    fixture_points_bonus_calculator(hash) if hash['fixture_points']

    hash['leg'] = hash['home'] ? 'H' : 'A'

    hash['advantage'] =
      if hash['home']
        hash['team_h_difficulty'] - hash['team_a_difficulty']
      else
        hash['team_a_difficulty'] - hash['team_h_difficulty']
      end
  end

  def grouped_list_position_arr
    arr = non_duplicates_arr + duplicates_arr
    arr.group_by { |h| h['role'] }.each_with_object({}) do |(k, v), h|
      h[k] = v.group_by { |g| g['singular_name_short'] }
    end
  end

  def status_class_hash
    {
      a: 'fa fa-check-circle',
      d: 'fa fa-question-circle',
      i: 'fa fa-ambulance',
      n: 'fa fa-times-circle',
      s: 'fa fa-gavel',
      u: 'fa fa-times-circle',
    }
  end

  def show_score
    round.status == 'started' || round.status == 'finished'
  end

  def editable
    (round.status == 'mini_draft' ||  round.status == 'waiver' || round.status == 'trade') && user_owns_fpl_team
  end

  def out_trade_groups
    trade_groups =
      InterTeamTradeGroup.where(out_fpl_team_list_id: fpl_team_list&.id).order(:status).map do |tg|
        {
          id: tg.id,
          trades: tg.decorate.all_inter_team_trades,
          status: tg.status,
          in_fpl_team: tg.in_fpl_team_list.fpl_team,
        }
      end

    trade_groups.group_by { |tg| tg[:status] }
  end

  def in_trade_groups
    trade_groups = InterTeamTradeGroup
      .where(in_fpl_team_list_id: fpl_team_list&.id)
      .where.not(status: 'pending')
      .order(:status)
      .map do |tg|
        {
          id: tg.id,
          trades: tg.decorate.all_inter_team_trades,
          status: tg.status,
          out_fpl_team: tg.out_fpl_team_list.fpl_team,
        }
      end

    trade_groups.group_by { |tg| tg[:status] }
  end

  def waiver_picks_arr
    fpl_team_list.waiver_picks.order(:pick_number).joins(
      'JOIN players AS in_players ON waiver_picks.in_player_id = in_players.id'
    ).joins(
      'JOIN players AS out_players ON waiver_picks.out_player_id = out_players.id'
    ).joins(
      'JOIN teams AS in_teams ON in_players.team_id = in_teams.id'
    ).joins(
      'JOIN teams AS out_teams ON out_players.team_id = out_teams.id'
    ).joins(
      'JOIN positions ON in_players.position_id = positions.id'
    ).pluck_to_hash(
      :id,
      :pick_number,
      :status,
      :singular_name_short,
      :in_player_id,
      'in_players.first_name as in_first_name',
      'in_players.last_name as in_last_name',
      'in_teams.short_name as in_team_short_name',
      :out_player_id,
      'out_players.first_name as out_first_name',
      'out_players.last_name as out_last_name',
      'out_teams.short_name as out_team_short_name'
    )
  end

  def fixture_points_bonus_calculator(hash)
    return if hash['finished'] || !hash['started']

    hash['fixture_points'] += 3 if hash['bps'].first['element'] == hash['player_id']
    hash['fixture_points'] += 2 if hash['bps'].second['element'] == hash['player_id']
    hash['fixture_points'] += 1 if hash['bps'].third['element'] == hash['player_id']
  end

  def non_duplicates_arr
    list_position_arr.group_by { |h| h['player_id'] }.select { |k, v| v.size == 1 }.values.flatten
  end

  def duplicates_arr
   list_position_arr
    .group_by { |h| h['player_id'] }
    .select { |k, v| v.size > 1 }
    .map do |_k, v|
      v[0]['fixture'] = v[0]['fixture'] + ', ' + v[1]['fixture']
      v[0]['fixture_points'] += v[1]['fixture_points']
      v[0]
    end
  end

  def authorised_user
    return if user_owns_fpl_team
    errors.add(:base, 'You are not authorised to visit this page.')
  end
end

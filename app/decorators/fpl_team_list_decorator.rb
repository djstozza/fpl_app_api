class FplTeamListDecorator < ApplicationDecorator
  def list_position_arr
    list_positions
      .order(role: :asc, position_id: :desc)
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
        :stats,
        :finished,
        :finished_provisional,
        :news,
        'fixtures.id AS fixture_id',
        'fpl_team_lists.round_id AS round_id',
        'opponents.short_name AS opponent_short_name',
        'opponents.id AS opponent_id',
        :team_h_difficulty,
        :team_a_difficulty,
      ).each_with_index.map do |hash, i|
        hash['i'] = i
        fixture_history =
          Player.find(hash['player_id']).player_fixture_histories.find do |history|
            history['round'] == hash['round_id'] && history['opponent_team'] == hash['opponent_id']
          end

        if fixture_history
          hash['minutes'] = fixture_history['minutes']
          hash['fixture_points'] = fixture_history['total_points']
          hash['event_points'] = score_calculator(hash)
        end

        home_fixture = hash['team_id'] == hash['team_h_id']

        hash['leg'] = home_fixture ? 'H' : 'A'
        hash['fixture'] = "#{hash['opponent_short_name']} (#{hash['leg']})"

        hash['advantage'] =
          if home_fixture
            hash['team_a_difficulty'] - hash['team_h_difficulty']
          else
            hash['team_h_difficulty'] - hash['team_a_difficulty']
          end

        hash['role'] = hash['role'].gsub(/tarting|ubstitute_/, '').upcase

        hash['status'] = status_class_hash[hash['status'].to_sym]

        hash
      end
  end

  def grouped_list_position_arr
    arr = non_duplicates_arr + duplicates_arr
    arr.group_by { |h| h['role'] }.each_with_object({}) do |(k, v), h|
      h[k] = v.group_by { |g| g['singular_name_short'] }
    end
  end

  def waiver_picks_arr
    waiver_picks.order(:pick_number).joins(
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

  def status
    if round.mini_draft && Time.now < round.deadline_time - 1.day
      'mini_draft'
    elsif Time.now < round.deadline_time - 1.day && round.id != Round.first.id
      'waiver'
    elsif Time.now < round.deadline_time
      'trade'
    elsif round.deadline_time < Time.now && Time.now < round.deadline_time + round.deadline_time_game_offset
      'pre_game'
    else
      'started'
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
      .where(leagues: { id: fpl_team.league_id }, fpl_team_lists: { round_id: round_id })
      .where.not(fpl_team_lists: { id: id })
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

  def tradeable_players(ids = [])
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
      .where(fpl_team_lists: { id: id })
      .where.not(id: ids)
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

  def tradeable_fpl_teams
    fpl_team.league.fpl_teams.where.not(id: fpl_team_id).order(:name)
  end

  def inter_team_trade_group_hash
    {
      out_trade_groups: out_trade_groups,
      in_trade_groups: in_trade_groups,
    }
  end

  private

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

  def score_calculator(hash)
    return hash['fixture_points'] if hash['finished'] || !hash['started']
    bps_arr = hash.dig(:stats, :bps)
    hash['fixture_points'] += 3 if bps_arr.first['element'] == hash['id']
    hash['fixture_points'] += 2 if bps_arr.second['element'] == hash['id']
    hash['fixture_points'] += 1 if bps_arr.third['element'] == hash['id']
  end

  def out_trade_groups
    trade_groups = InterTeamTradeGroup.where(out_fpl_team_list_id: id).map do |tg|
      {
        id: tg.id,
        trades: tg.decorate.all_inter_team_trades,
        out_players_tradeable: tradeable_players(tg.out_player_ids),
        in_players_tradeable: tg.in_fpl_team_list.decorate.tradeable_players(tg.in_player_ids),
        status: tg.status,
        in_fpl_team: tg.in_fpl_team_list.fpl_team,
      }
    end
    trade_groups.group_by { |tg| tg[:status] }
  end

  def in_trade_groups
    trade_groups = InterTeamTradeGroup
      .where(in_fpl_team_list_id: id)
      .where.not(status: 'pending')
      .map do |tg|
        { id: tg.id, trades: tg.decorate.all_inter_team_trades, status: tg.status, out_fpl_team: tg.out_fpl_team_list.fpl_team }
      end

      trade_groups.group_by { |tg| tg[:status] }
  end
end

class LeagueDecorator < ApplicationDecorator
  def fpl_teams_arr
    fpl_teams.joins(:user).order(total_score: :desc, name: :asc).pluck_to_hash(
      'fpl_teams.id AS fpl_team_id',
      'users.id AS user_id',
      :username,
      :name,
      :draft_pick_number,
      :mini_draft_pick_number,
      :rank,
      :total_score,
    )
  end

  def picked_players
    PlayerDecorator.new(players).players_hash
  end

  def unpicked_players
    players = Player.where.not(id: self.players.pluck(:id)).where('players.created_at < ?', drafting_deadline_time)
    PlayerDecorator.new(players).players_hash
  end

  def current_draft_pick
    draft_picks.order(:pick_number).find_by(player_id: nil, mini_draft: false)
  end

  def all_draft_picks
    draft_picks.order(:pick_number).includes(:player, :fpl_team, player: [:team, :position]).pluck_to_hash(
      :id,
      :pick_number,
      :fpl_team_id,
      'fpl_teams.name as fpl_team_name',
      :player_id,
      :position_id,
      :singular_name_short,
      :team_id,
      :short_name,
      'teams.name as team_name',
      :first_name,
      :last_name,
      :mini_draft,
    )
  end

  def all_non_passed_mini_draft_picks
    mini_draft_picks.order(:pick_number).where.not(passed: true).joins(:fpl_team).joins(
      'JOIN players AS in_players ON mini_draft_picks.in_player_id = in_players.id'
    ).joins(
      'JOIN players AS out_players ON mini_draft_picks.out_player_id = out_players.id'
    ).joins(
      'JOIN teams AS in_teams ON in_players.team_id = in_teams.id'
    ).joins(
      'JOIN teams AS out_teams ON out_players.team_id = out_teams.id'
    ).joins(
      'JOIN positions ON in_players.position_id = positions.id'
    ).pluck_to_hash(
      :id,
      :pick_number,
      :singular_name_short,
      :in_player_id,
      'fpl_teams.name as fpl_team_name',
      'in_players.first_name as in_first_name',
      'in_players.last_name as in_last_name',
      'in_teams.short_name as in_team_short_name',
      :out_player_id,
      'out_players.first_name as out_first_name',
      'out_players.last_name as out_last_name',
      'out_teams.short_name as out_team_short_name',
    )
  end

  def draft_response_hash
    fpl_team_decorator = current_draft_pick&.fpl_team&.decorate

    {
      league: self,
      fpl_teams: fpl_teams_arr,
      draft_picks: all_draft_picks,
      current_draft_pick: current_draft_pick,
      current_draft_pick_user: current_draft_pick&.user,
      unpicked_players: unpicked_players,
      mini_draft_picked: (fpl_team_decorator&.mini_draft_picked? || current_draft_pick.blank?),
      all_players_picked: (fpl_team_decorator&.all_players_picked? || current_draft_pick.blank?),
    }
  end

  def mini_draft_response_hash
    {
      league: self,
      fpl_teams: fpl_teams.order(:name),
      mini_draft_picks: all_non_passed_mini_draft_picks,
      current_mini_draft_pick: current_mini_draft_pick,
      current_mini_draft_pick_user: current_mini_draft_pick&.user,
      unpicked_players: unpicked_players,
    }
  end

  def current_mini_draft_pick
    mini_draft_picks.build(pick_number: next_mini_draft_pick_number, fpl_team: next_fpl_team, season: season)
  end

  def season
    Time.now > Round::WINTER_MINI_DRAFT_DEALINE ? 'winter' : 'summer'
  end

  def next_mini_draft_pick_number
    (mini_draft_picks.where(round: Round.current).order(:pick_number).last&.pick_number || 0) + 1
  end

  def all_fpl_teams_passed?
    fpl_teams.all? do |fpl_team|
      last_picks = fpl_team.mini_draft_picks.public_send(season).last(2)
      last_picks.any? && last_picks.count >= 2 && last_picks.all?(&:passed)
    end
  end

  def consecutive_passes
    last_mini_draft_picks&.any? && last_mini_draft_picks.count >= 2 && last_mini_draft_picks.all?(&:passed)
  end

  def next_fpl_team
    return if all_fpl_teams_passed?
    divider = next_mini_draft_pick_number % (2 * fpl_team_count)

    index = divider == 0 ? divider : divider - 1

    if index < fpl_team_count
      fpl_team_arr.reverse[index % fpl_team_count]
    else
      fpl_team_arr[index % fpl_team_count]
    end
  end

  private

  def drafting_deadline_time
    if Time.now < Round::SUMMER_MINI_DRAFT_DEADLINE
      Round.first.deadline_time
    elsif Time.now < Round::WINTER_MINI_DRAFT_DEALINE
      Round::SUMMER_MINI_DRAFT_DEADLINE
    else
      Round::WINTER_MINI_DRAFT_DEALINE
    end
  end

  def fpl_team_arr
    fpl_teams.order(:rank)
  end

  def fpl_team_count
    fpl_team_arr.count
  end

  def last_mini_draft_picks
    next_fpl_team&.mini_draft_picks&.public_send(season)&.last(2)
  end
end

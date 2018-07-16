class DraftPicks::Hash < ApplicationInteraction
  object :league, class: League

  delegate :fpl_teams, :draft_picks, :players, to: :league

  def execute
    hash
  end

  def hash
    {
      league: league,
      fpl_teams: fpl_teams_arr,
      draft_picks: all_draft_picks,
      current_draft_pick: current_draft_pick,
      current_draft_pick_user: current_draft_pick&.user,
      unpicked_players: unpicked_players,
      mini_draft_picked: mini_draft_picked?,
      all_players_picked: all_players_picked?,
    }
  end

  private

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

  def unpicked_players
    players = Player.where.not(id: self.players.pluck(:id)).where('players.created_at < ?', drafting_deadline_time)
    PlayerDecorator.new(players).players_hash
  end


  def drafting_deadline_time
    if Time.now < Round.summer_mini_draft_deadline
      Round.first.deadline_time
    elsif Time.now < Round.winter_mini_draft_deadline
      Round.summer_mini_draft_deadline
    else
      Round.winter_mini_draft_deadline
    end
  end

  def current_fpl_team
    current_draft_pick&.fpl_team
  end

  def mini_draft_picked?
    return true if current_fpl_team.blank?
    current_fpl_team.draft_picks.find_by(mini_draft: true).present?
  end

  def all_players_picked?
    return true if current_fpl_team.blank?
    current_fpl_team.draft_picks.where.not(player: nil).count == FplTeam::QUOTAS[:players]
  end

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
end

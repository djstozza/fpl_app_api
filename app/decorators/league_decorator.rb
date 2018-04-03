class LeagueDecorator < ApplicationDecorator
  def fpl_teams_arr
    fpl_teams.joins(:user).order(total_score: :desc, name: :asc).pluck_to_hash(
      'fpl_teams.id AS fpl_team_id',
      'users.id AS user_id',
      :username,
      :name,
      :draft_pick_number,
      :total_score
    )
  end

  def picked_players
    PlayerDecorator.new(players).players_hash
  end

  def unpicked_players
    deadline_time =
      if Time.now < Round::SUMMER_MINI_DRAFT_DEADLINE
        Round.first.deadline_time
      elsif Time.now < Round::WINTER_MINI_DRAFT_DEALINE
        Round::SUMMER_MINI_DRAFT_DEADLINE
      else
        Round::WINTER_MINI_DRAFT_DEALINE
      end

    players = Player.where.not(id: self.players.pluck(:id)).where('players.created_at < ?', deadline_time)
    PlayerDecorator.new(players).players_hash
  end

  def current_draft_pick
    draft_picks.order(:pick_number).where(player_id: nil).first
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
      :last_name
    )
  end
end

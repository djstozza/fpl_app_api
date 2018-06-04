class FplTeamLists::ProcessSubstitution < ApplicationInteraction
  object :list_position, class: ListPosition
  object :substitute_list_position, class: ListPosition
  object :user, class: User

  object :fpl_team_list, class: FplTeamList, default: -> { list_position.fpl_team_list }
  object :round, class: Round, default: -> { fpl_team_list.round }
  object :fpl_team, class: FplTeam, default: -> { fpl_team_list.fpl_team }
  object :player, class: Player, default: -> { list_position.player }
  object :substitute_player, class: Player, default: -> { substitute_list_position.player }

  validate :round_is_current
  validate :before_deadline_time
  validate :authorised_user
  validate :player_team_presnece
  validate :substitute_player_team_presence
  validate :valid_starting_line_up

  def execute
    role = list_position.role
    list_position.update(role: substitute_list_position.role)
    errors.merge!(list_position.errors)

    substitute_list_position.update(role: role)
    errors.merge!(substitute_list_position.errors)
  end

  def fpl_team_list_hash
    FplTeamLists::Hash.run(
      fpl_team_list: fpl_team_list,
      user: user,
      show_list_positions: true,
      show_waiver_picks: true,
      user_owns_fpl_team: fpl_team.user == user,
    ).result
  end


  private

  def round_is_current
    return if round == Round.current
    errors.add(:base, "You can only make changes to your squad's line up for the upcoming round.")
  end

  def before_deadline_time
    return if Time.now < round.deadline_time
    errors.add(:base, 'The deadline time for making substitutions has passed.')
  end

  def authorised_user
    return if fpl_team.user == user
    errors.add(:base, 'You are not authorised to make changes to this team.')
  end

  def player_team_presnece
    return if fpl_team.players.include?(player)
    errors.add(:base, "#{player.decorate.name} isn't part of your team.")
  end

  def substitute_player_team_presence
    return if fpl_team.players.include?(substitute_player)
    errors.add(:base, "#{substitute_player.decorate.name} isn't part of your team.")
  end

  def valid_starting_line_up
    return if list_position.decorate.substitute_options.include?(substitute_list_position.player_id)
    errors.add(:base, 'Invalid substitution.')
  end
end

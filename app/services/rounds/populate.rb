class Rounds::Populate < ApplicationInteraction
  def execute
    response.each do |round_json|
      round = Round.find_or_create_by(name: round_json['name'])
      round.update(
        deadline_time: round_json['deadline_time'],
        finished: round_json['finished'],
        data_checked: round_json['data_checked'],
        deadline_time_epoch: round_json['deadline_time_epoch'],
        deadline_time_game_offset: round_json['deadline_time_game_offset'],
        is_previous: round_json['is_previous'],
        is_current: round_json['is_current'],
        is_next: round_json['is_next'],
      )
    end

    return unless Round.where(mini_draft: true).any?

    rounds = Round.order(:deadline_time)

    round = rounds.find_by('deadline_time > ?', Round.summer_mini_draft_deadline + 3.days).update(mini_draft: true)
    errors.merge!(round.errors)

    round = rounds.find_by('deadline_time > ?', Round.winter_mini_draft_deadline + 3.days).update(mini_draft: true)
    errors.merge!(round.errors)
  end

  def response
    HTTParty.get('https://fantasy.premierleague.com/drf/events')
  end
end

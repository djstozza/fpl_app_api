class AddMiniDraftToRounds < ActiveRecord::Migration[5.1]
  def up
    return if column_exists? :rounds, :mini_draft, :boolean
    add_column :rounds, :mini_draft, :boolean
    rounds = Round.order(:deadline_time)
    rounds.find_by('deadline_time > ?', Round.summer_mini_draft_deadline + 3.days).update(mini_draft: true)
    rounds.find_by('deadline_time > ?', Round.winter_mini_draft_deadline + 3.days).update(mini_draft: true)
  end

  def down
    return unless column_exists? :rounds, :mini_draft, :boolean
    remove_column :rounds, :mini_draft, :boolean
  end
end

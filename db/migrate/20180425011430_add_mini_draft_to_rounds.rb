class AddMiniDraftToRounds < ActiveRecord::Migration[5.1]
  def up
    add_column :rounds, :mini_draft, :boolean
    rounds = Round.order(:deadline_time)
    rounds.where('deadline_time > ?', Round.summer_mini_draft_deadline).first.update(mini_draft: true)
    rounds.where('deadline_time > ?', Round.winter_mini_draft_deadline).first.update(mini_draft: true)
  end

  def down
    remove_column :rounds, :mini_draft, :boolean
  end
end

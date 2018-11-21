class AddMiniDraftToRounds < ActiveRecord::Migration[5.1]
  def up
    return if column_exists? :rounds, :mini_draft, :boolean
    add_column :rounds, :mini_draft, :boolean
  end

  def down
    return unless column_exists? :rounds, :mini_draft, :boolean
    remove_column :rounds, :mini_draft, :boolean
  end
end

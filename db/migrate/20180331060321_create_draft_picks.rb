class CreateDraftPicks < ActiveRecord::Migration[5.1]
  def change
    create_table :draft_picks do |t|
      t.integer :pick_number
      t.boolean :mini_draft, default: false
      t.references :league, index: true
      t.references :player, index: true
      t.references :fpl_team, index: true
      t.timestamps null: false
    end
  end
end

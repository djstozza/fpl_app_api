class CreateMiniDraftPicks < ActiveRecord::Migration[5.1]
  def change
    create_table :mini_draft_picks do |t|
      t.integer :pick_number
      t.integer :season
      t.boolean :passed, default: false
      t.references :league, index: true
      t.references :out_player, index: true, foreign_key: { to_table: :players }
      t.references :in_player, index: true, foreign_key: { to_table: :players }
      t.references :fpl_team, index: true
      t.references :round, index: true
      t.timestamps null: false
    end
  end
end

class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :code
      t.string :short_name
      t.integer :strength
      t.integer :position
      t.integer :played
      t.integer :win
      t.integer :loss
      t.integer :draw
      t.integer :points
      t.integer :form
      t.integer :link_url
      t.integer :strength_overall_home
      t.integer :strength_overall_away
      t.integer :strength_attack_home
      t.integer :strength_attack_away
      t.integer :strength_defence_home
      t.integer :strength_defence_away
      t.integer :team_division
      t.timestamps null: false
    end
  end
end

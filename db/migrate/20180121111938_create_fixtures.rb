class CreateFixtures < ActiveRecord::Migration[5.1]
  def change
    create_table :fixtures do |t|
      t.string :kickoff_time
      t.string :deadline_time
      t.integer :team_h_difficulty
      t.integer :team_a_difficulty
      t.integer :code
      t.integer :team_h_score
      t.integer :team_a_score
      t.integer :minutes
      t.boolean :started
      t.boolean :finished
      t.boolean :provisional_start_time
      t.boolean :finished_provisional
      t.integer :round_day
      t.references :round, index: true
      t.references :team_h, references: :team, index: true
      t.references :team_a, references: :team, index: true
      t.timestamps null: false
    end
  end
end

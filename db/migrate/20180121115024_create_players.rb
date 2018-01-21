class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name
      t.integer :squad_number
      t.integer :team_code
      t.string :photo
      t.string :web_name
      t.string :status
      t.integer :code
      t.string :news
      t.integer :now_cost
      t.integer :chance_of_playing_this_round
      t.integer :chance_of_playing_next_round
      t.decimal :value_form
      t.decimal :value_season
      t.integer :cost_change_start
      t.integer :cost_change_event
      t.integer :cost_change_start_fall
      t.integer :cost_change_event_fall
      t.boolean :in_dreamteam
      t.integer :dreamteam_count
      t.decimal :selected_by_percent
      t.decimal :form
      t.decimal :selected_by_percent
      t.integer :transfers_out
      t.integer :transfers_in
      t.integer :transfers_out_event
      t.integer :transfers_in_event
      t.integer :loans_in
      t.integer :loans_out
      t.integer :loaned_in
      t.integer :loaned_out
      t.integer :total_points
      t.integer :event_points
      t.decimal :points_per_game
      t.decimal :ep_this
      t.decimal :ep_next
      t.boolean :special
      t.integer :minutes
      t.integer :goals_scored
      t.integer :assists
      t.integer :clean_sheets
      t.integer :goals_conceded
      t.integer :own_goals
      t.integer :penalties_saved
      t.integer :penalties_missed
      t.integer :yellow_cards
      t.integer :red_cards
      t.integer :saves
      t.integer :bonus
      t.integer :bps
      t.decimal :influence
      t.decimal :creativity
      t.decimal :threat
      t.decimal :ict_index
      t.integer :ea_index
      t.jsonb :player_fixture_histories
      t.jsonb :player_past_histories
      t.references :position, index: true
      t.references :team, index: true
      t.timestamps null: false
    end
  end
end

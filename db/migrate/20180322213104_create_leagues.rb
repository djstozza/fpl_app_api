class CreateLeagues < ActiveRecord::Migration[5.1]
  def change
    create_table :leagues do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.boolean :active, default: false
      t.timestamps null: false
    end

    add_index :leagues, :name, unique: true
    add_reference :leagues, :commissioner, index: true, foreign_key: { to_table: :users }
  end
end

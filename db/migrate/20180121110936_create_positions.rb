class CreatePositions < ActiveRecord::Migration[5.1]
  def change
    create_table :positions do |t|
      t.string :singular_name
      t.string :singular_name_short
      t.string :plural_name
      t.string :plural_name_short
      t.timestamps null: false
    end
  end
end

class CreatePilots < ActiveRecord::Migration[7.1]
  def change
    create_table :pilots do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :airport_role, default: 1, null: false
      t.string :aircraft_type
      t.text :bio
      t.references :airport, null: false, foreign_key: true

      t.timestamps
    end
  end
end

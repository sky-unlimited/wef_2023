class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.references :pilot, null: false, foreign_key: true
      t.text :bio
      t.string :aircraft_type

      t.timestamps
    end
  end
end

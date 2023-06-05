class CreateRunways < ActiveRecord::Migration[7.0]
  def change
    create_table :runways do |t|
      t.references :airport, null: false, foreign_key: true
      t.integer :internal_id, null: false
      t.integer :length_meter
      t.integer :width_meter
      t.string :surface
      t.string :le_ident
      t.string :he_ident
      t.string :le_heading_degT
      t.string :he_heading_degT
      t.boolean :lighted, default: 0

      t.timestamps
    end
  end
end

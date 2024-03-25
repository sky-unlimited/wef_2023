class CreateVisitedAirports < ActiveRecord::Migration[7.1]
  def change
    create_table :visited_airports do |t|
      t.references :pilot, null: false, foreign_key: true
      t.references :airport, null: false, foreign_key: true

      t.timestamps
    end
  end
end

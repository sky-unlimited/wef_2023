class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :code, null: false
      t.string :name
      t.string :continent

      t.timestamps
    end

    add_index :countries, :id, unique: true
  end
end

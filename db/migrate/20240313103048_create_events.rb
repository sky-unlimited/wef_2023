class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :airport, null: false, foreign_key: true
      # 'type' is a reserved keyword in Ruby, so we use 'kind' instead
      t.integer :kind
      t.date :start_date
      t.date :end_date
      t.string :image_link
      t.string :url

      t.timestamps
    end
  end
end

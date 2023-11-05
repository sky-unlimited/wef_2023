class CreateSubscribers < ActiveRecord::Migration[7.0]
  def change
    create_table :subscribers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.boolean :accept_private_data_policy
      t.string :unsubscribe_hash

      t.timestamps
    end
  end
end

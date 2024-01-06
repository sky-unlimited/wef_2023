class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      t.string :last_name
      t.string :first_name
      t.string :company
      t.string :email, null: false
      t.string :phone
      t.integer :category, null:false
      t.text :description, null:false
      t.boolean :accept_privacy_policy
      t.string :ip_address, null:false
      t.string :honey_pot

      t.timestamps
    end
  end
end

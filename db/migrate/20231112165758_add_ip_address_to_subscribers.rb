class AddIpAddressToSubscribers < ActiveRecord::Migration[7.0]
  def change
    add_column :subscribers, :ip_address, :string, null: false, default: "::1", unique: true
  end
end

class AddColumnHoneyBotToSubscribers < ActiveRecord::Migration[7.1]
  def change
    add_column :subscribers, :honey_bot, :string
  end
end

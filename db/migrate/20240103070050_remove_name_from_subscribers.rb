class RemoveNameFromSubscribers < ActiveRecord::Migration[7.1]
  def change
    remove_column :subscribers, :name, :string
  end
end

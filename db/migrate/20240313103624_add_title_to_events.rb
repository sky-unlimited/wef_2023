class AddTitleToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :title, :string
  end
end

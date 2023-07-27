class AddUsernameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string, null: false, default: "user123"
    
    # Update existing users with a temporary default username
    User.where(username: nil).each do |user|
      user.update!(username: "user#{user.id}")
    end
  end
end

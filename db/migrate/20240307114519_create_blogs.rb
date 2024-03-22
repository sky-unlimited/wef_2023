class CreateBlogs < ActiveRecord::Migration[7.1]
  def change
    create_table :blogs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :keywords
      t.boolean :published, default: false
      t.boolean :scheduled_email, default: false
      t.boolean :sent_email, default: false
      t.datetime :sent_email_date

      t.timestamps
    end
  end
end

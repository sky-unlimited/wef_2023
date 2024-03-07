class CreateBlogs < ActiveRecord::Migration[7.1]
  def change
    create_table :blogs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :keywords
      t.integer :status, null: false
      t.datetime :blog_publication_date
      t.datetime :email_publication_date

      t.timestamps
    end
  end
end

class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :target_id, null: false
      t.integer :target_type, null: false
      t.integer :action, null: false

      t.timestamps
    end
  end
end

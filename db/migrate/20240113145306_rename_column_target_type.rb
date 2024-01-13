class RenameColumnTargetType < ActiveRecord::Migration[7.1]
  def change
    rename_column :audit_logs, :target_type, :target_controller
  end
end

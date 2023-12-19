class AddIpAddressToAuditLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :audit_logs, :ip_address, :string, null: false, default: "::1"
  end
end

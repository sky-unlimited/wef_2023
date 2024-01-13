require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  test "Correct audit_log Should save" do
    audit = audit_logs(:audit_1_ok)
    assert audit.save
  end

  test "Missing user should not save" do
    audit = AuditLog.new(target_controller: 0, target_id: 0, action: "created") 
    assert_not audit.save
  end

  test "Missing target_id should not save" do
    audit = AuditLog.new(user: users(:regular_user), target_controller: "fuel_stations", action: "created") 
    assert_not audit.save
  end

  test "Missing target_controller should not save" do
    audit = AuditLog.new(user: users(:regular_user), target_id: 0, action: "created") 
    assert_not audit.save
  end

  test "Missing action should not save" do
    audit = AuditLog.new(user: users(:regular_user), target_id: 0, target_controller: "fuel_stations") 
    assert_not audit.save
  end
end

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # provided emails should have valid domain names
  test "Correct user should save" do
    user = users(:regular_user)
    assert user.save
  end

  test "new created user should have a role" do
    user = User.new(email: "test@as-consult.io", password: "Hello123", )
    user.save!
    assert_equal user.role.nil?, false
  end

  test "new created user should icomply with password policy" do
    user = User.new(email: "test@as-consult.io", password: "hello123", )
    assert_not user.save
  end

  test "user invalid email should not save" do
    assert_not User.new(email: "wrong_email", password: "Hello123", username: "testtest").save
  end

  test "New user should have default pilot preferences" do
    user = users(:regular_user)
    assert_not_nil user.pilot, "The new user should have a default pilot profile"
  end

  test "already taken username should not save" do
    User.new(email: "test2@as-consult.io", password: "Hello123", username: "josmith66").save
    assert_not User.new(email: "test2@as-consult.io", password: "Hello123", username: "josmith66").save
  end
end

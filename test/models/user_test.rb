require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "student identity_label includes classroom, group, and role" do
    # alice: classroom 1班, group 1, student
    assert_equal "1班1组学员", users(:alice).identity_label
  end

  test "coach identity_label includes classroom, group, and role" do
    # coach_bob: classroom 1班, group 1, coach
    assert_equal "1班1组教练", users(:coach_bob).identity_label
  end

  test "assistant identity_label includes classroom without group" do
    # admin_eve: classroom 1班, no group, assistant
    assert_equal "1班辅导员", users(:admin_eve).identity_label
  end
end

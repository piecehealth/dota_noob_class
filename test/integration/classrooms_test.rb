require "test_helper"

class ClassroomsTest < ActionDispatch::IntegrationTest
  test "guest is redirected to login" do
    get mine_classrooms_path
    assert_redirected_to new_session_path
  end

  test "student cannot access my classroom" do
    sign_in users(:alice)
    get mine_classrooms_path
    assert_redirected_to root_path
  end

  test "coach sees their classroom" do
    sign_in users(:coach_bob)
    get mine_classrooms_path
    assert_response :success
    assert_select "h1", text: "我的班级"
  end

  test "coach sees group tabs" do
    sign_in users(:coach_bob)
    get mine_classrooms_path
    assert_response :success
    assert_select "input[type=radio][name=classroom_tabs]"
  end

  test "admin can access my classroom" do
    sign_in users(:admin_eve)
    get mine_classrooms_path
    assert_response :success
  end
end

require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest
  test "guest is redirected to login" do
    get matches_user_path(users(:alice))
    assert_redirected_to new_session_path
  end

  test "student can view their own matches" do
    sign_in users(:alice)
    get matches_user_path(users(:alice))
    assert_response :success
    assert_select "h1", text: users(:alice).display_name
  end

  test "student cannot view another student's matches" do
    sign_in users(:alice)
    get matches_user_path(users(:pending))
    assert_redirected_to root_path
  end

  test "coach can view any student's matches" do
    sign_in users(:coach_bob)
    get matches_user_path(users(:alice))
    assert_response :success
  end

  test "admin can view any student's matches" do
    sign_in users(:admin_eve)
    get matches_user_path(users(:alice))
    assert_response :success
  end
end

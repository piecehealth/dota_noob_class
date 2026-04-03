require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest
  test "guest can view any user's matches" do
    get matches_user_path(users(:alice))
    assert_response :success
    assert_select "h1", text: users(:alice).display_name
  end

  test "logged in user can view any user's matches" do
    sign_in users(:alice)
    get matches_user_path(users(:pending))
    assert_response :success
  end

  test "page shows user's display name" do
    get matches_user_path(users(:alice))
    assert_response :success
    assert_select "h1", text: users(:alice).display_name
  end
end

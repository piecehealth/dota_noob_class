require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  test "shows login form" do
    get new_session_path
    assert_response :success
  end

  test "already logged in user is redirected from login page" do
    sign_in users(:alice)
    get new_session_path
    assert_redirected_to root_path
  end

  test "successful login redirects to root and sets session" do
    post session_path, params: { username: "alice", password: "password123" }
    assert_redirected_to root_path
    assert_equal users(:alice).id, session[:user_id]
  end

  test "wrong password renders login form with error" do
    post session_path, params: { username: "alice", password: "wrongpassword" }
    assert_response :unprocessable_entity
  end

  test "unknown username renders login form with error" do
    post session_path, params: { username: "nobody", password: "password123" }
    assert_response :unprocessable_entity
  end

  test "logout clears session and redirects to login" do
    sign_in users(:alice)
    delete session_path
    assert_redirected_to new_session_path
    assert_nil session[:user_id]
  end
end

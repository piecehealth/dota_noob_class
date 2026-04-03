require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  test "shows login form" do
    get new_session_path
    assert_response :success
  end

  test "already logged in user is redirected from login page" do
    sign_in users(:admin_eve)
    get new_session_path
    assert_redirected_to root_path
  end

  test "successful login redirects to root and sets session" do
    post session_path, params: { username: "eve", password: "password123" }
    assert_redirected_to root_path
    assert_equal users(:admin_eve).id, session[:user_id]
  end

  test "wrong password redirects to login with alert" do
    post session_path, params: { username: "eve", password: "wrongpassword" }
    assert_redirected_to new_session_path
  end

  test "unknown username redirects to login with alert" do
    post session_path, params: { username: "nobody", password: "password123" }
    assert_redirected_to new_session_path
  end

  test "non-admin user cannot login" do
    post session_path, params: { username: "alice", password: "password123" }
    assert_redirected_to new_session_path
  end

  test "logout clears session and redirects to login" do
    sign_in users(:admin_eve)
    delete session_path
    assert_redirected_to new_session_path
    assert_nil session[:user_id]
  end
end

require "test_helper"

class ActivationsTest < ActionDispatch::IntegrationTest
  test "shows activation form for valid token" do
    get activation_path(users(:pending).activation_token)
    assert_response :success
  end

  test "invalid token redirects to login with alert" do
    get activation_path("totallyinvalidtoken")
    assert_redirected_to new_session_path
  end

  test "already activated token redirects to login" do
    get activation_path(users(:alice).activation_token)
    assert_redirected_to new_session_path
  end

  test "successful activation logs in user and redirects to root" do
    patch activation_path(users(:pending).activation_token),
      params: { user: { username: "zhangsan", password: "newpassword1", password_confirmation: "newpassword1" } }
    assert_redirected_to root_path
    assert_equal users(:pending).id, session[:user_id]
    assert users(:pending).reload.activated?
  end

  test "short password re-renders form" do
    patch activation_path(users(:pending).activation_token),
      params: { user: { username: "zhangsan", password: "short", password_confirmation: "short" } }
    assert_response :unprocessable_entity
  end

  test "mismatched passwords re-renders form" do
    patch activation_path(users(:pending).activation_token),
      params: { user: { username: "zhangsan", password: "newpassword1", password_confirmation: "mismatch" } }
    assert_response :unprocessable_entity
  end

  test "patching already activated token redirects to login" do
    patch activation_path(users(:alice).activation_token),
      params: { user: { username: "alice2", password: "newpassword1", password_confirmation: "newpassword1" } }
    assert_redirected_to new_session_path
  end
end

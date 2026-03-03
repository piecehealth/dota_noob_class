require "test_helper"

class PasswordsTest < ActionDispatch::IntegrationTest
  test "unauthenticated user is redirected to login" do
    get edit_password_path
    assert_redirected_to new_session_path
  end

  test "shows change password form when logged in" do
    sign_in users(:alice)
    get edit_password_path
    assert_response :success
  end

  test "successful password change redirects back to edit page" do
    sign_in users(:alice)
    patch password_path, params: { current_password: "password123", password: "newpassword1", password_confirmation: "newpassword1" }
    assert_redirected_to edit_password_path
  end

  test "wrong current password re-renders form with error" do
    sign_in users(:alice)
    patch password_path, params: { current_password: "wrongpassword", password: "newpassword1", password_confirmation: "newpassword1" }
    assert_response :unprocessable_entity
  end

  test "short new password re-renders form with error" do
    sign_in users(:alice)
    patch password_path, params: { current_password: "password123", password: "short", password_confirmation: "short" }
    assert_response :unprocessable_entity
  end

  test "mismatched new passwords re-renders form with error" do
    sign_in users(:alice)
    patch password_path, params: { current_password: "password123", password: "newpassword1", password_confirmation: "mismatch" }
    assert_response :unprocessable_entity
  end
end

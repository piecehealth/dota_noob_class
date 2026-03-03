require "test_helper"

class CoachingRequestsTest < ActionDispatch::IntegrationTest
  # index (coach)
  test "guest is redirected from index" do
    get coaching_requests_path
    assert_redirected_to new_session_path
  end

  test "student cannot access coach index" do
    sign_in users(:alice)
    get coaching_requests_path
    assert_redirected_to root_path
  end

  test "coach sees coaching requests index" do
    sign_in users(:coach_bob)
    get coaching_requests_path
    assert_response :success
    assert_select "h1", text: "复盘请求"
  end

  # mine (student)
  test "guest is redirected from mine" do
    get mine_coaching_requests_path
    assert_redirected_to new_session_path
  end

  test "coach cannot access mine" do
    sign_in users(:coach_bob)
    get mine_coaching_requests_path
    assert_redirected_to root_path
  end

  test "student sees their own coaching requests" do
    sign_in users(:alice)
    get mine_coaching_requests_path
    assert_response :success
    assert_select "h1", text: "我的复盘"
  end
end

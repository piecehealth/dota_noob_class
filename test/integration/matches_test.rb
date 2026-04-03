require "test_helper"

class MatchesTest < ActionDispatch::IntegrationTest
  test "guest is redirected to login" do
    get mine_matches_path
    assert_redirected_to new_session_path
  end

  test "logged-in user sees their matches" do
    sign_in users(:alice)
    get mine_matches_path
    assert_response :success
    assert_select "a", text: /8000000001/
    assert_select "a", text: /8000000002/
  end

  test "matches are ordered by played_at descending" do
    sign_in users(:alice)
    get mine_matches_path
    body = response.body
    pos1 = body.index("8000000001")
    pos2 = body.index("8000000002")
    assert pos1 && pos2, "both match IDs should appear in response"
    assert pos2 < pos1, "newer match should appear before older match"
  end
end

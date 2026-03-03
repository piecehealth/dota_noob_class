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
    assert_select "div", text: /#8000000001/
    assert_select "div", text: /#8000000002/
  end

  test "matches are ordered by played_at descending" do
    sign_in users(:alice)
    get mine_matches_path
    body = response.body
    assert body.index("#8000000002") < body.index("#8000000001"),
      "newer match should appear before older match"
  end
end

require "test_helper"

class MatchesCommentsTest < ActionDispatch::IntegrationTest
  test "guest is redirected" do
    post match_coaching_request_comments_path(matches(:loss_match)),
         params: { comment: { body: "<p>笔记内容</p>" } }
    assert_redirected_to new_session_path
  end

  test "logged-in user can post a comment" do
    sign_in users(:coach_bob)
    assert_difference "Comment.count" do
      post match_coaching_request_comments_path(matches(:loss_match)),
           params: { comment: { body: "<p>很好的一场复盘</p>" } }
    end
    assert_redirected_to match_coaching_request_path(matches(:loss_match))
    assert_equal "复盘笔记已发布", flash[:notice]
  end

  test "empty body is rejected" do
    sign_in users(:alice)
    assert_no_difference "Comment.count" do
      post match_coaching_request_comments_path(matches(:loss_match)),
           params: { comment: { body: "" } }
    end
    assert_equal "笔记内容不能为空", flash[:alert]
  end
end

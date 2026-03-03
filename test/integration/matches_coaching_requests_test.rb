require "test_helper"

class MatchesCoachingRequestsTest < ActionDispatch::IntegrationTest
  # show
  test "guest is redirected from show" do
    get match_coaching_request_path(matches(:win_match))
    assert_redirected_to new_session_path
  end

  test "student can view coaching request" do
    sign_in users(:alice)
    get match_coaching_request_path(matches(:win_match))
    assert_response :success
  end

  # create
  test "student can create a coaching request" do
    match = new_match_for(users(:alice), match_id: 9000001)
    sign_in users(:alice)
    assert_difference "CoachingRequest.count" do
      post match_coaching_request_path(match)
    end
    assert_redirected_to match_coaching_request_path(match)
    assert_equal "复盘请求已提交", flash[:notice]
  end

  test "coach cannot create a coaching request" do
    match = new_match_for(users(:alice), match_id: 9000002)
    sign_in users(:coach_bob)
    post match_coaching_request_path(match)
    assert_equal "只有学员可以发起复盘请求", flash[:alert]
  end

  test "student cannot create duplicate coaching request" do
    sign_in users(:alice)
    post match_coaching_request_path(matches(:win_match))
    assert_equal "该比赛已有复盘请求", flash[:alert]
  end

  test "student is blocked when weekly limit reached" do
    # fixtures already have 2 requests; create a 3rd to hit the limit of 3
    extra = new_match_for(users(:alice), match_id: 9000003)
    CoachingRequest.create!(match: extra, student: users(:alice))

    new_match = new_match_for(users(:alice), match_id: 9000004)
    sign_in users(:alice)
    post match_coaching_request_path(new_match)
    assert_redirected_to mine_matches_path
    assert_match "上限", flash[:alert]
  end

  # claim
  test "coach can claim a requested coaching request" do
    sign_in users(:coach_bob)
    patch claim_match_coaching_request_path(matches(:win_match))
    assert_redirected_to match_coaching_request_path(matches(:win_match))
    assert coaching_requests(:requested_cr).reload.in_progress?
    assert_equal users(:coach_bob), coaching_requests(:requested_cr).reload.coach
  end

  test "student cannot claim" do
    sign_in users(:alice)
    patch claim_match_coaching_request_path(matches(:win_match))
    assert_equal "只有教练可以认领请求", flash[:alert]
  end

  test "cannot claim an already in_progress request" do
    sign_in users(:coach_bob)
    patch claim_match_coaching_request_path(matches(:loss_match))
    assert_equal "该请求状态不允许认领", flash[:alert]
  end

  # complete
  test "coach can complete an in_progress coaching request" do
    sign_in users(:coach_bob)
    patch complete_match_coaching_request_path(matches(:loss_match))
    assert coaching_requests(:in_progress_cr).reload.completed?
  end

  test "student can complete an in_progress coaching request" do
    sign_in users(:alice)
    patch complete_match_coaching_request_path(matches(:loss_match))
    assert coaching_requests(:in_progress_cr).reload.completed?
  end

  test "cannot complete a requested coaching request" do
    sign_in users(:coach_bob)
    patch complete_match_coaching_request_path(matches(:win_match))
    assert_equal "该请求状态不允许完成", flash[:alert]
  end

  # reopen
  test "student can reopen a completed coaching request" do
    coaching_requests(:in_progress_cr).update!(status: :completed)
    sign_in users(:alice)
    patch reopen_match_coaching_request_path(matches(:loss_match))
    assert coaching_requests(:in_progress_cr).reload.requested?
  end

  test "cannot reopen a requested coaching request" do
    sign_in users(:alice)
    patch reopen_match_coaching_request_path(matches(:win_match))
    assert_equal "该请求状态不允许重新开启", flash[:alert]
  end

  # cancel
  test "student can cancel a requested coaching request" do
    sign_in users(:alice)
    assert_difference "CoachingRequest.count", -1 do
      delete cancel_match_coaching_request_path(matches(:win_match))
    end
    assert_redirected_to mine_coaching_requests_path
  end

  test "student cannot cancel an in_progress coaching request" do
    sign_in users(:alice)
    delete cancel_match_coaching_request_path(matches(:loss_match))
    assert_equal "仅待认领的请求可以关闭", flash[:alert]
  end

  test "coach cannot cancel a coaching request" do
    sign_in users(:coach_bob)
    delete cancel_match_coaching_request_path(matches(:win_match))
    assert_equal "无权操作", flash[:alert]
  end

  test "student cannot cancel a coaching request that was previously completed" do
    cr = coaching_requests(:requested_cr)
    # simulate: completed → reopened (currently requested again)
    cr.events.create!(operator: users(:coach_bob), from_status: :in_progress, to_status: :completed)

    sign_in users(:alice)
    assert_no_difference "CoachingRequest.count" do
      delete cancel_match_coaching_request_path(matches(:win_match))
    end
    assert_equal "已完成过的复盘请求不能关闭", flash[:alert]
  end

  private

    def new_match_for(user, match_id:)
      Match.create!(
        user: user, match_id: match_id, raw_data: "{}",
        player_slot: 0, on_radiant: true, won: true,
        hero_id: 1, kills: 5, deaths: 3, assists: 4,
        duration: 1800, played_at: Time.current, leaver_status: 0, source: 0
      )
    end
end

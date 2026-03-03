require "test_helper"

class CoachingRequestTest < ActiveSupport::TestCase
  test "weekly_count_for counts this week's requests" do
    # fixtures: requested_cr + in_progress_cr, both created_at: Time.current
    assert_equal 2, CoachingRequest.weekly_count_for(users(:alice))
  end

  test "weekly_count_for returns 0 for user with no requests" do
    assert_equal 0, CoachingRequest.weekly_count_for(users(:coach_bob))
  end

  test "weekly_count_for ignores requests from last week" do
    travel_to 2.weeks.ago do
      assert_equal 0, CoachingRequest.weekly_count_for(users(:alice))
    end
  end

  test "transition_to! changes status" do
    cr = coaching_requests(:requested_cr)
    cr.transition_to!(:in_progress, operator: users(:coach_bob))
    assert cr.in_progress?
  end

  test "transition_to! creates an event log with correct from/to" do
    cr = coaching_requests(:requested_cr)
    assert_difference "CoachingRequestEvent.count" do
      cr.transition_to!(:in_progress, operator: users(:coach_bob))
    end
    event = cr.events.last
    assert_equal "requested",   event.from_status
    assert_equal "in_progress", event.to_status
    assert_equal users(:coach_bob), event.operator
  end
end

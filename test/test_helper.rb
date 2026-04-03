ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  # Helper to sign in as a user for testing
  # Uses a test-only endpoint to set session
  def sign_in(user)
    # Post to sessions controller with admin credentials if user is admin
    # Otherwise, we need to bypass authentication for non-admin users in tests
    if user.admin?
      post session_path, params: { username: user.username, password: "password123" }
    else
      # For non-admin users: use a backdoor in test environment
      # We'll create a special controller action for this
      get "/test/sign_in/#{user.id}"
    end
  end
end

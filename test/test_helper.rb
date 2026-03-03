ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  private

  def sign_in(user, password: "password123")
    post session_path, params: { username: user.username, password: }
  end
end

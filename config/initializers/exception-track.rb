# frozen_string_literal: true

# Exception Track configuration
# Exceptions are automatically tracked in all environments
# Access control is handled by AdminConstraint in routes.rb

ExceptionTrack.configure do
  # environments for store Exception log in to database.
  # default: [:development, :production]
  # self.environments = %i(development production)
end

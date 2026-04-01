# frozen_string_literal: true

# Disable HTTP basic authentication (we use AdminConstraint in routes)
MissionControl::Jobs.http_basic_auth_enabled = false

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Bootsnap's load_path_cache freezes $LOAD_PATH, causing FrozenError
# when engine initializers (e.g. Devise) try to add paths via unshift
# in CI with eager_load enabled. Skip bootsnap entirely in CI.
unless ENV["CI"]
  require "bootsnap/setup" # Speed up boot time by caching expensive operations.
end

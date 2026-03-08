ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Ensure $LOAD_PATH is mutable before Rails engine initializers run.
# Bootsnap (and some Ruby/Bundler versions) freeze $LOAD_PATH for performance,
# but engine initializers (e.g. Devise) need to unshift paths into it.
if $LOAD_PATH.frozen?
  $LOAD_PATH = $LOAD_PATH.dup
end

# Skip bootsnap in CI to avoid $LOAD_PATH freeze issues.
unless ENV["CI"]
  require "bootsnap/setup" # Speed up boot time by caching expensive operations.
end

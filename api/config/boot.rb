ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Bootsnap's load_path_cache freezes $LOAD_PATH, causing FrozenError
# when engine initializers (e.g. Devise) try to add paths via unshift.
# Disable load_path_cache; keep compile_cache for speed.
require "bootsnap"
Bootsnap.setup(
  cache_dir: File.join(File.expand_path("..", __dir__), "tmp", "cache"),
  load_path_cache: false
)

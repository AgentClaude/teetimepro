require_relative "boot"

require "rails"

# Workaround: Devise 4.9.x tries to modify frozen load path arrays in Rails 8.
# Rails 8 freezes _all_load_paths after collection; Devise's Engine initializer
# then fails with FrozenError. This ensures the array is always mutable.
Rails::Engine.prepend(Module.new do
  private

  def _all_load_paths
    super.dup
  end
end)
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TeeTimePro
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    # API-only mode
    config.api_only = true

    # Generators
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.orm :active_record, primary_key_type: :bigint
    end

    # ActiveJob backend
    config.active_job.queue_adapter = :sidekiq

    # Default timezone
    config.time_zone = "UTC"
  end
end

# ActiveRecord Encryption configuration for test and CI environments
# Prevents ActiveRecord::Encryption::Errors::Configuration errors in tests

if Rails.env.test? || ENV["CI"]
  Rails.application.config.active_record.encryption.primary_key = "test-primary-key-that-is-32-bytes!"
  Rails.application.config.active_record.encryption.deterministic_key = "test-deterministic-key-32-bytes!!"
  Rails.application.config.active_record.encryption.key_derivation_salt = "test-key-derivation-salt-value"
end
class ApplicationJob < ActiveJob::Base
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError
end

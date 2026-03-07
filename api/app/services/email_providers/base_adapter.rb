# frozen_string_literal: true

module EmailProviders
  class BaseAdapter
    attr_reader :provider

    def initialize(provider)
      @provider = provider
    end

    # Send a single email, returns { success: bool, message_id: string, error: string }
    def send_email(to:, subject:, html_body:, text_body: nil, from: nil, reply_to: nil)
      raise NotImplementedError, "#{self.class.name} must implement #send_email"
    end

    # Send emails in batch, returns { success: bool, results: [...], error: string }
    def send_batch(messages:)
      raise NotImplementedError, "#{self.class.name} must implement #send_batch"
    end

    # Verify API credentials are valid
    def verify_credentials
      raise NotImplementedError, "#{self.class.name} must implement #verify_credentials"
    end

    # Parse an incoming webhook payload into normalized events
    def parse_webhook(payload:, headers: {})
      raise NotImplementedError, "#{self.class.name} must implement #parse_webhook"
    end

    # Verify webhook signature
    def verify_webhook_signature(payload:, signature:)
      raise NotImplementedError, "#{self.class.name} must implement #verify_webhook_signature"
    end

    protected

    def api_key
      provider.api_key
    end

    def from_email
      provider.from_email
    end

    def from_name
      provider.from_name
    end

    def default_from
      if from_name.present?
        "#{from_name} <#{from_email}>"
      else
        from_email
      end
    end
  end
end

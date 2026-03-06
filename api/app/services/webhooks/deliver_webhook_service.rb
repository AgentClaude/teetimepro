module Webhooks
  class DeliverWebhookService < ApplicationService
    attr_accessor :webhook_event

    validates :webhook_event, presence: true

    def call
      return validation_failure(self) unless valid?

      webhook_event.increment_attempts!

      begin
        response = send_webhook_request
        
        if response.code.to_i.between?(200, 299)
          webhook_event.mark_delivered!(response.code.to_i, response.body)
          success(
            webhook_event: webhook_event,
            response_code: response.code.to_i,
            delivered: true
          )
        else
          handle_failed_delivery(response.code.to_i, response.body)
        end
      rescue Net::TimeoutError, Net::OpenTimeout, Net::ReadTimeout => e
        handle_failed_delivery(nil, "Timeout: #{e.message}")
      rescue Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError => e
        handle_failed_delivery(nil, "Bad response: #{e.message}")
      rescue SocketError => e
        handle_failed_delivery(nil, "DNS/Socket error: #{e.message}")
      rescue StandardError => e
        handle_failed_delivery(nil, "Unexpected error: #{e.message}")
      end
    end

    private

    def send_webhook_request
      uri = URI(webhook_event.webhook_endpoint.url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 30

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['User-Agent'] = 'TeeTimes-Pro-Webhooks/1.0'
      request['X-Webhook-Event'] = webhook_event.event_type
      request['X-Webhook-Delivery-Id'] = webhook_event.id.to_s
      request['X-Webhook-Signature'] = generate_signature
      
      request.body = webhook_event.payload.to_json

      http.request(request)
    end

    def generate_signature
      secret = webhook_event.webhook_endpoint.secret
      payload = webhook_event.payload.to_json
      OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
    end

    def handle_failed_delivery(response_code, response_body)
      if webhook_event.should_retry?
        # Schedule retry with exponential backoff
        delay = webhook_event.next_retry_delay
        WebhookDeliveryJob.set(wait: delay.seconds).perform_later(webhook_event.id)
        
        failure(
          ["Delivery failed, retry scheduled"],
          webhook_event: webhook_event,
          response_code: response_code,
          retry_in: delay
        )
      else
        # No more retries, mark as failed
        webhook_event.mark_failed!(response_code, response_body)
        
        failure(
          ["Delivery failed after maximum attempts"],
          webhook_event: webhook_event,
          response_code: response_code,
          max_attempts_reached: true
        )
      end
    end
  end
end
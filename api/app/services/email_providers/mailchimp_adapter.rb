# frozen_string_literal: true

module EmailProviders
  class MailchimpAdapter < BaseAdapter
    # Mailchimp Transactional (Mandrill) API for sending
    MANDRILL_API_BASE = "https://mandrillapp.com/api/1.0"

    def send_email(to:, subject:, html_body:, text_body: nil, from: nil, reply_to: nil)
      payload = {
        key: api_key,
        message: {
          html: html_body,
          text: text_body,
          subject: subject,
          from_email: from || from_email,
          from_name: from_name,
          to: [{ email: to, type: "to" }],
          track_opens: true,
          track_clicks: true
        }.tap { |m| m[:headers] = { "Reply-To" => reply_to } if reply_to.present? }
      }

      response = post("/messages/send", payload)
      body = JSON.parse(response.body)

      if response.code.to_i == 200 && body.is_a?(Array)
        result = body.first
        if %w[sent queued scheduled].include?(result["status"])
          { success: true, message_id: result["_id"], error: nil }
        else
          { success: false, message_id: nil, error: result["reject_reason"] || result["status"] }
        end
      else
        { success: false, message_id: nil, error: parse_error(body) }
      end
    rescue StandardError => e
      { success: false, message_id: nil, error: e.message }
    end

    def send_batch(messages:)
      payload = {
        key: api_key,
        message: {
          html: messages.first[:html_body],
          text: messages.first[:text_body],
          subject: messages.first[:subject],
          from_email: from_email,
          from_name: from_name,
          to: messages.map { |msg| { email: msg[:to], type: "to" } },
          track_opens: true,
          track_clicks: true,
          preserve_recipients: false
        }
      }

      response = post("/messages/send", payload)
      body = JSON.parse(response.body)

      if response.code.to_i == 200 && body.is_a?(Array)
        results = body.map do |result|
          {
            to: result["email"],
            success: %w[sent queued scheduled].include?(result["status"]),
            message_id: result["_id"],
            error: result["reject_reason"]
          }
        end
        { success: results.all? { |r| r[:success] }, results: results, error: nil }
      else
        error = parse_error(body)
        { success: false, results: messages.map { |m| { to: m[:to], success: false, error: error } }, error: error }
      end
    rescue StandardError => e
      { success: false, results: [], error: e.message }
    end

    def verify_credentials
      payload = { key: api_key }
      response = post("/users/ping2", payload)
      body = JSON.parse(response.body)

      if response.code.to_i == 200 && body["PING"] == "PONG!"
        { success: true, username: body["username"] }
      else
        { success: false, error: parse_error(body) }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def parse_webhook(payload:, headers: {})
      events = JSON.parse(payload)
      events.map do |event|
        msg = event["msg"] || {}
        {
          event_type: normalize_event_type(event["event"]),
          message_id: msg["_id"],
          email: msg["email"],
          timestamp: Time.at(event["ts"].to_i),
          raw_event: event["event"],
          metadata: {
            reason: msg["bounce_description"] || msg["diag"],
            url: event["url"],
            useragent: msg["user_agent"],
            ip: msg["sender"]
          }
        }
      end
    end

    def verify_webhook_signature(payload:, signature:)
      return true if provider.webhook_secret.blank?

      expected = OpenSSL::HMAC.hexdigest(
        "SHA1",
        provider.webhook_secret,
        payload
      )
      ActiveSupport::SecurityUtils.secure_compare(expected, signature.to_s)
    end

    private

    def normalize_event_type(mandrill_event)
      case mandrill_event
      when "send" then :delivered
      when "open" then :opened
      when "click" then :clicked
      when "hard_bounce", "soft_bounce" then :bounced
      when "reject" then :failed
      when "spam" then :spam_reported
      when "unsub" then :unsubscribed
      else :unknown
      end
    end

    def post(path, body)
      uri = URI("#{MANDRILL_API_BASE}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = body.to_json

      http.request(request)
    end

    def parse_error(body)
      if body.is_a?(Hash)
        body["message"] || body["error"] || "Mailchimp API error"
      else
        "Mailchimp API error"
      end
    end
  end
end

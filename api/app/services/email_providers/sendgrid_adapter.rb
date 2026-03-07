# frozen_string_literal: true

module EmailProviders
  class SendgridAdapter < BaseAdapter
    SENDGRID_API_BASE = "https://api.sendgrid.com/v3"

    def send_email(to:, subject:, html_body:, text_body: nil, from: nil, reply_to: nil)
      payload = build_single_send_payload(
        to: to, subject: subject, html_body: html_body,
        text_body: text_body, from: from, reply_to: reply_to
      )

      response = post("/mail/send", payload)

      if response.code.to_i == 202
        message_id = response["X-Message-Id"]
        { success: true, message_id: message_id, error: nil }
      else
        { success: false, message_id: nil, error: parse_error(response) }
      end
    rescue StandardError => e
      { success: false, message_id: nil, error: e.message }
    end

    def send_batch(messages:)
      results = []

      # SendGrid supports up to 1000 personalizations per request
      messages.each_slice(1000) do |batch|
        payload = build_batch_payload(batch)
        response = post("/mail/send", payload)

        if response.code.to_i == 202
          batch.each do |msg|
            results << { to: msg[:to], success: true, message_id: response["X-Message-Id"], error: nil }
          end
        else
          error = parse_error(response)
          batch.each do |msg|
            results << { to: msg[:to], success: false, message_id: nil, error: error }
          end
        end
      end

      { success: results.all? { |r| r[:success] }, results: results, error: nil }
    rescue StandardError => e
      { success: false, results: [], error: e.message }
    end

    def verify_credentials
      response = get("/scopes")

      if response.code.to_i == 200
        { success: true, scopes: JSON.parse(response.body)["scopes"] }
      else
        { success: false, error: parse_error(response) }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def parse_webhook(payload:, headers: {})
      events = JSON.parse(payload)
      events.map do |event|
        {
          event_type: normalize_event_type(event["event"]),
          message_id: event["sg_message_id"]&.split(".")&.first,
          email: event["email"],
          timestamp: Time.at(event["timestamp"].to_i),
          raw_event: event["event"],
          metadata: {
            reason: event["reason"],
            response: event["response"],
            url: event["url"],
            useragent: event["useragent"],
            ip: event["ip"]
          }
        }
      end
    end

    def verify_webhook_signature(payload:, signature:)
      return true if provider.webhook_secret.blank?

      expected = OpenSSL::HMAC.hexdigest(
        "SHA256",
        provider.webhook_secret,
        payload
      )
      ActiveSupport::SecurityUtils.secure_compare(expected, signature.to_s)
    end

    private

    def build_single_send_payload(to:, subject:, html_body:, text_body:, from:, reply_to:)
      {
        personalizations: [{ to: [{ email: to }] }],
        from: { email: from || from_email, name: from_name },
        subject: subject,
        content: build_content(html_body, text_body),
        tracking_settings: {
          click_tracking: { enable: true },
          open_tracking: { enable: true }
        }
      }.tap do |p|
        p[:reply_to] = { email: reply_to } if reply_to.present?
      end
    end

    def build_batch_payload(messages)
      # All messages share the same subject/content from the campaign
      first = messages.first
      {
        personalizations: messages.map { |msg| { to: [{ email: msg[:to] }], subject: msg[:subject] } },
        from: { email: from_email, name: from_name },
        subject: first[:subject],
        content: build_content(first[:html_body], first[:text_body]),
        tracking_settings: {
          click_tracking: { enable: true },
          open_tracking: { enable: true }
        }
      }
    end

    def build_content(html_body, text_body)
      content = [{ type: "text/html", value: html_body }]
      content.unshift({ type: "text/plain", value: text_body }) if text_body.present?
      content
    end

    def normalize_event_type(sg_event)
      case sg_event
      when "delivered" then :delivered
      when "open" then :opened
      when "click" then :clicked
      when "bounce", "blocked" then :bounced
      when "dropped" then :failed
      when "spamreport" then :spam_reported
      when "unsubscribe" then :unsubscribed
      else :unknown
      end
    end

    def get(path)
      uri = URI("#{SENDGRID_API_BASE}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{api_key}"
      request["Content-Type"] = "application/json"

      http.request(request)
    end

    def post(path, body)
      uri = URI("#{SENDGRID_API_BASE}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{api_key}"
      request["Content-Type"] = "application/json"
      request.body = body.to_json

      http.request(request)
    end

    def parse_error(response)
      body = JSON.parse(response.body) rescue {}
      errors = body["errors"]&.map { |e| e["message"] }&.join(", ")
      errors.presence || "SendGrid API error (#{response.code})"
    end
  end
end

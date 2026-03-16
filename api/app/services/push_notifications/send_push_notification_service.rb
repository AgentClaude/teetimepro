# frozen_string_literal: true

module PushNotifications
  class SendPushNotificationService < ApplicationService
    EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send"
    MAX_BATCH_SIZE = 100

    attr_accessor :tokens, :title, :body, :data, :badge, :sound, :channel_id

    validates :tokens, presence: true
    validates :title, presence: true
    validates :body, presence: true

    def call
      return validation_failure(self) unless valid?

      active_tokens = Array(tokens).select(&:present?)
      return success(sent: 0, results: []) if active_tokens.empty?

      all_results = []
      active_tokens.each_slice(MAX_BATCH_SIZE) do |batch|
        results = send_batch(batch)
        all_results.concat(results)
      end

      handle_results(all_results)

      success(
        sent: all_results.count { |r| r[:status] == "ok" },
        failed: all_results.count { |r| r[:status] == "error" },
        results: all_results
      )
    rescue StandardError => e
      Rails.logger.error("Push notification delivery failed: #{e.message}")
      failure(["Push notification delivery failed: #{e.message}"])
    end

    private

    def send_batch(token_batch)
      messages = token_batch.map { |token| build_message(token) }

      response = connection.post(EXPO_PUSH_URL) do |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["Accept"] = "application/json"
        req.body = Oj.dump(messages, mode: :compat)
      end

      parsed = Oj.load(response.body)
      results = parsed["data"] || []

      results.each_with_index.map do |result, idx|
        {
          token: token_batch[idx],
          status: result["status"],
          message: result["message"],
          details: result["details"]
        }
      end
    rescue Faraday::Error => e
      Rails.logger.error("Expo push API request failed: #{e.message}")
      token_batch.map { |t| { token: t, status: "error", message: e.message } }
    end

    def build_message(token)
      msg = {
        to: token,
        title: title,
        body: body,
        sound: sound || "default"
      }
      msg[:data] = data if data.present?
      msg[:badge] = badge if badge.present?
      msg[:channelId] = channel_id if channel_id.present?
      msg
    end

    def handle_results(results)
      results.each do |result|
        next unless result[:status] == "error"

        details = result[:details]
        next unless details.is_a?(Hash)

        # Deactivate tokens that are no longer valid
        if details["error"].in?(%w[DeviceNotRegistered InvalidCredentials])
          DeviceToken.where(token: result[:token]).update_all(active: false)
          Rails.logger.info("Deactivated invalid push token: #{result[:token]}")
        end
      end
    end

    def connection
      @connection ||= Faraday.new do |f|
        f.request :retry, max: 2, interval: 0.5
        f.adapter Faraday.default_adapter
      end
    end
  end
end

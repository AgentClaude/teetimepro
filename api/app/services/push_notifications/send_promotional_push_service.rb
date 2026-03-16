# frozen_string_literal: true

module PushNotifications
  class SendPromotionalPushService < ApplicationService
    attr_accessor :organization, :title, :body, :data, :segment_id

    validates :organization, presence: true
    validates :title, presence: true
    validates :body, presence: true

    def call
      return validation_failure(self) unless valid?

      tokens = target_tokens

      return success(sent: 0, reason: "no_device_tokens") if tokens.empty?

      SendPushNotificationService.call(
        tokens: tokens,
        title: title,
        body: body,
        data: (data || {}).merge(type: "promotional"),
        channel_id: "promotions"
      )
    end

    private

    def target_tokens
      scope = DeviceToken.active.for_organization(organization)

      if segment_id.present?
        segment = GolferSegment.find_by(id: segment_id, organization: organization)
        return [] unless segment

        user_ids = GolferSegmentMembership
          .where(golfer_segment: segment)
          .joins(:user)
          .pluck(:user_id)

        scope = scope.where(user_id: user_ids)
      end

      scope.pluck(:token)
    end
  end
end

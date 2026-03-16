# frozen_string_literal: true

module Mutations
  class SendPromotionalPush < BaseMutation
    argument :title, String, required: true
    argument :body, String, required: true
    argument :segment_id, ID, required: false, description: "Optional golfer segment to target"
    argument :data, GraphQL::Types::JSON, required: false, description: "Additional data payload"

    field :sent, Integer, null: false
    field :failed, Integer, null: true
    field :errors, [String], null: false

    def resolve(title:, body:, segment_id: nil, data: nil)
      # Only managers and above can send promotional pushes
      unless context[:current_user]&.can_manage_course?
        return { sent: 0, errors: ["Not authorized to send promotional notifications"] }
      end

      result = PushNotifications::SendPromotionalPushService.call(
        organization: context[:current_organization],
        title: title,
        body: body,
        segment_id: segment_id,
        data: data
      )

      if result.success?
        { sent: result.sent || 0, failed: result.failed, errors: [] }
      else
        { sent: 0, failed: 0, errors: result.errors }
      end
    end
  end
end

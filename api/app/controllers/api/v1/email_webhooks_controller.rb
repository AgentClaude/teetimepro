# frozen_string_literal: true

module Api
  module V1
    class EmailWebhooksController < BaseController
      skip_before_action :authenticate_api_key!

      # POST /api/v1/email_webhooks/sendgrid
      def sendgrid
        provider = find_provider("sendgrid")
        return head :not_found unless provider

        adapter = provider.adapter
        unless adapter.verify_webhook_signature(
          payload: request.raw_post,
          signature: request.headers["X-Twilio-Email-Event-Webhook-Signature"]
        )
          return head :unauthorized
        end

        process_webhook(provider)
      end

      # POST /api/v1/email_webhooks/mailchimp
      def mailchimp
        provider = find_provider("mailchimp")
        return head :not_found unless provider

        adapter = provider.adapter
        unless adapter.verify_webhook_signature(
          payload: request.raw_post,
          signature: request.headers["X-Mandrill-Signature"]
        )
          return head :unauthorized
        end

        process_webhook(provider)
      end

      private

      def find_provider(type)
        org_id = params[:organization_id]
        return nil unless org_id

        EmailProvider.find_by(
          organization_id: org_id,
          provider_type: type,
          is_active: true
        )
      end

      def process_webhook(provider)
        result = Campaigns::ProcessEmailWebhookService.call(
          provider: provider,
          payload: request.raw_post,
          headers: request.headers.to_h
        )

        if result.success?
          render json: { processed: result.data[:processed_count] }, status: :ok
        else
          render json: { error: result.errors.join(", ") }, status: :unprocessable_entity
        end
      end
    end
  end
end

class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    @subscription_ids = []
  end

  def execute(data)
    result = TeeTimeProSchema.execute(
      query: data["query"],
      context: {
        current_user: current_user,
        channel: self
      },
      variables: data["variables"],
      operation_name: data["operationName"]
    )

    payload = {
      result: result.to_h,
      more: result.subscription?
    }

    if result.context[:subscription_id]
      @subscription_ids << result.context[:subscription_id]
    end

    transmit(payload)
  end

  def unsubscribed
    @subscription_ids.each do |sid|
      TeeTimeProSchema.subscriptions.delete_subscription(sid)
    end
  end
end

module Api
  class VoiceBotController < ActionController::API
    # Twilio webhook — returns TwiML to connect the call to the voice agent WebSocket
    # This is a fallback if Twilio is configured to hit the Rails API instead of the voice-agent service directly

    def incoming
      voice_agent_ws_url = ENV.fetch("VOICE_AGENT_WS_URL", "wss://localhost:3005/voice/stream")

      response = Twilio::TwiML::VoiceResponse.new
      response.connect do |connect|
        connect.stream(url: voice_agent_ws_url)
      end

      render xml: response.to_s
    end

    def status
      Rails.logger.info(
        "[VoiceBot] Call #{params[:CallSid]} status: #{params[:CallStatus]} " \
        "duration: #{params[:CallDuration]}s"
      )
      head :ok
    end
  end
end

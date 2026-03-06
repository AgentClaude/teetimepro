const VOICE_AGENT_WS_URL =
  process.env.VOICE_AGENT_WS_URL || "wss://localhost:3005/voice/stream";

export const TWIML_RESPONSE = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Connect>
    <Stream url="${VOICE_AGENT_WS_URL}" />
  </Connect>
</Response>`;

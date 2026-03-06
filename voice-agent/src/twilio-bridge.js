import WebSocket from "ws";
import { buildSettings } from "./deepgram-settings.js";
import { executeFunction } from "./function-handlers.js";
import { CallLogger } from "./call-logger.js";

const DEEPGRAM_URL = "wss://agent.deepgram.com/v1/agent/converse";
const DEEPGRAM_API_KEY = process.env.DEEPGRAM_API_KEY;

// Buffer size: collect ~0.4s of audio before forwarding (20 chunks of 160 bytes)
const AUDIO_BUFFER_SIZE = 20;

/**
 * Handle an incoming Twilio Media Stream WebSocket connection.
 * Bridges audio between Twilio and Deepgram Voice Agent API.
 */
export function handleTwilioConnection(twilioSocket, log) {
  let streamSid = null;
  let callMeta = {};
  let deepgramWs = null;
  let audioBuffer = [];
  let callLogger = new CallLogger({ channel: "twilio", log });

  // Connect to Deepgram Voice Agent API
  deepgramWs = new WebSocket(DEEPGRAM_URL, ["token", DEEPGRAM_API_KEY]);

  deepgramWs.on("open", () => {
    log.info("Connected to Deepgram Voice Agent API");

    // Send Settings message immediately
    const settings = buildSettings();
    deepgramWs.send(JSON.stringify(settings));
    log.info("Sent Deepgram Settings");
  });

  deepgramWs.on("message", (data) => {
    const msg = JSON.parse(data.toString());

    switch (msg.type) {
      case "SettingsApplied":
        log.info("Deepgram settings applied");
        break;

      case "AgentAudio":
        // Deepgram sends TTS audio — forward to Twilio as base64 mulaw
        if (streamSid && twilioSocket.readyState === WebSocket.OPEN) {
          twilioSocket.send(
            JSON.stringify({
              event: "media",
              streamSid,
              media: { payload: msg.audio },
            })
          );
        }
        break;

      case "FunctionCallRequest":
        handleFunctionCalls(msg, deepgramWs, callMeta, log, callLogger);
        break;

      case "UserStartedSpeaking":
        // Barge-in: clear any queued audio on Twilio side
        if (streamSid && twilioSocket.readyState === WebSocket.OPEN) {
          twilioSocket.send(
            JSON.stringify({ event: "clear", streamSid })
          );
        }
        break;

      case "AgentStartedSpeaking":
        log.info("Agent started speaking");
        break;

      case "ConversationText":
        if (msg.role === "user") {
          log.info({ text: msg.content }, "User said");
        } else {
          log.info({ text: msg.content }, "Agent said");
        }
        callLogger.addTranscript(msg.role, msg.content);
        break;

      case "AgentThinking":
        log.debug("Agent thinking...");
        break;

      case "Error":
        log.error({ error: msg }, "Deepgram error");
        break;

      default:
        log.debug({ type: msg.type }, "Deepgram message");
    }
  });

  deepgramWs.on("error", (err) => {
    log.error({ err }, "Deepgram WebSocket error");
  });

  deepgramWs.on("close", (code, reason) => {
    log.info({ code, reason: reason.toString() }, "Deepgram WebSocket closed");
    if (twilioSocket.readyState === WebSocket.OPEN) {
      twilioSocket.close();
    }
  });

  // Handle Twilio Media Stream messages
  twilioSocket.on("message", (data) => {
    const msg = JSON.parse(data.toString());

    switch (msg.event) {
      case "connected":
        log.info("Twilio stream connected");
        break;

      case "start":
        streamSid = msg.start.streamSid;
        callMeta = {
          callSid: msg.start.callSid,
          from: msg.start.customParameters?.from || "",
          to: msg.start.customParameters?.to || "",
        };
        callLogger.callSid = callMeta.callSid;
        callLogger.callerPhone = callMeta.from;
        log.info({ streamSid, callSid: callMeta.callSid }, "Twilio stream started");
        break;

      case "media":
        // Buffer audio and forward to Deepgram
        if (deepgramWs?.readyState === WebSocket.OPEN) {
          audioBuffer.push(Buffer.from(msg.media.payload, "base64"));

          if (audioBuffer.length >= AUDIO_BUFFER_SIZE) {
            const combined = Buffer.concat(audioBuffer);
            deepgramWs.send(combined);
            audioBuffer = [];
          }
        }
        break;

      case "stop":
        log.info("Twilio stream stopped");
        // Flush remaining audio
        if (audioBuffer.length > 0 && deepgramWs?.readyState === WebSocket.OPEN) {
          const combined = Buffer.concat(audioBuffer);
          deepgramWs.send(combined);
          audioBuffer = [];
        }
        if (callLogger.transcript.length > 0) {
          callLogger.save();
        }
        cleanup();
        break;

      default:
        log.debug({ event: msg.event }, "Twilio message");
    }
  });

  twilioSocket.on("close", () => {
    log.info("Twilio WebSocket closed");
    cleanup();
  });

  twilioSocket.on("error", (err) => {
    log.error({ err }, "Twilio WebSocket error");
    cleanup();
  });

  function cleanup() {
    if (deepgramWs?.readyState === WebSocket.OPEN) {
      deepgramWs.close();
    }
    audioBuffer = [];
  }
}

/**
 * Handle function calls from Deepgram Voice Agent
 */
async function handleFunctionCalls(msg, deepgramWs, callMeta, log, callLogger) {
  for (const fn of msg.functions || []) {
    log.info({ name: fn.name, args: fn.arguments }, "Function call requested");

    callLogger.addFunctionCall(fn.name, fn.arguments);

    try {
      const args = typeof fn.arguments === "string"
        ? JSON.parse(fn.arguments)
        : fn.arguments;

      const result = await executeFunction(fn.name, args, callMeta);

      log.info({ name: fn.name, result }, "Function call result");

      callLogger.addFunctionResult(fn.name, result);

      // Send FunctionCallResponse back to Deepgram
      if (deepgramWs.readyState === WebSocket.OPEN) {
        deepgramWs.send(
          JSON.stringify({
            type: "FunctionCallResponse",
            id: fn.id,
            name: fn.name,
            content: result,
          })
        );
      }
    } catch (err) {
      log.error({ err, name: fn.name }, "Function call failed");

      if (deepgramWs.readyState === WebSocket.OPEN) {
        deepgramWs.send(
          JSON.stringify({
            type: "FunctionCallResponse",
            id: fn.id,
            name: fn.name,
            content: JSON.stringify({ error: err.message }),
          })
        );
      }
    }
  }
}

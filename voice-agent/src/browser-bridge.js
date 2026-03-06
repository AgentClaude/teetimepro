import WebSocket from "ws";
import { buildSettings } from "./deepgram-settings.js";
import { executeFunction } from "./function-handlers.js";

const DEEPGRAM_URL = "wss://agent.deepgram.com/v1/agent/converse";
const DEEPGRAM_API_KEY = process.env.DEEPGRAM_API_KEY;
const API_BASE = process.env.API_URL || "http://api:3003";
const API_KEY = process.env.TEETIMEPRO_API_KEY || "";

/**
 * Fetch course config from Rails API
 */
async function fetchCourseData(courseId) {
  try {
    const res = await fetch(`${API_BASE}/api/v1/courses/${courseId}`, {
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        Accept: "application/json",
      },
    });
    if (!res.ok) return null;
    const data = await res.json();
    return data.data || data;
  } catch (err) {
    return null;
  }
}

/**
 * Handle a browser playground WebSocket connection.
 * Browser sends: { type: "config", courseId: 123 } then raw PCM audio (linear16 16kHz)
 * Browser receives: { type: "audio", audio: base64 } and { type: "transcript", role, content }
 */
export function handleBrowserConnection(browserSocket, log) {
  let deepgramWs = null;
  let courseId = null;
  let callMeta = {};

  browserSocket.on("message", async (data) => {
    // Check if it's a JSON control message
    if (typeof data === "string" || (Buffer.isBuffer(data) && data[0] === 0x7b)) {
      try {
        const msg = JSON.parse(data.toString());

        if (msg.type === "config") {
          courseId = msg.courseId;
          callMeta = { courseId };
          log.info({ courseId }, "Browser playground: starting session");

          // Fetch course data (including voice_config and timezone) from Rails
          const courseData = courseId ? await fetchCourseData(courseId) : null;
          const courseConfig = courseData?.voice_config || null;
          const timezone = courseData?.timezone || null;
          log.info({ hasCourseConfig: !!courseConfig, timezone }, "Course config loaded");

          // Connect to Deepgram with browser audio settings
          // Use separate input/output sample rates: 16kHz mic in, 24kHz TTS out
          connectToDeepgram(browserSocket, log, {
            inputEncoding: "linear16",
            inputSampleRate: 16000,
            outputEncoding: "linear16",
            outputSampleRate: 24000,
            courseConfig,
            courseId,
            timezone,
          });
          return;
        }
      } catch {
        // Not JSON, treat as audio
      }
    }

    // Forward raw audio to Deepgram
    if (deepgramWs?.readyState === WebSocket.OPEN) {
      deepgramWs.send(data);
    }
  });

  browserSocket.on("close", () => {
    log.info("Browser WebSocket closed");
    if (deepgramWs?.readyState === WebSocket.OPEN) {
      deepgramWs.close();
    }
  });

  browserSocket.on("error", (err) => {
    log.error({ err }, "Browser WebSocket error");
    if (deepgramWs?.readyState === WebSocket.OPEN) {
      deepgramWs.close();
    }
  });

  function connectToDeepgram(browserSocket, log, settingsOpts) {
    deepgramWs = new WebSocket(DEEPGRAM_URL, ["token", DEEPGRAM_API_KEY]);

    deepgramWs.on("open", () => {
      log.info("Connected to Deepgram (browser session)");
      const settings = buildSettings(settingsOpts);
      deepgramWs.send(JSON.stringify(settings));
      log.info("Sent Deepgram Settings (linear16 16kHz)");
    });

    deepgramWs.on("message", (data, isBinary) => {
      // Deepgram sends binary audio frames directly
      if (isBinary || (Buffer.isBuffer(data) && data[0] !== 0x7b)) {
        // Raw audio — base64 encode and send to browser
        if (browserSocket.readyState === WebSocket.OPEN) {
          const b64 = Buffer.isBuffer(data) ? data.toString("base64") : Buffer.from(data).toString("base64");
          sendToBrowser({ type: "audio", audio: b64 });
        }
        return;
      }

      const msg = JSON.parse(data.toString());

      switch (msg.type) {
        case "SettingsApplied":
          log.info("Deepgram settings applied (browser)");
          sendToBrowser({ type: "ready" });
          break;

        case "AgentAudio":
          // JSON-wrapped audio (base64 encoded)
          if (browserSocket.readyState === WebSocket.OPEN) {
            sendToBrowser({ type: "audio", audio: msg.audio });
          }
          break;

        case "FunctionCallRequest":
          handleFunctionCalls(msg, deepgramWs, callMeta, log);
          break;

        case "UserStartedSpeaking":
          sendToBrowser({ type: "user_started_speaking" });
          break;

        case "AgentStartedSpeaking":
          sendToBrowser({ type: "agent_started_speaking" });
          break;

        case "ConversationText":
          sendToBrowser({
            type: "transcript",
            role: msg.role,
            content: msg.content,
          });
          break;

        case "AgentThinking":
          sendToBrowser({ type: "thinking" });
          break;

        case "Error":
          log.error({ error: msg }, "Deepgram error (browser)");
          sendToBrowser({ type: "error", message: msg.description || "Deepgram error" });
          break;

        default:
          log.debug({ type: msg.type }, "Deepgram message (browser)");
      }
    });

    deepgramWs.on("error", (err) => {
      log.error({ err }, "Deepgram WebSocket error (browser)");
      sendToBrowser({ type: "error", message: "Connection to voice service failed" });
    });

    deepgramWs.on("close", (code, reason) => {
      log.info({ code, reason: reason.toString() }, "Deepgram closed (browser)");
      sendToBrowser({ type: "closed" });
    });
  }

  function sendToBrowser(msg) {
    if (browserSocket.readyState === WebSocket.OPEN) {
      browserSocket.send(JSON.stringify(msg));
    }
  }

  async function handleFunctionCalls(msg, deepgramWs, callMeta, log) {
    for (const fn of msg.functions || []) {
      log.info({ name: fn.name, args: fn.arguments }, "Function call (browser)");

      sendToBrowser({
        type: "function_call",
        name: fn.name,
        arguments: fn.arguments,
      });

      try {
        const args =
          typeof fn.arguments === "string"
            ? JSON.parse(fn.arguments)
            : fn.arguments;

        const result = await executeFunction(fn.name, args, callMeta);

        log.info({ name: fn.name, result }, "Function result (browser)");

        sendToBrowser({
          type: "function_result",
          name: fn.name,
          result,
        });

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
        log.error({ err, name: fn.name }, "Function call failed (browser)");

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
}

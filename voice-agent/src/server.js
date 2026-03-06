import Fastify from "fastify";
import fastifyWebsocket from "@fastify/websocket";
import fastifyStatic from "@fastify/static";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import { handleTwilioConnection } from "./twilio-bridge.js";
import { handleBrowserConnection } from "./browser-bridge.js";
import { TWIML_RESPONSE } from "./twiml.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const fastify = Fastify({ logger: true });

await fastify.register(fastifyWebsocket);

// Serve static files for playground
await fastify.register(fastifyStatic, {
  root: join(__dirname, "..", "public"),
  prefix: "/",
});

// Health check
fastify.get("/health", async () => ({ status: "ok", service: "voice-agent" }));

// Playground page
fastify.get("/playground", async (request, reply) => {
  return reply.sendFile("playground.html");
});

// Twilio webhook — returns TwiML to connect the call to our WebSocket
fastify.post("/voice/incoming", async (request, reply) => {
  reply.type("text/xml").send(TWIML_RESPONSE);
});

// Twilio Media Stream WebSocket endpoint
fastify.register(async function (app) {
  app.get("/voice/stream", { websocket: true }, (socket, request) => {
    fastify.log.info("Twilio WebSocket connected");
    handleTwilioConnection(socket, fastify.log);
  });
});

// Browser playground WebSocket endpoint
fastify.register(async function (app) {
  app.get("/playground/ws", { websocket: true }, (socket, request) => {
    fastify.log.info("Browser playground WebSocket connected");
    handleBrowserConnection(socket, fastify.log);
  });
});

// Proxy courses list from Rails API (for playground course selector)
const API_BASE = process.env.API_URL || "http://api:3003";
const API_KEY = process.env.TEETIMEPRO_API_KEY || "";

fastify.get("/api/courses", async (request, reply) => {
  try {
    const res = await fetch(`${API_BASE}/api/v1/courses`, {
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        Accept: "application/json",
      },
    });
    const data = await res.json();
    return data;
  } catch (err) {
    reply.code(502);
    return { error: "Could not fetch courses" };
  }
});

// Twilio status callback
fastify.post("/voice/status", async (request) => {
  const { CallSid, CallStatus, CallDuration } = request.body || {};
  fastify.log.info({ CallSid, CallStatus, CallDuration }, "Call status update");
  return { ok: true };
});

const port = parseInt(process.env.PORT || "3005", 10);
const host = process.env.HOST || "0.0.0.0";

try {
  await fastify.listen({ port, host });
  fastify.log.info(`Voice agent listening on ${host}:${port}`);
} catch (err) {
  fastify.log.error(err);
  process.exit(1);
}

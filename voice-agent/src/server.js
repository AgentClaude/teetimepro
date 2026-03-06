import Fastify from "fastify";
import fastifyWebsocket from "@fastify/websocket";
import { handleTwilioConnection } from "./twilio-bridge.js";
import { TWIML_RESPONSE } from "./twiml.js";

const fastify = Fastify({ logger: true });

await fastify.register(fastifyWebsocket);

// Health check
fastify.get("/health", async () => ({ status: "ok", service: "voice-agent" }));

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

/**
 * Collects conversation events during a call and saves them to the Rails API
 * when the call ends.
 */

const API_BASE = process.env.API_URL || "http://api:3003";
const API_KEY = process.env.TEETIMEPRO_API_KEY || "";

export class CallLogger {
  constructor({ channel, courseId, callSid, callerPhone, log }) {
    this.channel = channel || "browser";
    this.courseId = courseId || null;
    this.callSid = callSid || null;
    this.callerPhone = callerPhone || null;
    this.callerName = null;
    this.log = log;
    this.transcript = [];
    this.startedAt = new Date().toISOString();
  }

  /** Log a conversation text message (user or agent) */
  addTranscript(role, content) {
    this.transcript.push({
      type: "transcript",
      timestamp: new Date().toISOString(),
      role,
      content,
    });
  }

  /** Log a function call request */
  addFunctionCall(name, args) {
    this.transcript.push({
      type: "function_call",
      timestamp: new Date().toISOString(),
      name,
      arguments: typeof args === "string" ? args : JSON.stringify(args),
    });
  }

  /** Log a function call result */
  addFunctionResult(name, result) {
    // Try to parse the result to store structured data
    let parsed = result;
    try {
      parsed = typeof result === "string" ? JSON.parse(result) : result;
    } catch {
      // keep as string
    }

    this.transcript.push({
      type: "function_result",
      timestamp: new Date().toISOString(),
      name,
      result: parsed,
    });

    // Extract caller name from booking calls
    if (name === "create_booking" && parsed?.success) {
      // caller_name might have been in the args of the preceding function_call
      const callEntry = [...this.transcript]
        .reverse()
        .find((e) => e.type === "function_call" && e.name === "create_booking");
      if (callEntry) {
        try {
          const callArgs = JSON.parse(callEntry.arguments);
          if (callArgs.caller_name) {
            this.callerName = callArgs.caller_name;
          }
        } catch {
          // ignore
        }
      }
    }
  }

  /** Save the call log to the Rails API */
  async save() {
    const endedAt = new Date().toISOString();
    const durationMs = new Date(endedAt) - new Date(this.startedAt);
    const durationSeconds = Math.round(durationMs / 1000);

    const body = {
      course_id: this.courseId,
      call_sid: this.callSid,
      channel: this.channel,
      caller_phone: this.callerPhone,
      caller_name: this.callerName,
      status: "completed",
      duration_seconds: durationSeconds,
      transcript: this.transcript,
      started_at: this.startedAt,
      ended_at: endedAt,
    };

    try {
      const res = await fetch(`${API_BASE}/api/v1/voice_call_logs`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${API_KEY}`,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify(body),
      });

      if (res.ok) {
        const data = await res.json();
        this.log.info({ id: data.data?.id }, "Call log saved");
      } else {
        const err = await res.text().catch(() => "");
        this.log.error({ status: res.status, body: err }, "Failed to save call log");
      }
    } catch (err) {
      this.log.error({ err: err.message }, "Failed to save call log");
    }
  }
}

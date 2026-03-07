// Deepgram Voice Agent Settings — sent immediately after WebSocket connection

/**
 * Build Deepgram Settings message.
 * @param {object} opts
 * @param {string} opts.encoding  - "mulaw" (Twilio) or "linear16" (browser)
 * @param {number} opts.sampleRate - 8000 (Twilio) or 16000 (browser)
 * @param {object} opts.courseConfig - voice_config from Rails (optional)
 * @param {number} opts.courseId - course ID for function scoping (optional)
 * @param {string} opts.timezone - IANA timezone for current date (optional)
 */
export function buildSettings({
  encoding = "mulaw",
  sampleRate = 8000,
  inputEncoding = null,
  inputSampleRate = null,
  outputEncoding = null,
  outputSampleRate = null,
  courseConfig = null,
  courseId = null,
  timezone = null,
} = {}) {
  const config = courseConfig || {};
  const basePrompt = config.system_prompt || DEFAULT_SYSTEM_PROMPT;

  // Inject current date/time in the course's timezone
  const tz = timezone || "UTC";
  const now = new Date();
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone: tz,
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });
  const timeFormatter = new Intl.DateTimeFormat("en-US", {
    timeZone: tz,
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
  const currentDate = formatter.format(now);
  const currentTime = timeFormatter.format(now);
  const dateContext = `\n\n#Current Date & Time\nToday is ${currentDate}. The current time is ${currentTime} (${tz}).`;
  const systemPrompt = basePrompt + dateContext;

  const greeting =
    config.greeting ||
    "Hello! Thanks for calling. I can help you book a tee time. What date would you like to play?";
  const llmProvider =
    config.llm_provider || process.env.LLM_PROVIDER || "google";
  const llmModel =
    config.llm_model || process.env.LLM_MODEL || "gemini-2.5-flash";
  const voiceModel =
    config.voice_model || process.env.TTS_MODEL || "aura-2-odysseus-en";

  // Inject course_id into functions so the voice agent scopes queries
  const functions = buildFunctions(courseId);

  return {
    type: "Settings",
    audio: {
      input: {
        encoding: inputEncoding || encoding,
        sample_rate: inputSampleRate || sampleRate,
      },
      output: {
        encoding: outputEncoding || encoding,
        sample_rate: outputSampleRate || sampleRate,
        container: "none",
      },
    },
    agent: {
      language: "en",
      listen: {
        provider: { type: "deepgram", model: "nova-3" },
      },
      think: {
        provider: { type: llmProvider, model: llmModel },
        prompt: systemPrompt,
        functions,
      },
      speak: {
        provider: { type: "deepgram", model: voiceModel },
      },
      greeting,
    },
  };
}

const DEFAULT_SYSTEM_PROMPT = `#Role
You are the friendly phone booking assistant for a golf course. You help callers book tee times over the phone.

#General Guidelines
- Be warm, friendly, and professional.
- Keep responses to 1-2 sentences unless more detail is needed.
- Do not use markdown formatting.
- Use natural conversational language appropriate for a phone call.
- If unclear, ask for clarification.

#Voice-Specific Instructions
- Speak conversationally — your responses will be spoken aloud.
- Confirm what the customer said if uncertain.
- Spell out confirmation codes letter by letter.
- Say dollar amounts naturally (e.g., "seventy-five dollars" not "$75.00").

#Booking Flow
Your goal is to help callers book a tee time using a Reserve → Confirm flow. You need to collect:
1. **Date** — when they want to play (e.g., "tomorrow", "this Saturday", "March 8th")
2. **Number of players** — how many in their group (1-4)  
3. **Time preference** — morning, afternoon, or a specific time
4. **Name** — the caller's name for the reservation

**Booking Process (CRITICAL - Follow exactly):**
1. **Search** → Use search_tee_times to find available slots
2. **Present options** → Show up to 3 time slots with prices
3. **Reserve** → When caller chooses, use reserve_booking (creates pending booking)
4. **Confirm details** → Read back ALL details: "So that's [name] on [date] at [time] for [players] players, total $[amount]. Shall I confirm this booking?"
5. **Finalize** → 
   - If caller says YES → use confirm_booking
   - If caller says NO or changes mind → use cancel_booking

#Important Rules
- Only book dates within the next 14 days.
- Maximum 4 players per tee time.
- ALWAYS use reserve_booking first - NEVER skip the confirmation step.
- ALWAYS read back complete details before asking for confirmation.
- After reserve_booking, you MUST call either confirm_booking or cancel_booking.
- After confirmed booking, read the confirmation code letter by letter.
- If no tee times are available, offer alternative times or dates.

#When to Transfer to Human
You should transfer calls to a human staff member for:
- Caller explicitly asks for a manager or to speak to a person
- Billing disputes or refund requests
- Complaints about service or facilities
- Group event inquiries (10+ players) 
- Tournament registration or questions
- Any request you cannot fulfill after 2 attempts
- Complex requests that require human judgment

When transferring, explain to the caller: "Let me connect you with our staff right away. They'll be able to help you with that."
Use the transfer_to_human function with an appropriate reason and a brief summary.

#Closing
After booking, say: "You're all set! Is there anything else I can help with?"
If they say no: "Have a great round! Goodbye."`;

function buildFunctions(courseId) {
  const fns = [
    {
      name: "search_tee_times",
      description:
        "Search for available tee times. Supports single date or multi-day range (e.g., 'this weekend' uses date + date_end). Returns available time slots with prices, and suggests alternatives if nothing is found.",
      parameters: {
        type: "object",
        properties: {
          date: {
            type: "string",
            description:
              "The date to search for tee times in YYYY-MM-DD format. For multi-day searches, this is the start date.",
          },
          players: {
            type: "integer",
            description: "Number of players (1-4).",
          },
          time_preference: {
            type: "string",
            description:
              "Preferred time of day: 'early_morning' (6-8am), 'morning' (7-11am), 'midday' (11am-1pm), 'afternoon' (12-4pm), 'twilight' (3-6pm), or a specific hour like '8' or '14'.",
          },
          date_end: {
            type: "string",
            description:
              "Optional end date for multi-day search in YYYY-MM-DD format (e.g., for 'this weekend', date is Saturday and date_end is Sunday).",
          },
        },
        required: ["date", "players"],
      },
    },
    {
      name: "reserve_booking",
      description:
        "Reserve a tee time (creates a pending booking) that requires confirmation. Use this when the caller selects a tee time. Returns booking details for confirmation.",
      parameters: {
        type: "object",
        properties: {
          tee_time_id: {
            type: "integer",
            description:
              "The ID of the selected tee time from search results.",
          },
          players_count: {
            type: "integer",
            description: "Number of players (1-4).",
          },
          caller_name: {
            type: "string",
            description: "The caller's full name for the reservation.",
          },
          caller_phone: {
            type: "string",
            description: "The caller's phone number for the booking.",
          },
        },
        required: ["tee_time_id", "players_count", "caller_name"],
      },
    },
    {
      name: "confirm_booking",
      description:
        "Confirm a pending booking after the caller says yes to the details. This finalizes the reservation.",
      parameters: {
        type: "object",
        properties: {
          booking_id: {
            type: "integer",
            description: "The booking ID from the reserve_booking response.",
          },
        },
        required: ["booking_id"],
      },
    },
    {
      name: "cancel_booking",
      description:
        "Cancel a pending booking if the caller says no or changes their mind during confirmation.",
      parameters: {
        type: "object",
        properties: {
          booking_id: {
            type: "integer",
            description: "The booking ID from the reserve_booking response.",
          },
          reason: {
            type: "string",
            description: "Optional reason for cancellation.",
          },
        },
        required: ["booking_id"],
      },
    },
    {
      name: "get_course_info",
      description:
        "Get information about the golf course including rates, hours, and address.",
      parameters: {
        type: "object",
        properties: {},
      },
    },
    {
      name: "transfer_to_human",
      description:
        "Transfer the call to a human staff member when the caller needs assistance that the AI cannot provide. Use this when the caller explicitly asks for a manager/human, has billing disputes, complaints, group event inquiries (10+ players), tournament questions, or any request you cannot fulfill after 2 attempts.",
      parameters: {
        type: "object",
        properties: {
          reason: {
            type: "string",
            enum: ["billing_inquiry", "complaint", "group_event", "tournament", "manager_request", "other"],
            description: "The reason for the handoff to a human."
          },
          reason_detail: {
            type: "string", 
            description: "A brief summary of the conversation so far and what the caller needs."
          },
          caller_name: {
            type: "string",
            description: "The caller's name if known."
          }
        },
        required: ["reason", "reason_detail"]
      }
    },
  ];

  // Attach courseId metadata so function-handlers knows which course to query
  if (courseId) {
    fns._courseId = courseId;
  }

  return fns;
}

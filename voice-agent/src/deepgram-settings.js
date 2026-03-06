// Deepgram Voice Agent Settings — sent immediately after WebSocket connection
export function buildSettings() {
  return {
    type: "Settings",
    audio: {
      input: {
        encoding: "mulaw",
        sample_rate: 8000,
      },
      output: {
        encoding: "mulaw",
        sample_rate: 8000,
        container: "none",
      },
    },
    agent: {
      language: "en",
      listen: {
        provider: {
          type: "deepgram",
          model: "nova-3",
        },
      },
      think: {
        provider: {
          type: process.env.LLM_PROVIDER || "google",
          model: process.env.LLM_MODEL || "gemini-2.5-flash",
        },
        prompt: SYSTEM_PROMPT,
        functions: BOOKING_FUNCTIONS,
      },
      speak: {
        provider: {
          type: "deepgram",
          model: process.env.TTS_MODEL || "aura-2-odysseus-en",
        },
      },
      greeting:
        "Hello! Thanks for calling. I can help you book a tee time. What date would you like to play?",
    },
  };
}

const SYSTEM_PROMPT = `#Role
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
Your goal is to help callers book a tee time. You need to collect:
1. **Date** — when they want to play (e.g., "tomorrow", "this Saturday", "March 8th")
2. **Number of players** — how many in their group (1-4)
3. **Time preference** — morning, afternoon, or a specific time

Once you have all three, use the search_tee_times function to find available slots.
Present up to 3 options with times and prices.
When they choose, confirm the details and use create_booking to complete it.

#Important Rules
- Only book dates within the next 14 days.
- Maximum 4 players per tee time.
- Always confirm the full booking details before creating it:
  date, time, number of players, and total price.
- After booking, read the confirmation code letter by letter.
- If no tee times are available, offer alternative times or dates.

#Closing
After booking, say: "You're all set! Is there anything else I can help with?"
If they say no: "Have a great round! Goodbye."`;

const BOOKING_FUNCTIONS = [
  {
    name: "search_tee_times",
    description:
      "Search for available tee times on a specific date. Returns a list of available time slots with prices.",
    parameters: {
      type: "object",
      properties: {
        date: {
          type: "string",
          description:
            "The date to search for tee times in YYYY-MM-DD format.",
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
      },
      required: ["date", "players"],
    },
  },
  {
    name: "create_booking",
    description:
      "Create a tee time booking after the caller has confirmed the details. Returns a confirmation code.",
    parameters: {
      type: "object",
      properties: {
        tee_time_id: {
          type: "integer",
          description: "The ID of the selected tee time from search results.",
        },
        players_count: {
          type: "integer",
          description: "Number of players (1-4).",
        },
        caller_phone: {
          type: "string",
          description: "The caller's phone number for the booking.",
        },
      },
      required: ["tee_time_id", "players_count"],
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
];

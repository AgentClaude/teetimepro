// Handles Deepgram FunctionCallRequest by calling the Rails API

const API_BASE = process.env.API_URL || "http://api:3003";
const API_KEY = process.env.TEETIMEPRO_API_KEY || "";

/**
 * Execute a function call from Deepgram Voice Agent
 * @param {string} name - Function name
 * @param {object} args - Function arguments
 * @param {object} callMeta - Call metadata (from, to, streamSid)
 * @returns {string} - Result as string for the agent
 */
export async function executeFunction(name, args, callMeta) {
  switch (name) {
    case "search_tee_times":
      return await searchTeeTimes(args);
    case "create_booking":
      return await createBooking(args, callMeta);
    case "get_course_info":
      return await getCourseInfo();
    case "transfer_to_human":
      return await transferToHuman(args, callMeta);
    default:
      return JSON.stringify({ error: `Unknown function: ${name}` });
  }
}

/**
 * Search for available tee times, with support for multi-day ranges and alternatives.
 * @param {object} args
 * @param {string} args.date - Primary date (YYYY-MM-DD)
 * @param {number} args.players - Number of players
 * @param {string} [args.time_preference] - Time preference
 * @param {string} [args.date_end] - End date for multi-day search (YYYY-MM-DD)
 */
async function searchTeeTimes({ date, players, time_preference, date_end }) {
  try {
    const params = new URLSearchParams();

    if (date_end) {
      // Multi-day search (e.g., "this weekend")
      params.set("start_date", date);
      params.set("end_date", date_end);
    } else {
      params.set("date", date);
    }

    params.set("players", String(players));

    if (time_preference) {
      params.set("time_preference", time_preference);
    }

    const res = await apiFetch(`/api/v1/tee_times?${params}`);

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      return JSON.stringify({
        error: err.error || "Could not search tee times. Please try again.",
      });
    }

    const data = await res.json();
    const teeTimes = data.data || [];

    if (!teeTimes.length) {
      // Check for alternatives from the API
      if (data.alternatives && data.alternatives.length > 0) {
        const altSlots = data.alternatives.slice(0, 3).map((tt) => ({
          id: tt.id,
          date: tt.date,
          time: tt.formatted_time || tt.starts_at,
          available_spots: tt.available_spots,
          price_per_player_dollars: (tt.price_cents / 100).toFixed(2),
          total_dollars: ((tt.price_cents * players) / 100).toFixed(2),
        }));

        const dateLabel = date_end
          ? `${date} to ${date_end}`
          : date;

        return JSON.stringify({
          available: false,
          message: data.message || `No tee times available on ${dateLabel} for ${players} players.`,
          has_alternatives: true,
          alternatives: altSlots,
        });
      }

      const dateLabel = date_end
        ? `${date} to ${date_end}`
        : date;

      return JSON.stringify({
        available: false,
        message: `No tee times available on ${dateLabel} for ${players} players. Would you like to try a different date or time?`,
      });
    }

    // Format for the agent
    const slots = teeTimes.slice(0, 5).map((tt) => ({
      id: tt.id,
      date: tt.date,
      time: tt.formatted_time || tt.starts_at,
      available_spots: tt.available_spots,
      price_per_player_dollars: (tt.price_cents / 100).toFixed(2),
      total_dollars: ((tt.price_cents * players) / 100).toFixed(2),
    }));

    return JSON.stringify({
      available: true,
      date: date_end ? `${date} to ${date_end}` : date,
      players,
      tee_times: slots,
    });
  } catch (err) {
    return JSON.stringify({ error: `Search failed: ${err.message}` });
  }
}

async function createBooking({ tee_time_id, players_count, caller_name, caller_phone }, callMeta) {
  try {
    // Split caller name into first/last
    const nameParts = (caller_name || "Guest Caller").trim().split(/\s+/);
    const firstName = nameParts[0];
    const lastName = nameParts.length > 1 ? nameParts.slice(1).join(" ") : "";

    const body = {
      tee_time_id,
      players_count,
      phone: caller_phone || callMeta?.from,
      first_name: firstName,
      last_name: lastName,
    };

    const res = await apiFetch("/api/v1/bookings", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    const data = await res.json();

    if (!res.ok) {
      return JSON.stringify({
        success: false,
        error: data.error || "Booking failed",
      });
    }

    const booking = data.data || data;
    return JSON.stringify({
      success: true,
      confirmation_code: booking.confirmation_code,
      date: booking.tee_time?.starts_at || booking.date,
      players: booking.players_count,
      total_dollars: ((booking.total_cents || 0) / 100).toFixed(2),
    });
  } catch (err) {
    return JSON.stringify({ error: `Booking failed: ${err.message}` });
  }
}

async function getCourseInfo() {
  try {
    const res = await apiFetch("/api/v1/courses");
    const data = await res.json();
    const courses = data.data || data;

    if (!courses.length) {
      return JSON.stringify({ error: "No course information available" });
    }

    const course = courses[0];
    return JSON.stringify({
      name: course.name,
      holes: course.holes,
      address: `${course.address}, ${course.city}, ${course.state} ${course.zip}`,
      phone: course.phone,
      weekday_rate: `$${(course.weekday_rate_cents / 100).toFixed(2)}`,
      weekend_rate: `$${(course.weekend_rate_cents / 100).toFixed(2)}`,
      twilight_rate: `$${(course.twilight_rate_cents / 100).toFixed(2)}`,
      first_tee_time: course.first_tee_time,
      last_tee_time: course.last_tee_time,
    });
  } catch (err) {
    return JSON.stringify({ error: `Could not fetch course info: ${err.message}` });
  }
}

/**
 * Transfer call to human staff member
 * @param {object} args
 * @param {string} args.reason - Reason for handoff
 * @param {string} args.reason_detail - Summary of conversation and caller needs
 * @param {string} [args.caller_name] - Caller's name if known
 * @param {object} callMeta - Call metadata (from, to, streamSid)
 */
async function transferToHuman({ reason, reason_detail, caller_name }, callMeta) {
  try {
    const body = {
      call_sid: callMeta?.streamSid || callMeta?.callSid,
      caller_phone: callMeta?.from,
      caller_name,
      reason,
      reason_detail,
    };

    const res = await apiFetch("/api/v1/voice_handoffs", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    const data = await res.json();

    if (!res.ok) {
      return JSON.stringify({
        transfer: false,
        error: data.error || "Transfer failed. Please hold while I try to reach someone.",
      });
    }

    const handoffData = data.data || data;
    
    return JSON.stringify({
      transfer: true,
      handoff_id: handoffData.handoff?.id || handoffData.handoff_id,
      transfer_number: handoffData.transfer_number,
      message: "Transferring you to our staff right away. Please hold.",
    });
  } catch (err) {
    return JSON.stringify({
      transfer: false,
      error: `Transfer failed: ${err.message}`,
    });
  }
}

async function apiFetch(path, options = {}) {
  const url = `${API_BASE}${path}`;
  const headers = {
    Authorization: `Bearer ${API_KEY}`,
    Accept: "application/json",
    ...options.headers,
  };

  return fetch(url, { ...options, headers });
}

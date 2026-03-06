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
    default:
      return JSON.stringify({ error: `Unknown function: ${name}` });
  }
}

async function searchTeeTimes({ date, players, time_preference }) {
  try {
    const params = new URLSearchParams({
      date,
      players: String(players),
    });

    if (time_preference) {
      params.set("time_preference", time_preference);
    }

    const res = await apiFetch(`/api/v1/tee_times?${params}`);

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      return JSON.stringify({
        error: err.error || "Could not search tee times",
      });
    }

    const data = await res.json();
    const teeTimes = data.data || data;

    if (!teeTimes.length) {
      return JSON.stringify({
        available: false,
        message: `No tee times available on ${date} for ${players} players around that time.`,
      });
    }

    // Format for the agent
    const slots = teeTimes.slice(0, 5).map((tt) => ({
      id: tt.id,
      time: tt.formatted_time || tt.starts_at,
      available_spots: tt.available_spots,
      price_per_player_dollars: (tt.price_cents / 100).toFixed(2),
      total_dollars: ((tt.price_cents * players) / 100).toFixed(2),
    }));

    return JSON.stringify({
      available: true,
      date,
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

async function apiFetch(path, options = {}) {
  const url = `${API_BASE}${path}`;
  const headers = {
    Authorization: `Bearer ${API_KEY}`,
    Accept: "application/json",
    ...options.headers,
  };

  return fetch(url, { ...options, headers });
}

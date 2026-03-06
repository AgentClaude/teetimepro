# frozen_string_literal: true

puts "Seeding database..."

# ---------------------------------------------------------------------------
# Organizations
# ---------------------------------------------------------------------------
org1 = Organization.find_or_create_by!(slug: "mountain-view-gc") do |o|
  o.name = "Mountain View Golf Club"
  o.email = "info@mountainview.golf"
  o.phone = "(303) 555-0100"
  o.address = "1234 Fairway Drive, Boulder, CO 80302"
  o.timezone = "America/Denver"
  o.settings = { booking_window_days: 14, cancellation_hours: 24 }
end

org2 = Organization.find_or_create_by!(slug: "sunset-links") do |o|
  o.name = "Sunset Links Resort"
  o.email = "hello@sunsetlinks.com"
  o.phone = "(480) 555-0200"
  o.address = "8800 Desert Canyon Rd, Scottsdale, AZ 85255"
  o.timezone = "America/Phoenix"
  o.settings = { booking_window_days: 21, cancellation_hours: 48 }
end

puts "  Organizations: #{Organization.count}"

# ---------------------------------------------------------------------------
# Users — Org 1 (Mountain View)
# ---------------------------------------------------------------------------
admin1 = User.find_or_create_by!(email: "admin@mountainview.golf") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.organization = org1
  u.role = :admin
  u.first_name = "Sarah"
  u.last_name = "Johnson"
  u.phone = "(303) 555-0101"
end

staff1 = User.find_or_create_by!(email: "proshop@mountainview.golf") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.organization = org1
  u.role = :staff
  u.first_name = "Mike"
  u.last_name = "Thompson"
  u.phone = "(303) 555-0102"
end

manager1 = User.find_or_create_by!(email: "manager@mountainview.golf") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.organization = org1
  u.role = :manager
  u.first_name = "Lisa"
  u.last_name = "Chen"
  u.phone = "(303) 555-0103"
end

golfers_org1 = []
[
  { email: "alex.rivera@example.com",   first: "Alex",    last: "Rivera",    phone: "(303) 555-0200", handicap: 14.2, tee: "White" },
  { email: "jordan.baker@example.com",  first: "Jordan",  last: "Baker",     phone: "(303) 555-0201", handicap: 8.5,  tee: "Blue" },
  { email: "casey.woods@example.com",   first: "Casey",   last: "Woods",     phone: "(303) 555-0202", handicap: 22.1, tee: "Gold" },
  { email: "taylor.green@example.com",  first: "Taylor",  last: "Green",     phone: "(303) 555-0203", handicap: 3.7,  tee: "Black" },
  { email: "morgan.palmer@example.com", first: "Morgan",  last: "Palmer",    phone: "(303) 555-0204", handicap: nil,  tee: "White" },
].each do |attrs|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
    u.organization = org1
    u.role = :golfer
    u.first_name = attrs[:first]
    u.last_name = attrs[:last]
    u.phone = attrs[:phone]
  end

  GolferProfile.find_or_create_by!(user: user) do |gp|
    gp.handicap_index = attrs[:handicap]
    gp.home_course = "Mountain View Golf Club"
    gp.preferred_tee = attrs[:tee]
  end

  golfers_org1 << user
end

# ---------------------------------------------------------------------------
# Users — Org 2 (Sunset Links)
# ---------------------------------------------------------------------------
admin2 = User.find_or_create_by!(email: "admin@sunsetlinks.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.organization = org2
  u.role = :admin
  u.first_name = "David"
  u.last_name = "Martinez"
  u.phone = "(480) 555-0201"
end

staff2 = User.find_or_create_by!(email: "proshop@sunsetlinks.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.organization = org2
  u.role = :pro_shop
  u.first_name = "Rachel"
  u.last_name = "Kim"
  u.phone = "(480) 555-0202"
end

golfers_org2 = []
[
  { email: "pat.nicklaus@example.com",  first: "Pat",   last: "Nicklaus",  phone: "(480) 555-0300", handicap: 6.0,  tee: "Blue" },
  { email: "sam.hogan@example.com",     first: "Sam",   last: "Hogan",     phone: "(480) 555-0301", handicap: 18.3, tee: "White" },
].each do |attrs|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
    u.organization = org2
    u.role = :golfer
    u.first_name = attrs[:first]
    u.last_name = attrs[:last]
    u.phone = attrs[:phone]
  end

  GolferProfile.find_or_create_by!(user: user) do |gp|
    gp.handicap_index = attrs[:handicap]
    gp.home_course = "Sunset Links Resort"
    gp.preferred_tee = attrs[:tee]
  end

  golfers_org2 << user
end

puts "  Users: #{User.count}  |  Golfer Profiles: #{GolferProfile.count}"

# ---------------------------------------------------------------------------
# Courses
# ---------------------------------------------------------------------------
course1 = Course.find_or_create_by!(organization: org1, name: "Mountain View Championship Course") do |c|
  c.holes = 18
  c.interval_minutes = 8
  c.first_tee_time = "06:00"
  c.last_tee_time = "18:00"
  c.max_players_per_slot = 4
  c.weekday_rate_cents = 7500
  c.weekend_rate_cents = 9500
  c.twilight_rate_cents = 4500
  c.address = "1234 Fairway Drive"
  c.city = "Boulder"
  c.state = "CO"
  c.zip = "80302"
  c.phone = "(303) 555-0100"
  c.website = "https://mountainview.golf"
  c.latitude = 40.0150
  c.longitude = -105.2705
  c.timezone = "America/Denver"
end

course1b = Course.find_or_create_by!(organization: org1, name: "Mountain View Executive 9") do |c|
  c.holes = 9
  c.interval_minutes = 10
  c.first_tee_time = "07:00"
  c.last_tee_time = "17:00"
  c.max_players_per_slot = 4
  c.weekday_rate_cents = 3500
  c.weekend_rate_cents = 4500
  c.twilight_rate_cents = 2500
  c.address = "1234 Fairway Drive"
  c.city = "Boulder"
  c.state = "CO"
  c.zip = "80302"
  c.phone = "(303) 555-0100"
  c.website = "https://mountainview.golf"
  c.latitude = 40.0155
  c.longitude = -105.2710
  c.timezone = "America/Denver"
end

course2 = Course.find_or_create_by!(organization: org2, name: "Sunset Canyon Course") do |c|
  c.holes = 18
  c.interval_minutes = 10
  c.first_tee_time = "06:30"
  c.last_tee_time = "17:30"
  c.max_players_per_slot = 4
  c.weekday_rate_cents = 12_000
  c.weekend_rate_cents = 15_000
  c.twilight_rate_cents = 7_000
  c.address = "8800 Desert Canyon Rd"
  c.city = "Scottsdale"
  c.state = "AZ"
  c.zip = "85255"
  c.phone = "(480) 555-0200"
  c.website = "https://sunsetlinks.com"
  c.latitude = 33.7295
  c.longitude = -111.9280
  c.timezone = "America/Phoenix"
end

puts "  Courses: #{Course.count}"

# ---------------------------------------------------------------------------
# Helper: generate tee sheet + tee times for a course/date range
# ---------------------------------------------------------------------------
def generate_tee_sheets(course, date_range)
  date_range.each do |date|
    tee_sheet = TeeSheet.find_or_create_by!(course: course, date: date) do |ts|
      ts.generated_at = Time.current
    end

    tz = course.timezone
    start_time = date.in_time_zone(tz).change(hour: course.first_tee_time.to_i, min: course.first_tee_time.split(":").last.to_i)
    end_time   = date.in_time_zone(tz).change(hour: course.last_tee_time.to_i,  min: course.last_tee_time.split(":").last.to_i)

    current_time = start_time
    while current_time <= end_time
      is_weekend = date.saturday? || date.sunday?
      rate = is_weekend ? course.weekend_rate_cents : course.weekday_rate_cents
      rate = course.twilight_rate_cents if current_time.hour >= 15

      TeeTime.find_or_create_by!(tee_sheet: tee_sheet, starts_at: current_time) do |tt|
        tt.max_players = course.max_players_per_slot
        tt.price_cents = rate
        tt.price_currency = "USD"
        tt.status = :available
      end

      current_time += course.interval_minutes.minutes
    end
  end
end

today = Date.current

# Tee sheets: yesterday through +14 days for main courses, +7 for exec 9
generate_tee_sheets(course1,  (today - 1.day)..(today + 14.days))
generate_tee_sheets(course1b, (today - 1.day)..(today + 7.days))
generate_tee_sheets(course2,  (today - 1.day)..(today + 14.days))

puts "  Tee Sheets: #{TeeSheet.count}  |  Tee Times: #{TeeTime.count}"

# ---------------------------------------------------------------------------
# Bookings, Booking Players & Payments
# ---------------------------------------------------------------------------
booking_count = 0

# Org 1 — bookings across several days
booking_specs = [
  # Past booking (yesterday) — completed with payment
  { course: course1, date: today - 1.day, hour: 8,  user: golfers_org1[0], players: 4, status: :completed, payment: :completed },
  { course: course1, date: today - 1.day, hour: 9,  user: golfers_org1[1], players: 2, status: :completed, payment: :completed },
  # Today — confirmed and checked-in
  { course: course1, date: today, hour: 8,  user: golfers_org1[0], players: 3, status: :confirmed,  payment: :completed },
  { course: course1, date: today, hour: 9,  user: golfers_org1[1], players: 4, status: :checked_in, payment: :completed },
  { course: course1, date: today, hour: 10, user: golfers_org1[2], players: 2, status: :confirmed,  payment: :completed },
  { course: course1, date: today, hour: 14, user: golfers_org1[3], players: 1, status: :confirmed,  payment: :pending },
  # Today — cancelled booking
  { course: course1, date: today, hour: 11, user: golfers_org1[4], players: 3, status: :cancelled,  payment: :refunded },
  # Tomorrow
  { course: course1, date: today + 1.day, hour: 7,  user: golfers_org1[0], players: 4, status: :confirmed, payment: :completed },
  { course: course1, date: today + 1.day, hour: 8,  user: golfers_org1[3], players: 2, status: :confirmed, payment: :completed },
  { course: course1, date: today + 1.day, hour: 16, user: golfers_org1[2], players: 3, status: :confirmed, payment: :completed },
  # Day after tomorrow
  { course: course1, date: today + 2.days, hour: 9, user: golfers_org1[1], players: 4, status: :confirmed, payment: :pending },
  # Executive 9
  { course: course1b, date: today, hour: 8,  user: golfers_org1[4], players: 2, status: :confirmed, payment: :completed },
  { course: course1b, date: today + 1.day, hour: 10, user: golfers_org1[2], players: 2, status: :confirmed, payment: :completed },
]

# Org 2 — bookings
booking_specs += [
  { course: course2, date: today, hour: 7,  user: golfers_org2[0], players: 4, status: :confirmed,  payment: :completed },
  { course: course2, date: today, hour: 8,  user: golfers_org2[1], players: 2, status: :confirmed,  payment: :completed },
  { course: course2, date: today + 1.day, hour: 7, user: golfers_org2[0], players: 3, status: :confirmed, payment: :pending },
]

guest_names = [
  "Chris Evans", "Jamie Fox", "Drew Carey", "Robin Banks",
  "Sandy Wedge", "Chip Shotwell", "Birdie McPar", "Bunker Hill"
]

booking_specs.each_with_index do |spec, idx|
  tee_sheet = TeeSheet.find_by(course: spec[:course], date: spec[:date])
  next unless tee_sheet

  target_time = spec[:date].in_time_zone(spec[:course].timezone).change(hour: spec[:hour])
  tee_time = tee_sheet.tee_times.where("starts_at >= ?", target_time).order(:starts_at).first
  next unless tee_time

  booking = Booking.find_or_create_by!(tee_time: tee_time, user: spec[:user]) do |b|
    b.players_count = spec[:players]
    b.total_cents = tee_time.price_cents * spec[:players]
    b.total_currency = "USD"
    b.status = spec[:status]
  end

  # Mark tee time as booked
  tee_time.update!(status: :booked) unless spec[:status] == :cancelled

  # Booking players
  spec[:players].times do |p|
    name = if p == 0
             spec[:user].full_name
           else
             guest_names[(idx + p) % guest_names.size]
           end

    BookingPlayer.find_or_create_by!(booking: booking, name: name) do |bp|
      bp.golfer_profile = spec[:user].golfer_profile if p == 0
      bp.email = "#{name.parameterize}@example.com" if p > 0
    end
  end

  # Payment
  if spec[:payment]
    Payment.find_or_create_by!(booking: booking) do |pay|
      pay.stripe_payment_intent_id = "pi_seed_#{SecureRandom.hex(12)}"
      pay.amount_cents = booking.total_cents
      pay.amount_currency = "USD"
      pay.status = spec[:payment]
      pay.stripe_charge_id = "ch_seed_#{SecureRandom.hex(12)}" if spec[:payment] == :completed
      pay.refund_amount_cents = booking.total_cents if spec[:payment] == :refunded
      pay.refund_amount_currency = "USD" if spec[:payment] == :refunded
      pay.metadata = { source: "seed", created_at: Time.current.iso8601 }
    end
  end

  booking_count += 1
end

puts "  Bookings: #{Booking.count}  |  Booking Players: #{BookingPlayer.count}  |  Payments: #{Payment.count}"

# ---------------------------------------------------------------------------
# Memberships
# ---------------------------------------------------------------------------
membership_specs = [
  { user: golfers_org1[0], org: org1, tier: :gold,     status: :active,  price: 250_000, months_ago: 2, duration: 12 },
  { user: golfers_org1[1], org: org1, tier: :platinum,  status: :active,  price: 500_000, months_ago: 6, duration: 12 },
  { user: golfers_org1[2], org: org1, tier: :basic,     status: :active,  price: 75_000,  months_ago: 1, duration: 12 },
  { user: golfers_org1[3], org: org1, tier: :silver,    status: :active,  price: 150_000, months_ago: 3, duration: 12 },
  { user: golfers_org1[4], org: org1, tier: :basic,     status: :expired, price: 75_000,  months_ago: 14, duration: 12 },
  { user: golfers_org2[0], org: org2, tier: :platinum,  status: :active,  price: 800_000, months_ago: 1, duration: 12 },
  { user: golfers_org2[1], org: org2, tier: :silver,    status: :active,  price: 250_000, months_ago: 11, duration: 12 },
]

membership_specs.each do |spec|
  starts = spec[:months_ago].months.ago.beginning_of_day
  ends   = starts + spec[:duration].months

  Membership.find_or_create_by!(organization: spec[:org], user: spec[:user]) do |m|
    m.tier = spec[:tier]
    m.status = spec[:status]
    m.price_cents = spec[:price]
    m.price_currency = "USD"
    m.starts_at = starts
    m.ends_at = ends
    m.auto_renew = spec[:status] == :active
  end
end

puts "  Memberships: #{Membership.count}"

# ---------------------------------------------------------------------------
# API Keys
# ---------------------------------------------------------------------------
[
  { org: org1, name: "Mountain View Website",    tier: "standard", scopes: %w[read:tee_times read:courses] },
  { org: org1, name: "Mountain View Mobile App", tier: "premium",  scopes: %w[read:tee_times read:courses create:bookings read:bookings] },
  { org: org2, name: "Sunset Links Integration", tier: "enterprise", scopes: [] },
].each do |spec|
  # ApiKey auto-generates key_digest via before_validation, so just create
  key = ApiKey.find_or_create_by!(organization: spec[:org], name: spec[:name]) do |k|
    k.rate_limit_tier = spec[:tier]
    k.scopes = spec[:scopes]
    k.expires_at = 1.year.from_now
  end
  puts "  API Key: #{key.name} (#{key.prefix}...)" if key.prefix.present?
end

puts "  API Keys: #{ApiKey.count}"

# ---------------------------------------------------------------------------
# Webhook Endpoints & Events
# ---------------------------------------------------------------------------
webhook1 = WebhookEndpoint.find_or_create_by!(organization: org1, url: "https://hooks.mountainview.golf/bookings") do |w|
  w.events = %w[booking.created booking.cancelled booking.checked_in]
  w.active = true
end

webhook2 = WebhookEndpoint.find_or_create_by!(organization: org1, url: "https://hooks.mountainview.golf/payments") do |w|
  w.events = %w[payment.completed payment.refunded]
  w.active = true
end

webhook3 = WebhookEndpoint.find_or_create_by!(organization: org2, url: "https://integrations.sunsetlinks.com/webhooks") do |w|
  w.events = WebhookEndpoint::AVAILABLE_EVENTS
  w.active = true
end

# Sample webhook events (delivered + failed)
[
  { endpoint: webhook1, event_type: "booking.created",   status: :delivered, code: 200 },
  { endpoint: webhook1, event_type: "booking.cancelled", status: :delivered, code: 200 },
  { endpoint: webhook1, event_type: "booking.checked_in", status: :failed,  code: 500 },
  { endpoint: webhook2, event_type: "payment.completed", status: :delivered, code: 200 },
  { endpoint: webhook3, event_type: "booking.created",   status: :delivered, code: 200 },
  { endpoint: webhook3, event_type: "payment.completed", status: :pending,  code: nil },
].each do |spec|
  WebhookEvent.find_or_create_by!(
    webhook_endpoint: spec[:endpoint],
    event_type: spec[:event_type],
    payload: { event: spec[:event_type], data: { id: rand(1..100) }, timestamp: Time.current.iso8601 }.to_json
  ) do |e|
    e.status = spec[:status]
    e.attempts = spec[:status] == :pending ? 0 : rand(1..3)
    e.response_code = spec[:code]
    e.response_body = spec[:code] == 200 ? '{"ok":true}' : (spec[:code] ? '{"error":"internal"}' : nil)
    e.delivered_at = Time.current if spec[:status] == :delivered
    e.last_attempted_at = Time.current unless spec[:status] == :pending
  end
end

puts "  Webhook Endpoints: #{WebhookEndpoint.count}  |  Webhook Events: #{WebhookEvent.count}"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
puts ""
puts "Seeding complete!"
puts "  Organizations:   #{Organization.count}"
puts "  Users:           #{User.count}"
puts "  Golfer Profiles: #{GolferProfile.count}"
puts "  Courses:         #{Course.count}"
puts "  Tee Sheets:      #{TeeSheet.count}"
puts "  Tee Times:       #{TeeTime.count}"
puts "  Bookings:        #{Booking.count}"
puts "  Booking Players: #{BookingPlayer.count}"
puts "  Payments:        #{Payment.count}"
puts "  Memberships:     #{Membership.count}"
puts "  API Keys:        #{ApiKey.count}"
puts "  Webhooks:        #{WebhookEndpoint.count} endpoints, #{WebhookEvent.count} events"
puts ""
puts "Login credentials (all passwords: password123):"
puts "  Admin:   admin@mountainview.golf / admin@sunsetlinks.com"
puts "  Staff:   proshop@mountainview.golf / proshop@sunsetlinks.com"
puts "  Manager: manager@mountainview.golf"
puts "  Golfers: alex.rivera@example.com, jordan.baker@example.com, etc."

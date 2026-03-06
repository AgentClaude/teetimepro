# frozen_string_literal: true

puts "🌱 Seeding database..."

# Create demo organization
org = Organization.find_or_create_by!(slug: "mountain-view-gc") do |o|
  o.name = "Mountain View Golf Club"
  o.email = "info@mountainview.golf"
  o.phone = "(303) 555-0100"
  o.address = "1234 Fairway Drive, Boulder, CO 80302"
  o.timezone = "America/Denver"
  o.settings = { booking_window_days: 14, cancellation_hours: 24 }
end
puts "  ✅ Organization: #{org.name}"

# Create users
admin = User.find_or_create_by!(email: "admin@mountainview.golf") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.organization = org
  u.role = :admin
  u.first_name = "Sarah"
  u.last_name = "Johnson"
  u.phone = "(303) 555-0101"
end
puts "  ✅ Admin: #{admin.email}"

staff = User.find_or_create_by!(email: "proshop@mountainview.golf") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.organization = org
  u.role = :staff
  u.first_name = "Mike"
  u.last_name = "Thompson"
  u.phone = "(303) 555-0102"
end
puts "  ✅ Staff: #{staff.email}"

golfer = User.find_or_create_by!(email: "golfer@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.organization = org
  u.role = :golfer
  u.first_name = "Alex"
  u.last_name = "Rivera"
  u.phone = "(303) 555-0200"
end
puts "  ✅ Golfer: #{golfer.email}"

# Create golfer profile
GolferProfile.find_or_create_by!(user: golfer) do |gp|
  gp.handicap_index = 14.2
  gp.home_course = "Mountain View Golf Club"
  gp.preferred_tee = "White"
end

# Create course
course = Course.find_or_create_by!(organization: org, name: "Mountain View Championship Course") do |c|
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
puts "  ✅ Course: #{course.name}"

# Generate tee sheets for today + next 7 days
today = Date.current
(today..(today + 7.days)).each do |date|
  tee_sheet = TeeSheet.find_or_create_by!(course: course, date: date) do |ts|
    ts.generated_at = Time.current
  end

  # Generate tee times from 6:00 AM to 6:00 PM every 8 minutes
  start_time = date.in_time_zone(course.timezone).change(hour: 6, min: 0)
  end_time = date.in_time_zone(course.timezone).change(hour: 18, min: 0)

  current_time = start_time
  while current_time <= end_time
    is_weekend = date.saturday? || date.sunday?
    rate = is_weekend ? course.weekend_rate_cents : course.weekday_rate_cents
    # Twilight after 3 PM
    rate = course.twilight_rate_cents if current_time.hour >= 15

    TeeTime.find_or_create_by!(tee_sheet: tee_sheet, starts_at: current_time) do |tt|
      tt.max_players = 4
      tt.price_cents = rate
      tt.price_currency = "USD"
      tt.status = :available
    end

    current_time += course.interval_minutes.minutes
  end

  puts "  ✅ Tee sheet: #{date} (#{tee_sheet.tee_times.count} tee times)"
end

# Create sample bookings (for today and tomorrow)
tomorrow = today + 1.day
[today, tomorrow].each do |date|
  tee_sheet = TeeSheet.find_by(course: course, date: date)
  next unless tee_sheet

  morning_times = tee_sheet.tee_times.where("starts_at >= ? AND starts_at < ?",
    date.in_time_zone(course.timezone).change(hour: 8),
    date.in_time_zone(course.timezone).change(hour: 10)
  ).limit(3)

  morning_times.each_with_index do |tee_time, i|
    players = [2, 3, 4][i % 3]
    booking = Booking.find_or_create_by!(tee_time: tee_time, user: golfer) do |b|
      b.confirmation_code = "MV#{date.strftime('%m%d')}#{(i + 1).to_s.rjust(3, '0')}"
      b.players_count = players
      b.total_cents = tee_time.price_cents * players
      b.total_currency = "USD"
      b.status = :confirmed
    end

    # Add booking players
    players.times do |p|
      BookingPlayer.find_or_create_by!(booking: booking, name: "Player #{p + 1} - #{booking.confirmation_code}") do |bp|
        bp.email = "player#{p + 1}@example.com" if p > 0
      end
    end
  end
end

puts "\n🏌️ Seeding complete!"
puts "  Organizations: #{Organization.count}"
puts "  Users: #{User.count}"
puts "  Courses: #{Course.count}"
puts "  Tee Sheets: #{TeeSheet.count}"
puts "  Tee Times: #{TeeTime.count}"
puts "  Bookings: #{Booking.count}"
puts "  Booking Players: #{BookingPlayer.count}"

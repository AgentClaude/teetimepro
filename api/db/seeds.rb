# Seeds for TeeTimes Pro development environment

puts "🌱 Seeding TeeTimes Pro..."

# Create a default organization
org = Organization.find_or_create_by!(name: "Pine Valley Golf Club") do |o|
  o.slug = "pine-valley"
end
puts "  ✅ Organization: #{org.name}"

# Create admin user
admin = User.find_or_create_by!(email: "admin@pinevalley.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.first_name = "Admin"
  u.last_name = "User"
  u.role = :owner
  u.organization = org
end
puts "  ✅ Admin: #{admin.email}"

# Create staff user
staff = User.find_or_create_by!(email: "proshop@pinevalley.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.first_name = "Pro"
  u.last_name = "Shop"
  u.role = :pro_shop
  u.organization = org
end
puts "  ✅ Staff: #{staff.email}"

# Create golfer user
golfer = User.find_or_create_by!(email: "golfer@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.first_name = "John"
  u.last_name = "Golfer"
  u.role = :golfer
  u.organization = org
end
puts "  ✅ Golfer: #{golfer.email}"

# Create a golfer profile
GolferProfile.find_or_create_by!(user: golfer) do |p|
  p.handicap_index = 14.2
end

# Create a course
course = Course.find_or_create_by!(name: "Pine Valley Championship Course", organization: org) do |c|
  c.holes = 18
  c.interval_minutes = 10
  c.max_players_per_slot = 4
  c.first_tee_time = Time.zone.parse("06:00")
  c.last_tee_time = Time.zone.parse("17:00")
  c.weekday_rate_cents = 7500
  c.weekend_rate_cents = 9500
  c.twilight_rate_cents = 4500
end
puts "  ✅ Course: #{course.name}"

# Generate tee sheets for the next 7 days
7.times do |offset|
  date = Date.current + offset.days
  result = TeeSheets::GenerateTeeSheetService.call(course: course, date: date)
  if result.success?
    puts "  ✅ Tee sheet for #{date}: #{result.data.tee_times_count} tee times"
  end
end

puts "\n🏌️ Seeding complete!"
puts "  Login: admin@pinevalley.com / password123"
puts "  API:   http://localhost:3003"
puts "  Web:   http://localhost:3004"

require 'csv'

# ############################################
# CLEANING
# ############################################
puts "👉 Cleaning databases..."
AuditLog.destroy_all
PilotPref.destroy_all
User.destroy_all
Runway.destroy_all
FuelStation.destroy_all
Event.destroy_all
Airport.destroy_all
Country.destroy_all

puts "-------------------------------"
puts "All environments seeds"
puts "-------------------------------"

# ############################################
# IMPORT TASKS
# ############################################
Rake::Task['import:countries'].invoke
Rake::Task['import:airports'].invoke
Rake::Task['import:runways'].invoke
Rake::Task['import:fuel_stations'].invoke

# ############################################
# USERS
# ############################################
# Create an admin user
user = User.new
user.username = "alexstan57"
user.email = "alex@sky-unlimited.lu"
user.role = "admin"
user.password = "Default2024"
user.confirmed_at = Time.zone.now - 1.hour
user.confirmation_sent_at = Time.zone.now - 2.hours
user.save
pilot_pref = PilotPref.find_by(user_id: user.id)
pilot_pref.update(is_ultralight_pilot: true, is_private_pilot: false)
puts "Admin user alex created"
puts "Pilot pref alex created"

# Create users
if Rails.env.development? || Rails.env.staging?
  puts "-------------------------------"
  puts "development & staging seeds"
  puts "-------------------------------"
  user = User.new
  user.username = "rachel"
  user.email = "rachel@sky-unlimited.lu"
  user.role = "admin"
  user.password = "Default2024"
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  pilot_pref = PilotPref.find_by(user_id: user.id)
  pilot_pref.update(is_ultralight_pilot: true, is_private_pilot: true)
  puts "rachel user created"
  puts "rachel pilot prefs created"

  user = User.new
  user.username = "chris_bali"
  user.email = "christina.sugiono95@gmail.com"
  user.role = "admin"
  user.password = "Default2024"
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  pilot_pref = PilotPref.find_by(user_id: user.id)
  pilot_pref.update(airport: Airport.find_by(icao: "LFCL"), is_ultralight_pilot: true, is_private_pilot: true)
  puts "christina user created"
  puts "christina pilot prefs created"

  # Create dummy events
  lux_airport = Airport.find_by(icao: "ELLX")
  leipzig_airport = Airport.find_by(icao: "EDAC")
  munich_airport = Airport.find_by(icao: "EDDM")
  Event.create(title: "Event 1", kind: 0, start_date: Date.today + 1.week, end_date: Date.today + 1.week, image_link: "https://source.unsplash.com/random/?#{lux_airport.name}" , url: "https://google.com?q=#{lux_airport.name}", airport: lux_airport)
  Event.create(title: "Event 2", kind: 1, start_date: Date.today + 2.week, end_date: Date.today + 2.week + 2.day, image_link: "https://source.unsplash.com/random/?#{lux_airport.name}" , url: "https://google.com?q=#{lux_airport.name}", airport: lux_airport)
  Event.create(title: "Event 3", kind: 2, start_date: Date.today + 1.week, end_date: Date.today + 1.week + 2.day, image_link: "https://source.unsplash.com/random/?#{lux_airport.name}" , url: "https://google.com?q=#{lux_airport.name}", airport: lux_airport)
  Event.create(title: "Event 4", kind: 0, start_date: Date.today + 2.week, end_date: Date.today + 2.week + 1.day, image_link: "https://source.unsplash.com/random/?#{munich_airport.name}" , url: "https://google.com?q=#{munich_airport.name}", airport: munich_airport)
  Event.create(title: "Event 5", kind: 1, start_date: Date.today + 1.day, end_date: Date.today + 3.day, image_link: "https://source.unsplash.com/random/?#{munich_airport.name}" , url: "https://google.com?q=#{munich_airport.name}", airport: munich_airport)
  Event.create(title: "Event 6", kind: 2, start_date: Date.today + 5.day, end_date: Date.today + 5.day, image_link: "https://source.unsplash.com/random/?#{leipzig_airport.name}" , url: "https://google.com?q=#{leipzig_airport.name}", airport: leipzig_airport)
  Event.create(title: "Event 7", kind: 3, start_date: Date.today + 1.week, end_date: Date.today + 1.week, image_link: "https://source.unsplash.com/random/?#{leipzig_airport.name}" , url: "https://google.com?q=#{leipzig_airport.name}", airport: leipzig_airport)
end

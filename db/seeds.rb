require 'csv'

# ############################################
# CLEANING
# ############################################
puts "Cleaning databases..."
PilotPref.destroy_all
User.destroy_all

# ############################################
# USERS
# ############################################
# Deleting current users

# Create an admin user
user = User.new
user.first_name = "Alexandre"
user.last_name = "Stanescot"
user.username = "alexstan57"
user.email = "alex@sky-unlimited.lu"
user.role = "admin"
user.password = "alex@sky-unlimited.lu"
user.confirmed_at = Time.zone.now - 1.hour
user.confirmation_sent_at = Time.zone.now - 2.hours
user.save
pilot_pref = PilotPref.find_by(user_id: user.id)
pilot_pref.update(is_ultralight_pilot: true, is_private_pilot: false)
puts "Admin user alex created"
puts "Pilot pref alex created"

# Create an user
if Rails.env.development? || Rails.env.staging?
  user = User.new
  user.first_name = "Rachel"
  user.last_name = "Muller"
  user.username = "rachmu57"
  user.email = "rachel@sky-unlimited.lu"
  user.role = "admin"
  user.password = "rachel@sky-unlimited.lu"
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  pilot_pref = PilotPref.find_by(user_id: user.id)
  pilot_pref.update(is_ultralight_pilot: true, is_private_pilot: true)
  puts "User rachel created in dev"
  puts "Pilot pref rachel created"

  user = User.new
  user.first_name = "Margaux"
  user.last_name = "Arnould"
  user.username = "marnou01"
  user.email = "margaux@sky-unlimited.lu"
  user.role = "user"
  user.password = "margaux@sky-unlimited.lu"
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  pilot_pref = PilotPref.find_by(user_id: user.id)
  pilot_pref.update(airport: Airport.find_by(icao: "LFQA"), is_ultralight_pilot: false, is_private_pilot: true)
  puts "User margaux created in dev"
  puts "Pilot pref margaux created"
end

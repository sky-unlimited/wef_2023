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
Airport.destroy_all
Country.destroy_all
Blog.destroy_all

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

if Rails.env.development? || Rails.env.staging?
  # Create users
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

  # Create blogs
  lorem = 'Cras aliquam tincidunt accumsan. Pellentesque metus libero, bibendum quis mollis vitae, accumsan non ipsum. In id purus quis ipsum suscipit luctus. Etiam maximus magna sed leo dapibus tristique. Suspendisse potenti. Etiam a nisl purus. Etiam porttitor risus ac ligula consectetur, in porttitor ligula tincidunt. Praesent sodales lacus tincidunt, rhoncus justo sed, molestie ipsum. Sed finibus erat sed vulputate scelerisque.

Vivamus condimentum tempus tortor, sit amet ornare arcu maximus sit amet. Mauris sed ex nec augue varius fermentum. Sed maximus nisi ut ex tincidunt, quis tincidunt diam venenatis. Integer tristique hendrerit tellus ac egestas. Nulla facilisi. Nam non fringilla eros. Donec ultricies elit lacinia tincidunt scelerisque. Quisque non condimentum nisi. Donec interdum vehicula enim a ornare. Donec feugiat in eros at ultrices. Nam in leo non ante placerat scelerisque. Aliquam ut turpis volutpat, finibus odio vel, ullamcorper nisi.

Nam lacinia risus lorem, ut dignissim tellus sollicitudin eget. Nam eu condimentum metus. Nam in elit non tortor molestie placerat. Nullam maximus quam leo, sed condimentum velit aliquet nec. Donec iaculis est id venenatis suscipit. Nam quis nisl nunc. Duis id leo arcu. Cras vestibulum bibendum urna, id pharetra dui suscipit ac.'
  hash = { user: User.first, title: 'My first blog!',
           keywords: 'test, seed',
           content: lorem }
  blog = Blog.new(hash)
  blog.save
  puts "Blog#1 created!"
end

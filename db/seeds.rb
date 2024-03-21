require 'csv'

# ############################################
# CLEANING
# ############################################
puts '👉 Cleaning databases...'
AuditLog.destroy_all
PilotPref.destroy_all
Blog.destroy_all
User.destroy_all
Runway.destroy_all
FuelStation.destroy_all
OsmPoi.destroy_all
Event.destroy_all
Airport.destroy_all
Country.destroy_all

puts '-------------------------------'
puts 'All environments seeds'
puts '-------------------------------'

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
user.username = 'alexstan57'
user.email = 'alex@sky-unlimited.lu'
user.role = 'admin'
user.password = 'Default2024'
user.confirmed_at = Time.zone.now - 1.hour
user.confirmation_sent_at = Time.zone.now - 2.hours
user.save
pilot_pref = PilotPref.find_by(user_id: user.id)
pilot_pref.update(is_ultralight_pilot: true, is_private_pilot: false)
puts 'Admin user alex created'
puts 'Pilot pref alex created'

if Rails.env.development? || Rails.env.staging?
  # Create users
  puts '-------------------------------'
  puts 'development & staging seeds'
  puts '-------------------------------'
  user = User.new
  user.username = 'rachel'
  user.email = 'rachel@sky-unlimited.lu'
  user.role = 'admin'
  user.password = 'Default2024'
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  pilot_pref = PilotPref.find_by(user_id: user.id)
  pilot_pref.update(is_ultralight_pilot: true, is_private_pilot: true)
  puts 'rachel user created'
  puts 'rachel pilot prefs created'

  user = User.new
  user.username = 'chris_bali'
  user.email = 'christina.sugiono95@gmail.com'
  user.role = 'admin'
  user.password = 'Default2024'
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  pilot_pref = PilotPref.find_by(user_id: user.id)
  pilot_pref.update(airport: Airport.find_by(icao: "LFCL"), is_ultralight_pilot: true, is_private_pilot: true)
  puts "christina user created"
  puts "christina pilot prefs created"

  # Create blogs
  i = 0
  rand(5..15).times do
    i += 1
    # content
    lorem = ""
    rand(3..10).times do
      lorem += Faker::Lorem.paragraph(sentence_count: 40)
    end
    # post
    hash = { user: User.first, title: Faker::Lorem.sentence,
             keywords: 'test, seed',
             content: lorem }
    blog = Blog.new(hash)
    blog.published = true if i.odd?
    blog.save
    puts "Blog##{i}1 created!"
  end

  # Create subscribers
  hash = { email: 'alex@sky-unlimited.lu',
           accept_private_data_policy: true,
           honey_bot: '' }
  subscriber = Subscriber.new(hash)
  subscriber.save
  puts "Subscriber created for #{hash[:email]} !"

  # Create dummy events
  friedrichshafen_airport = Airport.find_by(icao: "EDNY")
  Event.create(title: "Aero Friedrichshafen_airport", kind: 0, start_date: DateTime.parse("2024-04-17.12:00:00"), end_date: DateTime.parse("2024-04-20.12:00:00"), image_link: "https://cdn.messe-friedrichshafen.de/assets/aero/logos/_AUTOx240_crop_center-center_none_ns/logo-aero-friedrichshafen.png?v=1706175611" , url: "https://www.aero-expo.com", airport: friedrichshafen_airport)
  10.times do |i|
    start_date = Date.today + rand(1..3).day
    end_date = start_date + rand(0..3).day
    airport = Airport.all.sample
    kind = Event.kinds.values.sample
    Event.create(title: "Event #{i + 1}", kind: kind, start_date: start_date, end_date: end_date, image_link: "https://source.unsplash.com/random/?#{airport.name}" , url: "https://google.com?q=#{airport.name}", airport: airport)
  end
end

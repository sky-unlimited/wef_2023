require 'csv'

if Rails.env.development? || Rails.env.staging?
  # ############################################
  # CLEANING
  # ############################################
  puts '👉 Cleaning databases...'
  AuditLog.destroy_all
  Preference.destroy_all
  VisitedAirport.destroy_all
  Pilot.destroy_all
  Blog.destroy_all
  Follower.destroy_all
  FuelStation.destroy_all
  User.destroy_all
  Runway.destroy_all
  FuelStation.destroy_all
  Event.destroy_all
  Airport.destroy_all
  Country.destroy_all
  Certificate.destroy_all

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
  user.pilot.update(bio: Faker::Lorem.paragraph(sentence_count: 3),
                    aircraft_type: 'Nynja 912 ULS')
  preference = Preference.find_by(pilot: user.pilot)
  preference.update(is_ultralight_pilot: true, is_private_pilot: false)
  puts 'Alex user - pilot - preferences created'
end

if Rails.env.development? || Rails.env.staging?
  # Create users
  puts '-------------------------------'
  puts 'development & staging seeds'
  puts '-------------------------------'
  user = User.new
  user.username = 'RachelFly'
  user.email = 'rachel@sky-unlimited.lu'
  user.role = 'admin'
  user.password = 'Default2024'
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  user.pilot.update(bio: Faker::Lorem.paragraph(sentence_count: 3),
                    aircraft_type: 'Alpi Pionneer 200')
  preference = Preference.find_by(pilot: user.pilot)
  preference.update(is_ultralight_pilot: true, is_private_pilot: true)
  puts 'Rachel user - pilot - preferences created'

  user = User.new
  user.username = 'chris_bali'
  user.email = 'christina.sugiono95@gmail.com'
  user.role = 'admin'
  user.password = 'Default2024'
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  user.pilot.update(airport: Airport.find_by(icao: 'LFCL'),
                    bio: Faker::Lorem.paragraph(sentence_count: 3),
                    aircraft_type: 'Cessna 172')
  preference = Preference.find_by(pilot: user.pilot)
  preference.update(is_ultralight_pilot: true, is_private_pilot: true)
  puts 'christina user - pilot - preferences created'

  # Create blogs
  i = 0
  rand(5..15).times do
    i += 1
    # content
    lorem = ''
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
  friedrichshafen_airport = Airport.find_by(icao: 'EDNY')
  start_date  = Date.today + rand(1..3).day
  end_date    = start_date + rand(0..2).day
  Event.create(title: 'Aero Friedrichshafen', kind: 0,
               start_date:, end_date:,
               image_link: 'https://cdn.messe-friedrichshafen.de/assets/aero/logos/_AUTOx240_crop_center-center_none_ns/logo-aero-friedrichshafen.png?v=1706175611',
               url: 'https://www.aero-expo.com',
               airport: friedrichshafen_airport)
  blois_airport = Airport.find_by(icao: 'LFOQ')
  start_date  = Date.today + rand(1..3).day
  end_date    = start_date + rand(0..2).day
  Event.create(title: "Mondial de l'ULM", kind: 0,
               start_date:, end_date:,
               image_link: 'https://mondialulm.fr/images/logo/logo-MULM-w800x252px.png',
               url: 'https://mondialulm.fr/',
               airport: blois_airport)
  la_ferte_airport = Airport.find_by(icao: 'LFFQ')
  start_date  = Date.today + rand(1..3).day
  end_date    = start_date + rand(0..2).day
  Event.create(title: 'Fête Aérienne', kind: 1,
               start_date:, end_date:,
               image_link: 'https://letempsdeshelices.fr/wp-content/uploads/2024/01/Affiche-le-temps-des-helices-2024-1280x1898.jpg',
               url: 'https://letempsdeshelices.fr/',
               airport: la_ferte_airport)
  muret_airport = Airport.find_by(icao: 'LFBR')
  start_date  = Date.today + rand(1..3).day
  end_date    = start_date + rand(0..2).day
  Event.create(title: 'Air Expo Muret', kind: 1,
               start_date:, end_date:,
               image_link: 'https://airshowdisplay.fr/medias/evenement/image/affiche/air-expo-muret-2024.jpg',
               url: 'https://airshowdisplay.fr',
               airport: muret_airport)

  # Create visited airports
  airports_alex   = Airport.where(actif: true).sample(20)
  airports_rachel = Airport.where(actif: true).sample(20)
  airports_chris  = Airport.where(actif: true).sample(20)
  i = 0
  20.times do
    # Pilot Alex
    VisitedAirport.create(
      pilot: Pilot.find_by(
        user: User.find_by(username: 'alexstan57')
      ),
      airport: airports_alex[i]
    )
    # Pilot Rachel
    VisitedAirport.create(
      pilot: Pilot.find_by(
        user: User.find_by(username: 'RachelFly')
      ),
      airport: airports_rachel[i]
    )
    # Pilot Chris
    VisitedAirport.create(
      pilot: Pilot.find_by(
        user: User.find_by(username: 'chris_bali')
      ),
      airport: airports_chris[i]
    )
    i += 1
  end
  puts 'Visited airports created for Alex'
  puts 'Visited airports created for Rachel'
  puts 'Visited airports created for Chris'

  # Create followers
  Follower.create(following: User.find_by(username: 'RachelFly'),
                  follower: User.find_by(username: 'alexstan57'))
  Follower.create(following: User.find_by(username: 'chris_bali'),
                  follower: User.find_by(username: 'alexstan57'))
  puts 'User alex is following rachel and Chris'
  Follower.create(following: User.find_by(username: 'alexstan57'),
                  follower: User.find_by(username: 'RachelFly'))
  Follower.create(following: User.find_by(username: 'chris_bali'),
                  follower: User.find_by(username: 'RachelFly'))
  puts 'User rachel is following Alex and Chris'
  Follower.create(following: User.find_by(username: 'RachelFly'),
                  follower: User.find_by(username: 'chris_bali'))
  Follower.create(following: User.find_by(username: 'alexstan57'),
                  follower: User.find_by(username: 'chris_bali'))
  puts 'User chris is following rachel and Alex'

  # Fuel stations
  FuelStation.create(airport: Airport.find_by(local_code: 'LF5755'),
                     provider: 'Other',
                     status: :active,
                     fuel_mogas: 'yes',
                     email: 'info@aeroplume.lu')
  AuditLog.create(user: User.find_by(username: 'alexstan57'),
                  target_id: FuelStation.last.id,
                  target_controller: 'fuel_stations',
                  action: 'created')
  puts 'Alex created a FuelStation at LF5755'

end

# Create Certificates
Certificate.create!(name: 'Student')
Certificate.create!(name: 'Ultra-light/Microlight')
Certificate.create!(name: 'Private')
Certificate.create!(name: 'Commercial')

User.all.each do |u|
  if u.preference.is_private_pilot
    PilotCertificate.create!(pilot: u.pilot,
                             certificate: Certificate.find_by(name: 'Private'))
  end
  next unless u.preference.is_ultralight_pilot

  PilotCertificate.create!(pilot: u.pilot,
                           certificate: Certificate.find_by(
                             name: 'Ultra-light/Microlight'
                           ))
end

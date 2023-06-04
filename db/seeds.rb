require 'csv'

# ############################################
# CLEANING
# ############################################
puts "Cleaning databases..."
User.destroy_all
Country.destroy_all

# ############################################
# USERS
# ############################################
# Deleting current users

# Create an admin user
user = User.new
user.first_name = "Alexandre"
user.last_name = "Stanescot"
user.email = "alex@aerostan.com"
user.role = "admin"
user.password = "alex@aerostan.com"
user.confirmed_at = Time.zone.now - 1.hour
user.confirmation_sent_at = Time.zone.now - 2.hours
user.save
puts "Admin user alex created"

# Create an user
if Rails.env.development?
  user = User.new
  user.first_name = "Rachel"
  user.last_name = "Muller"
  user.email = "rachel.fly@me.com"
  user.role = "user"
  user.password = "rachel.fly@me.com"
  user.confirmed_at = Time.zone.now - 1.hour
  user.confirmation_sent_at = Time.zone.now - 2.hours
  user.save
  puts "User rachel created in dev"
end

# ############################################
# COUNTRIES
# ############################################
filepath = "ourairports-data/countries.csv"
puts "Reading #{filepath}..."
counter_created = 0
counter_rejected = 0
CSV.foreach(filepath, headers: :first_row) do |row|
  country = Country.create(code: row['code'], name: row['name'], continent: row['continent'])
  country.persisted? ? counter_created += 1 : counter_rejected += 1
end
puts "#{counter_created} / #{counter_created + counter_rejected} countries created!"


puts "Seeds complete! 🌻"

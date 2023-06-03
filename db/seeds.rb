# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# ############################################
# CLEANING
# ############################################
puts "Cleaning databases..."
User.destroy_all

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

puts "Seeds complete! 🌻"

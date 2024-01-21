source "https://rubygems.org"

ruby '3.2.2'

# Version management
# https://bundler.io/guides/gemfile.html
# ~> : major release. Example: ~> 2.0.3 is identical to >= 2.0.3 and < 2.1. ~> 2.1 is identical to >= 2.1 and < 3.0.

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5.4'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails', '~> 1.2', '>= 1.2.3'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails', '~> 1.5'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails', '~> 1.3'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder', '~> 2.11', '>= 2.11.5'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

#A modern web server and application server for Ruby, Python and Node.js, optimized for performance, low memory usage and ease of use.
gem 'passenger', '~> 6.0', '>= 6.0.19'

# Project related additionnal gems
gem 'devise', '~> 4.9', '>= 4.9.2'
gem 'sass-rails', '~> 6.0'
gem 'ed25519', '~> 1.3'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
gem 'rack-cors', '~> 2.0', '>= 2.0.1'
gem 'rest-client', '~> 2.1'
gem 'normalize_country', '~> 0.3.2'
gem 'email_validator', '~> 2.2', '>= 2.2.4', require: 'email_validator/strict'

# Charts js
gem 'chartkick', '~> 5.0', '>= 5.0.5'
gem 'groupdate', '~> 6.4'

# Cache server
gem 'redis', '~> 5.0', '>= 5.0.8'
gem 'redis-rails', '~> 5.0', '>= 5.0.2'

# Background jobs
gem 'sidekiq', '~> 7.2'
gem 'sidekiq-failures', '~> 1.0', '>= 1.0.4'

# Geospatial queries
gem 'activerecord-postgis-adapter', '~> 9.0', '>= 8.0.2'
gem 'rgeo', '~> 3.0', '>= 3.0.1'
gem 'rgeo-geojson', '~> 2.1', '>= 2.1.1'
gem 'rgeo-proj4', '~> 4.0.0'
gem 'ffi-geos', '~> 2.4'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]

  # Use the Puma web server [https://github.com/puma/puma]
  gem 'puma', '~> 6.4'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  
  # Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH.
  gem 'capistrano-rake', require: false
  gem 'capistrano', '~> 3.17', '>= 3.17.3', require: false
  gem 'capistrano-rails', '~> 1.4'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.4'
  gem 'capistrano-bundler', '~> 2.1'
  gem 'capistrano-git-with-submodules', '~> 2.0', '>= 2.0.6'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara', '~> 3.39', '>= 3.39.2'
  gem 'selenium-webdriver', '~> 4.16'
  #gem 'webdrivers', '~>5.2'
end



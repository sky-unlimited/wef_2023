source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.5'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara', '~> 3.39', '>= 3.39.2'
  gem 'selenium-webdriver', '~> 4.10'
  gem 'webdrivers', '~> 5.2'
end
gem 'devise', '~> 4.9', '>= 4.9.2'
gem 'dotenv-rails', '~> 2.8', '>= 2.8.1'
gem 'sass-rails', '~> 6.0'
gem 'ed25519', '~> 1.3'
gem "bcrypt_pbkdf", ">= 1.0", "< 2.0"
gem 'rack-cors', '~> 2.0', '>= 2.0.1'
gem 'rest-client', '~> 2.1'
gem 'normalize_country', '~> 0.3.2'
gem 'postmark-rails', '~> 0.22.1'


# Geospatial queries
gem 'activerecord-postgis-adapter', '~> 8.0', '>= 8.0.2'
gem 'rgeo', '~> 3.0'
gem 'rgeo-geojson', '~> 2.1', '>= 2.1.1'
gem 'rgeo-proj4', '~> 4.0'
gem 'ffi-geos', '~> 2.4'

group :development do
  gem 'capistrano-rake', require: false
  gem 'capistrano', '~> 3.17', '>= 3.17.3'
  gem 'capistrano-rails', '~> 1.4'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.4'
  gem 'capistrano-git-with-submodules', '~> 2.0', '>= 2.0.6'
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Devise::Test::IntegrationHelpers
  #include Warden::Test::Helpers
  #Warden.test_mode!

  # Capybara::Screenshot.prune_strategy = { keep: 20 }
end

Capybara.save_path = Rails.root.join("tmp/capybara")

# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!
# ActionMailer setup
Rails.application.config.assets.paths << Rails.root.join("node_modules")
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.smtp_settings = {
:address              => ENV["MAIL_SMTP_SERVER"],
:port                 => ENV["MAIL_SMTP_PORT"],
:domain               => ENV["MAIL_DOMAIN"],
:user_name            => ENV["MAIL_USERNAME"],
:password             => ENV["MAIL_PASSWORD"],
:authentication       => :login,
:ssl                  => true,
:tls                  => true
}

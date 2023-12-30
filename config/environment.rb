# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# ActionMailer setup
#Rails.application.config.assets.paths << Rails.root.join("node_modules")
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.smtp_settings = {
  :address              => Rails.application.credentials.action_mailer.mail_smtp_server,
  :port                 => Rails.application.credentials.action_mailer.mail_smtp_port,
  :domain               => Rails.application.credentials.action_mailer.mail_domain,
  :user_name            => Rails.application.credentials.action_mailer.mail_login,
  :password             => Rails.application.credentials.action_mailer.mail_password,
  :authentication       => :login,
  :ssl                  => true,
  :tls                  => true
}

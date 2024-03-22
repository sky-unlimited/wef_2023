require 'csv'

namespace :maintenance do
  desc "Copies the registered users email to newsletter subscription list"
  task copy_users_email_to_subscribers: :environment do
    User.all.each do |user|
      if user.confirmed_at?
        puts "#{user.email} is confirmed"
        hash = { email: user.email, accept_private_data_policy: true,
                 honey_bot: "" }
        subscriber = Subscriber.new(hash)
        puts "#{user.email} added to subscribers" if subscriber.save
      end
    end
  end
end

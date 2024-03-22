# Job sending newsletter per email
class SendNewsletterJob < ApplicationJob
  queue_as :default

  def perform(blog)
    # Do something later
    Subscriber.all.each do |subscriber|
      BlogMailer.with(blog:,
                      subscriber:)
                .newsletter_email.deliver_later
    end

    # Once performed we mark newsletters as sent
    blog.sent_email = true
    blog.sent_email_date = Time.current
    blog.save
  end
end

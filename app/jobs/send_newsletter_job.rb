# Job sending newsletter per email
class SendNewsletterJob < ApplicationJob
  queue_as :default

  def perform(blog)
    # Do something later

    # Once performed we mark newsletters as sent
    blog.sent_email = true
    blog.sent_email_date = Date.current
    blog.save
  end
end

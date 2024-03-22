# Manages the sending of the newsletters
class BlogMailer < ApplicationMailer
  def newsletter_email
    # Attach image
    attachments.inline['full-logo-early-dark.png'] =
      File.read("#{Rails.root}/app/assets/images/full-logo-early-dark.png")

    @subscriber = params[:subscriber]
    @blog = params[:blog]
    @link_unsubscribe = unsubscribe_url(
      unsubscribe_hash: @subscriber.unsubscribe_hash, locale: :en
    )
    @link_root = root_url
    subject = "Weekend-Fly Newsletter | #{l Time.current, format: :date_short}"
    mail(to: @subscriber.email, subject:)
  end
end

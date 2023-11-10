class SubscribersMailer < ApplicationMailer

  def subscribed
    # Attach image
    attachments.inline["full-logo-early-dark.png"] = File.read("#{Rails.root}/app/assets/images/full-logo-early-dark.png")

    @subscriber = params[:subscriber]
    @link_unsubscribe = params[:link]
    @link_root = root_url
    mail(to: @subscriber.email, subject: default_i18n_subject)
  end

end

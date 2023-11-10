class SubscribersMailer < ApplicationMailer

  def subscribed
    @subscriber = params[:subscriber]
    @link_unsubscribe = params[:link]
    @link_root = root_url
    mail(to: @subscriber.email, subject: default_i18n_subject)
  end

end

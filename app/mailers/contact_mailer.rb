class ContactMailer < ApplicationMailer
  def new_submission
    # Attach image
    attachments.inline["full-logo-early-dark.png"] = File.read("#{Rails.root}/app/assets/images/full-logo-early-dark.png")

    @contact = params[:contact]
    recipient = params[:recipient]
    mail(to: recipient, subject: default_i18n_subject(category: @contact.category))
  end
end

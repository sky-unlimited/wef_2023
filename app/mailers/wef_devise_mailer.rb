class WefDeviseMailer < Devise::Mailer
  default template_path: 'devise/mailer'
  layout 'default_wef'

  before_action :attach_logo_image

  private

  def attach_logo_image
    attachments.inline['full-logo-early-dark.png'] = File.read("#{Rails.root}/app/assets/images/full-logo-early-dark.png")
  end

end

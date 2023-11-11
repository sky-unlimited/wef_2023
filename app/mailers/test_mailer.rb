class TestMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.test_mailer.hello.subject
  #
  # To test email from rails console: TestMailer.hello.deliver_now
  default from: 'team@weekend-fly.com'

  # layout default wef
  #layout 'default_wef'

  def hello
    # Attach image
    attachments.inline["full-logo-early-dark.png"] = File.read("#{Rails.root}/app/assets/images/full-logo-early-dark.png")

    # Send email
    mail(
      subject: 'Test from Weekend Fly!',
      to: 'alex@sky-unlimited.lu',
      #html_body: '<strong>Hello</strong> dear Postmark user.',
      track_opens: 'true',
      message_stream: 'outbound') do |format|
        format.html { render layout: 'default_wef' }
        format.text
      end
  end
end

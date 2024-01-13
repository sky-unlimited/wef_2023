class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, :except => :index
  after_action :audit_log, only: [ :create ]

  def index
    if current_user.role == "admin"
      @contacts = Contact.all
      respond_to do |format|
        format.html
        format.csv { send_data @contacts.to_csv, filename: "contacts-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
      end
    end
  end

  def new
    @contact = Contact.new
    @is_session = current_user.nil? ? false : true
    unless current_user.nil?
      @contact.email    = current_user.email
      @contact.username = current_user.username
    end
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.request = request  # Pass the request object to the model in order to retrieve ip_address

    if @contact.save
      ContactMailer.with(contact: @contact, recipient: WEF_CONFIG["contact_form_recipient"]).new_submission.deliver_later
      flash.notice = t('contact.notice.form_sent')
      redirect_to root_path
    else
      logger.warn "#{Time.now} - [SECURITY] - Contact failure: #{request.remote_ip} | #{@contact.email}"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:username, :last_name, :first_name, :company, :email, :phone, :category, :description, :accept_privacy_policy, :honey_bot) 
  end
end

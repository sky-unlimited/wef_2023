class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, :except => :index

  def index
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
    @contact.request = request  # Pass the request object to the model

    if @contact.save
      ContactMailer.with(contact: @contact, recipient: WEF_CONFIG["contact_form_recipient"]).new_submission.deliver_later
      flash.notice = t('contact.notice.form_sent')
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:username, :last_name, :first_name, :company, :email, :phone, :category, :description, :accept_privacy_policy, :honey_bot) 
  end
end
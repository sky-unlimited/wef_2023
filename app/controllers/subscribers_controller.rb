class SubscribersController < ApplicationController
  skip_before_action :authenticate_user!, :except => :index

  def create
    @subscriber = Subscriber.new(subscriber_input_params)
    @subscriber.request = request  # Pass the request object to the model
    if @subscriber.save
      cookies[:saved_subscriber] = true
      flash.notice = t("subscribers.flash.register_ok")
      SubscribersMailer.with(subscriber: @subscriber, link: unsubscribe_url(@subscriber.unsubscribe_hash)).subscribed.deliver_later
      redirect_to root_path
    else
      flash.alert = "#{t("subscribers.flash.register_nok")}: #{@subscriber.errors.first.full_message}"
      logger.warn "#{Time.now} - [SECURITY] - Subscribers failure: #{request.remote_ip} | #{@subscriber.email}"
      redirect_to root_path
    end
  end

  def unsubscribe
    record = Subscriber.find_by(unsubscribe_hash: params[:unsubscribe_hash])
    @email = record.email
    record.destroy
    cookies.delete :saved_subscriber
  end

  def index
    if current_user.role == "admin"
      @subscribers = Subscriber.all
      respond_to do |format|
        format.html
        format.csv { send_data @subscribers.to_csv, filename: "subscribers-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
      end
    end
  end

  private

  def subscriber_input_params
    params.require(:subscriber).permit(:email, :accept_private_data_policy, :unsubscribe_hash, :honey_bot)
  end
end

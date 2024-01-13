class ApplicationController < ActionController::Base
    around_action :switch_locale
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :authenticate_user!
  
    protected
  
    def configure_permitted_parameters
      attributes = [ :username, :picture ]
      devise_parameter_sanitizer.permit(:account_update, keys: attributes)
      devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    end

    def switch_locale(&action)
      locale = params[:locale] || I18n.default_locale
      I18n.with_locale(locale, &action)
    end

    def default_url_options
      #{ locale: I18n.locale }
      { :locale => ((I18n.locale == I18n.default_locale) ? nil : I18n.locale) }
    end

    # Method below devise compatible
    def after_sign_in_path_for(resource)
      if params[:redirect_to].present?
        store_location_for(resource, params[:redirect_to])
      elsif request.referer == new_user_session_url
        super
      else
        store_location_for(resource) || request.referer || root_path
      end
    end

    def audit_log
      action = params[:action] = "create" ? 0 : 1 # we can't keep AudotLog method names as :create or :update
      @audit_log = AuditLog.new(
        action: action,
        target_type: params[:controller].to_sym,
        user_id: current_user.id,
        target_id: params[:id]
      ) 
      @audit_log.save
    end
end

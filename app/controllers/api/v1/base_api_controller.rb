class Api::V1::BaseApiController < ActionController::API
    before_action :ensure_authentication_token, only: [:update, :create]
    before_action :authenticate_user_from_token!
    respond_to :json, :multipart_form

    # generate authentication_token for current_user, replace simple_token_authentication
    def ensure_authentication_token
        if current_user.nil?
            return
        else
            user_auth = current_user.authentication_token
            if user_auth.blank?
                renew_authentication_token(current_user)
            end
        end
    end

    def renew_authentication_token(resource)
        loop do
            token = Devise.friendly_token
            if not User.where(authentication_token: token).first
                resource.authentication_token = token
                resource.save
                break
            end
        end
    end

    def authenticate_user_from_token!
        user_email = params[:user_email].presence
        user = user_email && User.find_by_email(user_email)
        if user && Devise.secure_compare(user.authentication_token, params[:user_token])
            sign_in user, store: false
            renew_authentication_token(user)
            # puts(user.authentication_token)
        end
    end
end
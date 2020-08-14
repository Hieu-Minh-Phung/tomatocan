class Api::V1::RegistrationsController < Api::V1::BaseApiController
  skip_before_action :ensure_authentication_token
  
  def create  
    user = User.new(user_params)
    # manually generate authentication token, replace simple_authentication_token token generation before save
    renew_authentication_token(user) 
    if user.save
      render :json=> {:success=>true, :name=>user.name, :token=>user.authentication_token, :permalink=>user.permalink, :email=>user.email, :id=>user.id}, :status=>201
      return
    else
      warden.custom_failure!
      render :json=> {:success=>false, :errors=>user.errors}, :status=>422
    end
  end

  def user_params
    params.require(:user).permit(:email, :name, :permalink, :password)
  end

end
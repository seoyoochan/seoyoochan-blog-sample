class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  skip_before_filter :authenticate_user!


  def provider_name?(auth)
    name = case auth.provider
             when "facebook" then "Facebook"
             when "twitter" then "Twitter"
             when "google_oauth2" then "Google+"
             when "linkedin" then "Linkedin"
             when "github" then "Github"
           end
  end

  def set_auth_session(auth=nil,provider=nil,uid=nil)
    if auth
      session[:current_user_provider] = "#{auth.provider}"
      session[:current_user_provider_uid] = auth.uid
    else
      session[:current_user_provider] = "#{provider}"
      session[:current_user_provider_uid] = uid
    end
  end

  def all
    auth = request.env["omniauth.auth"]
    sns_provider = provider_name?(auth)

    identity = User.from_omniauth(auth, current_user) # Start Callback

    if identity.blank? # Validate the returned data

      identity = User.from_omniauth(auth, current_user) # Fetch the data

      if identity
        flash[:warning] = "Please changer your twitter email address" if identity.email.include? ("@twitter.com")
        identity = User.from_omniauth(auth, current_user)
        sign_in_and_redirect identity
      end

    else
      identity = User.from_omniauth(auth, current_user) # Fetch the data
      set_auth_session(auth)
      if identity.present?
        flash[:warning] = "Please changer your twitter email address" if identity.email.include? ("@twitter.com")
        sign_in_and_redirect identity
      end
    end
  end

  def failure
    #handle you logic here..
    #and delegate to super.
    super
  end


  alias_method :facebook, :all
  alias_method :twitter, :all
  alias_method :linkedin, :all
  alias_method :github, :all
  alias_method :passthru, :all
  alias_method :google_oauth2, :all

end
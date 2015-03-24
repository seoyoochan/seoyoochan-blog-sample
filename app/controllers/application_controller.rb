class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # with: :null_session # an empty session (until the next valid request)
  # with: :reset_session # a new session (destroying the old one)
  protect_from_forgery with: :exception

  # add_flash_types :error, :success, :warning, :info # Custom flash types
  before_filter :configure_devise_params, if: :devise_controller?
  before_filter :setting_auto_user_locale, if: :human?
  before_filter :set_time_zone
  before_filter :current_or_guest_user
  before_filter :search_object

  def index
    render "layouts/application"
  end

  def human?
    robot = (request.env["HTTP_USER_AGENT"].match(/\(.*https?:\/\/.*\)/)) || (request.env["HTTP_USER_AGENT"].match(/Twitterbot\/1.0/))
    if robot
      false
    else
      true
    end
  end

  def search_object
    @search_object = Search.new(search_params)
  end

  def go_back
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end


  private
  def user_layout
    if current_user.admin?
      "admin"
    else
      "application"
    end
  end

  def configure_devise_params
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password, :first_name, :last_name, :username, :birthday, :locale, :gender, :website, :avatar, :avatar_cache, :job, :description, :location, :phone, :facebook_account_url, :twitter_account_url, :googleplus_account_url, :github_account_url, :linkedin_account_url, :address, :remove_avatar, :avatar_cache, :name) }
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :first_name, :last_name, :username, :agreement, :birthday, :gender, :avatar, :avatar_cache, :current_sign_in_ip, :last_sign_in_ip) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:email, :password, :remember_me) }
  end

  def set_time_zone
  	default_time_zone = Time.now
  	client_time_zone = cookies["jstz_time_zone"]
  	Time.zone = client_time_zone if client_time_zone.present?
  end

  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        # logging_in
        find_guest_user.destroy
        session[:guest_user_id] = nil
      end
    else
      guest_user
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    # Cache the value the first time it's gotten.
    guest_user = find_guest_user
    @cached_guest_user = guest_user ? guest_user : create_guest_user.id
    logger.debug "손님계정: #{@cached_guest_user.inspect}"

  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
    session[:guest_user_id] = nil
    guest_user
  end

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in
    # For example:
    # guest_comments = guest_user.comments.all
    # guest_comments.each do |comment|
    # comment.user_id = current_user.id
    # comment.save!
    # end
  end

  def find_guest_user
    User.find(session[:guest_user_id]) if session[:guest_user_id]
  end

  def create_guest_user
    u = User.new(username: "guest#{Time.now.to_i}#{rand(1000)}", email: "guest_#{Time.now.to_i}#{rand(9000)}@example.com", current_sign_in_ip: "#{request.remote_ip}", last_sign_in_ip: "#{request.remote_ip}")
    u.skip_confirmation!
    u.save!(:validate => false)
    session[:guest_user_id] = u.id
    u
  end

  def search_params
    params.require(:search).permit(:keywords, :category_id, :user_id) if params[:search]
  end

end

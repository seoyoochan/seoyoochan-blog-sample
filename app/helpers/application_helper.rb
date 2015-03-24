module ApplicationHelper
	def my_locales
		@locales = {"en" => "English (US)" , "ko" => "한국어",}
	end

	def current_locale
		my_locales[I18n.locale.to_s]
	end

	def browser_locale
		@browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym
	end

	def setting_locale
    browser_locale
    if @locales.include?(@browser_locale)
       I18n.locale = @browser_locale.to_s
    else
       I18n.locale = :en
    end
  end

  def setting_auto_user_locale
    my_locales
    setting_locale unless signed_in?
    current_user.locale = I18n.locale.to_s if signed_in? && current_user.locale.nil?
    I18n.locale = current_user.locale.to_sym if signed_in? && current_user.locale.present?
  end

  def current_path
    if (params["action"] == "home") && (params["controller"] == "pages")
    "#{ link_to t('current_path.home'), root_path, class: 'waves-effect waves-button' }".html_safe
    elsif ( (params["action"] == "new") || (params["action"] == "create") ) && (params["controller"] == "devise/sessions")
    "#{ link_to t('current_path.signin'), user_session_path, class: 'waves-effect waves-button' }".html_safe
    elsif ( (params["action"] == "new") || (params["action"] == "create") ) && (params["controller"] == "users/registrations")
    "#{ link_to t('current_path.signup'), new_user_registration_path, class: 'waves-effect waves-button' }".html_safe
    elsif ( (params["action"] == "edit") || (params["action"] == "update") ) && (params["controller"] == "users/registrations")
      "#{ link_to t('current_path.settings'), settings_path, class: 'waves-effect waves-button' }".html_safe
    elsif ((params["action"] == "blog") && (params["controller"] == "pages")) || params["controller"] == "posts"
      "#{ link_to t('current_path.blog'), blog_path, class: 'waves-effect waves-button' }".html_safe
    elsif params["controller"] == "categories"
      "#{ link_to t('current_path.category'), categories_path, class: 'waves-effect waves-button' }".html_safe
    elsif params["controller"] == "searches"
      "#{ link_to t('current_path.searches'), new_search_path, class: 'waves-effect waves-button' }".html_safe
    elsif params["controller"] == "policies"
      "#{ link_to t('current_path.policies'), new_search_path, class: 'waves-effect waves-button' }".html_safe
    end
  end

  def header_line
    if (params["controller"] == "devise/sessions") ||
       (params["controller"] == "users/registrations") ||
       (params["controller"] == "devise/passwords") ||
       (params["controller"] == "devise/mailer") ||
       (params["controller"] == "devise/confirmations")

      ".waves-ripple {background-color: #F47D49 !important;}".html_safe
    end
  end

  # make the devise resource mapping available and understandable in places other than the devise views.
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def name_mapper(current_user=nil)
    if current_user.nil?
      return nil
    end

    # logger.debug "eastern_format// #{eastern_format}"
    # logger.debug "western_format// #{western_format}"

    # 1. user's name exists?
    if current_user.name.present?
      return current_user.name
    else
    # 2. then his locale exists?
      eastern_format = "#{current_user.last_name}#{current_user.first_name}" if current_user.locale == "ko"
      western_format = "#{current_user.first_name} #{current_user.last_name}" if current_user.locale == "en"
      return eastern_format if eastern_format.present?
      return western_format if western_format.present?
    end
  end

  def custom_flash(type)
    case type
      when "notice" then "info"
      when "info" then "info"
      when "success" then "success"
      when "error" then "alert"
      when "warning" then "warning"
      else type.to_s
    end
  end

  def summarize(body, length)
    simple_format(truncate(body.gsub(/<\/?.*?>/,  ""), :length => length)).gsub(/<\/?.*?>/,  "")
  end

end

class User < ActiveRecord::Base
  rolify

  acts_as_tagger
  acts_as_voter

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :confirmable, :lockable,
         :omniauthable, :omniauth_providers => [:facebook, :twitter, :google_oauth2, :github, :linkedin]

  has_many :posts, dependent: :destroy
  has_many :views, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :categories, dependent: :nullify
  has_many :searches, dependent: :destroy

  mount_uploader :avatar, AvatarUploader

  validates :email, presence: true
  validates :email, uniqueness: { :case_sensitive => false, :allow_blank => false }, format: { :with => Devise.email_regexp }, :if => :email_changed?
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, presence: { length: { within: Devise.password_length } }, :on => :create
  validates :password, presence: true, :on => :update, :unless => lambda { |user| user.password.blank? }

  validates_integrity_of  :avatar
  validates_processing_of :avatar


  # Skip 'current password' requirement
  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params)
  end

  def self.fb_locales_available(fb_user_locale)
    locales = {"en_US" => "en", "ko_KR" => "ko"}
    if locales.include?(fb_user_locale)
      locales[fb_user_locale].to_s
    else
      "en"
    end
  end

  def self.tw_locales_available(tw_user_locale)
    if I18n.available_locales.include?(tw_user_locale)
      tw_user_locale
    else
      "en"
    end
  end

  def self.linkedin_locales_available(linkedin_user_locale)
    locales = {"us" => "en", "kr" => "ko"}
    if locales.include?(linkedin_user_locale)
      locales[linkedin_user_locale].to_s
    else
      "en"
    end
  end


  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end


  def self.from_omniauth(auth, current_user = nil)

    logger.debug " @@@@@@@@@@@: #{auth.inspect} \n"

    # 해당 SNS의 계정이 존재하는지 Authorization 데이터베이스에서 조회
    identity = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s, :token => auth.credentials.token).first_or_initialize

    # 해당 SNS의 계정으로 인증한적이 있는지
    if identity.user.blank?

      user = current_user.nil? ? User.where('email = ?', auth.info.email).first : current_user

      if user.blank?
        # 최초로그인엔 user가 없으므로 회원가입
        signup_by_facebook(auth, identity) if auth.provider == "facebook"
        signup_by_google_oauth2(auth, identity) if auth.provider == "google_oauth2"
        signup_by_github(auth, identity) if auth.provider == "github"
        signup_by_linkedin(auth, identity) if auth.provider == "linkedin"
        signup_by_twitter(auth, identity) if auth.provider == "twitter"
      else
        # 이미 로그인 사용자가 다른 SNS 연결할때 정보 업데이트
        sns_crawling(user, auth, identity)
      end
    else
      sns_crawling(identity.user, auth, identity)
      identity.user # 이미 인증한 경우엔 해당 identity에 연결된 user를 리턴
    end

  end


  def self.signup_by_facebook(auth, identity)
    user = User.new
    user.password = Devise.friendly_token[0,20]
    user.email = auth.info.email
    user.agreement = 1
    user.confirmed_at = Time.now
    user.name = auth.info.name if auth.info.name
    user.username = auth.info.name if auth.info.name
    user.first_name = auth.info.first_name if auth.info.first_name
    user.last_name = auth.info.last_name if auth.info.last_name
    user.locale = fb_locales_available(auth.extra.raw_info.locale) if auth.extra.raw_info.locale
    user.gender = auth.extra.raw_info.gender if auth.extra.raw_info.gender
    user.facebook_account_url = auth.info.urls.Facebook
    user.sns_avatar = auth.info.image if auth.info.image
    user.skip_confirmation_notification!
    user.skip_confirmation!
    user.save(validate: false)
    identity.username = user.name
    identity.user_id = user.id
    identity.save(validate: false)
    user
  end

  def self.signup_by_google_oauth2(auth, identity)
    user = User.new
    user.password = Devise.friendly_token[0,20]
    user.agreement = 1
    user.confirmed_at = Time.now
    user.name = auth.info.name if auth.info.name
    user.email = auth.info.email if auth.info.email
    user.first_name = auth.info.first_name if auth.info.first_name
    user.last_name = auth.info.last_name if auth.info.last_name
    user.sns_avatar = auth.info.image if auth.info.image
    user.googleplus_account_url = auth.extra.raw_info.profile
    user.gender = auth.extra.raw_info.gender if auth.extra.raw_info.gender
    user.birthday = auth.extra.raw_info.birthday if auth.extra.raw_info.birthday
    user.locale = auth.extra.raw_info.locale if auth.extra.raw_info.locale
    user.skip_confirmation_notification!
    user.skip_confirmation!
    user.save(validate: false)
    identity.username = auth.info.name
    identity.user_id = user.id
    identity.save
    user
  end

  def self.signup_by_github(auth, identity)

  end

  def self.signup_by_linkedin(auth, identity)
    user = User.new
    user.password = Devise.friendly_token[0,20]
    user.agreement = 1
    user.confirmed_at = Time.now
    user.email = auth.info.email if auth.info.email
    user.name = auth.info.name if auth.info.name
    user.first_name = auth.info.first_name if auth.info.first_name
    user.last_name = auth.info.last_name if auth.info.last_name
    user.username = auth.info.nickname if auth.info.nickname
    user.address = auth.info.location if auth.info.location
    user.sns_avatar = auth.info.image if auth.info.image
    user.description = auth.info.description if auth.info.description
    user.job = auth.info.industry if auth.info.industry
    user.phone = auth.info.phone if auth.info.phone
    user.linkedin_account_url = auth.info.urls.public_profile
    user.locale = linkedin_locales_available(auth.extra.raw_info.location.country.code) if auth.extra.raw_info.location.country.code
    user.skip_confirmation_notification!
    user.skip_confirmation!
    user.save(validate: false)
    identity.username = auth.info.name
    identity.user_id = user.id
    identity.save
    user
  end

  def self.signup_by_twitter(auth, identity)
    user = User.new
    user.password = Devise.friendly_token[0,20]
    user.agreement = 1
    user.name = auth.info.name if auth.info.name
    user.username = auth.info.nickname if auth.info.nickname
    user.address = auth.info.location if auth.info.location
    user.sns_avatar = auth.info.image if auth.info.image
    user.description = auth.info.description if auth.info.description
    user.website = auth.info.urls.Website if auth.info.urls.Website
    user.twitter_account_url = auth.info.urls.Twitter
    user.locale = tw_locales_available(auth.extra.lang) if auth.extra.lang
    # user.email = "#{auth.uid}@#{auth.provider}.com" if user.email.blank?
    user.skip_confirmation!
    user.save(validate: false)
    identity.username = auth.info.nickname
    identity.user_id = user.id
    identity.save
    user
  end


  def self.sns_crawling(user, auth, identity)
    if auth.provider == "facebook"
      user.name = auth.info.name if auth.info.name
      user.email = auth.info.email if auth.info.email
      user.username = auth.info.nickname if auth.info.nickname
      user.first_name = auth.info.first_name if auth.info.first_name
      user.last_name = auth.info.last_name if auth.info.last_name
      user.locale = fb_locales_available(auth.extra.raw_info.locale) if auth.extra.raw_info.locale
      user.gender = auth.extra.raw_info.gender if auth.extra.raw_info.gender
      user.address = auth.info.location if auth.info.location
      user.facebook_account_url = auth.info.urls.Facebook if auth.info.urls.Facebook
      user.sns_avatar = auth.info.image if auth.info.image
      identity.username = user.username
      identity.user_id = user.id
      identity.save
      user.skip_confirmation_notification!
      user.skip_confirmation!
      user.save!(validate: false)
    end

    if auth.provider == "twitter"
      user.name = auth.info.name if auth.info.name
      user.username = auth.info.nickname if auth.info.nickname
      user.address = auth.info.location if auth.info.location
      user.sns_avatar = auth.info.image if auth.info.image
      user.description = auth.info.description if auth.info.description
      user.website = auth.info.urls.Website if auth.info.urls.Website
      user.twitter_account_url = auth.info.urls.Twitter if auth.info.urls.Twitter
      user.locale = tw_locales_available(auth.extra.lang) if auth.extra.lang
      identity.username = user.username
      identity.user_id = user.id
      identity.save
      user.skip_confirmation_notification!
      user.skip_confirmation!
      user.save(validate: false)
    end

    if auth.provider == "google_oauth2"
      user.name = auth.info.name if auth.info.name
      user.email = auth.info.email if auth.info.email
      user.first_name = auth.info.first_name if auth.info.first_name
      user.last_name = auth.info.last_name if auth.info.last_name
      user.sns_avatar = auth.info.image if auth.info.image
      user.googleplus_account_url = auth.extra.raw_info.profile if auth.extra.raw_info.profile
      user.gender = auth.extra.raw_info.gender if auth.extra.raw_info.gender
      user.birthday = auth.extra.raw_info.birthday if user.birthday
      user.locale = auth.extra.raw_info.locale if auth.extra.raw_info.locale
      identity.username = user.name
      identity.user_id = user.id
      identity.save
      user.skip_confirmation_notification!
      user.skip_confirmation!
      user.save(validate: false)
    end

    if auth.provider == "github"

    end

    if auth.provider == "linkedin"
      user.email = auth.info.email if auth.info.email
      user.name = auth.info.name if auth.info.name
      user.first_name = auth.info.first_name if auth.info.first_name
      user.last_name = auth.info.last_name if auth.info.last_name
      user.username = auth.info.nickname if auth.info.nickname
      user.address = auth.info.location if auth.info.location
      user.sns_avatar = auth.info.image if auth.info.image
      user.description = auth.info.description if auth.info.description
      user.linkedin_account_url = auth.info.urls.public_profile if auth.info.urls.public_profile
      user.locale = linkedin_locales_available(auth.extra.raw_info.location.country.code) if auth.extra.raw_info.location.country.code
      identity.username = user.username
      identity.user_id = user.id
      identity.save
      user.skip_confirmation_notification!
      user.skip_confirmation!
      user.save(validate: false)
    end
  end

  def self.add_email_identity(provider, uid, email)
    identity = Authorization.where(:provider => provider, :uid => uid.to_s).first
    identity.user.email = email
    identity.user.save(validate: false)
    identity.user
  end

  private
  def set_default_role
  	add_role :basic
  end

end


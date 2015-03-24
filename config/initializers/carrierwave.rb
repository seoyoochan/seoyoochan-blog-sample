CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',                        # required
      :aws_access_key_id      => ENV['SEOYOOCHAN_AWS_KEY_ID'],                        # required
      :aws_secret_access_key  => ENV['SEOYOOCHAN_AWS_SECRET_KEY']                        # required
      # :region                 => 'Tokyo',                  # optional, defaults to 'us-east-1'
      # :host                   => 'www.seoyoochan.com',             # optional, defaults to nil
      # :endpoint               => 'https://seoyoochan.s3-website-ap-northeast-1.amazonaws.com' # optional, defaults to nil
  }
  config.fog_directory  = ENV['SEOYOOCHAN_AWS_BUCKET_NAME']                     # required
  # config.fog_public     = false                                   # optional, defaults to true
  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
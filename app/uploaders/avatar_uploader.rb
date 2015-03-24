# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  # include CarrierWaveDirect::Uploader

  include CarrierWave::MiniMagick

  # include CarrierWave::MimeTypes
  # process :set_content_type

  if Rails.env.development? || Rails.env.test?
    storage :file
    # This store_dir is only used when Rails run in development or test
    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  else
    storage :fog
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))

    # "/images/fallback/" + [version_name, "default.png"].compact.join('_')
    'default_avatar.png' #rails will look at 'app/assets/images/default_avatar.png'
  end


  # Create different versions of your uploaded files:
  version :large_avatar do
    # returns a 150x150 image
    process :resize_to_fill => [150, 150]
  end

  version :medium_avatar do
    # returns a 80x80 image
    process :resize_to_fill => [80, 80]
  end

  version :small_avatar do
    # returns a 35x35 image
    process :resize_to_fill => [42, 42]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end

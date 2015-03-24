# encoding: utf-8
class RedactorRailsPictureUploader < CarrierWave::Uploader::Base
  include RedactorRails::Backend::CarrierWave

  # Include RMagick or ImageScience support:
  include CarrierWave::MiniMagick
  # include CarrierWave::ImageScience


  if Rails.env.development? || Rails.env.test?
    storage :file
    def store_dir
      "system/redactor_assets/pictures/#{model.id}"
    end
  else
    storage :fog
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  process :read_dimensions

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fill => [118, 100]
  end

  version :content do
    process :resize_to_limit => [470, 315]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    RedactorRails.image_file_types
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end

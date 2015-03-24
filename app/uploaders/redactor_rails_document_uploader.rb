# encoding: utf-8
class RedactorRailsDocumentUploader < CarrierWave::Uploader::Base
  include RedactorRails::Backend::CarrierWave

  include CarrierWave::MiniMagick

  if Rails.env.development? || Rails.env.test?
    storage :file
    def store_dir
      "system/redactor_assets/documents/#{model.id}"
    end
  else
    storage :fog
  end

  # def extension_white_list
  #   RedactorRails.document_file_types
  # end
end

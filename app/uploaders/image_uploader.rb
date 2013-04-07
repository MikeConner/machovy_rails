# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
   include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Put this in the intializer so we can test
  # Choose what kind of storage to use for this uploader:
  #storage :file
#   storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :product_front_page do
    process :resize_to_fill => [470, 470]
  end

  version :product_detail do
    process :resize_to_fill => [400, 200]
  end
  
  # deal or affiliate (listing)  
  version :product_thumb do
    process :resize_to_fill => [60, 60]
  end
  
  # Image associated with a blog post (front page, on a phone)
  version :blog_mobile_photo do
    process :resize_to_fill => [282, 186]
  end
    
  # Image associated with a blog post on front page (non-mobile)
  version :blog_frontpage_photo do
    process :resize_to_fill => [235, 300]
  end
    
  # Image associated with a blog post on front page (non-mobile)
  version :blog_content_photo do
    process :resize_to_fill => [810, 300]
  end
    
  # Image associated with a blog post on front page (non-mobile)
  version :blog_contributor_photo do
    process :resize_to_fill => [310, 150]
  end
    
  # Curator photos
  version :contributor_photo do
    process :resize_to_fill => [100, 100]
  end
   
  #Cropping
  version :pre_crop do
    process :resize_to_limit => [600,10000]
  end
  version :wide_front_page do
    process :crop_wide
    process :resize_to_fill => [475, 215]
  end
  version :narrow_front_page do
    process :crop_narrow
    process :resize_to_fill => [275, 215]
  end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end


  # Crop processor

 
  def crop_wide
    if model.BDcrop_x.present?
      resize_to_limit(600,10000)
      manipulate! do |img|
        x = model.BDcrop_x.to_i
        y = model.BDcrop_y.to_i
        w = model.BDcrop_w.to_i
        h = model.BDcrop_h.to_i
        img.crop!(x, y, h, w)
      end
    end
  end
 
  def crop_narrow
    if model.LDcrop_x.present?
      resize_to_limit(600,10000)
      manipulate! do |img|
        x = model.LDcrop_x.to_i
        y = model.LDcrop_y.to_i
        w = model.LDcrop_w.to_i
        h = model.LDcrop_h.to_i
        img.crop!(x, y, h, w)
      end
    end
  end
 


end

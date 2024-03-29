namespace :db do
  desc "Verify images are present"
  task :image_check => :environment do
    # Grab the last argument (first is db:image_check)
    arg = ARGV.last
    # If you give rake two arguments; it will try to run two tasks; create a dummy task with the name of the argument to avoid an error
    task arg.to_sym do ; end
    
    # Set the boolean flag, being tolerant of case and details; Recreate, recreate, recreate_Images will all work
    recreate_images = 'recreate' == arg.downcase[0, 8]
    if recreate_images
      puts "Recreating Images"
    end 
    
    puts "Checking Blog Posts..."
    BlogPost.all.each do |post|
      if post.associated_image.file.nil? or !post.associated_image.file.exists?
        puts "Blog Post #{post.id} (#{post.title}) missing associated image #{post.associated_image_url}"     
      elsif recreate_images
        post.associated_image.recreate_versions!   
      end
    end
    
    puts "Checking Curators..."
    Curator.all.each do |curator|
      if curator.picture.file.nil? or !curator.picture.file.exists?
        puts "Curator #{!curator.id} (#{!curator.name}) missing picture #{!curator.picture_url}"        
      elsif recreate_images
        curator.picture.recreate_versions!   
      end
    end
    
    puts "Checking Promotions..."
    Promotion.all.each do |promotion|
      if promotion.teaser_image.file.nil? or !promotion.teaser_image.file.exists?
        puts "Promotion #{promotion.id} (#{promotion.title}) missing teaser image #{promotion.teaser_image_url}"
      elsif recreate_images
        promotion.teaser_image.recreate_versions!
      end
      
      if promotion.main_image.file.nil? or !promotion.main_image.file.exists?
        puts "Promotion #{promotion.id} (#{promotion.title}) missing main image #{promotion.main_image_url}"
      elsif recreate_images
        promotion.main_image.recreate_versions!
      end

      promotion.promotion_images.each do |slideshow|
        if slideshow.slideshow_image.nil? or !slideshow.slideshow_image.file.exists?
          puts "Promotion #{promotion.id} (#{promotion.title}) missing slideshow image #{slideshow.slideshow_image_url}"          
        elsif recreate_images
          slideshow.slideshow_image.recreate_versions!
        end
      end
    end
  end
end

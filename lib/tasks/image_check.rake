namespace :db do
  desc "Verify images are present"
  task :image_check => :environment do
    puts "Checking Blog Posts..."
    BlogPost.all.each do |post|
      if post.associated_image.file.nil? or !post.associated_image.file.exists?
        puts "Blog Post #{post.id} (#{post.title}) missing associated image #{post.associated_image_url}"        
      end
    end
    
    puts "Checking Curators..."
    Curator.all.each do |curator|
      if curator.picture.file.nil? or !curator.picture.file.exists?
        puts "Curator #{!curator.id} (#{!curator.name}) missing picture #{!curator.picture_url}"        
      end
    end
    
    puts "Checking Promotions..."
    Promotion.all.each do |promotion|
      if promotion.teaser_image.file.nil? or !promotion.teaser_image.file.exists?
        puts "Promotion #{promotion.id} (#{promotion.title}) missing teaser image #{promotion.teaser_image_url}"
      end
      if promotion.main_image.file.nil? or !promotion.main_image.file.exists?
        puts "Promotion #{promotion.id} (#{promotion.title}) missing main image #{promotion.main_image_url}"
      end
      promotion.promotion_images.each do |slideshow|
        if slideshow.slideshow_image.nil? or slideshow.slideshow_image.file.exists?
          puts "Promotion #{promotion.id} (#{promotion.title}) missing slideshow image #{slideshow.slideshow_image_url}"          
        end
      end
    end
  end
end

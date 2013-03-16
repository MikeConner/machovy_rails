namespace :db do
  desc "Verify images are present"
  task :fill_blog_images => :environment do
    BlogPost.all.each do |post|
      if !post.associated_image.present?
        puts "Updating #{post.id} #{post.title}"
        post.update_attributes!(:remote_associated_image_url => 'http://www.tastytreasures.ca/wp-content/uploads/2011/11/placeholder.jpg')
      end
    end
  end
end

class AddImageToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :associated_image, :string
  end
end

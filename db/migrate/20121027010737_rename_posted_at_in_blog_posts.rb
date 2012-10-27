class RenamePostedAtInBlogPosts < ActiveRecord::Migration
  def change
    rename_column :blog_posts, :posted_at, :activation_date
  end
end

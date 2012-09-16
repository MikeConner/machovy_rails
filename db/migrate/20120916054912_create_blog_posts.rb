class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.text :body
      t.integer :curator_id
      t.datetime :posted_at
      t.integer :weight
      t.integer :metro_id

      t.timestamps
    end
  end
end

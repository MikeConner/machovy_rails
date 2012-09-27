class BlogpostPromotion < ActiveRecord::Migration
  def up
    create_table :blog_posts_promotions, :id => false do |t|
      t.references :blog_post, :promotion
    end
  end

  def down
    drop_table :blog_posts_promotions
  end

end

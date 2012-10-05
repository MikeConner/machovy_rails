class ModelReview < ActiveRecord::Migration
  def up
    # Logging table
    create_table :activities do |t|
      t.integer :user_id
      t.string :activity_name, { :null => false, :limit => 32 }
      t.integer :activity_id, :null => false
      t.string :description
      
      t.timestamps
    end
    
    # Metro is redundant; comes through curator
    remove_column :blog_posts, :metro_id
    # Join table should not be nullable, and have unique index
    drop_table :blog_posts_promotions
    create_table :blog_posts_promotions, :id => false do |t|
      t.references :blog_post, :null => false
      t.references :promotion, :null => false
    end    
    add_index(:blog_posts_promotions, [:blog_post_id, :promotion_id], :unique => true)
    
    # rename status to be description
    rename_column :categories, :status, :active
    # name can't be null
    change_column :categories, :name, :string, :null => false
    # add unique index
    add_index :categories, :name, :unique => true
    # belongs_to itself for parent
    add_column :categories, :parent_category_id, :integer
    drop_table :categories_promotions
    create_table :categories_promotions, :id => false do |t|
      t.references :category, :null => false
      t.references :promotion, :null => false
    end    
    add_index(:categories_promotions, [:category_id, :promotion_id], :unique => true)
    
    # Remove user and metro associations; curator doesn't need to be tied to a user, just any ContentAdmin
    # metro/promotions through blog_posts
    remove_column :curators, :user_id
    remove_column :curators, :metro_id
    remove_column :promotions, :curator_id
    add_index :curators, :name, :unique => true
    add_index :curators, :twitter, :unique => true
    
    # Make name unique, non-null
    change_column :metros, :name, :string, :null => false
    add_index :metros, :name, :unique => true
    
    add_column :orders, :fine_print, :text
    
    add_index :roles, :name, :unique => true
    drop_table :roles_users
    create_table :roles_users, :id => false do |t|
      t.references :role, :null => false
      t.references :user, :null => false
    end    
    add_index(:roles_users, [:role_id, :user_id], :unique => true)
    
    # Getting rid of these; two images are enough
    drop_table :promotion_images
    drop_table :promotion_images_promotions
    
    # Add promotion status field (e.g., approved, rejected)
    add_column :promotions, :status, :string, { :limit => 32, :default => "Proposed" }
    rename_column :promotions, :start, :start_date
    rename_column :promotions, :end, :end_date
    
    rename_column :videos, :destination, :destination_url
    
   # remove redundant foreign keys
    remove_column :vouchers, :user_id
    remove_column :vouchers, :promotion_id
    change_column :vouchers, :status, :string, { :limit => 16, :default => "Available" }
    
    # vendors/users is now 1-to-1
    rename_column :vendors, :fbook, :facebook
    add_column :vendors, :user_id, :integer
    drop_table :users_vendors    
  end

  def down
    drop_table :activities

    add_column :blog_posts, :metro_id, :integer
    
    rename_column :categories, :active, :status
    remove_index :categories, :column => :name
    remove_column :categories, :parent_category_id
    
    add_column :curators, :user_id, :integer
    add_column :curators, :metro_id, :integer
    add_column :promotions, :curator_id, :integer
    remove_index :curators, :column => :name
    remove_index :curators, :column => :twitter
    
    remove_index :metros, :column => :name
    
    remove_column :orders, :fine_print
    
    remove_index :roles, :column => :name
    
    create_table :promotion_images do |t|
      t.string :name
      t.string :destination
      t.string :type

      t.timestamps
    end

    create_table 'promotion_images_promotions', :id => false do |t|
       t.references :promotion, :promotion_image
    end    
    
    remove_column :promotions, :status
    rename_column :promotions, :start_date, :start
    rename_column :promotions, :end_date, :end

    rename_column :videos, :destination_url, :destination
        
    add_column :vouchers, :user_id, :integer
    add_column :vouchers, :promotion_id, :integer
    change_column :vouchers, :status, :string

    rename_column :vendors, :facebook, :fbook
    remove_column :vendors, :user_id
    
    create_table :users_vendors, :id => false do |t|
      t.references :user, :vendor
    end
    
    remove_index :blog_posts_promotions, :column => [:blog_post_id, :promotion_id]
    remove_index :categories_promotions, :column => [:category_id, :promotion_id]
  end
end

class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references :user
      t.references :order
      t.integer :stars
      t.boolean :recommend
      t.text :comments
      
      t.timestamps
    end
    
    add_index :feedbacks, [:user_id, :order_id], :unique => true
  end
end

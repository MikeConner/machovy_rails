class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :stars
      t.text :comment
      t.references :idea
      t.references :user

      t.timestamps
    end
    
    # A user can only rate an idea once
    add_index :ratings, [:idea_id, :user_id], :unique => true
  end
end

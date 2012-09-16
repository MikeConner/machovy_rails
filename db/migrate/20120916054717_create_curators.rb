class CreateCurators < ActiveRecord::Migration
  def change
    create_table :curators do |t|
      t.string :name
      t.string :picture
      t.text :bio
      t.string :twitter
      t.integer :user_id
      t.integer :metro_id

      t.timestamps
    end
  end
end

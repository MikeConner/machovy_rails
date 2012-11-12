class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.string :name, :limit => Idea::MAX_NAME_LEN
      t.string :title, :limit => Idea::MAX_TITLE_LEN
      t.text :content
      t.references :user
      
      t.timestamps
    end
  end
end

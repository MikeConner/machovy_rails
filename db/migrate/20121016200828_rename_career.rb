class RenameCareer < ActiveRecord::Migration
  def up
    drop_table :careers
		
    drop_table :positions if table_exists?(:positions) 
    create_table :positions do |t|
      t.string :title
      t.text :description
      t.datetime :expiration
      t.string :email_contact
      t.string :email_subject

      t.timestamps
    end
  end

  def down
    drop_table :positions
    
    create_table :careers do |t|
      t.string :title
      t.text :description
      t.datetime :expiration
      t.string :email_contact
      t.string :email_subject

      t.timestamps
    end
  end
end

class CreateCareers < ActiveRecord::Migration
  def change
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

class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :name
      t.string :destination
      t.boolean :active

      t.timestamps
    end
  end
end

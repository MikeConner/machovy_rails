class AddCuratorToVideo < ActiveRecord::Migration
  def up
    add_column :videos, :title, :string, :limit => Video::MAX_TITLE_LEN
    add_column :videos, :curator_id, :integer
    add_column :videos, :caption, :text
    remove_column :videos, :active
    remove_column :videos, :name
  end
  
  def down
    remove_column :videos, :curator_id
    remove_column :title, :string
    remove_column :videos, :caption
    add_column :videos, :active, :boolean
    add_column :videos, :name, :string
  end
end

class AddFieldsToCurator < ActiveRecord::Migration
  def change
    add_column :curators, :slug, :string
    add_column :curators, :title, :string, :limit => Curator::MAX_TITLE_LEN
    
    add_index :curators, :slug
  end
end

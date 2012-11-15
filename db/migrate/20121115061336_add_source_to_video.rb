class AddSourceToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :source, :string, :limit => Video::MAX_SOURCE_LEN
  end
end

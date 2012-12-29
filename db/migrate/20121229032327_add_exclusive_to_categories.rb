class AddExclusiveToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :exclusive, :boolean, :default => false
  end
end

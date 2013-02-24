class AddWeightToCurators < ActiveRecord::Migration
  def change
    add_column :curators, :weight, :integer
  end
end

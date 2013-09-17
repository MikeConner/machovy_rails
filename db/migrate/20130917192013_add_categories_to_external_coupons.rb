class AddCategoriesToExternalCoupons < ActiveRecord::Migration
  def change
    create_table :categories_external_coupons, :id => false do |t|
      t.references :category, :external_coupon
    end
    
    add_index :categories_external_coupons, [:category_id, :external_coupon_id], :unique => true, :name => 'by_category_and_coupon'
  end
end

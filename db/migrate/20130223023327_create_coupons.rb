class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :title, :limit => Coupon::MAX_TITLE_LEN
      t.integer :value
      t.text :description
      t.string :slug
      t.string :coupon_image
      t.references :vendor
      
      t.timestamps
    end
  end
end

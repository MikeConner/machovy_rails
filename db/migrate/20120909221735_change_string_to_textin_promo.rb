class ChangeStringToTextinPromo < ActiveRecord::Migration
  def up
      change_column :promotions, :description, :text
      change_column :promotions, :limitations, :text
      change_column :promotions, :voucher_instructions, :text
      
  end

  def down
    change_column :promotions, :description, :string
    change_column :promotions, :limitations, :string
    change_column :promotions, :voucher_instructions, :string
    

  end
end

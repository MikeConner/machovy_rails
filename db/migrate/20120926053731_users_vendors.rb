class UsersVendors < ActiveRecord::Migration

def up
    create_table :users_vendors, :id => false do |t|
    t.references :user, :vendor
  end
end

def down
  drop_table :users_vendors
end

end

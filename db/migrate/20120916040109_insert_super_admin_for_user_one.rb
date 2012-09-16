class InsertSuperAdminForUserOne < ActiveRecord::Migration
  def up
      execute "insert into roles_users (user_id, role_id) values (1, 1)"
  end

  def down
  end
end

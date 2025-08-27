class ChangeIsAdminToUserType < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :is_admin
    add_column :users, :user_type, :integer, default: 0, null: false
  end
end

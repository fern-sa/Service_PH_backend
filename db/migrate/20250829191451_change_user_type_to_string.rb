class ChangeUserTypeToString < ActiveRecord::Migration[7.2]
  def up
    # Add new string column
    add_column :users, :user_type_string, :string, default: 'customer'
    
    # Convert existing data
    execute <<-SQL
      UPDATE users 
      SET user_type_string = CASE 
        WHEN user_type = 0 THEN 'customer'
        WHEN user_type = 1 THEN 'service_provider'  
        WHEN user_type = 2 THEN 'admin'
        ELSE 'customer'
      END
    SQL
    
    # Remove old column and rename new one
    remove_column :users, :user_type
    rename_column :users, :user_type_string, :user_type
    
    # Add index
    add_index :users, :user_type
  end
  
  def down
    # Add integer column back
    add_column :users, :user_type_int, :integer, default: 0
    
    # Convert back to integers
    execute <<-SQL
      UPDATE users 
      SET user_type_int = CASE 
        WHEN user_type = 'customer' THEN 0
        WHEN user_type = 'service_provider' THEN 1
        WHEN user_type = 'admin' THEN 2
        ELSE 0
      END
    SQL
    
    remove_column :users, :user_type
    rename_column :users, :user_type_int, :user_type
    add_index :users, :user_type
  end
end

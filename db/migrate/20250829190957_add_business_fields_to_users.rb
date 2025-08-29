class AddBusinessFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :city, :string
    add_column :users, :province, :string
    add_column :users, :service_radius_km, :integer, default: 20
    add_column :users, :verified, :boolean, default: false
    add_column :users, :active, :boolean, default: true
    
    # Add indexes for performance
    add_index :users, [:city, :province]
    add_index :users, :verified
    add_index :users, :active
  end
end

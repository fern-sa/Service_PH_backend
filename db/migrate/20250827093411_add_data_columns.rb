class AddDataColumns < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :location, :string
    add_column :users, :longitude, :decimal
    add_column :users, :latitude, :decimal
    add_column :users, :age, :integer
    add_column :users, :phone, :string
    add_index :users, :phone, unique: true
    add_column :users, :total_reviews, :integer, default: 0
    add_column :users, :rating, :decimal
    add_column :users, :bio, :text
  end
end

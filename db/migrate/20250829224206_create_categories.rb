class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :icon, default: "🔧"
      t.integer :sort_order, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :categories, :active
    add_index :categories, :sort_order
  end
end

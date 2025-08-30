class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.decimal :budget_min, precision: 10, scale: 2
      t.decimal :budget_max, precision: 10, scale: 2
      t.string :location, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :city
      t.string :province
      t.datetime :preferred_date
      t.string :status, default: 'open'
      t.integer :assigned_offer_id
      t.datetime :completed_at
      t.decimal :final_price, precision: 10, scale: 2

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, [:latitude, :longitude]
    add_index :tasks, :preferred_date
    add_index :tasks, :created_at
  end
end
